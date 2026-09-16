# Plot ROC curves for one or more markers

Plots receiver operating characteristic curves with the area under the
curve and its confidence interval in the legend.

## Usage

``` r
plot_ROC(
  scores,
  labels,
  force05 = FALSE,
  palette = "house",
  legend.pos = "bottom",
  title = NULL,
  font = "Arial",
  percent.style = FALSE
)
```

## Arguments

- scores:

  Numeric vector, or a matrix or data frame with one column per marker.

- labels:

  Binary outcome, one value per observation.

- force05:

  Flip markers whose area under the curve is below 0.5 so that every
  curve is plotted above the diagonal.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- legend.pos:

  Legend position: a position such as `"bottom"`, or an x/y coordinate
  pair in panel units for a legend inside the panel.

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
set.seed(1)
scores <- cbind(marker1 = rnorm(80), marker2 = rnorm(80))
labels <- rep(c(0, 1), each = 40)
p <- plot_ROC(scores, labels)
```
