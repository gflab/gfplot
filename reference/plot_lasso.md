# Plot lasso coefficient paths

Draws the coefficient paths of a fitted `glmnet` model against the log
lambda sequence and labels the coefficients that remain non-zero at the
selected value of `s`.

## Usage

``` r
plot_lasso(fit, s, font = "Arial")
```

## Arguments

- fit:

  A fitted model from `glmnet::glmnet()`.

- s:

  Selected value of the penalty parameter.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## Examples

``` r
# \donttest{
if (requireNamespace("glmnet", quietly = TRUE)) {
  set.seed(1)
  x <- matrix(rnorm(100 * 5), nrow = 100)
  y <- rnorm(100) + x[, 1]
  p <- plot_lasso(glmnet::glmnet(x, y), s = 0.05)
}
# }
```
