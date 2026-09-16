#' Grouped bar plot with optional significance annotations
#'
#' Draws the mean of `value` per group with standard error bars, and adds
#' pairwise significance labels when `comparisons` is supplied.
#'
#' This function replaced the 0.1.0 `plot_barplot()`, which took no arguments
#' and could not be called.
#'
#' @param value Numeric values to summarise.
#' @param group Grouping vector, one value per observation.
#' @param comparisons Optional list of length-two vectors naming the groups to
#'   compare, for example `list(c("A", "B"))`.
#' @param palette Palette name passed to [get_color()].
#' @param color Optional vector of fill colours; overrides `palette`.
#' @param ylab,xlab,title Axis and plot labels.
#' @param font Font family used in the plot.
#' @param label Significance label style passed to
#'   [ggpubr::stat_compare_means()].
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' set.seed(1)
#' p <- plot_barplot(
#'   value = c(rnorm(20), rnorm(20, 1)),
#'   group = rep(c("A", "B"), each = 20)
#' )
#'
#' if (requireNamespace("ggpubr", quietly = TRUE)) {
#'   p <- plot_barplot(
#'     value = c(rnorm(20), rnorm(20, 1), rnorm(20, 2)),
#'     group = rep(c("A", "B", "C"), each = 20),
#'     comparisons = list(c("A", "B"), c("B", "C"))
#'   )
#' }
plot_barplot <- function(value, group, comparisons = NULL,
                         palette = "jama_classic", color = NULL,
                         ylab = "Score", xlab = NULL, title = NULL,
                         font = "Arial", label = "p.signif") {
  if (!is.factor(group)) {
    group <- factor(group)
  }
  df <- data.frame(value = value, group = group)
  if (is.null(color)) {
    color <- get_color(palette, nlevels(group))
  }

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = .data$group, y = .data$value, fill = .data$group)
  ) +
    ggplot2::stat_summary(
      geom = "bar", fun = mean, width = 0.5, color = NA
    ) +
    ggplot2::stat_summary(
      geom = "errorbar", fun.data = ggplot2::mean_se, width = 0.3
    ) +
    ggplot2::scale_fill_manual(values = color) +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.08))
    ) +
    cowplot::theme_cowplot(font_family = font) +
    ggplot2::theme(
      legend.position = "none",
      axis.title.x = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5)
    ) +
    ggplot2::labs(x = xlab, y = ylab, title = title)

  if (!is.null(comparisons)) {
    gfplot_require("ggpubr")
    p <- p + ggpubr::stat_compare_means(
      comparisons = comparisons, label = label
    )
  }
  p
}

#' Plot the correlation between two variables
#'
#' @param x,y Numeric vectors.
#' @param groups Optional grouping vector used to colour the points.
#' @param xlab,ylab Axis labels.
#' @param legend.pos Legend position.
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' p <- plot_cor(iris$Sepal.Length, iris$Sepal.Width)
plot_cor <- function(x, y, groups = NULL, xlab = NULL, ylab = NULL,
                     legend.pos = "top") {
  # stats::cor.test() returns the same Pearson r and p-value that
  # Hmisc::rcorr() did, including under missing values, without pulling in a
  # package of that size.
  estimate <- tryCatch(
    stats::cor.test(x, y),
    error = function(e) NULL,
    warning = function(w) NULL
  )
  pval <- if (is.null(estimate)) {
    "Correlation = NA"
  } else {
    paste(
      sprintf("Correlation = %.3f\nP", unname(estimate$estimate)),
      ifelse(
        estimate$p.value == 0,
        "< 1e-22",
        paste0("= ", signif(estimate$p.value, 3))
      )
    )
  }

  df.plot <- data.frame(a = x, b = y)
  p <- ggplot2::ggplot(df.plot, ggplot2::aes(x = .data$a, y = .data$b)) +
    ggplot2::geom_smooth(
      method = "lm", formula = y ~ x, se = FALSE,
      linetype = "dashed", colour = "grey50"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5),
      legend.title = ggplot2::element_blank(),
      legend.position = legend.pos
    ) +
    ggplot2::annotate(
      "text", x = Inf, y = Inf, hjust = 1, vjust = 1, label = pval
    ) +
    ggplot2::labs(x = xlab, y = ylab)

  if (!is.null(groups)) {
    df.plot$groups <- groups
    p$data <- df.plot
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(color = .data$groups), alpha = 0.5
      ) +
      ggplot2::scale_color_manual(
        values = get_color("jama_classic", length(unique(groups)))
      )
  } else {
    p <- p + ggplot2::geom_point(alpha = 0.5)
  }
  p
}

