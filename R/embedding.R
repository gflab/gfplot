#' Grouped embedding scatter
#'
#' Plot samples in a two-dimensional embedding, coloured by group. The
#' embedding can be supplied already computed, or computed here from a feature
#' matrix with [stats::prcomp()], \pkg{Rtsne}, or \pkg{umap}.
#'
#' `plot_PCA()` and `plot_UMAP()` are thin wrappers around this function, so a
#' figure keeps the same look whichever embedding it shows.
#'
#' @param data A feature matrix with samples in rows, or a two-column matrix of
#'   coordinates when `method = "none"`.
#' @param groups Group labels, one per sample.
#' @param method Embedding to compute: `"pca"`, `"tsne"`, `"umap"`, or
#'   `"none"` when `data` already holds coordinates.
#' @param perplexity Perplexity for t-SNE. Values much larger than the number
#'   of samples are rejected by the back end.
#' @param seed Optional seed for the stochastic embeddings.
#' @param ellipse Draw a confidence ellipse per group.
#' @param label_centres Label each group at the centre of its points.
#' @param palette Palette name passed to [get_color()].
#' @param title,xlab,ylab Axis and plot labels.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#'
#' @seealso [plot_PCA()], [plot_UMAP()]
#' @export
#' @examples
#' set.seed(1)
#' data <- matrix(rnorm(200), nrow = 20)
#' groups <- rep(c("A", "B"), each = 10)
#' p <- plot_embedding(data, groups, method = "pca")
plot_embedding <- function(data, groups, method = c("pca", "tsne", "umap", "none"),
                           perplexity = 30, seed = NULL, ellipse = FALSE,
                           label_centres = FALSE, palette = "house",
                           title = NULL, xlab = NULL, ylab = NULL,
                           font = "Arial") {
  method <- match.arg(method)
  data <- as.matrix(data)
  if (!is.numeric(data)) {
    cli::cli_abort("{.arg data} must be numeric.")
  }
  if (nrow(data) != length(groups)) {
    cli::cli_abort(c(
      "{.arg data} must have one row per sample.",
      x = "{.arg data} has {nrow(data)} rows.",
      x = "{.arg groups} has length {length(groups)}."
    ))
  }

  coordinates <- switch(method,
    none = {
      if (ncol(data) < 2) {
        cli::cli_abort(
          "With {.code method = \"none\"}, {.arg data} needs two columns of coordinates."
        )
      }
      list(x = data[, 1], y = data[, 2], xlab = "Component 1", ylab = "Component 2")
    },
    pca = {
      fit <- stats::prcomp(data)
      variance <- round(100 * fit$sdev^2 / sum(fit$sdev^2), 1)
      list(
        x = fit$x[, 1], y = fit$x[, 2],
        xlab = sprintf("PC1 (%.1f%%)", variance[1]),
        ylab = sprintf("PC2 (%.1f%%)", variance[2])
      )
    },
    tsne = {
      gfplot_require("Rtsne")
      # Rtsne needs perplexity below (n - 1) / 3. Checking here turns its
      # "perplexity is too large for the number of samples" into a message
      # that names a value the data can support.
      maximum <- (nrow(data) - 1) / 3
      if (perplexity >= maximum) {
        cli::cli_abort(c(
          "{.arg perplexity} is too large for {nrow(data)} samples.",
          x = "t-SNE needs perplexity below {(nrow(data) - 1) / 3} here.",
          i = "Use {.code perplexity = {max(2, floor(maximum / 2))}}, or supply more samples."
        ))
      }
      fit <- if (is.null(seed)) {
        Rtsne::Rtsne(data, perplexity = perplexity, check_duplicates = FALSE)
      } else {
        withr::with_seed(seed, Rtsne::Rtsne(
          data, perplexity = perplexity, check_duplicates = FALSE
        ))
      }
      list(x = fit$Y[, 1], y = fit$Y[, 2], xlab = "t-SNE 1", ylab = "t-SNE 2")
    },
    umap = {
      gfplot_require("umap")
      fit <- if (is.null(seed)) {
        umap::umap(data)
      } else {
        withr::with_seed(seed, umap::umap(data))
      }
      list(x = fit$layout[, 1], y = fit$layout[, 2], xlab = "UMAP 1", ylab = "UMAP 2")
    }
  )

  groups <- factor(groups)
  plot_df <- data.frame(
    x = coordinates$x, y = coordinates$y, group = groups
  )
  colors <- if (identical(tolower(palette), "house")) {
    gfplot_group_colors(levels(groups))
  } else {
    stats::setNames(get_color(palette, nlevels(groups)), levels(groups))
  }

  p <- ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data$x, y = .data$y, colour = .data$group)
  ) +
    ggplot2::geom_point(alpha = 0.8, size = 1.4) +
    ggplot2::scale_colour_manual(
      values = colors,
      guide = gfplot_legend(levels(groups))
    ) +
    gfplot_theme(font = font) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) +
    ggplot2::labs(
      x = xlab %||% coordinates$xlab,
      y = ylab %||% coordinates$ylab,
      title = title
    )

  if (isTRUE(ellipse)) {
    # A confidence ellipse needs more points than a degenerate spread can
    # support, so groups that are too small are skipped.
    sufficient <- names(which(table(groups) >= 4))
    if (length(sufficient) == 0) {
      cli::cli_inform(
        "Skipping ellipses: every group has fewer than four samples."
      )
    } else {
      p <- p + ggplot2::stat_ellipse(
        data = plot_df[plot_df$group %in% sufficient, , drop = FALSE],
        ggplot2::aes(x = .data$x, y = .data$y, colour = .data$group),
        type = "norm", level = 0.95, linewidth = 0.5
      )
    }
  }

  if (isTRUE(label_centres)) {
    centres <- stats::aggregate(
      cbind(x, y) ~ group, data = plot_df, FUN = stats::median
    )
    p <- p + ggplot2::geom_text(
      data = centres,
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$group),
      colour = unname(gfplot_colors("text")),
      size = 3.2, family = font, fontface = "bold"
    )
  }
  p
}
