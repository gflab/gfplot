# Prepare the Arial font family for figure output

Figures produced by `gfplot` use Arial. On macOS the `quartz` device
resolves Arial directly. PDF and PostScript output need the font to be
registered with the device, which `extrafont` does; this function runs
the registration and reports whether Arial is then available.

## Usage

``` r
gfplot_font_setup(quiet = FALSE)
```

## Arguments

- quiet:

  Suppress progress output.

## Value

`TRUE` when Arial is registered for the current device, `FALSE`
otherwise, invisibly.

## Details

Run `extrafont::font_import()` once, before the first call to this
function, to add system fonts to the `extrafont` database.

## See also

[`plot_KMCurve()`](https://gaofeng21cn.github.io/gfplot/reference/plot_KMCurve.md)
for the `font` argument.

## Examples

``` r
if (FALSE) { # \dontrun{
extrafont::font_import()
gfplot_font_setup()
} # }
```
