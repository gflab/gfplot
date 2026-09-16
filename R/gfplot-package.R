#' gfplot: publication-ready figures for cancer bioinformatics
#'
#' The package collects plotting helpers for figures that recur in cancer
#' bioinformatics: survival curves, ROC and time-dependent ROC curves, risk
#' scores, dimensionality-reduction projections, boxplots, correlation plots,
#' lasso coefficient paths, enrichment plots, and immune-infiltration radar
#' charts.
#'
#' @section Figure style:
#' `gfplot` is opinionated about presentation. Figures use Arial and the
#' [cowplot::theme_cowplot()] theme, which is the lab standard for publication
#' output. Loading the package therefore sets the global `ggplot2` theme to
#' `theme_cowplot()` as the session baseline: attaching `gfplot` is a
#' statement that this style is the intended default, so every figure in the
#' session — including figures drawn by other packages — starts from the same
#' look.
#'
#' This is a deliberate choice rather than an incidental side effect. Set
#' `options(gfplot.set_theme = FALSE)` before `library(gfplot)` to keep an
#' existing theme; `ggplot2::theme_set()` can also be called afterwards to
#' choose a different baseline.
#'
#' Font and colour follow the same principle. Arial is the default on every
#' plotting function, and [get_color()] returns journal palettes, so figures
#' are consistent across a manuscript without per-figure tuning. See
#' [gfplot_save()] for writing files that render the font correctly.
#'
#' @keywords internal
#' @import ggplot2
#' @importFrom rlang .data
"_PACKAGE"
