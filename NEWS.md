# gfplot 0.2.0

Modernisation of the 0.1.0 package. Every exported function keeps its name
and arguments, so existing scripts continue to run unchanged.

## Repairs

* `plot_barplot()` was not callable: it took no arguments and referenced
  undefined variables. It is now a working grouped bar plot with optional
  significance annotations.
* `plot_cor()` computed group-specific colour scales but never assigned them,
  so the `groups` argument had no effect on the plot.
* `plot_KMCurve()` used `class(x) == "factor"`, which errors on R 4.2 and
  later when the class vector has more than one element. It now uses
  `is.factor()` and `is.logical()`.
* `plot_KMCurve()` computed the hazard ratio through `survcomp`. It now uses a
  univariable Cox model from the `survival` package, which gives the same
  hazard ratio and confidence interval without a Bioconductor dependency.
* `plot_Boxplot()` no longer relies on `qplot()`, handles non-factor groups,
  and builds every pairwise comparison instead of assuming two groups.
* `plot_immune()` no longer hard-codes the positions of the immune-cell
  columns, which previously broke for panels with a different number of cell
  types.
* `plot_RiskScore()` coerces non-factor event vectors before reading their
  levels; previously a numeric event vector produced an empty colour scale.
* `plot_MulROC()` uses `sprintf()` instead of `stringr::str_pad()`, removing
  an undeclared dependency.
* `plot_TimeROC()` and `plot_GO()` label axes correctly and use current
  `ggplot2` line-width semantics.
* `plot_lasso()` uses `tidyr::pivot_longer()` instead of the retired
  `reshape::melt()` and drops the unused text-position data frame.
* `plot_ROC()` now accepts a matrix as well as a data frame for `scores`.
  In 0.1.0 a matrix was walked element by element, which raised a length
  error. The curve layout is unchanged, and a spurious warning from
  `precrec` under `ggplot2` 4.0 is suppressed.
* `plot_KMCurve()` no longer passes `element_blank()` to the risk-table
  title, which current `survminer` and `ggplot2` reject.

## Dependencies

* `survminer`, `pROC`, `stringr`, `ggpubr`, and `survival` are now declared.
  In 0.1.0 they were used but missing from `DESCRIPTION`, so a clean
  installation could fail at run time.
* `reshape`, `ggfortify`, `MASS`, and `survcomp` are no longer needed.
* Optional back ends (`fgsea`, `ggpubr`, `ggsignif`, `glmnet`, `ggradar`,
  `HTSanalyzeR2`, `survivalROC`, `umap`) are declared in `Suggests` and
  checked at call time with an actionable error message, so `library(gfplot)`
  works without them.
* `LICENSE`, `URL`, and `BugReports` fields were added.

## Behaviour

* `gfplot` still sets the global `ggplot2` theme to `cowplot::theme_cowplot()`
  when it is loaded. Set `options(gfplot.set_theme = FALSE)` before loading
  the package to keep your own theme.
* Arial remains the default figure font on every plotting function. The font
  pipeline is now a documented part of the package: `gfplot_font_setup()`
  registers Arial for PDF and PostScript output through `extrafont`, after the
  one-time `extrafont::font_import()`. The `quartz` and `agg` devices on
  macOS resolve Arial directly, so no registration is needed for on-screen or
  PNG output there.
* The `font` argument is passed to the graphics device unchanged, as in
  0.1.0. If the requested family is not available, the device reports it; run
  `gfplot_font_setup()` to fix PDF and PostScript output.
* Examples assign figures to `p` instead of printing them, so `R CMD check`
  does not depend on the fonts installed on the build machine.

## Tests and continuous integration

* Placeholder tests were replaced by smoke tests over synthetic data for every
  exported function.
* GitHub Actions runs `R CMD check` on macOS, Windows, and Linux (current and
  previous release) and builds a `pkgdown` site.
