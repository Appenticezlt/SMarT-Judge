getwd()
# plot_violin_distance.R
#这个脚本直接运行可以得到一张小提琴图 
library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)

# 1. 读取数据（替换为你的实际 CSV 文件名）
distance_data <- read_csv("Distance_All_Summary100--150ns.csv")

# 2. 保留需要列并转换为长格式
ordered_proteins <- c( "WT",paste0("QW", 1:12))

distance_long <- distance_data %>%
  select(Time, all_of(ordered_proteins)) %>%
  pivot_longer(
    cols = -Time,
    names_to = "Protein",
    values_to = "Distance"
  ) %>%
  filter(is.finite(Distance), Protein %in% ordered_proteins) %>%
  mutate(Protein = factor(Protein, levels = ordered_proteins))

# 3. SCI 色卡
sci_colors <- c(
  "QW1"="#E64B35", "QW2"="#4DBBD5", "QW3"="#00A087", "QW4"="#3C5488",
  "QW5"="#F39B7F", "QW6"="#8491B4", "QW7"="#91D1C2", "QW8"="#DC0000",
  "QW9"="#7E6148", "QW10"="#B09C85", "QW11"="#F0E442", "QW12"="#0072B2",
  "WT"="#D55E00"
)

# 4. 绘图（小提琴图 + 箱线图 + 中位数点 + 均值点）
p <- ggplot(distance_long, aes(x = Protein, y = Distance, fill = Protein)) +
  geom_violin(trim = FALSE, scale = "width", color = NA, alpha = 0.8) +
  geom_boxplot(width = 0.2, outlier.shape = NA, fill = "white", color = "black", linewidth = 0.5) +
  stat_summary(fun = median, geom = "crossbar", width = 0.2, color = "black", linewidth = 0.2) +
  stat_summary(fun = mean, geom = "point", shape = 21, size = 1, fill = "black", color = "black") +
  scale_fill_manual(values = sci_colors) +
  labs(
    title = "Distance Distribution between Attacking and Attacked Atoms (100--150ns)",
    x = "CALC WT and Mutants",
    y = "Distance (Å)"
  ) +
  theme_minimal() +
  theme(
      panel.grid.major.y = element_blank(),  # 去除主要横向网格线
      panel.grid.minor.y = element_blank(),  # 去除次要横向网格线
      panel.grid.major.x = element_blank(),  # 如不想保留纵向线也可以去除
      panel.grid.minor.x = element_blank(),
      panel.border = element_rect(color = "black", fill = NA, linewidth  = 1.2),
      panel.background = element_blank(),
    plot.title = element_text(size = 15, hjust = 0.5, face = "bold"),
    axis.title = element_text(size = 13),
    axis.text.x = element_text(size =10, color = "black"),
    legend.position = "none"
  )+
  scale_y_continuous(
    limits = c(2, 15),
    breaks = seq(2, 14, by = 2)
  ) 
p
violin_grob
gt
# 5. 保存图像
ggsave("distance_violin_plot_100-150ns带标题.png", plot = p, width = 10, height = 6)
ggsave("distance_violin_plot_100-150ns带标题.pdf", plot = p, width = 10, height = 6)
ggsave("distance_violin_plot_100-150ns带标题.svg", plot = p, width = 10, height = 6)

message("✅ 图像已保存为 PNG 和 SVG：distance_violin_plot")
