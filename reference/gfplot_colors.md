# House colours by semantic role

Returns the colours `gfplot` uses, addressed by role rather than by hex
value. Override any role for a session with
`options(gfplot.palette = list(primary = "#123456"))`, which is how the
suite is retuned without editing figures.

## Usage

``` r
gfplot_colors(role = "all")
```

## Arguments

- role:

  Colour roles to return. Use `"all"` for every role, or `"series"` for
  the ordered ramp that multi-series figures walk. Aliases such as
  `"model_curve"`, `"comparator_curve"`, and `"reference_line"` map onto
  the same roles.

## Value

A named character vector of colours.

## See also

[`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md)
for journal palettes and
[`gfplot_theme()`](https://gflab.github.io/gfplot/reference/gfplot_theme.md)
for the type and grid settings that go with these colours.

## Examples

``` r
gfplot_colors("primary")
#>   primary 
#> "#0B4F6C" 
gfplot_colors(c("model_curve", "comparator_curve"))
#>      model_curve comparator_curve 
#>        "#0B4F6C"        "#2A9D8F" 
gfplot_colors("series")
#>     primary   secondary    tertiary  quaternary      violet neutral_mid 
#>   "#0B4F6C"   "#2A9D8F"   "#B84A3A"   "#D99A2B"   "#6F63B6"   "#767676" 
```
