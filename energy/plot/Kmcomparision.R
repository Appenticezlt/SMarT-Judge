# ==== 1. 加载包 ====
library(readxl)
library(tidyverse)
library(patchwork)

# ==== 2. 读取并整理数据 ====
df_raw <- read_excel("kcal_per_mutant_summary - 副本.xlsx")
df_raw <- read_excel("kcal_per_mutant_summary.xlsx", .name_repair = "unique")
# 转置并重命名列
df <- as.data.frame(t(df_raw[-1]))
colnames(df) <- df_raw[[1]]
df$Protein <- colnames(df_raw)[-1]

# 保证 Protein 顺序
ordered_proteins <- c("WT", paste0("QW", 1:12))
df <- df %>%
  filter(Protein %in% ordered_proteins) %>%
  mutate(Protein = factor(Protein, levels = ordered_proteins))

# ==== 3. 提取所需数值 ====
df_energy <- df %>%
  transmute(
    Protein,
    pdb1 = as.numeric(`pdb1 kcal/mol`),
    pdb2 = as.numeric(`pdb2 kcal/mol`),
    pdb3 = as.numeric(`pdb3 kcal/mol`)
  ) %>%
  rowwise() %>%
  mutate(
    mean_energy = mean(c(pdb1, pdb2, pdb3), na.rm = TRUE),
    sd_energy = sd(c(pdb1, pdb2, pdb3), na.rm = TRUE)
  ) %>%
  ungroup()
# 提取所需km数值
df_km <- df %>%
  select(Protein, Km = `Km`) %>%
  mutate(Km = as.numeric(Km))
# 提取所需kcat数值
df_kcatkm  <- df %>%
  select(Protein, kcatkm =`kcat/km` ) %>%
  mutate(Km = as.numeric(kcatkm))

# ==== 4. 颜色设置（SCI红蓝） ===="#046B38""#CCEA9C
red_color <- "#C01A34"
blue_color <- "#02A6DD"
green_color <- "#58B668"
# ==== 5. 上图 Kcatkm 柱状图 ====
bar_kcatkm<- ggplot(df_kcatkm, aes(x = Protein, y = kcatkm)) +
  geom_bar(stat = "identity", fill = green_color, width = 0.6) +
  labs(y =  expression(k[cat]~"/" ~K[m] ~ (s^-1 ~ mM^-1)),x = NULL) +
  theme_classic() +
  theme(
    panel.grid.major.y = element_blank(),  # 去除主要横向网格线
    panel.grid.minor.y = element_blank(),  # 去除次要横向网格线
    panel.grid.major.x = element_blank(),  # 如不想保留纵向线也可以去除
    panel.grid.minor.x = element_blank(),
    # panel.border = element_rect(color = "black", fill = NA, linewidth  = 1.2),
    panel.background = element_blank(),
    axis.text.y = element_text(size = 10, color = "black"),
    axis.title.x = element_blank(),
    axis.text.x = element_text(size = 10, color = "black"),
    axis.title.y = element_text(size = 1, color = "black"),
    panel.grid = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
    axis.ticks = element_line(color = "black", linewidth = 0.5),
    axis.ticks.length = unit(0.2, "cm"),  # 设置短横线的长度
    axis.line = element_line(color = "black", linewidth = 0.8),  # 只画坐标轴线
  )+
  scale_y_continuous(
    limits = c(0,6000 ),
    breaks = seq(0, 6000, 1000),  # 主刻度
    minor_breaks = seq(0, 6000, 500),  # ⬅️ 添加次刻度
    expand = expansion(mult = c(0.01, 0.01))
  )
bar_kcatkm
# 一个尝试性的添加细节坐标轴的尝试
bar_kcatkm <- ggplot(df_kcatkm, aes(x = Protein, y = kcatkm)) +
  geom_bar(stat = "identity", fill = red_color, width = 0.6) +
  labs(y = expression(k[cat]~"/" ~K[m] ~ (s^-1 ~ mM^-1)), x = NULL) +
  theme_classic() +
  theme(
    panel.grid.major.y = element_blank(),  # 去除主要横向网格线
    panel.grid.minor.y = element_blank(),  # 添加次刻度线
    panel.grid.major.x = element_blank(),  # 如不想保留纵向线也可以去除
    panel.grid.minor.x = element_blank(),
    panel.background = element_blank(),
    axis.text.y = element_text(size = 10, color = "black"),
    axis.title.x = element_blank(),
    axis.text.x = element_text(size = 10, color = "black"),
    axis.title.y = element_text(size = 10, color = "black"),
    panel.grid = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
    axis.ticks = element_line(color = "black", linewidth = 0.5),  # 保留刻度线
    axis.ticks.length = unit(0.1, "cm"),  # 设置刻度线长度（短横线）
    axis.line = element_line(color = "black", linewidth = 0.8)  # 保留坐标轴线
  ) +
  scale_y_continuous(
    limits = c(0, 6000),
    breaks = seq(0, 6000, 1000),  # 主刻度
    minor_breaks = seq(0, 6000, 500)  # 次刻度
  ) +
  geom_segment(
    aes(x = -0.15, xend = -0.05, y = seq(0, 6000, 500), yend = seq(0, 6000, 500)),
    color = "black", linewidth = 0.5
  )

