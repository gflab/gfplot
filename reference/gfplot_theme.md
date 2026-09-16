# House theme for publication figures

The theme every `gfplot` figure is drawn with: bold axis titles, a thin
major grid, a panel border, and a horizontal legend under the panel.
Sizes derive from `base_size`, so one number rescales the figure.

## Usage

``` r
gfplot_theme(
  base_size = 11,
  font = "Arial",
  grid = TRUE,
  border = TRUE,
  legend = c("bottom", "right", "top", "left", "none"),
  margin = c(9, 10, 8, 10)
)
```

## Arguments

- base_size:

  Base font size in points. Other sizes are derived from it.

- font:

  Font family. Defaults to Arial.

- grid:

  Draw the major grid.

- border:

  Draw the panel border.

- legend:

  Legend position, one of `"bottom"`, `"right"`, `"top"`, `"left"`, or
  `"none"`.

- margin:

  Plot margin in points, in the order top, right, bottom, left.

## Value

A `ggplot2` theme object.

## Details

This theme is also the session baseline: attaching `gfplot` sets it as
the global `ggplot2` theme so that figures drawn by other packages
match. Set `options(gfplot.set_theme = FALSE)` before
[`library(gfplot)`](https://github.com/gflab/gfplot) to keep an existing
theme instead.

## See also

[`gfplot_colors()`](https://gflab.github.io/gfplot/reference/gfplot_colors.md)
for the colours that go with it.

## Examples

``` r
library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  gfplot_theme()
```
