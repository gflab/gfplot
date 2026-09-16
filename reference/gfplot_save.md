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
  width = NULL,
  height = NULL,
  dpi = 300,
  size = NULL,
  font = "Arial",
  provenance = FALSE,
  call = NULL,
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

  Size in inches. Default to 7 by 5, or to the `size` preset when one is
  given.

- dpi:

  Resolution for raster output.

- size:

  Journal size preset, used when `width` and `height` are not given:
  `"single"` for one column, `"onehalf"` for 1.5 columns, `"double"` for
  the full text width, or `"slide"` for a 16:9 presentation. The journal
  widths follow the common 85 mm, 114 mm, and 170 mm conventions.
  Supplying `width` or `height` overrides the preset for that dimension.

- font:

  Font family passed to the device unchanged.

- provenance:

  Write a `.json` file next to the figure recording what produced it:
  the figure family or call, the package and R versions, the output size
  and device, and the SHA-256 of the written file. This is what makes a
  figure in a manuscript traceable to the code that drew it.

- call:

  The call to record in the provenance file. Defaults to the function as
  it was invoked.

- ...:

  Passed on to the device function.

## Value

`filename`, invisibly. The path of the provenance file is attached as
the `"provenance"` attribute when one is written.

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
