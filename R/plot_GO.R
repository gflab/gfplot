#' Dot plot of enriched terms
#'
#' Plots the most significant terms with gene ratio on the x-axis, term on the
#' y-axis, point size by gene count, and colour by significance.
#'
#' @param gsea Result table with the columns `p_value`, `term_name`,
#'   `intersection_size`, and `query_size`.
#' @param n Maximum number of terms to display.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#' @export
plot_GO <- function(gsea, n = 20, font = "Arial") {
  gsea <- gsea[order(gsea$p_value), , drop = FALSE]
  df.plot <- data.frame(
    Term = gsea$term_name,
    Count = gsea$intersection_size,
    GeneRatio = gsea$intersection_size / gsea$query_size,
    P = gsea$p_value,
    stringsAsFactors = FALSE
  )
  df.plot <- df.plot[!duplicated(df.plot$Term), , drop = FALSE]
  df.plot <- df.plot[order(df.plot$GeneRatio), , drop = FALSE]
  df.plot$Term <- factor(df.plot$Term, levels = df.plot$Term)
  df.plot <- df.plot[seq_len(min(n, nrow(df.plot))), , drop = FALSE]

  ggplot2::ggplot(df.plot) +
    gfplot_theme(font = font) +
    ggplot2::geom_point(
      ggplot2::aes(
        x = .data$GeneRatio, y = .data$Term,
        size = .data$Count, color = -log10(.data$P)
      )
    ) +
    ggplot2::theme(axis.title.y = ggplot2::element_blank()) +
    ggplot2::labs(x = "Gene Ratio")
}
