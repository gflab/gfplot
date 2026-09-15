# Plot a running enrichment score for a ranked gene list

Computes the enrichment score with `DOSE::gseaScores()` and the p-value
with `fgsea`, then draws the running score with the leading-edge
position.

## Usage

``` r
ggGSEA(input, gs, title = "")
```

## Arguments

- input:

  Named numeric vector of ranked statistics.

- gs:

  Gene set: a character vector of gene names.

- title:

  Plot title.

## Value

A `ggplot` object.
