# Figures for differential and response data.

#' Volcano plot
#'
#' Effect size against significance, with the calling thresholds drawn. This
#' is the standard first look at a differential analysis: it separates the
#' features that moved a lot from the ones that moved reliably, and shows how
#' many of each the thresholds produce.
#'
#' @param effect Numeric effect sizes, typically a log fold change.
#' @param p_value Significance values on the same scale as `p_threshold`.
#' @param label Feature labels.
#' @param effect_threshold,p_threshold Calling thresholds. Features past both
#'   are labelled as significant.
#' @param label_top Label the most significant features instead of every
#'   significant one. Set to `0` to label none, or `Inf` to label all.
#' @param palette Palette name passed to [get_color()].
#' @param repel Repel the labels so they do not overlap.
#' @param xlab,ylab,title Axis and plot labels.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#'
#' @export
#' @examples
#' set.seed(1)
#' effect <- rnorm(2000)
#' p_value <- runif(2000)^2
#' p <- plot_volcano(effect, p_value, paste0("gene", seq_along(effect)))
plot_volcano <- function(effect, p_value, label = NULL,
                         effect_threshold = 1, p_threshold = 0.05,
                         label_top = 10, palette = "house", repel = TRUE,
                         xlab = "Effect size", ylab = expression(-log[10]~italic(P)),
                         title = NULL, font = "Arial") {
  check_length(effect, p_value, "effect", "p_value")
  if (is.null(label)) {
    label <- as.character(seq_along(effect))
  }
  check_length(effect, label, "effect", "label")
  if (p_threshold <= 0 || p_threshold >= 1) {
    cli::cli_abort("{.arg p_threshold} must be strictly between 0 and 1.")
  }
  if (effect_threshold < 0) {
    cli::cli_abort("{.arg effect_threshold} must not be negative.")
  }

  keep <- !is.na(effect) & !is.na(p_value) & p_value > 0
  if (sum(keep) < 2) {
    cli::cli_abort("At least two features with an effect and a p-value are required.")
  }
  dropped <- sum(!keep)
  if (dropped > 0) {
    cli::cli_inform("Dropping {dropped} feature{?s} without a usable effect and p-value.")
  }

  plot_df <- data.frame(
    label = as.character(label[keep]),
    effect = as.numeric(effect[keep]),
    significance = -log10(as.numeric(p_value[keep])),
    stringsAsFactors = FALSE
  )
  threshold_line <- -log10(p_threshold)
  plot_df$class <- ifelse(
    plot_df$significance >= threshold_line &
      abs(plot_df$effect) >= effect_threshold,
    ifelse(plot_df$effect > 0, "Up", "Down"),
    "Not significant"
  )
  plot_df$class <- factor(
    plot_df$class, levels = c("Up", "Down", "Not significant")
  )

  shown <- plot_df[plot_df$class != "Not significant", , drop = FALSE]
  shown <- shown[order(-shown$significance), , drop = FALSE]
  if (is.finite(label_top)) {
    shown <- utils::head(shown, label_top)
  }

  colors <- c(
    Up = unname(gfplot_colors("tertiary")),
    Down = unname(gfplot_colors("primary")),
    `Not significant` = unname(gfplot_colors("neutral_mid"))
  )
  p <- ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data$effect, y = .data$significance, colour = .data$class)
  ) +
    ggplot2::geom_vline(
      xintercept = c(-effect_threshold, effect_threshold),
      colour = unname(gfplot_colors("reference_line")),
      linetype = "dashed", linewidth = 0.35
    ) +
    ggplot2::geom_hline(
      yintercept = threshold_line,
      colour = unname(gfplot_colors("reference_line")),
      linetype = "dashed", linewidth = 0.35
    ) +
    ggplot2::geom_point(size = 1, alpha = 0.75) +
    ggplot2::scale_colour_manual(
      values = colors,
      guide = gfplot_legend(names(colors))
    ) +
    gfplot_theme(font = font, border = FALSE) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) +
    ggplot2::labs(x = xlab, y = ylab, title = title)

  if (nrow(shown) > 0) {
    p <- p + if (isTRUE(repel) && requireNamespace("ggrepel", quietly = TRUE)) {
      ggrepel::geom_text_repel(
        data = shown,
        ggplot2::aes(label = .data$label),
        size = 2.5, family = font, segment.size = 0.2,
        min.segment.length = 0, max.overlaps = 20,
        colour = unname(gfplot_colors("text"))
      )
    } else {
      ggplot2::geom_text(
        data = shown,
        ggplot2::aes(label = .data$label),
        size = 2.5, family = font, vjust = -0.6,
        colour = unname(gfplot_colors("text"))
      )
    }
  }
  p
}

