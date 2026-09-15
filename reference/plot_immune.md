# Radar chart of immune-cell infiltration by group

Radar chart of immune-cell infiltration by group

## Usage

``` r
plot_immune(res, group, title = "", legend.position = "left")
```

## Arguments

- res:

  Immune-cell estimates with cell types in the first column and samples
  in the remaining columns.

- group:

  Named group labels, indexed by sample.

- title:

  Plot title.

- legend.position:

  Legend position.

## Value

A `ggplot` object.
