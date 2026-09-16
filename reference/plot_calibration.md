# Calibration curve

Predicted probability against the observed proportion of events. A model
whose points sit on the diagonal predicts the level it claims; one above
the diagonal under-predicts risk and one below over-predicts.

## Usage

``` r
plot_calibration(
  probability,
  outcome,
  positive = NULL,
  bins = 10,
  smooth = FALSE,
  show_ci = TRUE,
  palette = "house",
  ci_level = 0.95,
  xlab = "Predicted probability",
  ylab = "Observed proportion",
  title = NULL,
  font = "Arial"
)
```

## Arguments

- probability:

  Predicted probabilities, or a matrix or data frame with one column per
  model.

- outcome:

  Binary outcome, one value per observation.

- positive:

  Value of `outcome` that represents the event.

- bins:

  Number of groups to divide the predictions into. Quantile bins are
  used, so every point rests on a similar number of observations.

- smooth:

  Draw a loess curve through the points instead of connecting them.

- show_ci:

  Draw binomial confidence intervals for each point.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- ci_level:

  Confidence level of the intervals.

- xlab, ylab, title:

  Axis and plot labels.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## See also

[`plot_ROC()`](https://gflab.github.io/gfplot/reference/plot_ROC.md) for
discrimination,
[`plot_decision_curve()`](https://gflab.github.io/gfplot/reference/plot_decision_curve.md)
for whether acting on the predictions helps.

## Examples

``` r
set.seed(1)
outcome <- rbinom(200, 1, 0.4)
probability <- plogis(rnorm(200) + outcome * 0.5)
p <- plot_calibration(probability, outcome)
```
