# Legend layout for a set of series labels

Legends in `gfplot` figures sit under the panel and wrap onto as many
rows as the number of series needs, so a wide legend does not squeeze
the panel.

## Usage

``` r
gfplot_legend(labels, base_size = 11, hide_single = TRUE)
```

## Arguments

- labels:

  Series labels the legend will show.

- base_size:

  Base font size, used to scale the legend keys.

- hide_single:

  Hide the legend when only one series is present, where it would only
  restate the axis. Set to `FALSE` when the legend carries information,
  as with the area under the curve printed by
  [`plot_ROC()`](https://gflab.github.io/gfplot/reference/plot_ROC.md).

## Value

A `ggplot2` guide specification, or `"none"` for a single series when
`hide_single = TRUE`.

## Examples

``` r
gfplot_legend(c("Low risk", "High risk"))
#> <ggproto object: Class GuideLegend, Guide, gg>
#>     add_title: function
#>     arrange_layout: function
#>     assemble_drawing: function
#>     available_aes: any
#>     build_decor: function
#>     build_labels: function
#>     build_ticks: function
#>     build_title: function
#>     draw: function
#>     draw_early_exit: function
#>     elements: list
#>     extract_decor: function
#>     extract_key: function
#>     extract_params: function
#>     get_layer_key: function
#>     hashables: list
#>     measure_grobs: function
#>     merge: function
#>     override_elements: function
#>     params: list
#>     process_layers: function
#>     setup_elements: function
#>     setup_params: function
#>     train: function
#>     transform: function
#>     super:  <ggproto object: Class GuideLegend, Guide, gg>
```
