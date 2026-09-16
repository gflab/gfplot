# Colour palettes used by the plotting functions

Returns a vector of journal-style colours. When `palette` is a vector of
length greater than one it is returned unchanged, so the argument can
also be used to pass colours through from a caller.

## Usage

``` r
get_color(palette, n = 6)
```

## Arguments

- palette:

  Palette name: `"nature"`, `"jco"`, `"lancet"`, `"jama"`,
  `"jama_classic"`, `"house"` for the lab series ramp described in
  [`gfplot_colors()`](https://gflab.github.io/gfplot/reference/gfplot_colors.md),
  or any other value, which selects the ColorBrewer `"Set1"` palette.

- n:

  Number of colours to return.

## Value

A character vector of colours.

## Examples

``` r
get_color("jama", 3)
#> [1] "#374E55FF" "#DF8F44FF" "#00A1D5FF"
get_color("house", 4)
#> [1] "#0B4F6C" "#2A9D8F" "#B84A3A" "#D99A2B"
get_color(c("#111111", "#222222"))
#> [1] "#111111" "#222222"
```
