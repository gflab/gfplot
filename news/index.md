# Changelog

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
  no longer relies on `qplot()`, handles non-factor groups, and builds
  every pairwise comparison instead of assuming two groups.
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
  no longer passes `element_blank()` to the risk-table title, which
  current `survminer` and `ggplot2` reject.

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
