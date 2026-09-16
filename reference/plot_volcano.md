# Volcano plot

Effect size against significance, with the calling thresholds drawn.
This is the standard first look at a differential analysis: it separates
the features that moved a lot from the ones that moved reliably, and
shows how many of each the thresholds produce.

## Usage

``` r
plot_volcano(
  effect,
  p_value,
  label = NULL,
  effect_threshold = 1,
  p_threshold = 0.05,
  label_top = 10,
  palette = "house",
  repel = TRUE,
  xlab = "Effect size",
  ylab = expression(-log[10] ~ italic(P)),
  title = NULL,
  font = "Arial"
)
```

## Arguments

- effect:

  Numeric effect sizes, typically a log fold change.

- p_value:

  Significance values on the same scale as `p_threshold`.

- label:

  Feature labels.

- effect_threshold, p_threshold:

  Calling thresholds. Features past both are labelled as significant.

- label_top:

  Label the most significant features instead of every significant one.
  Set to `0` to label none, or `Inf` to label all.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- repel:

  Repel the labels so they do not overlap.

- xlab, ylab, title:

  Axis and plot labels.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## Examples

``` r
set.seed(1)
effect <- rnorm(2000)
p_value <- runif(2000)^2
p <- plot_volcano(effect, p_value, paste0("gene", seq_along(effect)))
```
