# Changelog

## VARcheck 0.1.1

- Fixed axis orientation in the scatter panel: predictions are now on
  the x-axis and residuals on the y-axis, consistent with the other
  panels and the conventional residuals-vs-predictions plot.
- Added [`set.seed()`](https://rdrr.io/r/base/Random.html) to the
  example-analyses vignette for reproducibility.
- [`plot_var_check()`](https://bsiepe.github.io/VARcheck/reference/plot_var_check.md)
  gains a `title` argument for adding an overall plot title, useful when
  calling the function in a loop over subjects.

## VARcheck 0.1.0

CRAN release: 2026-05-19

- Initial CRAN release.
- [`new_var_data()`](https://bsiepe.github.io/VARcheck/reference/new_var_data.md):
  constructs a model-agnostic `var_data` object from empirical data,
  predictions, residuals, and optional simulated data. Accepts a single
  matrix (single subject) or a list of matrices (multiple subjects).
- [`plot_var_check()`](https://bsiepe.github.io/VARcheck/reference/plot_var_check.md):
  assembles a multi-panel diagnostic grid — one row per variable — with
  empirical vs. predicted time series, residual inspection, a residuals
  vs. predictions scatter, and optional posterior predictive check
  panels.
- [`theme_varcheck()`](https://bsiepe.github.io/VARcheck/reference/theme_varcheck.md):
  default minimal ggplot2 theme used by
  [`plot_var_check()`](https://bsiepe.github.io/VARcheck/reference/plot_var_check.md),
  available for standalone use.
