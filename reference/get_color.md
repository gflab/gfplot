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
  `"jama_classic"`, or any other value, which selects the ColorBrewer
  `"Set1"` palette.

- n:

  Number of colours to return.

## Value

A character vector of colours.

## Examples

``` r
get_color("jama", 3)
#> [1] "#374E55FF" "#DF8F44FF" "#00A1D5FF"
get_color(c("#111111", "#222222"))
#> [1] "#111111" "#222222"
```
