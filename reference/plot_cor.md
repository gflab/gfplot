# Plot the correlation between two variables

Plot the correlation between two variables

## Usage

``` r
plot_cor(x, y, groups = NULL, xlab = NULL, ylab = NULL, legend.pos = "top")
```

## Arguments

- x, y:

  Numeric vectors.

- groups:

  Optional grouping vector used to colour the points.

- xlab, ylab:

  Axis labels.

- legend.pos:

  Legend position.

## Value

A `ggplot` object.

## Examples

``` r
p <- plot_cor(iris$Sepal.Length, iris$Sepal.Width)
```
