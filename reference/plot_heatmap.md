# Heatmap of a matrix

Draws the values of a matrix as tiles with a colourbar. This is the
display for correlation matrices, signature scores by group, and any
rectangular table of values where the pattern matters more than the
numbers.

## Usage

``` r
plot_heatmap(
  matrix,
  row_order = NULL,
  column_order = NULL,
  values = FALSE,
  digits = 2,
  midpoint = NULL,
  diverging = FALSE,
  low = NULL,
  mid = NULL,
  high = NULL,
  legend_label = "Value",
  title = NULL,
  font = "Arial"
)
```

## Arguments

- matrix:

  Numeric matrix, or a data frame whose columns are numeric.

- row_order, column_order:

  Optional ordering of rows and columns. Use `"cluster"` to order by
  hierarchical clustering, `"value"` to order by the first principal
  component, or supply a character vector of names.

- values:

  Print the numeric value in each tile.

- digits:

  Significant digits for the printed values.

- midpoint:

  Value mapped to the middle of the colourbar. Defaults to the median,
  which centres a diverging scale on a typical value.

- diverging:

  Use a diverging scale, for values that have a meaningful centre such
  as a correlation.

- low, mid, high:

  Colours for the low, middle, and high ends.

- legend_label:

  Title of the colourbar.

- title:

  Plot title.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## Examples

``` r
set.seed(1)
m <- cor(matrix(rnorm(60), nrow = 20))
diag(m) <- NA
p <- plot_heatmap(m, diverging = TRUE, midpoint = 0,
                  legend_label = "Correlation")
```
