#' Compare distributions across groups
#'
#' Violin plots with the individual observations overlaid, which shows both
#' the shape of each distribution and how much data stands behind it. A
#' boxplot alone hides a bimodal group and a group with four samples.
#'
#' @param value Numeric values.
#' @param group Grouping vector, one value per observation.
#' @param order Group order. Defaults to the order of the levels, or of first
#'   appearance for a plain vector.
#' @param show Which to draw: `"violin"`, `"box"`, or `"both"`.
#' @param points Draw the individual observations.
#' @param points_maximum Draw the observations only when there are at most
#'   this many, since a violin over thousands of points is unreadable. Use
#'   `Inf` to always draw them.
#' @param show_n Print the number of observations under each group.
#' @param significance Add pairwise Wilcoxon comparisons. `TRUE` compares
#'   every pair; a list such as `list(c("A", "B"))` compares those pairs only.
#' @param palette Palette name passed to [get_color()].
#' @param ylab,xlab,title Axis and plot labels.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#'
#' @seealso [plot_Boxplot()] for the box-only version.
#' @export
#' @examples
#' set.seed(1)
#' p <- plot_violin(c(rnorm(40), rnorm(40, 1)), rep(c("A", "B"), each = 40))
plot_violin <- function(value, group, order = NULL,
                        show = c("violin", "box", "both"),
                        points = TRUE, points_maximum = 300,
                        show_n = TRUE, significance = FALSE,
                        palette = "house", ylab = NULL, xlab = NULL,
                        title = NULL, font = "Arial") {
  show <- match.arg(show)
  check_numeric(value, "value")
  check_length(value, group, "value", "group")
  keep <- !is.na(value) & !is.na(group)
  dropped <- sum(!keep)
  if (dropped > 0) {
    cli::cli_inform("Dropping {dropped} observation{?s} without a value and a group.")
  }
  value <- value[keep]
  group <- as.character(group[keep])
  if (length(value) < 2) {
    cli::cli_abort("At least two observations are required.")
  }

  levels_used <- if (is.null(order)) unique(group) else as.character(order)
  missing_levels <- setdiff(unique(group), levels_used)
  if (length(missing_levels) > 0) {
    cli::cli_abort(c(
      "{.arg order} does not name every group.",
      i = "Missing: {.val {missing_levels}}."
    ))
  }
  plot_df <- data.frame(
    value = value,
    group = factor(group, levels = intersect(levels_used, unique(group)))
  )
  colors <- if (identical(tolower(palette), "house")) {
    gfplot_group_colors(levels(plot_df$group))
  } else {
    stats::setNames(
      get_color(palette, nlevels(plot_df$group)), levels(plot_df$group)
    )
  }

  p <- ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data$group, y = .data$value, fill = .data$group)
  )
  if (show %in% c("violin", "both")) {
    # trim = TRUE ends the violin at the observed extremes. With trim = FALSE
    # the density tails extend past the data and collide with anything drawn
    # below the groups, such as the observation counts.
    p <- p + ggplot2::geom_violin(
      colour = NA, alpha = 0.55, scale = "width", trim = TRUE
    )
  }
  if (show %in% c("box", "both")) {
    p <- p + ggplot2::geom_boxplot(
      width = 0.14, outlier.shape = NA, alpha = 0.9,
      colour = unname(gfplot_colors("text"))
    )
  }
  if (isTRUE(points) && nrow(plot_df) <= points_maximum) {
    p <- p + ggplot2::geom_jitter(
      width = 0.12, size = 0.7, alpha = 0.5,
      colour = unname(gfplot_colors("text"))
    )
  }
  p <- p +
    ggplot2::scale_fill_manual(values = colors, guide = "none") +
    gfplot_theme(font = font, grid = FALSE, border = FALSE, legend = "none") +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) +
    ggplot2::labs(x = xlab, y = ylab, title = title)

  if (isTRUE(show_n)) {
    counts <- as.data.frame(table(plot_df$group))
    names(counts) <- c("group", "n")
    counts$label <- paste0("n = ", counts$n)
    span <- diff(range(plot_df$value, na.rm = TRUE))
    floor_ <- min(plot_df$value) - 0.08 * span
    counts$y <- floor_
    p <- p + ggplot2::scale_y_continuous(
      limits = c(floor_, NA),
      expand = ggplot2::expansion(mult = c(0.02, 0.05))
    )
    p <- p + ggplot2::geom_text(
      data = counts,
      ggplot2::aes(x = .data$group, y = .data$y, label = .data$label),
      inherit.aes = FALSE,
      size = 2.6, family = font,
      colour = unname(gfplot_colors("muted"))
    )
  }

  if (!isFALSE(significance) && nlevels(plot_df$group) > 1) {
    if (!requireNamespace("ggsignif", quietly = TRUE)) {
      cli::cli_inform(c(
        "Skipping significance brackets: {.pkg ggsignif} is not installed.",
        i = "Install it with {.run install.packages(\"ggsignif\")}."
      ))
    } else {
      pairs <- if (isTRUE(significance)) {
        utils::combn(levels(plot_df$group), 2, simplify = FALSE)
      } else {
        lapply(significance, as.character)
      }
      p <- p + ggsignif::geom_signif(
        comparisons = pairs, test = "wilcox.test",
        map_signif_level = TRUE, textsize = 2.6
      )
    }
  }
  p
}
