# Boxplot with optional pairwise significance annotations

Boxplot with optional pairwise significance annotations

## Usage

``` r
plot_Boxplot(
  value,
  label,
  palette = "house",
  title = NULL,
  ylab = "Expression",
  font = "Arial"
)
```

## Arguments

- value:

  Numeric values.

- label:

  Grouping vector.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- title:

  Plot title.

- ylab:

  Y-axis label.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## Examples

``` r
set.seed(1)
p <- plot_Boxplot(c(rnorm(20), rnorm(20, 1)), rep(c("A", "B"), each = 20))
```
