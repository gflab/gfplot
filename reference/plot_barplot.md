# Grouped bar plot with optional significance annotations

Draws the mean of `value` per group with standard error bars, and adds
pairwise significance labels when `comparisons` is supplied.

## Usage

``` r
plot_barplot(
  value,
  group,
  comparisons = NULL,
  palette = "jama_classic",
  color = NULL,
  ylab = "Score",
  xlab = NULL,
  title = NULL,
  font = "Arial",
  label = "p.signif"
)
```

## Arguments

- value:

  Numeric values to summarise.

- group:

  Grouping vector, one value per observation.

- comparisons:

  Optional list of length-two vectors naming the groups to compare, for
  example `list(c("A", "B"))`.

- palette:

  Palette name passed to
  [`get_color()`](https://gaofeng21cn.github.io/gfplot/reference/get_color.md).

- color:

  Optional vector of fill colours; overrides `palette`.

- ylab, xlab, title:

  Axis and plot labels.

- font:

  Font family used in the plot.

- label:

  Significance label style passed to
  [`ggpubr::stat_compare_means()`](https://rpkgs.datanovia.com/ggpubr/reference/stat_compare_means.html).

## Value

A `ggplot` object.

## Details

This function replaced the 0.1.0 `plot_barplot()`, which took no
arguments and could not be called.

## Examples

``` r
set.seed(1)
p <- plot_barplot(
  value = c(rnorm(20), rnorm(20, 1)),
  group = rep(c("A", "B"), each = 20)
)
```
