import os
import argparse
import torch
import torchani
import pandas as pd
import glob 
#导入对应的包，其中compute.py 中的包是自己写的，证明有效
def get_atom_type(atom_string):
    """按照元素周期表来转换原子，注意特殊的Cl识别，Cel5A没有Cl"""
    atom_type = atom_string
    if atom_type[:1] == "Cl":  # Special handling for Cl
        return "Cl"
    else:
        return atom_type[0]  # For other elements, return the first character
        
def calculate_energy(species, coordinates):
    """ 计算体系的能量 """
    model = torchani.models.ANI2x(periodic_table_index=True)
    energy = model((species, coordinates)).energies
    return energy.item()# 

def parse_ligand_pdb(file_path, ligand_ids):

    """ 解析PDB文件，仅提取配体的三维坐标 """
    coordinates = []
    species = []# 定义 TorchANI 计算的输入
    seen_coords = set()
    atom_type_to_index = {'H': 1, 'C': 6, 'N': 7, 'O': 8, 'F': 9, 'S': 16,'Cl':17}#对应的元素与其原子序数的映射
    with open(file_path, 'r',encoding='utf-8') as file:
        for line in file:
            if line.startswith('HETATM') or line.startswith('ATOM'):# 考虑这两个开头的行，ANISOU不是原子坐标，不考虑
                parts = line.split()#分离需要的行
                if parts[3] in ligand_ids:  # 配体ID  parts[3]是配体或者氨基酸的号所在的位置
                    atom_type = get_atom_type(parts[2])#part[2]是元素的符号 有，一般第一个原子时元素
                    x, y, z = float(parts[5]), float(parts[6]), float(parts[7])#提取空间坐标
                    #for i in range(3,8):print(parts[i])
                    coord_tuple = (x, y, z)
                    # 判断当前坐标是否已经存在
                    if coord_tuple in seen_coords:
                        continue  # 如果重复则跳过 
                    seen_coords.add(coord_tuple)
                    coordinates.append([x, y, z]) #导入coordinates
                    species.extend(atom_type_to_index.get(atom) for atom in atom_type) #映射转换后导入species
    return torch.tensor([coordinates], requires_grad=True), torch.LongTensor([species])

def parse_mutation_pdb(file_path, mutation_position):
    """ 解析PDB文件，提取突变氨基酸的三维坐标 """
    coordinates = []
    species = []# 定义 TorchANI 计算的输入
    seen_coords = set()
    atom_type_to_index = {'H': 1, 'C': 6, 'N': 7, 'O': 8, 'F': 9, 'S': 16, 'Cl':17}#对应的元素与其原子序数的映射
    with open(file_path, 'r',encoding='utf-8') as file:
        for line in file:
            if line.startswith('ATOM') or line.startswith('HETATM'): 
                parts = line.split()
                if parts[4] == mutation_position:
                    atom_type = get_atom_type(parts[2])
                    if atom_type in atom_type_to_index:
                        x, y, z = float(parts[5]), float(parts[6]), float(parts[7])
                        #for i in range(4,8):print(parts[i])
                        coord_tuple = (x, y, z)
                        # 判断当前坐标是否已经存在
                        if coord_tuple in seen_coords:
                            continue  # 如果重复则跳过 
                        seen_coords.add(coord_tuple)
                        coordinates.append([x, y, z])
                        species.extend(atom_type_to_index.get(atom) for atom in atom_type)#这段也可以写成函数封装
    #print(species)
    
    return torch.tensor([coordinates], requires_grad=True), torch.LongTensor([species])

def process_folder(folder, ligand_ids, combined_positions):
    records = []
    # 修改这一行：匹配所有包含 ".pdb" 的文件，不论后缀
    pdb_pattern = os.path.join(folder, '*.pdb*')
    pdb_paths = sorted(glob.glob(pdb_pattern))
    for pdb_path in pdb_paths:
        pdb = os.path.basename(pdb_path)
        # 之后的逻辑无需改动
        # 1) 只配体
        lig_coords, lig_species = parse_ligand_pdb(pdb_path, ligand_ids)
        E_lig = calculate_energy(lig_species, lig_coords)
        print(E_lig)
        # 2) 只残基
        res_coords = None; res_species = None
        for pos in combined_positions:
            coords_i, species_i = parse_mutation_pdb(pdb_path, str(pos))
            if res_coords is None:
                res_coords, res_species = coords_i, species_i
            else:
                res_coords   = torch.cat([res_coords,   coords_i],   dim=1)
                res_species  = torch.cat([res_species, species_i], dim=1)
        print( pdb_path, "正在运行中，目前进行到环节——E_res能量计算中")
        E_res = calculate_energy(res_species, res_coords)
        print("E_res能量为：",E_res)
        # 3) 配体 + 残基
        comb_coords  = torch.cat([lig_coords,  res_coords],  dim=1)
        comb_species = torch.cat([lig_species, res_species], dim=1)
        print(pdb_path,"正在运行中，目前进行到环节——E_comb能量计算中")
        E_comb = calculate_energy(comb_species, comb_coords)
        print("E_comb能量为：",E_comb)
        # 4) 相互作用能
        E_int = E_comb - E_lig - E_res
        print(pdb_path,"的E_int能量为：",E_int)
        records.append({
            'pdb': pdb,
            'ligand_energy':   E_lig,
            'residue_energy':  E_res,
            'combined_energy': E_comb,
            'interaction':     E_int
        })
        print(records)
        print(f"[{folder}] {pdb} → ΔE = {E_int:.4f}")
        
    return pd.DataFrame(records)


def main():
    parser = argparse.ArgumentParser(
        description="批量计算配体与指定残基的相互作用能"
    )
    parser.add_argument(
        '--combined_positions',
        nargs='+', type=int,
        default=[104,105,187,224,189,190,140,141,144,149,278,281,282,285],
        help="与配体合并计算的残基编号列表，默认“104 105 187 ... 285”"
    )
    parser.add_argument(
        '--ligand_ids',
        nargs='+', default=['LIG'],
        help="配体残基名列表，默认 ['LIG']"
    )
    args = parser.parse_args()

    # 遍历当前目录下所有以 pdb 开头的文件夹
    for name in sorted(os.listdir('.')):
        if os.path.isdir(name) and name.lower().startswith('pdb'):
            print(f"—— 处理文件夹：{name} ——")
            df = process_folder(name, args.ligand_ids, args.combined_positions)
            # 输出 Excel
            out_xlsx = f"{name}.xlsx"
            df.to_excel(out_xlsx, index=False, sheet_name=name)
            print(f"  已保存 → {out_xlsx}\n")

if __name__ == '__main__':
    main()