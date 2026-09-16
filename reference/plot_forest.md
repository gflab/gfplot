# Forest plot of effect estimates

Draws point estimates with confidence intervals on a horizontal axis,
with the numbers printed alongside. This is the standard display for
hazard ratios, odds ratios, and mean differences, and it reads a table
straight from `clinstats::cox_table()` or `clinstats::logistic_table()`.

## Usage

``` r
plot_forest(
  data,
  term,
  estimate,
  lower,
  upper,
  p = NULL,
  group = NULL,
  label = NULL,
  log_scale = FALSE,
  ref_line = NULL,
  estimate_label = "Estimate (95% CI)",
  p_label = "P",
  show_table = TRUE,
  digits = 2,
  xlab = NULL,
  title = NULL,
  font = "Arial"
)
```

## Arguments

- data:

  Data frame holding the estimates.

- term:

  Column of row labels, one per estimate.

- estimate:

  Column of point estimates.

- lower, upper:

  Columns of the confidence limits.

- p:

  Optional column of p-values, shown as a right-hand column.

- group:

  Optional column naming the section each estimate belongs to. Sections
  are drawn as facets with a shared axis.

- label:

  Optional column overriding `term` for display, for example a formatted
  "Age, per year" instead of a variable name.

- log_scale:

  Plot the axis on a log scale, which is what ratios need so that a
  halving and a doubling are the same distance.

- ref_line:

  Value of the reference line. Defaults to 1 when `log_scale = TRUE` and
  0 otherwise.

- estimate_label:

  Column heading for the estimate table.

- p_label:

  Column heading for the p-value column.

- show_table:

  Print the estimate and p-value columns.

- digits:

  Significant digits for the printed numbers.

- xlab, title:

  Axis and plot labels.

- font:

  Font family used in the plot.

## Value

A `ggplot` object, or a composed panel when `show_table = TRUE`, as with
the risk table of
[`plot_KMCurve()`](https://gflab.github.io/gfplot/reference/plot_KMCurve.md).
Both print and save the same way.

## See also

[`gfplot_spec()`](https://gflab.github.io/gfplot/reference/gfplot_spec.md)
to build the same figure as a value. The companion package `clinstats`
produces the estimates this draws.

## Examples

``` r
effects <- data.frame(
  term = c("Age, per year", "Stage III vs II", "MSI-high"),
  hr = c(1.02, 1.84, 0.62),
  lower = c(0.99, 1.51, 0.44),
  upper = c(1.05, 2.24, 0.88),
  p = c(0.21, 4.1e-07, 0.008)
)
p <- plot_forest(
  effects,
  term = "term", estimate = "hr", lower = "lower", upper = "upper",
  p = "p", log_scale = TRUE
)

# Straight from a clinstats table
# \donttest{
if (requireNamespace("clinstats", quietly = TRUE)) {
  tbl <- clinstats::cox_table(
    clinstats::clin_crc,
    time = "rfs.delay", event = "rfs.event",
    factors = c("sex", "age", "tnm.stage"), multivariable = "none"
  )
  p <- plot_forest(
    tbl,
    term = "term", estimate = "hr_univariable",
    lower = "univ_ci_lower", upper = "univ_ci_upper", p = "univ_p",
    log_scale = TRUE
  )
}
# }
```
