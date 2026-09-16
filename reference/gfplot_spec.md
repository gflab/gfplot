# Build a figure specification

Captures the data and the settings for one figure as a value, validates
them, and returns an object that
[`gfplot_render()`](https://gflab.github.io/gfplot/reference/gfplot_render.md)
turns into a `ggplot`. Use this when the figure is decided in one place
and drawn in another, or when a specification needs to be stored,
compared, or passed across a process boundary.

## Usage

``` r
gfplot_spec(family, ...)
```

## Arguments

- family:

  Figure family, for example `"forest"`.

- ...:

  Family-specific arguments. For `"forest"`: `data`, `term`, `estimate`,
  `lower`, and `upper`, plus the optional settings documented in
  [`plot_forest()`](https://gflab.github.io/gfplot/reference/plot_forest.md).

## Value

An object of class `gfplot_spec`.

## Details

Call
[`gfplot_families()`](https://gflab.github.io/gfplot/reference/gfplot_families.md)
for the available families and their required arguments.

## See also

[`gfplot_render()`](https://gflab.github.io/gfplot/reference/gfplot_render.md),
[`plot_forest()`](https://gflab.github.io/gfplot/reference/plot_forest.md)

## Examples

``` r
effects <- data.frame(
  term = c("Age", "Stage III"),
  hr = c(1.02, 1.84),
  lower = c(0.99, 1.51),
  upper = c(1.05, 2.24)
)
spec <- gfplot_spec(
  "forest",
  data = effects, term = "term",
  estimate = "hr", lower = "lower", upper = "upper"
)
spec
#> <gfplot_spec>
#> • family: "forest" (Forest plot)
#> • arguments: "data", "term", "estimate", "lower", and "upper"
```
