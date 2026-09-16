# Figures whose data is a matrix rather than a column.

#' Heatmap of a matrix
#'
#' Draws the values of a matrix as tiles with a colourbar. This is the display
#' for correlation matrices, signature scores by group, and any rectangular
#' table of values where the pattern matters more than the numbers.
#'
#' @param matrix Numeric matrix, or a data frame whose columns are numeric.
#' @param row_order,column_order Optional ordering of rows and columns. Use
#'   `"cluster"` to order by hierarchical clustering, `"value"` to order by
#'   the first principal component, or supply a character vector of names.
#' @param values Print the numeric value in each tile.
#' @param digits Significant digits for the printed values.
#' @param midpoint Value mapped to the middle of the colourbar. Defaults to the
#'   median, which centres a diverging scale on a typical value.
#' @param diverging Use a diverging scale, for values that have a meaningful
#'   centre such as a correlation.
#' @param low,mid,high Colours for the low, middle, and high ends.
#' @param legend_label Title of the colourbar.
#' @param title Plot title.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#'
#' @export
#' @examples
#' set.seed(1)
#' m <- cor(matrix(rnorm(60), nrow = 20))
#' diag(m) <- NA
#' p <- plot_heatmap(m, diverging = TRUE, midpoint = 0,
#'                   legend_label = "Correlation")
plot_heatmap <- function(matrix, row_order = NULL, column_order = NULL,
                         values = FALSE, digits = 2, midpoint = NULL,
                         diverging = FALSE, low = NULL, mid = NULL, high = NULL,
                         legend_label = "Value", title = NULL, font = "Arial") {
  m <- as.matrix(matrix)
  if (!is.numeric(m)) {
    cli::cli_abort("{.arg matrix} must be numeric.")
  }
  if (is.null(rownames(m))) {
    rownames(m) <- as.character(seq_len(nrow(m)))
  }
  if (is.null(colnames(m))) {
    colnames(m) <- as.character(seq_len(ncol(m)))
  }

  m <- m[gfplot_matrix_order(m, row_order, margin = 1), , drop = FALSE]
  m <- m[, gfplot_matrix_order(m, column_order, margin = 2), drop = FALSE]

  plot_df <- data.frame(
    row = factor(rep(rownames(m), times = ncol(m)), levels = rev(rownames(m))),
    column = factor(rep(colnames(m), each = nrow(m)), levels = colnames(m)),
    value = as.vector(m)
  )

  if (is.null(midpoint)) {
    midpoint <- if (isTRUE(diverging)) {
      0
    } else {
      stats::median(m, na.rm = TRUE)
    }
  }
  limits <- range(m, na.rm = TRUE)
  if (isTRUE(diverging)) {
    # Keep the colourbar symmetric about the midpoint so equal distances read
    # as equal colours.
    span <- max(abs(limits - midpoint))
    limits <- c(midpoint - span, midpoint + span)
  }
  if (is.null(low)) {
    low <- if (isTRUE(diverging)) "#2A6F97" else unname(gfplot_colors("light"))
  }
  if (is.null(mid)) {
    mid <- if (isTRUE(diverging)) "#F7F7F7" else unname(gfplot_colors("primary"))
  }
  if (is.null(high)) {
    high <- if (isTRUE(diverging)) "#B84A3A" else unname(gfplot_colors("tertiary"))
  }

  p <- ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data$column, y = .data$row, fill = .data$value)
  ) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.3) +
    gfplot_theme(font = font, grid = FALSE, border = FALSE) +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(
        angle = if (ncol(m) > 6) 45 else 0,
        hjust = if (ncol(m) > 6) 1 else 0.5
      ),
      panel.grid = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5)
    ) +
    ggplot2::labs(title = title, fill = legend_label)

  p <- p + if (isTRUE(diverging)) {
    ggplot2::scale_fill_gradient2(
      low = low, mid = mid, high = high, midpoint = midpoint, limits = limits,
      na.value = "grey92"
    )
  } else {
    ggplot2::scale_fill_gradient(
      low = low, high = high, limits = limits, na.value = "grey92"
    )
  }

  if (isTRUE(values)) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = gfplot_matrix_label(.data$value, digits)),
      size = 2.6, family = font,
      colour = unname(gfplot_colors("text"))
    )
  }
  p
}

# Order one margin of a matrix, by clustering, by first principal component,
# or by a supplied order.
gfplot_matrix_order <- function(m, order_spec, margin) {
  labels <- if (margin == 1) rownames(m) else colnames(m)
  size <- if (margin == 1) nrow(m) else ncol(m)
  if (is.null(order_spec) || size < 2) {
    return(seq_len(size))
  }
  if (is.character(order_spec) && length(order_spec) == 1) {
    if (identical(order_spec, "cluster")) {
      work <- if (margin == 1) m else t(m)
      work[is.na(work)] <- stats::median(work, na.rm = TRUE)
      distance <- stats::dist(work)
      if (any(!is.finite(distance))) {
        return(seq_len(size))
      }
      return(stats::hclust(distance, method = "complete")$order)
    }
    if (identical(order_spec, "value")) {
      work <- if (margin == 1) m else t(m)
      work[is.na(work)] <- stats::median(work, na.rm = TRUE)
      return(order(stats::prcomp(work)$x[, 1]))
    }
    order_spec <- strsplit(order_spec, ",")[[1]]
  }
  match(trimws(order_spec), labels)
}

