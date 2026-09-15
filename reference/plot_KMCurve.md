# Plot a Kaplan-Meier curve with risk table and hazard ratio

Draws survival curves for two or more groups, with an optional
number-at- risk table, the log-rank p-value, and, for two groups, the
hazard ratio from a univariable Cox model.

## Usage

``` r
plot_KMCurve(
  clinical,
  labels,
  limit = NULL,
  annot = NULL,
  color = NULL,
  font = "Arial",
  xlab = "Follow up",
  ylab = "Survival Probability",
  title = NULL,
  legend.pos = "top",
  palette = "jama_classic",
  risk.table = TRUE,
  risk.table.ratio = 0.4,
  anno.pos = "bottom",
  anno.x.shift = 0.5
)
```

## Arguments

- clinical:

  A survival object created by
  [`survival::Surv()`](https://rdrr.io/pkg/survival/man/Surv.html).

- labels:

  A vector of group labels, one per patient.

- limit:

  Optional follow-up limit; later observations are censored at the
  limit.

- annot:

  Optional extra annotation added to the plot.

- color:

  Optional vector of colours. A named vector also sets the group order.

- font:

  Font family used in the plot.

- xlab, ylab, title:

  Axis and plot labels.

- legend.pos:

  Legend position.

- palette:

  Palette name passed to
  [`get_color()`](https://gaofeng21cn.github.io/gfplot/reference/get_color.md).

- risk.table:

  Draw the number-at-risk table.

- risk.table.ratio:

  Relative height of the risk table.

- anno.pos:

  Either `"bottom"` or `"top"`; where the annotations are placed.

- anno.x.shift:

  Horizontal position of the annotations when `anno.pos = "top"`.

## Value

A `ggplot` object, or a `cowplot` grid when `risk.table = TRUE`.

## Examples

``` r
library(survival)
fit_data <- survival::lung
p <- plot_KMCurve(
  Surv(fit_data$time, fit_data$status == 2),
  factor(fit_data$sex),
  risk.table = FALSE
)
```
