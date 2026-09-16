# Waterfall plot of response

Patients ranked by response, with the bar height showing how far each
departed from baseline and the fill showing the response category. This
is the standard display of response in a single-arm trial.

## Usage

``` r
plot_waterfall(
  response,
  category = NULL,
  patient = NULL,
  label_top = 0,
  thresholds = c(`Partial response` = -30, `Stable disease` = 20),
  threshold_labels = TRUE,
  show_patients = FALSE,
  palette = "house",
  xlab = NULL,
  ylab = "Change from baseline (%)",
  title = NULL,
  font = "Arial"
)
```

## Arguments

- response:

  Numeric response values, for example a percentage change from
  baseline. `NA` values are dropped.

- category:

  Optional response category per patient, used to fill the bars.
  Defaults to the RECIST-style cut-offs, where -30 and 20 percent
  separate partial response, stable disease, and progression.

- patient:

  Optional patient labels, used on the x axis when few enough bars are
  drawn to read them.

- label_top:

  Label this many of the largest and smallest bars, which is what a
  reader wants from a dense waterfall.

- thresholds:

  Cut-offs between response categories, as a named vector such as
  `c("Partial response" = -30, "Stable disease" = 20)`. Values at or
  below the first are partial response and values above the last are
  progression.

- threshold_labels:

  Print the cut-off lines and their values.

- show_patients:

  Print patient labels under the bars.

- palette:

  Palette name passed to
  [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md).

- xlab, ylab, title:

  Axis and plot labels.

- font:

  Font family used in the plot.

## Value

A `ggplot` object.

## Examples

``` r
set.seed(1)
response <- c(rnorm(40, -10, 20), rnorm(10, 40, 15))
p <- plot_waterfall(response)
```
