# Compare distributions across groups

Violin plots with the individual observations overlaid, which shows both
the shape of each distribution and how much data stands behind it. A
boxplot alone hides a bimodal group and a group with four samples.

## Usage

``` r
plot_violin(
  value,
  group,
  order = NULL,
  show = c("violin", "box", "both"),
  points = TRUE,
  points_maximum = 300,
  show_n = TRUE,
  significance = FALSE,
  palette = "house",
  ylab = NULL,
  xlab = NULL,
  title = NULL,
  font = "Arial"
)
```

## Arguments

- value:

  Numeric values.

- group:

  Grouping vector, one value per observation.

- order:

  Group order. Defaults to the order of the levels, or of first
  appearance for a plain vector.

- show:

  Which to draw: `"violin"`, `"box"`, or `"both"`.

- points:

  Draw the individual observations.

- points_maximum:

  Draw the observations only when there are at most this many, since a
  violin over thousands of points is unreadable. Use `Inf` to always
  draw them.

- show_n:

  Print the number of observations under each group.

- significance:

  Add pairwise Wilcoxon comparisons. `TRUE` compares every pair; a list
  such as `list(c("A", "B"))` compares those pairs only.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- ylab, xlab, title:

  Axis and plot labels.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## See also

[`plot_Boxplot()`](https://gflab.github.io/gfplot/reference/plot_Boxplot.md)
for the box-only version.

## Examples

``` r
set.seed(1)
p <- plot_violin(c(rnorm(40), rnorm(40, 1)), rep(c("A", "B"), each = 40))
```