#' Principal component analysis plot
#'
#' @param data Matrix or data frame with samples in rows and features in
#'   columns.
#' @param labs Group labels, one per sample.
#' @param title Plot title.
#' @param palette Palette name passed to [get_color()].
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' set.seed(1)
#' p <- plot_PCA(matrix(rnorm(200), nrow = 20), rep(c("A", "B"), each = 10))
plot_PCA <- function(data, labs,
                     title = "Evaluate the batch effect between groups",
                     palette = "nature") {
  df <- data.frame(group = labs, data, check.names = FALSE)
  pca <- stats::prcomp(df[, -1])
  variance <- round(100 * pca$sdev^2 / sum(pca$sdev^2), 1)
  plot_df <- data.frame(
    group = labs,
    PC1 = pca$x[, 1],
    PC2 = pca$x[, 2]
  )
  groups <- levels(factor(labs))

  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data$PC1, y = .data$PC2, color = .data$group)
  ) +
    ggplot2::geom_point() +
    cowplot::theme_cowplot() +
    ggplot2::theme(
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5)
    ) +
    ggplot2::scale_color_manual(
      labels = groups,
      values = get_color(palette, length(groups))
    ) +
    ggplot2::labs(
      title = title,
      x = sprintf("PC1 (%.1f%%)", variance[1]),
      y = sprintf("PC2 (%.1f%%)", variance[2])
    )
}

#' UMAP projection plot
#'
#' @inheritParams plot_PCA
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("umap", quietly = TRUE)) {
#'   set.seed(1)
#'   p <- plot_UMAP(matrix(rnorm(200), nrow = 20), rep(c("A", "B"), each = 10))
#' }
#' }
plot_UMAP <- function(data, labs,
                      title = "Evaluate the batch effect between groups",
                      palette = "nature") {
  gfplot_require("umap")
  embedding <- umap::umap(data)
  df_plot <- data.frame(
    Group = labs,
    UMAP1 = embedding$layout[, 1],
    UMAP2 = embedding$layout[, 2],
    check.names = FALSE
  )
  groups <- levels(factor(labs))

  ggplot2::ggplot(
    df_plot,
    ggplot2::aes(x = .data$UMAP1, y = .data$UMAP2, color = .data$Group)
  ) +
    ggplot2::geom_point() +
    cowplot::theme_cowplot() +
    ggplot2::theme(
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5)
    ) +
    ggplot2::scale_color_manual(
      labels = groups,
      values = get_color(palette, length(groups))
    ) +
    ggplot2::ggtitle(title)
}

#' Plot a risk score ordered by patient
#'
#' @param rs Numeric risk scores. Names, when present, are used as patient
#'   identifiers.
#' @param event Event indicator used to fill the bars.
#' @param legend.position Legend position.
#' @param palette Palette name passed to [get_color()].
#' @param color Optional vector of fill colours; overrides `palette`.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' set.seed(1)
#' p <- plot_RiskScore(rnorm(30), rbinom(30, 1, 0.4))
plot_RiskScore <- function(rs, event, legend.position = c(0.2, 0.8),
                           palette = "jama", color = NULL, font = "Arial") {
  if (is.logical(event)) {
    event <- factor(
      event,
      levels = c(TRUE, FALSE),
      labels = c("Dead/Recurrence", "Disease free")
    )
  } else if (!is.factor(event)) {
    event <- factor(event)
  }
  if (is.null(names(rs))) {
    names(rs) <- seq_along(rs)
  }

  df <- data.frame(pt = names(rs), rs = rs, event = event)
  df <- df[order(df$rs), , drop = FALSE]
  df$pt <- factor(df$pt, levels = as.character(df$pt))

  if (is.null(color)) {
    color <- get_color(palette, nlevels(event))
  }

  ggplot2::ggplot(
    df,
    ggplot2::aes(x = .data$pt, y = .data$rs, fill = .data$event)
  ) +
    ggplot2::geom_bar(stat = "identity", alpha = 0.7) +
    cowplot::theme_cowplot(font_family = font) +
    ggplot2::ylab("Risk score") +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5),
      axis.text.x = ggplot2::element_blank(),
      axis.title.x = ggplot2::element_blank(),
      axis.line.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      legend.title = ggplot2::element_blank(),
      legend.position = legend.position,
      legend.key.width = ggplot2::unit(1, "cm")
    ) +
    ggplot2::scale_fill_manual(
      labels = levels(event), values = color
    )
}

#' Boxplot with optional pairwise significance annotations
#'
#' @param value Numeric values.
#' @param label Grouping vector.
#' @param palette Palette name passed to [get_color()].
#' @param title Plot title.
#' @param ylab Y-axis label.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' set.seed(1)
#' p <- plot_Boxplot(c(rnorm(20), rnorm(20, 1)), rep(c("A", "B"), each = 20))
plot_Boxplot <- function(value, label, palette = "nature", title = NULL,
                         ylab = "Expression", font = "Arial") {
  if (!is.factor(label)) {
    label <- factor(label)
  }
  df <- data.frame(value = value, label = label)

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = .data$label, y = .data$value, color = .data$label)
  ) +
    ggplot2::geom_boxplot() +
    cowplot::theme_cowplot(font_family = font) +
    ggplot2::theme(
      legend.position = "none",
      plot.title = ggplot2::element_text(hjust = 0.5)
    ) +
    ggplot2::scale_color_manual(
      values = get_color(palette, nlevels(label))
    ) +
    ggplot2::labs(x = NULL, y = ylab, title = title)

  if (nlevels(label) > 1 && requireNamespace("ggsignif", quietly = TRUE)) {
    pairs <- utils::combn(levels(label), 2, simplify = FALSE)
    p <- p + ggsignif::geom_signif(
      comparisons = pairs,
      test = "wilcox.test",
      map_signif_level = TRUE
    )
  }
  p
}
