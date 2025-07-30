#!/bin/bash

# 遍历当前目录下的每一个文件夹
for dir in */; do
    # 去掉路径末尾的斜杠
    dir=${dir%/}
    
    # 创建以文件夹名称命名的新文件夹
    mkdir -p "$dir/$dir"
    
    # 查找并复制 .pdb 文件
    find "$dir" -maxdepth 1 -type f -name "*.pdb" -exec cp {} "$dir/$dir" \;
    
    # 查找并复制名字中带有 solvated 的 .prmtop 文件
    find "$dir" -maxdepth 1 -type f -name "*solvated*.prmtop" -exec cp {} "$dir/$dir" \;
    
    # 查找并复制 equil.rst 文件
    find "$dir" -maxdepth 1 -type f -name "equil.rst" -exec cp {} "$dir/$dir" \;
done
