getwd()
library(readxl)
library(ggplot2)
library(dplyr)
color_map <- c(
  "pdb1" = "#E64B35",  # Red
  "pdb2" = "#4DBBD5",  # Cyan
  "pdb3" = "#00A087"   # Green
)
# 函数：读取单个文件并打上 source 标签，同时单位从 Hartree → kcal/mol
read_and_tag <- function(file, tag) {
  df <- read_excel(file)
  df$conformation_number <- as.numeric(gsub(".*\\.pdb\\.", "", df$pdb))  # 提取数字编号
  df$interaction <- df$interaction * 627.509  # Hartree → kcal/mol
  
  df <- df[order(df$conformation_number), ]  # 按编号从小到大排序
  df <- head(df, 500)  # 只保留前 500 帧
  
  df$source <- tag
  df %>% select(conformation_number, interaction, source)
}
# 获取当前目录下的所有子文件夹
subdirs <- list.dirs(path = ".", recursive = FALSE, full.names = TRUE)

# 遍历每个突变体文件夹
for (folder in subdirs) {
  # 构建每个 Excel 文件的完整路径
  pdb1_file <- file.path(folder, "pdb1.xlsx")
  pdb2_file <- file.path(folder, "pdb2.xlsx")
  pdb3_file <- file.path(folder, "pdb3.xlsx")
  
  if (file.exists(pdb1_file) && file.exists(pdb2_file) && file.exists(pdb3_file)) {
    message("📂 正在处理：", folder)
    
    df1 <- read_and_tag(pdb1_file, "pdb1")
    df2 <- read_and_tag(pdb2_file, "pdb2")
    df3 <- read_and_tag(pdb3_file, "pdb3")
    all_df <- bind_rows(df1, df2, df3)
    
    title_name <- basename(folder)
    plot_title <- paste("Interaction Energy of", title_name,"Predicted by TorchANI")
    
    p <- ggplot(all_df, aes(x = conformation_number, y = interaction, color = source)) +
      geom_line(linewidth = 0.5) +
      scale_color_manual(values = color_map)  +
      labs(
        title = plot_title,
        x = "Conformation Number",
        y = "Interaction Energy (kcal/mol)",
        color = " "
      ) +
      scale_y_continuous(
        limits = c(-35, 0),
        breaks = seq(-35, 0, by= 10),
        expand = expansion(mult = c(0.001, 0.001))
      ) +
      scale_x_continuous(
        expand = expansion(mult = c(0.001, 0.001))
      )+
      theme_classic() +
      theme(
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
        panel.background = element_blank(),
        axis.title.y = element_text(size = 13),
        plot.title = element_text(size = 15, hjust = 0.5, face = "bold"),
        # axis.text.x = element_text(size = 7, color = "black"),
        # axis.text.y = element_text(size = 10, color = "black"),
        legend.position = "none"
      )
    
    out_path <- file.path(folder, paste0(title_name, "_interaction.png"))
    ggsave(out_path, plot = p, width = 8, height = 5, dpi = 300)
    message("✅ 保存图片：", out_path)
  } else {
    warning("⚠️ 缺少文件，跳过目录：", folder)
  }
}

library(gridExtra)
library(cowplot)

# 存储每个突变体的图
combined_plot_list <- list()

# 遍历目录重新绘图收集到列表中（避免保存图再读取）
for (folder in subdirs) {
  pdb1_file <- file.path(folder, "pdb1.xlsx")
  pdb2_file <- file.path(folder, "pdb2.xlsx")
  pdb3_file <- file.path(folder, "pdb3.xlsx")
  if (file.exists(pdb1_file) && file.exists(pdb2_file) && file.exists(pdb3_file)) {
    df1 <- read_and_tag(pdb1_file, "pdb1")
    df2 <- read_and_tag(pdb2_file, "pdb2")
    df3 <- read_and_tag(pdb3_file, "pdb3")
    all_df <- bind_rows(df1, df2, df3)
    
    plot_title <- basename(folder)
    p <- ggplot(all_df, aes(x = conformation_number, y = interaction, color = source)) +
      geom_line(linewidth = 0.4) +
      scale_color_manual(values = color_map) +
      labs(
        title = plot_title,
        x = "Conformation Number", y = "Interaction Energy (kcal/mol)"
      ) +
      scale_y_continuous(
        limits = c(-35, 0),
        breaks = seq(-35, 0, by= 10),
        expand = expansion(mult = c(0.001, 0.001))
      ) +
      scale_x_continuous(
        expand = expansion(mult = c(0.001, 0.001))
      )+
      theme_classic() +
      theme(
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
        panel.background = element_blank(),
        axis.title.y = element_text(size = 7),
        plot.title = element_text(size = 13, hjust = 0.5, face = "bold"),
        axis.text.x = element_text(size = 7, color = "black"),
        #axis.text.y = element_text(size = 10, color = "black"),
        legend.position = "none"
      )
    
    combined_plot_list[[plot_title]] <- p
  }
}
# 自定义顺序：QW1 ~ QW12, WT
ordered_names <- c(paste0("QW", 1:12), "WT")
ordered_plot_list 
# 按照有序名称提取图，跳过缺失的--重画要运行
ordered_plot_list <- combined_plot_list[ordered_names[ordered_names %in% names(combined_plot_list)]]
library(gridExtra)
ordered_plot_list
library(cowplot)
# 拼接为多面板
final_combined <- plot_grid(plotlist = ordered_plot_list, ncol = 3)
final_combinedtwo <- plot_grid(plotlist = ordered_plot_list, ncol = 2)
final_combined
final_combinedtwo
# 拼接为多面板
final_combined <- plot_grid(plotlist = combined_plot_list, ncol = 3)
ordered_plot_list
# 保存拼接图
ggsave("一列Interaction_Panel_Interactionenergy调整表格.pdf", plot = final_combinedtwo, width = 15, height = 10)
ggsave("一列Interaction_Panel_Interactionenergy调整表格.svg", plot = final_combinedtwo, width = 15, height = 10)
ggsave("All_Folders_Interaction_Panel_Interactionenergy调整表格.pdf", plot = final_combined, width = 15, height = 10)
ggsave("All_Folders_Interaction_PanelInteractioinenrg.png", plot = final_combined, width = 15, height = 10, dpi = 300)

message("✅ 所有图已拼接保存为：All_Folders_Interaction_Panel.pdf/png")
p
final_combined
