#' gfplot: publication-ready figures for cancer bioinformatics
#'
#' The package collects plotting helpers for figures that recur in cancer
#' bioinformatics: survival curves, ROC and time-dependent ROC curves, risk
#' scores, dimensionality-reduction projections, boxplots, correlation plots,
#' lasso coefficient paths, enrichment plots, and immune-infiltration radar
#' charts.
#'
#' Loading the package sets the global `ggplot2` theme to
#' [cowplot::theme_cowplot()] unless `options(gfplot.set_theme = FALSE)` is
#' set beforehand.
#'
#' @keywords internal
#' @import ggplot2
#' @importFrom rlang .data
"_PACKAGE"
