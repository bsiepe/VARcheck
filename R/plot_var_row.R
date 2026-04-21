# Builds the list of panel plots for a single variable.
# Returns a named list of ggplot objects in the order they appear left-to-right.
.plot_var_row <- function(
    emp, pred, res, sim,
    panels, colors, base_theme,
    ylim_data, ylim_res,
    show_legend) {
  n <- length(emp)
  df <- data.frame(time = seq_len(n), emp = emp, pred = pred, res = res)
  if (!is.null(sim)) df$sim <- sim

  out <- list()

  if ("data" %in% panels) {
    out$data_line <- .panel_data_line(df, colors, base_theme, ylim_data, show_legend)
    out$data_hist <- .panel_hist(emp, base_theme, ylim_data)
  }

  if ("residuals" %in% panels) {
    out$res_line <- .panel_residuals_line(df, base_theme, ylim_res)
    out$res_hist <- .panel_hist(res, base_theme, ylim_res)
  }

  if ("scatter" %in% panels) {
    out$scatter <- .panel_scatter(df, base_theme, xlim = ylim_res, ylim = ylim_data)
  }

  if ("simulated" %in% panels) {
    out$sim_line <- .panel_sim_line(df, base_theme, ylim_data)
    out$sim_hist <- .panel_hist(sim, base_theme, ylim_data)
  }

  out
}
