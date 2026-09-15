# gfplot

Publication-ready figures for cancer bioinformatics. `gfplot` provides
the plotting helpers that recur in molecular-subtype, biomarker, and
risk-score papers: Kaplan-Meier curves with hazard ratios, ROC and
time-dependent ROC curves, multiple-ROC comparisons, risk-score
distributions, PCA and UMAP projections, boxplots, correlation plots,
lasso coefficient paths, enrichment plots, and immune-infiltration radar
charts.

## Installation

``` r

# install.packages("remotes")
remotes::install_github("gflab/gfplot")
```

The historical path `gaofeng21cn/gfplot` redirects to this repository,
so scripts that install from either location keep working.

## Quick start

``` r

library(gfplot)
library(survival)

data(lung)
keep <- complete.cases(lung[, c("time", "status", "sex")])

# Kaplan-Meier curves with log-rank p-value and hazard ratio
plot_KMCurve(
  Surv(lung$time[keep], lung$status[keep] == 2),
  factor(lung$sex[keep], labels = c("Male", "Female")),
  risk.table = FALSE
)

# ROC curves with area under the curve in the legend
plot_ROC(
  cbind(CCND1 = rnorm(80), MYC = rnorm(80)),
  rep(c(0, 1), each = 40)
)
```

## Functions

| Area | Functions |
|----|----|
| Survival | [`plot_KMCurve()`](https://gflab.github.io/gfplot/reference/plot_KMCurve.md), [`generate_time_event()`](https://gflab.github.io/gfplot/reference/generate_time_event.md) |
| Discrimination | [`plot_ROC()`](https://gflab.github.io/gfplot/reference/plot_ROC.md), [`plot_TimeROC()`](https://gflab.github.io/gfplot/reference/plot_TimeROC.md), [`plot_MulROC()`](https://gflab.github.io/gfplot/reference/plot_MulROC.md) |
| Sample-level figures | [`plot_RiskScore()`](https://gflab.github.io/gfplot/reference/plot_RiskScore.md), [`plot_Boxplot()`](https://gflab.github.io/gfplot/reference/plot_Boxplot.md), [`plot_barplot()`](https://gflab.github.io/gfplot/reference/plot_barplot.md), [`plot_cor()`](https://gflab.github.io/gfplot/reference/plot_cor.md) |
| Projections and models | [`plot_PCA()`](https://gflab.github.io/gfplot/reference/plot_PCA.md), [`plot_UMAP()`](https://gflab.github.io/gfplot/reference/plot_UMAP.md), [`plot_lasso()`](https://gflab.github.io/gfplot/reference/plot_lasso.md) |
| Enrichment and immune figures | [`plot_GO()`](https://gflab.github.io/gfplot/reference/plot_GO.md), [`viewGSEA()`](https://gflab.github.io/gfplot/reference/viewGSEA.md), [`ggGSEA()`](https://gflab.github.io/gfplot/reference/ggGSEA.md), [`plot_immune()`](https://gflab.github.io/gfplot/reference/plot_immune.md) |
| Helpers | [`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md) |

Every function returns a `ggplot` object, so figures can be modified
with the usual `ggplot2` grammar.

## Optional back ends

Some functions build on specialised packages. They are declared in
`Suggests` and report an actionable message when missing, so
[`library(gfplot)`](https://github.com/gflab/gfplot) always works:

| Function | Back end |
|----|----|
| [`plot_KMCurve()`](https://gflab.github.io/gfplot/reference/plot_KMCurve.md) | `survminer` |
| [`plot_TimeROC()`](https://gflab.github.io/gfplot/reference/plot_TimeROC.md) | `survivalROC` (or `timeROC` for new work) |
| [`plot_UMAP()`](https://gflab.github.io/gfplot/reference/plot_UMAP.md) | `umap` |
| [`plot_lasso()`](https://gflab.github.io/gfplot/reference/plot_lasso.md) | `glmnet` |
| [`plot_immune()`](https://gflab.github.io/gfplot/reference/plot_immune.md) | `ggradar` |
| [`viewGSEA()`](https://gflab.github.io/gfplot/reference/viewGSEA.md), [`ggGSEA()`](https://gflab.github.io/gfplot/reference/ggGSEA.md) | `DOSE`, `HTSanalyzeR2`, `fgsea` |
| [`plot_barplot()`](https://gflab.github.io/gfplot/reference/plot_barplot.md) significance | `ggpubr` |

## Fonts

Figures use Arial on every plotting function, which is the lab style for
publication output. On macOS the `quartz` and `agg` devices resolve
Arial directly. PDF and PostScript output need the font registered with
the device, which `extrafont` does:

``` r

extrafont::font_import()   # once per machine
gfplot_font_setup()        # registers Arial with the graphics devices
```

[`gfplot_font_setup()`](https://gflab.github.io/gfplot/reference/gfplot_font_setup.md)
reports whether Arial is then available. Every plotting function takes
`font`, so a different family can be used for a specific figure; the
value is passed to the device unchanged.

Figures are rendered when they are printed, so examples in the help
pages assign them to `p`; call `print(p)` or `ggsave()` to produce the
file.

## Themes

Loading `gfplot` sets the global `ggplot2` theme to
[`cowplot::theme_cowplot()`](https://wilkelab.org/cowplot/reference/theme_cowplot.html).
Set the option before loading the package to keep your own theme:

``` r

options(gfplot.set_theme = FALSE)
library(gfplot)
```

## Version history

`0.2.0` modernises the package: it repairs functions that could not run,
fixes undeclared dependencies, and adds tests and continuous
integration. See `NEWS.md` for the full list. The original `0.1.0`
sources remain available in this repository’s history at commit
`89a60bd`, which is tagged `v0.1.0`.

## License and citation

MIT licensed. See `CITATION.cff` for citation metadata.

## Maintenance

Maintained by Feng Gao under the [gflab](https://github.com/gflab)
organisation. Bug reports and feature requests are welcome through
GitHub Issues.
