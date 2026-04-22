# Relative sub-panel widths for each column type.
# "data", "residuals", "simulated" each occupy a main plot (4) + small
# histogram (1). "scatter" has no histogram so it takes only 4.
.panel_widths <- list(
  data = c(4, 1),
  residuals = c(4, 1),
  scatter = c(4),
  simulated = c(4, 1)
)

.col_labels <- list(
  data = "Empirical & Predicted",
  residuals = "Residuals",
  scatter = "Residuals vs. Predicted",
  simulated = "Simulated"
)

# A blank text label used for row/column annotations.
.label_plot <- function(label, angle = 0, size = 4) {
  ggplot2::ggplot() +
    ggplot2::annotate(
      "text",
      x = 0.5, y = 0.5,
      label = label,
      angle = angle,
      size = size
    ) +
    ggplot2::theme_void() +
    ggplot2::coord_cartesian(
      xlim = c(0, 1), ylim = c(0, 1),
      expand = FALSE
    )
}

.padded_range <- function(x, buffer = 0.05) {
  r <- range(x, na.rm = TRUE)
  span <- diff(r)
  r + c(-1, 1) * span * buffer
}

#' Plot VAR model diagnostics
#'
#' Creates a multi-panel diagnostic grid for a fitted VAR model.
#' Each row corresponds to one variable; columns show (a) empirical data
#' vs. predictions, (b) residuals over time, (c) residuals vs. predictions
#' scatter, and (d) data simulated from the estimated model. Each time-series
#' panel is accompanied by a marginal histogram with a Gaussian overlay.
#'
#' @param data A `var_data` object created with [new_var_data()].
#' @param subject Integer. Index of the subject to plot. Defaults to `1`.
#' @param vars Character or integer vector selecting variables to include.
#'   Defaults to all variables.
#' @param panels Character vector controlling which columns are shown. Any
#'   subset of `c("data", "residuals", "scatter", "simulated")`, in that
#'   order. Defaults to all four.
#' @param colors Named list controlling line colours. Recognised elements:
#'   `empirical` (default `"black"`) and `predicted` (default
#'   `"darkorange2"`). Partial lists are merged with the defaults.
#' @param theme A `ggplot2::theme()` object added on top of
#'   [theme_varcheck()]. Use this to override individual theme elements.
#' @param ylim_data Numeric vector of length 2. Shared y-limits for the
#'   data-scale panels (empirical/predicted/simulated). Auto-computed from
#'   the data if `NULL`.
#' @param ylim_res Numeric vector of length 2. Shared y-limits for the
#'   residual panels. Auto-computed from the residuals if `NULL`.
#'
#' @return A `patchwork` object.
#' @export
#'
#' @examples
#' set.seed(1)
#' emp <- matrix(rnorm(300), nrow = 100, ncol = 3)
#' pred <- emp + matrix(rnorm(300, sd = 0.3), 100, 3)
#' res <- emp - pred
#' sim <- matrix(rnorm(300), 100, 3)
#' vd <- new_var_data(emp, pred, res, sim, var_names = c("X1", "X2", "X3"))
#' \donttest{
#' plot_var_check(vd)
#' }
plot_var_check <- function(
    data,
    subject = 1,
    vars = NULL,
    panels = c("data", "residuals", "scatter", "simulated"),
    colors = list(),
    theme = NULL,
    ylim_data = NULL,
    ylim_res = NULL) {
  if (!inherits(data, "var_data")) {
    stop(
      "`data` must be a `var_data` object. See `new_var_data()`.",
      call. = FALSE
    )
  }
  if (!is.numeric(subject) || length(subject) != 1 ||
    subject < 1 || subject > data$n_subjects) {
    stop(
      "`subject` must be a single integer between 1 and ",
      data$n_subjects, ".",
      call. = FALSE
    )
  }

  valid_panels <- c("data", "residuals", "scatter", "simulated")
  panels <- match.arg(panels, valid_panels, several.ok = TRUE)

  if ("simulated" %in% panels && is.null(data$simulated)) {
    stop(
      '`panels` includes "simulated" but `data$simulated` is NULL.\n',
      'Either provide simulated data in `new_var_data()` or drop "simulated"',
      " from `panels`.",
      call. = FALSE
    )
  }

  # Resolve variable selection
  if (is.null(vars)) {
    var_idx <- seq_len(data$n_vars)
  } else if (is.character(vars)) {
    var_idx <- match(vars, data$var_names)
    missing_vars <- vars[is.na(var_idx)]
    if (length(missing_vars) > 0) {
      stop(
        "Unknown variable(s): ", paste(missing_vars, collapse = ", "),
        call. = FALSE
      )
    }
  } else {
    var_idx <- as.integer(vars)
  }
  var_labels <- data$var_names[var_idx]
  n_vars <- length(var_idx)

  # Extract subject data
  subj <- as.integer(subject)
  emp_mat <- data$empirical[[subj]][, var_idx, drop = FALSE]
  pred_mat <- data$predicted[[subj]][, var_idx, drop = FALSE]
  res_mat <- data$residuals[[subj]][, var_idx, drop = FALSE]
  sim_mat <- if (!is.null(data$simulated)) {
    data$simulated[[subj]][, var_idx, drop = FALSE]
  } else {
    NULL
  }

  # Inform once if NAs are present across any of the plotted matrices
  all_vals <- c(emp_mat, pred_mat, res_mat, sim_mat)
  n_na <- sum(is.na(all_vals))
  if (n_na > 0) {
    message(
      n_na, " NA value(s) detected across the plotted matrices. ",
      "Missing timepoints are excluded from all panels."
    )
  }

  # Merge colors with defaults
  colors <- utils::modifyList(.default_colors(), colors)

  # Build theme
  base_theme <- theme_varcheck()
  if (!is.null(theme)) base_theme <- base_theme + theme

  # Auto-compute shared y-limits across selected variables
  if (is.null(ylim_data)) {
    data_vals <- c(emp_mat, pred_mat)
    if (!is.null(sim_mat)) data_vals <- c(data_vals, sim_mat)
    ylim_data <- .padded_range(data_vals)
  }
  if (is.null(ylim_res)) {
    ylim_res <- .padded_range(res_mat)
  }

  # --- Build header row ---
  # The header row has one label per column group. Panels with a histogram
  # sub-panel (data, residuals, simulated) also get a trailing spacer so the
  # label spans only the main plot, not the histogram
  header_plots <- list(patchwork::plot_spacer()) # placeholder for row-label column
  for (p in panels) {
    header_plots <- c(header_plots, list(.label_plot(.col_labels[[p]])))
    if (p != "scatter") {
      # spacer occupies the histogram sub-panel position
      header_plots <- c(header_plots, list(patchwork::plot_spacer()))
    }
  }

  # Width vector: row label (0.6) + widths per selected panel
  row_label_width <- 0.6
  col_widths <- unlist(.panel_widths[panels])
  all_widths <- c(row_label_width, col_widths)

  assembled_header <- Reduce(`+`, header_plots) +
    patchwork::plot_layout(widths = all_widths)

  # --- Build data rows ---
  assembled_rows <- lapply(seq_len(n_vars), function(i) {
    panel_plots <- .plot_var_row(
      emp = emp_mat[, i],
      pred = pred_mat[, i],
      res = res_mat[, i],
      sim = if (!is.null(sim_mat)) sim_mat[, i] else NULL,
      panels = panels,
      colors = colors,
      base_theme = base_theme,
      ylim_data = ylim_data,
      ylim_res = ylim_res,
      show_legend = (i == 1)
    )
    row_label <- .label_plot(var_labels[i], angle = 90)
    all_plots <- c(list(row_label), unname(panel_plots))
    Reduce(`+`, all_plots) + patchwork::plot_layout(widths = all_widths)
  })

  # --- Stack header + data rows ---
  heights <- c(0.5, rep(4, n_vars))
  Reduce(`/`, c(list(assembled_header), assembled_rows)) +
    patchwork::plot_layout(heights = heights)
}
