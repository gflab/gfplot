# Plot several ROC curves from separate datasets

Each element of `scores` is matched with the corresponding element of
`labels`, which allows the curves to come from different cohorts or
endpoints rather than from different markers of the same cohort.

## Usage

``` r
plot_MulROC(
  scores,
  labels,
  palette = "house",
  color = NULL,
  legend.pos = "bottom",
  title = NULL,
  font = "Arial",
  percent.style = FALSE
)
```

## Arguments

- scores:

  A named list of numeric marker vectors.

- labels:

  A list of binary outcomes, one per element of `scores`.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- color:

  Optional vector of colours; overrides `palette`.

- legend.pos:

  Legend position: a position such as `"bottom"`, or an x/y coordinate
  pair in panel units for a legend inside the panel.

- title:

  Plot title.

- font:

  Font family used in the plot.

- percent.style:

  Label the axes as percentages.

## Value

A `ggplot` object.

## Examples

``` r
set.seed(1)
scores <- list(cohortA = rnorm(60), cohortB = rnorm(60))
labels <- list(rbinom(60, 1, 0.5), rbinom(60, 1, 0.5))
p <- plot_MulROC(scores, labels)
```
