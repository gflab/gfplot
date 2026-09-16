# Grouped embedding scatter

Plot samples in a two-dimensional embedding, coloured by group. The
embedding can be supplied already computed, or computed here from a
feature matrix with
[`stats::prcomp()`](https://rdrr.io/r/stats/prcomp.html), Rtsne, or
umap.

## Usage

``` r
plot_embedding(
  data,
  groups,
  method = c("pca", "tsne", "umap", "none"),
  perplexity = 30,
  seed = NULL,
  ellipse = FALSE,
  label_centres = FALSE,
  palette = "house",
  title = NULL,
  xlab = NULL,
  ylab = NULL,
  font = "Arial"
)
```

## Arguments

- data:

  A feature matrix with samples in rows, or a two-column matrix of
  coordinates when `method = "none"`.

- groups:

  Group labels, one per sample.

- method:

  Embedding to compute: `"pca"`, `"tsne"`, `"umap"`, or `"none"` when
  `data` already holds coordinates.

- perplexity:

  Perplexity for t-SNE. Values much larger than the number of samples
  are rejected by the back end.

- seed:

  Optional seed for the stochastic embeddings.

- ellipse:

  Draw a confidence ellipse per group.

- label_centres:

  Label each group at the centre of its points.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- title, xlab, ylab:

  Axis and plot labels.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## Details

[`plot_PCA()`](https://gflab.github.io/gfplot/reference/plot_PCA.md) and
[`plot_UMAP()`](https://gflab.github.io/gfplot/reference/plot_UMAP.md)
are thin wrappers around this function, so a figure keeps the same look
whichever embedding it shows.

## See also

[`plot_PCA()`](https://gflab.github.io/gfplot/reference/plot_PCA.md),
[`plot_UMAP()`](https://gflab.github.io/gfplot/reference/plot_UMAP.md)

## Examples

``` r
set.seed(1)
data <- matrix(rnorm(200), nrow = 20)
groups <- rep(c("A", "B"), each = 10)
p <- plot_embedding(data, groups, method = "pca")
```
