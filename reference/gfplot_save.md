# Save a figure using a device that can render the requested font

Writing an R figure with Arial is device dependent: the base
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html) device needs the family
registered with it, while the ragg raster devices and the macOS `quartz`
device resolve system fonts directly. This function chooses a route that
can render `font` for the requested file extension, so a figure is
written with the intended typeface instead of silently falling back to a
default.

## Usage

``` r
gfplot_save(
  plot,
  filename,
  width = 7,
  height = 5,
  dpi = 300,
  font = "Arial",
  ...
)
```

## Arguments

- plot:

  A `ggplot` object, or any object with a
  [`print()`](https://rdrr.io/r/base/print.html) method that draws it.

- filename:

  Output path. The extension selects the device: `.png`, `.tiff`,
  `.jpg`, `.jpeg`, or `.pdf`.

- width, height:

  Size in inches.

- dpi:

  Resolution for raster output.

- font:

  Font family passed to the device unchanged.

- ...:

  Passed on to the device function.

## Value

`filename`, invisibly.

## See also

[`gfplot_font_setup()`](https://gflab.github.io/gfplot/reference/gfplot_font_setup.md)
to see which devices can render a font.

## Examples

``` r
p <- plot_Boxplot(c(rnorm(20), rnorm(20, 1)), rep(c("A", "B"), each = 20))
path <- tempfile(fileext = ".png")
gfplot_save(p, path, width = 4, height = 3)
unlink(path)
```
