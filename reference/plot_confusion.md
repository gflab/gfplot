# Confusion matrix

Predicted against actual class, with the count in each cell. Percentages
are given per actual class, which is the direction that shows
sensitivity and specificity; overall percentages would hide a class the
model misses.

## Usage

``` r
plot_confusion(
  predicted = NULL,
  actual = NULL,
  predicted_labels = NULL,
  actual_labels = NULL,
  positive = NULL,
  show = c("count", "percent", "both"),
  digits = 1,
  title = NULL,
  font = "Arial"
)
```

## Arguments

- predicted, predicted_labels:

  Predicted class labels.

- actual, actual_labels:

  Actual class labels. `actual` may also be a table or matrix of counts,
  in which case the labels are taken from its dimnames.

- positive:

  Value of the outcome that counts as the positive class, used to order
  and label the axes. With `positive` supplied, the two classes are
  shown as `"Negative"` and `"Positive"`; pass `predicted_labels` and
  `actual_labels` to name them differently.

- show:

  Which numbers to print: `"count"`, `"percent"` (by actual class), or
  `"both"`.

- digits:

  Significant digits for percentages.

- title:

  Plot title.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## Examples

``` r
set.seed(1)
actual <- rbinom(200, 1, 0.4)
predicted <- ifelse(runif(200) < 0.8, actual, 1 - actual)
p <- plot_confusion(predicted, actual, positive = 1)
```
