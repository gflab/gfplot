# Decision curve

Net benefit across decision thresholds. Net benefit weights the true
positives a model finds against the false positives it costs, at the
threshold probability a clinician would use to act. It is the figure
that answers whether using the model is better than treating everyone or
no one.

## Usage

``` r
plot_decision_curve(
  probability,
  outcome,
  positive = NULL,
  thresholds = seq(0.01, 0.5, by = 0.01),
  treat_all = TRUE,
  treat_none = TRUE,
  palette = "house",
  xlab = "Threshold probability",
  ylab = "Net benefit",
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

- thresholds:

  Decision thresholds to evaluate. Defaults to 0.01 to 0.5, which covers
  the range used in most clinical decisions.

- treat_all:

  Draw the reference curve for treating every patient.

- treat_none:

  Draw the reference line for treating no patient.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- xlab, ylab, title:

  Axis and plot labels.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## See also

[`plot_calibration()`](https://gflab.github.io/gfplot/reference/plot_calibration.md)
for whether the predicted levels are honest.

## Examples

``` r
set.seed(1)
outcome <- rbinom(300, 1, 0.3)
probability <- plogis(rnorm(300) + outcome)
p <- plot_decision_curve(probability, outcome)
```
