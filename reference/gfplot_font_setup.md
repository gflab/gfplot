# Check which devices can render the figure font

Figures produced by `gfplot` use Arial. The raster devices supplied by
ragg and the `quartz` device on macOS resolve system fonts such as Arial
directly, so most output needs no preparation at all. The base
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html) device keeps its own
font table and needs the family registered with it, which extrafont
does.

## Usage

``` r
gfplot_font_setup(font = "Arial", quiet = FALSE)
```

## Arguments

- font:

  Font family to check.

- quiet:

  Suppress the report.

## Value

A named logical vector, invisibly, with one entry per device route:
`raster` (ragg PNG/TIFF/JPEG), `quartz` (macOS PDF and screen), and
`pdf` (base [`pdf()`](https://rdrr.io/r/grDevices/pdf.html)). These are
the routes
[`gfplot_save()`](https://gflab.github.io/gfplot/reference/gfplot_save.md)
chooses between.

## Details

This function reports which routes work in the current session and, when
vector PDF output would otherwise be unavailable, registers the font
with extrafont so that [`pdf()`](https://rdrr.io/r/grDevices/pdf.html)
can use it.

## See also

[`gfplot_save()`](https://gflab.github.io/gfplot/reference/gfplot_save.md)
to write a figure using a device that can render the font, and
[`plot_KMCurve()`](https://gflab.github.io/gfplot/reference/plot_KMCurve.md)
for the `font` argument.

## Examples

``` r
gfplot_font_setup()
#> Figure font "Arial" can be rendered by:
#> • ragg raster devices (PNG, TIFF, JPEG): no
#> • quartz (macOS PDF and screen): no
#> • base pdf(): no
#> ℹ gfplot_save() picks a route that can render the font.
```
