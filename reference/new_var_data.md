# Create a VAR data object

Constructs a \`var_data\` object used as input to \[plot_var_check()\].
Each component is either a single \`T x p\` numeric matrix (single
subject) or a list of \`T_i x p\` matrices (multiple subjects). Single
matrices are coerced to a length-1 list automatically.

## Usage

``` r
new_var_data(
  empirical,
  predicted,
  residuals,
  simulated = NULL,
  var_names = NULL
)

# S3 method for class 'var_data'
print(x, ...)
```

## Arguments

- empirical:

  Numeric matrix or list of matrices. Observed values.

- predicted:

  Numeric matrix or list of matrices. Model predictions.

- residuals:

  Numeric matrix or list of matrices. Residuals (\`empirical -
  predicted\`).

- simulated:

  Optional numeric matrix or list of matrices. Data simulated from the
  fitted model. Required only when plotting the \`"simulated"\` panel.

- var_names:

  Optional character vector of length \`p\` with variable names used as
  plot labels. Defaults to \`"V1"\`, \`"V2"\`, etc.

- x:

  A \`var_data\` object.

- ...:

  Not used; present for S3 method compatibility.

## Value

An object of class \`var_data\`.

## Examples

``` r
set.seed(1)
emp <- matrix(rnorm(75), nrow = 100, ncol = 2)
#> Warning: data length [75] is not a sub-multiple or multiple of the number of rows [100]
pred <- emp + matrix(rnorm(75, sd = 0.3), 100, 2)
#> Warning: data length [75] is not a sub-multiple or multiple of the number of rows [100]
res <- emp - pred
sim <- matrix(rnorm(75), 100, 2)
#> Warning: data length [75] is not a sub-multiple or multiple of the number of rows [100]
vd <- new_var_data(emp, pred, res, sim, var_names = c("Mood", "Energy"))
```
