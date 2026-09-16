# gfplot

<!-- badges: start -->
[![R-CMD-check](https://github.com/gflab/gfplot/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gflab/gfplot/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Publication-ready figures for cancer bioinformatics. `gfplot` provides the
plotting helpers that recur in molecular-subtype, biomarker, and risk-score
papers: Kaplan-Meier curves with hazard ratios, ROC and time-dependent ROC
curves, multiple-ROC comparisons, risk-score distributions, PCA and UMAP
projections, boxplots, correlation plots, lasso coefficient paths, enrichment
plots, and immune-infiltration radar charts.

## Installation

```r
# install.packages("remotes")
remotes::install_github("gflab/gfplot")
```

The historical path `gaofeng21cn/gfplot` redirects to this repository, so
scripts that install from either location keep working.

## Quick start

```r
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
| --- | --- |
| Survival | `plot_KMCurve()`, `generate_time_event()` |
| Discrimination | `plot_ROC()`, `plot_TimeROC()`, `plot_MulROC()` |
| Sample-level figures | `plot_RiskScore()`, `plot_Boxplot()`, `plot_barplot()`, `plot_cor()` |
| Projections and models | `plot_PCA()`, `plot_UMAP()`, `plot_lasso()` |
| Enrichment and immune figures | `plot_GO()`, `viewGSEA()`, `ggGSEA()`, `plot_immune()` |
| Helpers | `get_color()` |

Every function returns a `ggplot` object, so figures can be modified with the
usual `ggplot2` grammar.

## Optional back ends

Some functions build on specialised packages. They are declared in `Suggests`
and report an actionable message when missing, so `library(gfplot)` always
works:

| Function | Back end |
| --- | --- |
| `plot_KMCurve()` | `survminer` |
| `plot_TimeROC()` | `survivalROC` (or `timeROC` for new work) |
| `plot_UMAP()` | `umap` |
| `plot_lasso()` | `glmnet` |
| `plot_immune()` | `ggradar` |
| `viewGSEA()`, `ggGSEA()` | `DOSE`, `HTSanalyzeR2`, `fgsea` |
| `plot_barplot()` significance | `ggpubr` |

## Fonts

Figures use Arial on every plotting function, which is the lab style for
publication output. Most output needs no preparation: the raster devices in
[ragg](https://ragg.r-lib.org/) and the `quartz` device on macOS resolve
system fonts directly.

`gfplot_save()` writes a figure through a device that can render the font,
chosen from the file extension:

```r
gfplot_save(plot_KMCurve(clin, labs), "figure.png", width = 7, height = 5)
gfplot_save(plot_KMCurve(clin, labs), "figure.pdf", width = 7, height = 5)
```

`gfplot_font_setup()` reports which routes work in the current session:

```
Figure font "Arial" can be rendered by:
• ragg raster devices (PNG, TIFF, JPEG): yes
• quartz (macOS PDF and screen): yes
• base pdf(): no
```

The base `pdf()` device keeps its own font table and is the one route that
needs help. `gfplot_font_setup()` registers Arial with it through
[extrafont](https://github.com/wch/extrafont) when that package is
installed; a one-time `extrafont::font_import()` is required before that can
work. On macOS, prefer `gfplot_save(..., "figure.pdf")`, which uses `quartz`
and needs none of this.

Every plotting function takes `font`, so a different family can be used for a
specific figure; the value is passed to the device unchanged.

Figures are rendered when they are printed, so examples in the help pages
assign them to `p`; call `print(p)` or `ggsave()` to produce the file.

## Saving figures

`gfplot_save()` chooses the device from the file extension: `.png`, `.tiff`,
`.jpg`, `.jpeg`, and `.pdf` are supported. Raster output goes through
`ragg`, which resolves system fonts; PDF output uses `quartz` on macOS and
the base device elsewhere.

```r
p <- plot_ROC(scores, labels)
gfplot_save(p, "roc.png", width = 5, height = 4, dpi = 300)
```

## Themes

Loading `gfplot` sets the global `ggplot2` theme to
`cowplot::theme_cowplot()`. Set the option before loading the package to keep
your own theme:

```r
options(gfplot.set_theme = FALSE)
library(gfplot)
```

## Version history

`0.2.0` modernises the package: it repairs functions that could not run, fixes
undeclared dependencies, and adds tests and continuous integration. See
`NEWS.md` for the full list. Both `0.1.0` and `0.2.0` are tagged, so a
specific state can be pinned.

## Provenance

`gfplot` was published first at `gaofeng21cn/gfplot` and later at
`gflab/gfplot`. The repository was deleted in August 2026. Other public
research code still installed it — `LidocaineQ/PIANOS` calls
`devtools::install_github("gflab/gfplot")` in its README and notebooks — so
those install commands became dead links.

The package was restored in September 2026 from a verified `git bundle` of the
full history. The recovered commit `89a60bdb` carries the original `0.1.0`
sources unchanged and is tagged `v0.1.0`; `v0.2.0` adds the modernisation on
top. The repository moved to the `gflab` organisation, which is why the
personal path redirects here and both install commands resolve to the same
commit.

Every exported function keeps its `0.1.0` name and arguments, so existing
calls continue to work without edits. If you are reading this because an
install failed in that window, the package is installable again and no change
to your code is required.

## License and citation

MIT licensed. See `CITATION.cff` for citation metadata.

## Maintenance

Maintained by Feng Gao under the [gflab](https://github.com/gflab)
organisation. Bug reports and feature requests are welcome through GitHub
Issues.
