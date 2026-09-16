# Draw a figure from a specification

Draw a figure from a specification

## Usage

``` r
gfplot_render(spec)
```

## Arguments

- spec:

  A specification from
  [`gfplot_spec()`](https://gflab.github.io/gfplot/reference/gfplot_spec.md).

## Value

A `ggplot` object, ready to print or pass to
[`gfplot_save()`](https://gflab.github.io/gfplot/reference/gfplot_save.md).

## See also

[`gfplot_spec()`](https://gflab.github.io/gfplot/reference/gfplot_spec.md)

## Examples

``` r
effects <- data.frame(
  term = c("Age", "Stage III"),
  hr = c(1.02, 1.84),
  lower = c(0.99, 1.51),
  upper = c(1.05, 2.24)
)
p <- gfplot_render(gfplot_spec(
  "forest",
  data = effects, term = "term",
  estimate = "hr", lower = "lower", upper = "upper"
))
#> The base `pdf()` device cannot render "Arial", so it may substitute a fallback
#> font in vector PDF output.
#> ℹ Use `gfplot_save(plot, "figure.pdf")` to write through a device that can
#>   render it.
#> ℹ Or run `gfplot_font_setup()` to register the font with the device.
```