bar_kcatkm
# ==== 5. 上图 Km 柱状图 ====
bar_km<- ggplot(df_km, aes(x = Protein, y = Km)) +
  geom_bar(stat = "identity", fill = red_color, width = 0.6) +
  labs(y =  expression(K[m] ~ "(mM)"), x = NULL) +
  theme(
    panel.grid.major.y = element_blank(),  # 去除主要横向网格线
    panel.grid.minor.y = element_blank(),  # 添加次刻度线
    panel.grid.major.x = element_blank(),  # 如不想保留纵向线也可以去除
    panel.grid.minor.x = element_blank(),
    panel.background = element_blank(),
    axis.text.y = element_text(size = 10, color = "black"),
    axis.title.x = element_blank(),
    axis.text.x = element_text(size = 10, color = "black"),
    axis.title.y = element_text(size = 10, color = "black"),
    panel.grid = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
    axis.ticks = element_line(color = "black", linewidth = 0.5),  # 保留刻度线
    axis.ticks.length = unit(0.1, "cm"),  # 设置刻度线长度（短横线）
    axis.line = element_line(color = "black", linewidth = 0.8)  # 保留坐标轴线
  ) +
scale_y_continuous(
  expand = expansion(mult = c(0.01, 0.01)
  ))
bar_km

# ==== 6. 下图 Energy 柱状图 ====
bar_energy<- ggplot(df_energy, aes(x = Protein, y = mean_energy)) +
  geom_bar(stat = "identity", fill = blue_color, width = 0.6) +
  geom_errorbar(aes(ymin = mean_energy - sd_energy, ymax = mean_energy + sd_energy),
                width = 0.2, color = "black") +
  labs(y = expression("Average Interaction Energy (kcal/mol)"), x = "CALB WT and Mutants") +
  theme(
    panel.grid.major.y = element_blank(),  # 去除主要横向网格线
    panel.grid.minor.y = element_blank(),  # 添加次刻度线
    panel.grid.major.x = element_blank(),  # 如不想保留纵向线也可以去除
    panel.grid.minor.x = element_blank(),
    panel.background = element_blank(),
    axis.text.y = element_text(size = 10, color = "black"),
    axis.title.x = element_blank(),
    axis.text.x = element_text(size = 10, color = "black"),
    axis.title.y = element_text(size = 10, color = "black"),
    panel.grid = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
    axis.ticks = element_line(color = "black", linewidth = 0.5),  # 保留刻度线
    axis.ticks.length = unit(0.1, "cm"),  # 设置刻度线长度（短横线）
    axis.line = element_line(color = "black", linewidth = 0.8)  # 保留坐标轴线
  ) +
  scale_y_continuous(
    limits = c(-20, 0),
    breaks = seq(-20, 0, 5),  # 主刻度
    minor_breaks = seq(-20, 0, 5) , # 次刻度
    expand = expansion(mult = c(0.01, 0.01))
  ) 
p2 
bar_energy

# 修改 bar_energy 图：隐藏 x 刻度，添加 x 轴总标题
bar_energy_mod <- bar_energy +
  labs(x = "CALB WT and Mutants") +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_text(size = 15, color = "black")
  )

# 合并图形（1列2行）kcat/km energy
combined_plot <- bar_kcatkm / bar_energy +
  plot_layout(heights = c(1, 1)) + 
   plot_annotation(title = expression("TorchANI Energy Prediction and " ~k[cat]~"/" ~K[m] ~ (s^-1 ~ mM^-1)~"Comparision"))&
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    legend.position = "none",
    axis.title.y = element_text(size = 15, color = "black"),
  )
combined_plot
# 合并图形（1列2行） km energy
combined_plot5 <- bar_km / bar_energy +
  plot_layout(heights = c(1, 1)) + 
  plot_annotation(title = expression("TorchANI Energy Prediction and " ~K[m] ~ (mM)~"Comparision"))&
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    legend.position = "none",
    axis.title.y = element_text(size = 15, color = "black"),
  )
combined_plot5

# ==== 7. 合并上下图并保存 ====
combined_plot <- p1 / p2 + plot_layout(heights = c(1, 1.2))
combined_plot
ggsave("Kcat_Energy_combined_kcalgreen.pdf", combined_plot, width = 10, height = 8)
ggsave("Kcat_Energy_combined_kcalgreen.svg", combined_plot, width = 10, height = 8)
ggsave("Kcat_Energy_combinedgreen.png", combined_plot, width = 10, height = 8,dpi=300)
ggsave("Km_Energy_combined_kcal5.pdf", combined_plot5, width = 10, height = 8)
ggsave("Km_Energy_combined_kcal5.svg", combined_plot5, width = 10, height = 8)
ggsave("Km_Energy_combined5.png", combined_plot5, width = 10, height = 8,dpi=300)

message("✅ 图片已保存为 PDF 和 SVG：Km_Energy_combined.*")
