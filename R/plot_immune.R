#' Radar chart of immune-cell infiltration by group
#'
#' @param res Immune-cell estimates with cell types in the first column and
#'   samples in the remaining columns.
#' @param group Named group labels, indexed by sample.
#' @param title Plot title.
#' @param legend.position Legend position.
#'
#' @return A `ggplot` object.
#' @export
plot_immune <- function(res, group, title = "", legend.position = "left") {
  gfplot_require(
    "ggradar",
    "Install it with remotes::install_github(\"ricardo-bion/ggradar\")."
  )

  df <- data.frame(res, check.names = FALSE)
  rownames(df) <- df[, 1]
  df <- df[, -1, drop = FALSE]
  df <- data.frame(t(df), check.names = FALSE)
  df$RiskGroup <- group[rownames(df)]
  df <- df[!is.na(df$RiskGroup), , drop = FALSE]

  cell_types <- setdiff(names(df), "RiskGroup")
  immune_radar <- stats::aggregate(
    df[, cell_types, drop = FALSE],
    by = list(RiskGroup = df$RiskGroup),
    FUN = mean,
    na.rm = TRUE
  )
  names(immune_radar) <- c("RiskGroup", pretty_cell_names(cell_types))

  values <- as.matrix(immune_radar[, -1, drop = FALSE])
  grid.max <- max(values, na.rm = TRUE) * 1.2
  grid.min <- stats::median(values, na.rm = TRUE)

  ggradar::ggradar(
    immune_radar,
    grid.min = 0,
    font.radar = "Arial",
    grid.mid = grid.min,
    grid.max = grid.max,
    plot.extent.x.sf = 1,
    plot.extent.y.sf = 1.2,
    grid.line.width = 0.2,
    grid.label.size = 0,
    axis.label.size = 4,
    axis.label.offset = 1,
    group.line.width = 0.2,
    group.point.size = 1,
    background.circle.transparency = 0,
    plot.legend = nrow(immune_radar) > 1,
    plot.title = title
  ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 16),
      legend.position = legend.position,
      legend.text = ggplot2::element_text(size = 8),
      legend.key.size = ggplot2::unit(0.5, "cm"),
      legend.key.width = ggplot2::unit(0.5, "cm"),
      legend.key.height = ggplot2::unit(0.5, "cm")
    )
}

# Long immune-cell names are wrapped so that radar axis labels stay readable.
pretty_cell_names <- function(x) {
  x <- gsub("T cell CD4+ (non-regulatory)", "T cell CD4+\n(non-regulatory)", x, fixed = TRUE)
  x <- gsub("T cell regulatory (Tregs)", "T cell regulatory\n(Tregs)", x, fixed = TRUE)
  x
}
