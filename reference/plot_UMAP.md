# UMAP projection plot

UMAP projection plot

## Usage

``` r
plot_UMAP(
  data,
  labs,
  title = "Evaluate the batch effect between groups",
  palette = "house",
  font = "Arial",
  ...
)
```

## Arguments

- data:

  Matrix or data frame with samples in rows and features in columns.

- labs:

  Group labels, one per sample.

- title:

  Plot title.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- font:

  Font family used in the plot.

- ...:

  Passed to
  [`plot_embedding()`](https://gflab.github.io/gfplot/reference/plot_embedding.md).

## Value

A `ggplot` object.

## Examples

``` r
# \donttest{
if (requireNamespace("umap", quietly = TRUE)) {
  set.seed(1)
  p <- plot_UMAP(matrix(rnorm(200), nrow = 20), rep(c("A", "B"), each = 10))
}
# }
```
