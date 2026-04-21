#' Default VARcheck ggplot2 theme
#'
#' A minimal theme used as the default style for all VARcheck plots.
#' Pass a `ggplot2::theme()` object to the `theme` argument of
#' [plot_var_check()] to override individual elements on top of this base.
#'
#' @return A `ggplot2` theme object.
#' @export
theme_varcheck <- function() {
  ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      legend.title = ggplot2::element_blank(),
      legend.spacing.y = ggplot2::unit(0.04, "cm"),
      legend.key.height = ggplot2::unit(0.4, "cm")
    )
}

.default_colors <- function() {
  list(empirical = "black", predicted = "darkorange2")
}