#' Waterfall plot of response
#'
#' Patients ranked by response, with the bar height showing how far each
#' departed from baseline and the fill showing the response category. This is
#' the standard display of response in a single-arm trial.
#'
#' @param response Numeric response values, for example a percentage change
#'   from baseline. `NA` values are dropped.
#' @param category Optional response category per patient, used to fill the
#'   bars. Defaults to the RECIST-style cut-offs, where -30 and 20 percent
#'   separate partial response, stable disease, and progression.
#' @param patient Optional patient labels, used on the x axis when few enough
#'   bars are drawn to read them.
#' @param label_top Label this many of the largest and smallest bars, which is
#'   what a reader wants from a dense waterfall.
#' @param thresholds Cut-offs between response categories, as a named vector
#'   such as `c("Partial response" = -30, "Stable disease" = 20)`. Values at
#'   or below the first are partial response and values above the last are
#'   progression.
#' @param threshold_labels Print the cut-off lines and their values.
#' @param show_patients Print patient labels under the bars.
#' @param palette Palette name passed to [get_color()].
#' @param xlab,ylab,title Axis and plot labels.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#'
#' @export
#' @examples
#' set.seed(1)
#' response <- c(rnorm(40, -10, 20), rnorm(10, 40, 15))
#' p <- plot_waterfall(response)
plot_waterfall <- function(response, category = NULL, patient = NULL,
                           label_top = 0,
                           thresholds = c(
                             "Partial response" = -30,
                             "Stable disease" = 20
                           ),
                           threshold_labels = TRUE,
                           show_patients = FALSE,
                           palette = "house",
                           xlab = NULL, ylab = "Change from baseline (%)",
                           title = NULL, font = "Arial") {
  if (!is.numeric(response)) {
    cli::cli_abort("{.arg response} must be numeric.")
  }
  keep <- !is.na(response)
  dropped <- sum(!keep)
  if (dropped > 0) {
    cli::cli_inform("Dropping {dropped} patient{?s} without a response value.")
  }
  response <- response[keep]
  if (length(response) < 2) {
    cli::cli_abort("At least two patients are required.")
  }
  if (is.null(patient)) {
    patient <- as.character(seq_along(response))
  } else {
    check_length(patient, keep, "patient", "response")
    patient <- as.character(patient[keep])
  }
  if (is.null(category)) {
    category <- gfplot_response_category(response, thresholds)
  } else {
    check_length(category, keep, "category", "response")
    category <- as.character(category[keep])
  }

  order_index <- order(response, decreasing = TRUE)
  plot_df <- data.frame(
    patient = factor(patient[order_index], levels = patient[order_index]),
    response = response[order_index],
    category = category[order_index]
  )
  category_levels <- c(
    names(thresholds), "Progressive disease"
  )
  present <- category_levels[category_levels %in% unique(plot_df$category)]
  plot_df$category <- factor(
    plot_df$category,
    levels = c(setdiff(unique(plot_df$category), present), present)
  )

  fill <- gfplot_response_colors(levels(plot_df$category))
  p <- ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data$patient, y = .data$response, fill = .data$category)
  ) +
    ggplot2::geom_col(width = 0.85) +
    ggplot2::geom_hline(
      yintercept = 0,
      colour = unname(gfplot_colors("reference_line")),
      linewidth = 0.4
    ) +
    ggplot2::scale_fill_manual(
      values = fill,
      guide = gfplot_legend(levels(plot_df$category))
    ) +
    gfplot_theme(font = font, border = FALSE) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5)
    ) +
    ggplot2::labs(x = xlab, y = ylab, title = title)

  if (isTRUE(threshold_labels) && length(thresholds) > 0) {
    # The bars run from the largest response on the left to the smallest on
    # the right, so a positive cut-off is labelled in the empty right margin
    # and a negative one in the empty left margin. Labelling both on the same
    # side would put the lower label on top of the deepest bars.
    lines <- data.frame(
      value = unname(thresholds),
      x = ifelse(unname(thresholds) > 0, nrow(plot_df), 1),
      hjust = ifelse(unname(thresholds) > 0, 1.02, -0.02)
    )
    p <- p +
      ggplot2::geom_hline(
        data = lines,
        ggplot2::aes(yintercept = .data$value),
        colour = unname(gfplot_colors("muted")),
        linetype = "dashed", linewidth = 0.35
      )
    for (index in seq_len(nrow(lines))) {
      p <- p + ggplot2::annotate(
        "text",
        x = lines$x[index], y = lines$value[index],
        label = paste0(
          names(thresholds)[index], " (", lines$value[index], "%)"
        ),
        hjust = lines$hjust[index], vjust = -0.5, size = 2.5, family = font,
        colour = unname(gfplot_colors("muted"))
      )
    }
  }

  if (isTRUE(show_patients)) {
    p <- p + ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = 90, hjust = 1, vjust = 0.5, size = 6
      ),
      axis.ticks.x = ggplot2::element_line()
    )
  }

  if (label_top > 0 && nrow(plot_df) > 0) {
    label_index <- unique(c(
      utils::head(order(-plot_df$response), label_top),
      utils::head(order(plot_df$response), label_top)
    ))
    p <- p + ggplot2::geom_text(
      data = plot_df[label_index, , drop = FALSE],
      ggplot2::aes(label = .data$patient),
      # A bar that grows downward needs its label underneath, or the text
      # lands inside the bar and collides with the cut-off lines.
      size = 2.3, family = font,
      vjust = ifelse(plot_df$response[label_index] > 0, -0.6, 1.6),
      colour = unname(gfplot_colors("text"))
    )
  }
  p
}

# Assign each patient to a response category from the cut-offs.
gfplot_response_category <- function(response, thresholds) {
  if (length(thresholds) == 0) {
    return(rep("Response", length(response)))
  }
  breaks <- c(-Inf, unname(thresholds), Inf)
  labels <- c(names(thresholds), "Progressive disease")
  as.character(cut(response, breaks = breaks, labels = labels))
}

# Category colours: better response takes the model colour, worse takes the
# comparator colour, so the direction reads without consulting the legend.
gfplot_response_colors <- function(categories) {
  roles <- c(
    "Partial response" = "primary",
    "Stable disease" = "quaternary",
    "Progressive disease" = "tertiary",
    "Response" = "primary"
  )
  values <- vapply(categories, function(category) {
    # Single-bracket lookup, because `[[` errors on a name that is absent and
    # a caller may supply categories of their own.
    role <- if (category %in% names(roles)) {
      unname(roles[category])
    } else {
      "neutral_mid"
    }
    unname(gfplot_colors(role))
  }, character(1))
  stats::setNames(values, categories)
}
