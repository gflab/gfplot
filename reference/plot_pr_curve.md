# Precision-recall curve

Precision against recall for a binary outcome. On an imbalanced outcome
the ROC curve can look encouraging while precision stays low, which is
what this plot exposes: it is the recommended companion when the event
is rare.

## Usage

``` r
plot_pr_curve(
  scores,
  labels,
  positive = NULL,
  palette = "house",
  title = NULL,
  font = "Arial",
  show_auc = TRUE
)
```

## Arguments

- scores:

  Numeric vector, or a matrix or data frame with one column per marker.

- labels:

  Binary outcome, one value per observation.

- positive:

  Percentile of the scores above which the positive class is expected.
  Used only to draw the no-skill reference line, which is the prevalence
  of the positive class.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- title:

  Plot title.

- font:

  Font family used in the plot.

- show_auc:

  Print the area under the curve, computed by the trapezoid rule, in the
  legend.

## Value

A `ggplot` object.

## See also

[`plot_ROC()`](https://gflab.github.io/gfplot/reference/plot_ROC.md) for
discrimination,
[`plot_calibration()`](https://gflab.github.io/gfplot/reference/plot_calibration.md)
for the level of the predictions.

## Examples

``` r
set.seed(1)
outcome <- rbinom(200, 1, 0.15)
score <- outcome * 0.8 + rnorm(200)
p <- plot_pr_curve(score, outcome)
```
