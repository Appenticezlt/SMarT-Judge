# 加载所需库
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(cowplot)
library(svglite)  # 用于保存 SVG

# 读取数据
df <- read_csv("Distance_All_Summary.csv")

# 筛选 200ns 范围内数据
df_filtered <- df %>% filter(Time <= 200)
df_filtered <- df %>% filter(Time <= 150)

# 转为长格式
df_long <- df_filtered %>%
  pivot_longer(cols = -c(Time, Frame), names_to = "Protein", values_to = "Distance")

# 指定 SCI 配色
sci_colors <- c(
  "QW1" = "#E64B35", "QW2" = "#4DBBD5", "QW3" = "#00A087",
  "QW4" = "#3C5488", "QW5" = "#F39B7F", "QW6" = "#8491B4",
  "QW7" = "#91D1C2", "QW8" = "#DC0000", "QW9" = "#7E6148",
  "QW10" = "#B09C85", "QW11" = "#F0E442", "QW12" = "#0072B2",
  "WT" = "#D55E00"
)

# 设置蛋白顺序
ordered_proteins <- c(paste0("QW", 1:12), "WT")
df_long$Protein <- factor(df_long$Protein, levels = ordered_proteins)

# 绘图并保存单张图
plot_list <- list()

for (prot in ordered_proteins) {
  df_sub <- df_long %>% filter(Protein == prot)
  
  p <- ggplot(df_sub, aes(x = Time, y = Distance)) +
    geom_line(color = sci_colors[[prot]], linewidth = 0.8) +
    labs(
      title = paste(prot),
      x = "Time (ns)",
      y = "Distance (Å)"
    ) +
    coord_cartesian(ylim = c(0,15))+
    theme_minimal() +
    theme(
      panel.grid.major.y = element_blank(),  # 去除主要横向网格线
      panel.grid.minor.y = element_blank(),  # 去除次要横向网格线
      panel.grid.major.x = element_blank(),  # 如不想保留纵向线也可以去除
      panel.grid.minor.x = element_blank(),
      panel.background = element_blank(),
      plot.title = element_text(hjust = 0.5, size = 14),
      axis.title = element_text(size = 12),
      axis.ticks = element_line(color = "black", linewidth = 0.5), # 设置短横线
      axis.ticks.length = unit(0.2, "cm"), # 设置短横线的长度
      axis.line = element_line(color = "black", linewidth = 0.8),
      panel.border = element_rect(color = "black", fill = NA, linewidth  = 1.2)
    )+
    scale_y_continuous(
      limits = c(0, 15),
      breaks = seq(0, 15, by = 3),
      expand = expansion(mult = c(0.001, 0.001))
    ) +
    scale_x_continuous(
      expand = expansion(mult = c(0.001, 0.001))
    )
  
  plot_list[[prot]] <- p
}

# 合并图：每行3个子图
combined_plot <- plot_grid(plotlist = plot_list, ncol = 3)
combined_plottwo <- plot_grid(plotlist = plot_list, ncol = 2)
# 保存合图（PNG + PDF + SVG）
# ggsave("Distance_QW_WT_all.png", combined_plot, width = 18, height = 16, dpi = 300)
ggsave("Distance_QW_WT_all150ns统一坐标更two新.pdf", combined_plot, width = 18, height = 16)
ggsave("Distance_QW_WT_all150ns格式调整.svg", combined_plot, width = 18, height = 16)
ggsave("Distance_QW_WT_all150ns统一坐标更twos新每行二图.pdf", combined_plottwo, width = 18, height = 16)
ggsave("Distance_QW_WT_all150ns格式调整每行二图.svg", combined_plottwo, width = 18, height = 16)

message("✅ 所有图（PNG+PDF+SVG）已成功保存！")
