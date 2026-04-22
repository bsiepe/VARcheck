# Changelog

## VARcheck 0.1.0

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
