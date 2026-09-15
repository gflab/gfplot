# Plot time-dependent ROC curves

Plots survival ROC curves at one or more time points using the
Kaplan-Meier method of the `survivalROC` package.

## Usage

``` r
plot_TimeROC(
  scores,
  survival,
  time_points,
  groups,
  palette = "jama",
  legend.pos = c(0.4, 0.15),
  title = NULL,
  font = "Arial",
  percent.style = FALSE
)
```

## Arguments

- scores:

  Numeric marker values.

- survival:

  A two-column survival object.

- time_points:

  Time points at which the curves are evaluated.

- groups:

  Labels for the curves, one per time point.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- legend.pos:

  Legend position as an x/y coordinate pair.

- title:

  Plot title.

- font:

  Font family used in the plot.

- percent.style:

  Label the axes as percentages.

## Value

A `ggplot` object.

## Examples

``` r
# \donttest{
if (requireNamespace("survivalROC", quietly = TRUE)) {
  set.seed(1)
  surv <- survival::Surv(rexp(100), rbinom(100, 1, 0.6))
  p <- plot_TimeROC(rnorm(100), surv, c(1, 2), c("year1", "year2"))
}
# }
```
