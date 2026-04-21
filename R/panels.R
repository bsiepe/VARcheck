# Internal panel builders. Each returns a single ggplot object.
# Panels are assembled into rows by .plot_var_row() and the full grid
# by plot_var_check().

.panel_data_line <- function(df, colors, base_theme, ylim, show_legend) {
  r2 <- 1 - stats::var(df$res, na.rm = TRUE) / stats::var(df$emp, na.rm = TRUE)
  rmse <- sqrt(mean(df$res^2, na.rm = TRUE))
  label <- paste0(
    "R\u00b2 = ", round(r2, 2),
    "\nRMSE = ", round(rmse, 2)
  )

  ggplot2::ggplot(df, ggplot2::aes(time, emp)) +
    ggplot2::geom_line(
      ggplot2::aes(color = "Empirical"),
      linewidth = 0.35
    ) +
    ggplot2::geom_line(
      ggplot2::aes(y = pred, color = "Predictions"),
      linewidth = 0.35
    ) +
    ggplot2::annotate(
      "text",
      x = Inf, y = -Inf,
      hjust = 1.1, vjust = -0.3,
      label = label,
      size = 2.5
    ) +
    ggplot2::coord_cartesian(ylim = ylim) +
    ggplot2::scale_color_manual(
      values = c(
        "Empirical" = colors$empirical,
        "Predictions" = colors$predicted
      )
    ) +
    ggplot2::labs(x = "Time") +
    base_theme +
    ggplot2::theme(
      axis.title.x = ggplot2::element_text(),
      legend.position = if (show_legend) c(0.3, 0.9) else "none"
    )
}

# Shared histogram panel: flipped, bins = 20, Gaussian overlay.
# Used for data, residuals, and simulated columns.
.panel_hist <- function(values, base_theme, xlim) {
  mu <- mean(values, na.rm = TRUE)
  s <- stats::sd(values, na.rm = TRUE)
  df_h <- data.frame(x = values)

  ggplot2::ggplot(df_h, ggplot2::aes(x)) +
    ggplot2::geom_histogram(
      ggplot2::aes(y = ggplot2::after_stat(density)),
      bins = 20,
      fill = "grey50"
    ) +
    ggplot2::coord_flip(xlim = xlim) +
    ggplot2::stat_function(
      fun = stats::dnorm,
      args = list(mean = mu, sd = s),
      linewidth = 1
    ) +
    base_theme +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
}

.panel_residuals_line <- function(df, base_theme, ylim) {
  n <- nrow(df)
  # AR(1) coefficient as a proxy for residual autocorrelation
  lm_ar <- stats::lm(df$res[-1] ~ df$res[-n])
  ar1 <- round(stats::coef(lm_ar)[2], 2)
  ci <- round(stats::confint(lm_ar, level = 0.95)[2, ], 2)
  ar_label <- paste0("AR(1) = ", ar1, " [", ci[1], ", ", ci[2], "]")

  ggplot2::ggplot(df, ggplot2::aes(time, res)) +
    ggplot2::geom_line(linewidth = 0.35) +
    ggplot2::coord_cartesian(ylim = ylim) +
    ggplot2::annotate(
      "text",
      x = -Inf, y = -Inf,
      hjust = -0.1, vjust = -0.5,
      label = ar_label,
      size = 2.5
    ) +
    ggplot2::labs(x = "Time") +
    base_theme +
    ggplot2::theme(axis.title.x = ggplot2::element_text())
}

.panel_scatter <- function(df, base_theme, xlim, ylim) {
  ggplot2::ggplot(df, ggplot2::aes(x = res, y = pred)) +
    ggplot2::geom_point(alpha = 0.4, size = 0.8) +
    ggplot2::coord_cartesian(xlim = xlim, ylim = ylim) +
    ggplot2::labs(x = "Residuals", y = "Predictions") +
    base_theme +
    ggplot2::theme(
      axis.title.x = ggplot2::element_text(),
      axis.title.y = ggplot2::element_text()
    )
}

.panel_sim_line <- function(df, base_theme, ylim) {
  ggplot2::ggplot(df, ggplot2::aes(time, sim)) +
    ggplot2::geom_line(linewidth = 0.35) +
    ggplot2::coord_cartesian(ylim = ylim) +
    ggplot2::labs(x = "Time") +
    base_theme +
    ggplot2::theme(axis.title.x = ggplot2::element_text())
}
