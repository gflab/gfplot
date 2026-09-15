# Dot plot of enriched terms

Plots the most significant terms with gene ratio on the x-axis, term on
the y-axis, point size by gene count, and colour by significance.

## Usage

``` r
plot_GO(gsea, n = 20, font = "Arial")
```

## Arguments

- gsea:

  Result table with the columns `p_value`, `term_name`,
  `intersection_size`, and `query_size`.

- n:

  Maximum number of terms to display.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.
