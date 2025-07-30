final_combined
combined_plot
ordered_plot_list
final_combined_2 <- plot_grid(plotlist = ordered_plot_list, ncol = 4)
final_combined_2
library(patchwork)  # ✅ 关键包
plots_all <- c(ordered_plot_list, list(combined_plot))
# 设计布局：6行3列
layout_area <- c(
  # 前13个图，按顺序从第1行到第5行第1列，填满前13格
  area(t=1, l=1, b=1, r=1),  area(t=1, l=2, b=1, r=2),  area(t=1, l=3, b=1, r=3),
  area(t=2, l=1, b=2, r=1),  area(t=2, l=2, b=2, r=2),  area(t=2, l=3, b=2, r=3),
  area(t=3, l=1, b=3, r=1),  area(t=3, l=2, b=3, r=2),  area(t=3, l=3, b=3, r=3),
  area(t=4, l=1, b=4, r=1),  area(t=4, l=2, b=4, r=2),  area(t=4, l=3, b=4, r=3),
  area(t=5, l=1, b=5, r=1),
  
  # 第14张图跨第5、6行，第2、3列
  area(t=5, l=2, b=6, r=3)
)

final_plot <- wrap_plots(plots_all, design = layout_area)

print(final_plot)
ggsave("combined_energy_kcal.pdf", final_plot, width=15, height=20)
ggsave("combined_energy_kcal.png", final_plot, width=15, height=20,dpi=300)
ggsave("combined_energy_5x3_kcal.svg", final_plot, width=15, height=20)
