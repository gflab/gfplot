# Cumulative incidence of competing events

The probability of each event type over follow-up, in the presence of
competing events. When a patient can experience one of several mutually
exclusive events, a Kaplan-Meier estimate of any single one is biased
upward, because patients who had a competing event are still counted as
being at risk of the event of interest. The cumulative incidence
function accounts for them.

## Usage

``` r
plot_cumulative_incidence(
  time,
  status,
  group = NULL,
  event = NULL,
  conf_int = FALSE,
  palette = "house",
  xlab = "Follow up",
  ylab = "Cumulative incidence",
  title = NULL,
  legend_title = NULL,
  font = "Arial"
)
```

## Arguments

- time:

  Follow-up times.

- status:

  Event type per patient. The first level is the event of interest, `0`
  is censoring, and any further levels are competing events. A factor
  with a `0` level, a numeric code vector, or a character vector are all
  accepted.

- group:

  Optional grouping vector, giving one panel per group.

- event:

  Optional event type to plot. By default every event type is drawn.

- conf_int:

  Draw pointwise confidence bands.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- xlab, ylab, title:

  Axis and plot labels.

- legend_title:

  Legend title.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## See also

[`plot_KMCurve()`](https://gflab.github.io/gfplot/reference/plot_KMCurve.md)
for a single event where no competing risk applies.

## Examples

``` r
set.seed(1)
time <- rexp(200)
status <- sample(c(0, 1, 2), 200, replace = TRUE, prob = c(0.4, 0.4, 0.2))
p <- plot_cumulative_incidence(time, status, group = rep(c("A", "B"), 100))
```
