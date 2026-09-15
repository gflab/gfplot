# Plot a risk score ordered by patient

Plot a risk score ordered by patient

## Usage

``` r
plot_RiskScore(
  rs,
  event,
  legend.position = c(0.2, 0.8),
  palette = "jama",
  color = NULL,
  font = "Arial"
)
```

## Arguments

- rs:

  Numeric risk scores. Names, when present, are used as patient
  identifiers.

- event:

  Event indicator used to fill the bars.

- legend.position:

  Legend position.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- color:

  Optional vector of fill colours; overrides `palette`.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## Examples

``` r
set.seed(1)
p <- plot_RiskScore(rnorm(30), rbinom(30, 1, 0.4))
```