gfplot_matrix_label <- function(value, digits) {
  ifelse(is.na(value), "", formatC(value, format = "g", digits = digits))
}

#' Confusion matrix
#'
#' Predicted against actual class, with the count in each cell. Percentages
#' are given per actual class, which is the direction that shows sensitivity
#' and specificity; overall percentages would hide a class the model misses.
#'
#' @param predicted,predicted_labels Predicted class labels.
#' @param actual,actual_labels Actual class labels. `actual` may also be a
#'   table or matrix of counts, in which case the labels are taken from its
#'   dimnames.
#' @param positive Value of the outcome that counts as the positive class,
#'   used to order and label the axes. With `positive` supplied, the two
#'   classes are shown as `"Negative"` and `"Positive"`; pass
#'   `predicted_labels` and `actual_labels` to name them differently.
#' @param show Which numbers to print: `"count"`, `"percent"` (by actual
#'   class), or `"both"`.
#' @param digits Significant digits for percentages.
#' @param title Plot title.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#'
#' @export
#' @examples
#' set.seed(1)
#' actual <- rbinom(200, 1, 0.4)
#' predicted <- ifelse(runif(200) < 0.8, actual, 1 - actual)
#' p <- plot_confusion(predicted, actual, positive = 1)
plot_confusion <- function(predicted = NULL, actual = NULL,
                           predicted_labels = NULL, actual_labels = NULL,
                           positive = NULL, show = c("count", "percent", "both"),
                           digits = 1, title = NULL, font = "Arial") {
  show <- match.arg(show)
  counts <- gfplot_confusion_counts(predicted, actual)
  if (nrow(counts) != 2 || ncol(counts) != 2) {
    cli::cli_abort(c(
      "{.fn plot_confusion} needs a two-by-two table.",
      i = "Found {nrow(counts)} predicted and {ncol(counts)} actual classes."
    ))
  }

  # A binary confusion matrix reads with the negative class first and the
  # positive class last, so the positive class lands on the right column and
  # the top row, which is where a reader looks for it.
  order_classes <- function(labels, fallback) {
    labels <- if (is.null(labels)) fallback else as.character(labels)
    if (!is.null(positive)) {
      original <- labels
      labels <- ifelse(labels == as.character(positive), "Positive", "Negative")
    }
    labels
  }
  predicted_names <- order_classes(predicted_labels, rownames(counts))
  actual_names <- order_classes(actual_labels, colnames(counts))
  if (!is.null(positive)) {
    counts <- counts[
      gfplot_positive_last(rownames(counts), positive),
      gfplot_positive_last(colnames(counts), positive),
      drop = FALSE
    ]
  }
  rownames(counts) <- predicted_names
  colnames(counts) <- actual_names

  per_actual <- sweep(counts, 2, colSums(counts), "/") * 100
  plot_df <- data.frame(
    predicted = factor(
      rep(rownames(counts), times = ncol(counts)), levels = rownames(counts)
    ),
    actual = factor(
      rep(colnames(counts), each = nrow(counts)), levels = colnames(counts)
    ),
    count = as.vector(counts),
    percent = as.vector(per_actual)
  )
  plot_df$label <- switch(show,
    count = as.character(plot_df$count),
    percent = paste0(formatC(plot_df$percent, format = "f", digits = digits), "%"),
    both = paste0(
      plot_df$count, "\n",
      formatC(plot_df$percent, format = "f", digits = digits), "%"
    )
  )

  # Shade by row percentage so the diagonal reads at a glance whatever the
  # class sizes are.
  ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data$actual, y = .data$predicted, fill = .data$percent)
  ) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.6) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$label),
      size = 3.4, family = font, lineheight = 1.1,
      colour = unname(gfplot_colors("text"))
    ) +
    ggplot2::scale_fill_gradient(
      low = unname(gfplot_colors("light")),
      high = unname(gfplot_colors("primary")),
      limits = c(0, 100)
    ) +
    # First level at the bottom, so the last level sits on top.
    ggplot2::scale_y_discrete(limits = rownames(counts)) +
    ggplot2::scale_x_discrete(limits = colnames(counts)) +
    gfplot_theme(font = font, grid = FALSE, border = FALSE, legend = "none") +
    ggplot2::theme(
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5)
    ) +
    ggplot2::labs(
      x = "Actual", y = "Predicted", title = title
    )
}

# Take either two label vectors or a table of counts.
gfplot_confusion_counts <- function(predicted, actual) {
  if (is.table(actual) || (is.matrix(actual) && is.null(predicted))) {
    counts <- as.matrix(actual)
    if (is.null(rownames(counts)) || is.null(colnames(counts))) {
      cli::cli_abort("A count table needs row and column names.")
    }
    return(counts)
  }
  if (is.null(predicted) || is.null(actual)) {
    cli::cli_abort(c(
      "Supply either {.arg predicted} and {.arg actual}, or a count table as {.arg actual}."
    ))
  }
  check_length(predicted, actual, "predicted", "actual")
  keep <- !is.na(predicted) & !is.na(actual)
  if (sum(keep) < 2) {
    cli::cli_abort("At least two complete observations are required.")
  }
  table(
    predicted = factor(predicted[keep]),
    actual = factor(actual[keep])
  )
}

gfplot_positive_last <- function(labels, positive) {
  labels <- as.character(labels)
  index <- which(labels == as.character(positive))
  if (length(index) != 1) {
    return(labels)
  }
  c(labels[-index], labels[index])
}
