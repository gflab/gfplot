# Changelog

## gfplot 0.6.0

Nine new figure families, journal size presets, and a provenance record.
Every existing function keeps its name and arguments.

### New figure families

The Prediction Performance category is now complete, and five other
categories gain their first entries.

| Family | What it answers |
|----|----|
| [`plot_pr_curve()`](https://gflab.github.io/gfplot/reference/plot_pr_curve.md) | Precision against recall, for a rare positive class where the ROC curve can look encouraging |
| [`plot_calibration()`](https://gflab.github.io/gfplot/reference/plot_calibration.md) | Whether a model is honest about the probability it predicts, not only about the ranking |
| [`plot_decision_curve()`](https://gflab.github.io/gfplot/reference/plot_decision_curve.md) | Whether acting on the model does more good than harm, against treating everyone and no one |
| [`plot_cumulative_incidence()`](https://gflab.github.io/gfplot/reference/plot_cumulative_incidence.md) | The probability of each event when competing events prevent the one of interest |
| [`plot_volcano()`](https://gflab.github.io/gfplot/reference/plot_volcano.md) | Effect size against significance, for a differential analysis |
| [`plot_waterfall()`](https://gflab.github.io/gfplot/reference/plot_waterfall.md) | Patients ranked by response, with the RECIST-style cut-offs |
| [`plot_heatmap()`](https://gflab.github.io/gfplot/reference/plot_heatmap.md) | A matrix of values, with a diverging scale centred where it belongs |
| [`plot_confusion()`](https://gflab.github.io/gfplot/reference/plot_confusion.md) | Predicted against actual class, as counts or row percentages |
| [`plot_violin()`](https://gflab.github.io/gfplot/reference/plot_violin.md) | Grouped distributions with the observations shown |

[`plot_embedding()`](https://gflab.github.io/gfplot/reference/plot_embedding.md)
generalises the projection plots and the wrappers now delegate to it, so
PCA, t-SNE, and UMAP share one implementation:

``` r

plot_embedding(data, groups, method = "tsne", perplexity = 30, seed = 1)
plot_PCA(data, groups)   # same function, method = "pca"
plot_UMAP(data, groups)  # same function, method = "umap"
plot_tsne(data, groups)  # same function, method = "tsne"
```

All nine are available through the specification layer as well, and
[`gfplot_families()`](https://gflab.github.io/gfplot/reference/gfplot_families.md)
now indexes 26 figures across 10 categories.

### Journal size presets

[`gfplot_save()`](https://gflab.github.io/gfplot/reference/gfplot_save.md)
takes a `size` argument using the common column widths, so a figure is
produced at the size the journal will print it:

``` r

gfplot_save(p, "figure2.png", size = "single")   # 85 mm
gfplot_save(p, "figure2.png", size = "onehalf")  # 114 mm
gfplot_save(p, "figure2.png", size = "double")   # 170 mm
gfplot_save(p, "figure2.png", size = "slide")    # 16:9
```

An explicit `width` or `height` still wins, so a standard width can be
paired with a chosen height. Without a preset the previous 7 by 5 inch
default applies, so existing calls are unaffected.

### Provenance

`gfplot_save(..., provenance = TRUE)` writes a `.provenance.json` next
to the figure recording what produced it: the figure family when the
plot came from a specification, the package and R versions, the output
size, device, and font, and the SHA-256 of the written file. That is
what makes a figure in a manuscript traceable to the code that drew it.
It is off by default so no unexpected files appear.

### Repairs

- Figure categories are spelled one way, so
  [`gfplot_families()`](https://gflab.github.io/gfplot/reference/gfplot_families.md)
  no longer splits a category in two over capitalisation or lists
  survival figures under both “Survival” and “Time-to-Event”.
- `gfplot_response_colors()` errored on a response category it did not
  know, which broke
  [`plot_waterfall()`](https://gflab.github.io/gfplot/reference/plot_waterfall.md)
  for caller-supplied categories.
- [`plot_waterfall()`](https://gflab.github.io/gfplot/reference/plot_waterfall.md)
  silently recycled a `patient` or `category` vector of the wrong length
  instead of reporting it.
- [`plot_waterfall()`](https://gflab.github.io/gfplot/reference/plot_waterfall.md)
  placed a negative cut-off label on top of the deepest bars, and put a
  downward bar’s patient label inside the bar.
- [`gfplot_save()`](https://gflab.github.io/gfplot/reference/gfplot_save.md)
  computed the file hash before the device closed, so the provenance
  hash was of an unflushed file.

### Tests

Three hundred and five tests, adding coverage for every new family, the
size presets, and the provenance record.

## gfplot 0.5.0

Adds a figure-specification layer and the first new figure family,
forest plots. Every existing function keeps its name and arguments.

### Figure specifications

[`gfplot_spec()`](https://gflab.github.io/gfplot/reference/gfplot_spec.md)
captures the data and settings for a figure as a value that can be
validated, printed, and rendered later, and
[`gfplot_render()`](https://gflab.github.io/gfplot/reference/gfplot_render.md)
draws it. This is the entry point for a pipeline, a report template, or
an agent that has the numbers and a description of the chart it wants in
one place but draws in another.

``` r

spec <- gfplot_spec(
  "forest",
  data = effects, term = "term",
  estimate = "hr", lower = "lower", upper = "upper"
)
gfplot_render(spec)
```

[`gfplot_families()`](https://gflab.github.io/gfplot/reference/gfplot_families.md)
indexes every figure the package can draw — both the
specification-driven families and the existing functions — with its
category and an example call.

### Forest plots

[`plot_forest()`](https://gflab.github.io/gfplot/reference/plot_forest.md)
draws effect estimates with confidence intervals, the numbers printed
alongside, optional grouping, and optional log scaling for ratios. It
reads a `clinstats` regression table without reshaping:

``` r

table <- clinstats::cox_table(
  clinstats::clin_crc,
  time = "rfs.delay", event = "rfs.event",
  factors = c("sex", "age", "tnm.stage"), multivariable = "none"
)
plot_forest(
  table,
  term = "term", estimate = "hr_univariable",
  lower = "univ_ci_lower", upper = "univ_ci_upper", p = "univ_p",
  log_scale = TRUE
)
```

`clinstats` is listed in `Suggests`, so it is only needed by that
example and the integration test.

### Notes

- The number column is a composed panel, as with the risk table of
  [`plot_KMCurve()`](https://gflab.github.io/gfplot/reference/plot_KMCurve.md),
  so it lines up with the rows at any figure size.
- Ratios use a log axis, where a halving and a doubling are the same
  distance; differences use a linear axis. A log axis with non-positive
  limits is rejected with an explanation rather than drawn.

### Tests

One hundred and sixty-five tests, adding coverage for the specification
layer, the forest plot across both scales, grouped and ungrouped
layouts, input validation, and the `clinstats` integration.

## gfplot 0.4.1

- Relicensed from MIT to the Apache License 2.0, the default for lab
  open-source software. The R package metadata, `CITATION.cff`, and the
  README all report the new licence.
- Versions released before this one were published under MIT and keep
  those terms; the `v0.1.0` through `v0.4.0` tags are unchanged.

## gfplot 0.4.0

Adds an explicit style layer, so the house style is defined in one place
instead of being restated in every plotting function.

### The style layer

- [`gfplot_colors()`](https://gflab.github.io/gfplot/reference/gfplot_colors.md)
  returns colours by semantic role — `"model_curve"`,
  `"comparator_curve"`, `"reference_line"`, `"text"`, `"grid"` — so a
  figure says what a colour is for rather than naming a hex value.
  Override any role for a session with
  `options(gfplot.palette = list(primary = "#123456"))`.
- [`gfplot_theme()`](https://gflab.github.io/gfplot/reference/gfplot_theme.md)
  is the theme every figure is drawn with: bold axis titles, a thin
  major grid, a panel border, and a horizontal legend under the panel.
  Sizes derive from `base_size`, so one number rescales a figure.
- [`gfplot_legend()`](https://gflab.github.io/gfplot/reference/gfplot_legend.md)
  wraps the legend onto as many rows as the number of series needs, and
  hides it when a single series would only restate the axis.
- `get_color("house")` returns the lab series ramp, and
  [`plot_Boxplot()`](https://gflab.github.io/gfplot/reference/plot_Boxplot.md),
  [`plot_RiskScore()`](https://gflab.github.io/gfplot/reference/plot_RiskScore.md),
  and
  [`plot_KMCurve()`](https://gflab.github.io/gfplot/reference/plot_KMCurve.md)
  map risk-group labels onto paired colours regardless of spelling, so
  “Low Risk”, “low-risk”, and “low risk” all take the model-curve
  colour.

### Changed defaults

- The default `palette` for every plotting function is now `"house"`,
  the lab ramp. The journal palettes remain available by name.
- [`plot_ROC()`](https://gflab.github.io/gfplot/reference/plot_ROC.md),
  [`plot_TimeROC()`](https://gflab.github.io/gfplot/reference/plot_TimeROC.md),
  and
  [`plot_MulROC()`](https://gflab.github.io/gfplot/reference/plot_MulROC.md)
  place the legend at the bottom by default, where the
  area-under-the-curve labels have room, instead of at a fixed point
  inside the panel. Pass an x/y coordinate pair to `legend.pos` for an
  inside-panel legend.
- ROC panels use a fixed 0 to 1 range with no expansion, so the diagonal
  meets the corners.
- [`plot_PCA()`](https://gflab.github.io/gfplot/reference/plot_PCA.md),
  [`plot_UMAP()`](https://gflab.github.io/gfplot/reference/plot_UMAP.md),
  and
  [`plot_lasso()`](https://gflab.github.io/gfplot/reference/plot_lasso.md)
  take a `font` argument, like the other plotting functions.

### Repairs

- [`gfplot_colors()`](https://gflab.github.io/gfplot/reference/gfplot_colors.md)
  accepts a vector of roles, which previously failed with “the condition
  has length \> 1”.

### Tests

One hundred and twenty-three tests, including coverage for role and
alias resolution, palette overrides, risk-group colour matching, theme
scaling, and legend wrapping.

### Documentation

The README is rewritten around how the package is actually used: what it
is for, the house style and why it is opinionated, quick-start examples
with figures produced by the package, a function and argument index, and
a table of optional back ends with install commands.

## gfplot 0.3.0

Modernises the package around two goals: figures come out in Arial
without setup, and the package depends on less to maintain.

### Fonts no longer need a registration step for most output

In 0.2.0, writing Arial meant running `extrafont::font_import()` and
then `extrafont::loadfonts()`. That is only needed by the base
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html) device. The raster
devices in and the `quartz` device on macOS resolve system fonts
directly, so PNG, TIFF, JPEG, and macOS PDF output need no preparation
at all.

- [`gfplot_font_setup()`](https://gflab.github.io/gfplot/reference/gfplot_font_setup.md)
  now reports which routes can render the font in the current session
  instead of only driving `extrafont`. It returns a named logical vector
  with one entry per route that
  [`gfplot_save()`](https://gflab.github.io/gfplot/reference/gfplot_save.md)
  chooses between (`raster`, `quartz`, `pdf`) and registers the font
  with `extrafont` when that is the only way to get vector PDF output.
- Added
  [`gfplot_save()`](https://gflab.github.io/gfplot/reference/gfplot_save.md),
  which writes a figure through a device that can render the requested
  font, chosen from the file extension. It closes the device even when
  drawing fails.
- The default figure font is still Arial, and the `font` argument is
  still passed to the device unchanged.

### Fewer dependencies

- [`plot_ROC()`](https://gflab.github.io/gfplot/reference/plot_ROC.md)
  no longer uses . Curves are built with , which was already a
  dependency, so the package no longer pulls in and the `ggplot2` 4.0
  warning that came with it.
- [`plot_cor()`](https://gflab.github.io/gfplot/reference/plot_cor.md)
  no longer uses .
  [`stats::cor.test()`](https://rdrr.io/r/stats/cor.test.html) returns
  the same Pearson correlation and p-value, including under missing
  values, so is no longer a dependency.

### Repairs

- [`plot_ROC()`](https://gflab.github.io/gfplot/reference/plot_ROC.md)
  reported `1 - AUC` in the legend for a marker whose direction was
  reversed. The curve was drawn with a fixed convention while the legend
  came from `pROC`’s automatic direction, so a marker drawn below the
  diagonal was labelled with the mirrored value. Both now use the same
  direction, and the legend always describes the curve that is drawn.
- [`plot_ROC()`](https://gflab.github.io/gfplot/reference/plot_ROC.md)
  reproduces the 0.1.0 appearance: axis labels `1 - Specificity` and
  `Sensitivity`, the dashed reference diagonal, and equal coordinate
  scaling.
- Missing optional back ends report a formatted error that names the
  package and the install command, through .
- `plot_KMCurve(risk.table = TRUE)` no longer floods the console with
  `font family 'Arial' not found in PostScript font database`. `cowplot`
  measures text against that database once per element while assembling
  the risk table — 79 warnings for a two-group curve — even though
  rendering goes through the device the user chooses. The probe is now
  reported once per session as a formatted message naming the affected
  route and the fix.

### Documentation

The README is rewritten around how the package is actually used: what it
is for, the house style and why it is opinionated, quick-start examples
with figures produced by the package, a function and argument index, and
a table of optional back ends with install commands.

### Tests

Seventy tests, including new coverage for the direction of the plotted
curve, `force05`, the correlation annotation under missing and
degenerate input, and
[`gfplot_save()`](https://gflab.github.io/gfplot/reference/gfplot_save.md).

## gfplot 0.2.0

Modernisation of the 0.1.0 package. Every exported function keeps its
name and arguments, so existing scripts continue to run unchanged.

### Repairs

- [`plot_barplot()`](https://gflab.github.io/gfplot/reference/plot_barplot.md)
  was not callable: it took no arguments and referenced undefined
  variables. It is now a working grouped bar plot with optional
  significance annotations.
- [`plot_cor()`](https://gflab.github.io/gfplot/reference/plot_cor.md)
  computed group-specific colour scales but never assigned them, so the
  `groups` argument had no effect on the plot.
- [`plot_KMCurve()`](https://gflab.github.io/gfplot/reference/plot_KMCurve.md)
  used `class(x) == "factor"`, which errors on R 4.2 and later when the
  class vector has more than one element. It now uses
  [`is.factor()`](https://rdrr.io/r/base/factor.html) and
  [`is.logical()`](https://rdrr.io/r/base/logical.html).
- [`plot_KMCurve()`](https://gflab.github.io/gfplot/reference/plot_KMCurve.md)
  computed the hazard ratio through `survcomp`. It now uses a
  univariable Cox model from the `survival` package, which gives the
  same hazard ratio and confidence interval without a Bioconductor
  dependency.
- [`plot_Boxplot()`](https://gflab.github.io/gfplot/reference/plot_Boxplot.md)
  no longer relies on
  [`qplot()`](https://ggplot2.tidyverse.org/reference/qplot.html),
  handles non-factor groups, and builds every pairwise comparison
  instead of assuming two groups.
- [`plot_immune()`](https://gflab.github.io/gfplot/reference/plot_immune.md)
  no longer hard-codes the positions of the immune-cell columns, which
  previously broke for panels with a different number of cell types.
- [`plot_RiskScore()`](https://gflab.github.io/gfplot/reference/plot_RiskScore.md)
  coerces non-factor event vectors before reading their levels;
  previously a numeric event vector produced an empty colour scale.
- [`plot_MulROC()`](https://gflab.github.io/gfplot/reference/plot_MulROC.md)
  uses [`sprintf()`](https://rdrr.io/r/base/sprintf.html) instead of
  [`stringr::str_pad()`](https://stringr.tidyverse.org/reference/str_pad.html),
  removing an undeclared dependency.
- [`plot_TimeROC()`](https://gflab.github.io/gfplot/reference/plot_TimeROC.md)
  and [`plot_GO()`](https://gflab.github.io/gfplot/reference/plot_GO.md)
  label axes correctly and use current `ggplot2` line-width semantics.
- [`plot_lasso()`](https://gflab.github.io/gfplot/reference/plot_lasso.md)
  uses
  [`tidyr::pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html)
  instead of the retired `reshape::melt()` and drops the unused
  text-position data frame.
- [`plot_ROC()`](https://gflab.github.io/gfplot/reference/plot_ROC.md)
  now accepts a matrix as well as a data frame for `scores`. In 0.1.0 a
  matrix was walked element by element, which raised a length error. The
  curve layout is unchanged, and a spurious warning from `precrec` under
  `ggplot2` 4.0 is suppressed.
- [`plot_KMCurve()`](https://gflab.github.io/gfplot/reference/plot_KMCurve.md)
  no longer passes
  [`element_blank()`](https://ggplot2.tidyverse.org/reference/element.html)
  to the risk-table title, which current `survminer` and `ggplot2`
  reject.

### Dependencies

- `survminer`, `pROC`, `stringr`, `ggpubr`, and `survival` are now
  declared. In 0.1.0 they were used but missing from `DESCRIPTION`, so a
  clean installation could fail at run time.
- `reshape`, `ggfortify`, `MASS`, and `survcomp` are no longer needed.
- Optional back ends (`fgsea`, `ggpubr`, `ggsignif`, `glmnet`,
  `ggradar`, `HTSanalyzeR2`, `survivalROC`, `umap`) are declared in
  `Suggests` and checked at call time with an actionable error message,
  so [`library(gfplot)`](https://github.com/gflab/gfplot) works without
  them.
- `LICENSE`, `URL`, and `BugReports` fields were added.

### Behaviour

- `gfplot` still sets the global `ggplot2` theme to
  [`cowplot::theme_cowplot()`](https://wilkelab.org/cowplot/reference/theme_cowplot.html)
  when it is loaded. Set `options(gfplot.set_theme = FALSE)` before
  loading the package to keep your own theme.
- Arial remains the default figure font on every plotting function. The
  font pipeline is now a documented part of the package:
  [`gfplot_font_setup()`](https://gflab.github.io/gfplot/reference/gfplot_font_setup.md)
  registers Arial for PDF and PostScript output through `extrafont`,
  after the one-time `extrafont::font_import()`. The `quartz` and `agg`
  devices on macOS resolve Arial directly, so no registration is needed
  for on-screen or PNG output there.
- The `font` argument is passed to the graphics device unchanged, as in
  0.1.0. If the requested family is not available, the device reports
  it; run
  [`gfplot_font_setup()`](https://gflab.github.io/gfplot/reference/gfplot_font_setup.md)
  to fix PDF and PostScript output.
- Examples assign figures to `p` instead of printing them, so
  `R CMD check` does not depend on the fonts installed on the build
  machine.

### Tests and continuous integration

- Placeholder tests were replaced by smoke tests over synthetic data for
  every exported function.
- GitHub Actions runs `R CMD check` on macOS, Windows, and Linux
  (current and previous release) and builds a `pkgdown` site.
