# t-SNE projection of samples coloured by group

t-SNE projection of samples coloured by group

## Usage

``` r
plot_tsne(
  data,
  labs,
  title = "Evaluate the batch effect between groups",
  perplexity = 30,
  seed = 1,
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

- perplexity:

  Perplexity for the t-SNE embedding.

- seed:

  Optional seed; t-SNE is stochastic, so a seed makes a figure
  reproducible.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- font:

  Font family used in the plot.

- ...:

  Passed to
  [`plot_embedding()`](https://gflab.github.io/gfplot/reference/plot_embedding.md),
  for example `ellipse`, `seed`, or `label_centres`.

## Value

A `ggplot` object.

## Examples

``` r
# \donttest{
if (requireNamespace("Rtsne", quietly = TRUE)) {
  set.seed(1)
  p <- plot_tsne(matrix(rnorm(200), nrow = 20), rep(c("A", "B"), each = 10))
}
# }
```
