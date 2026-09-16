#' Forest plot of effect estimates
#'
#' Draws point estimates with confidence intervals on a horizontal axis, with
#' the numbers printed alongside. This is the standard display for hazard
#' ratios, odds ratios, and mean differences, and it reads a table straight
#' from `clinstats::cox_table()` or `clinstats::logistic_table()`.
#'
#' @param data Data frame holding the estimates.
#' @param term Column of row labels, one per estimate.
#' @param estimate Column of point estimates.
#' @param lower,upper Columns of the confidence limits.
#' @param p Optional column of p-values, shown as a right-hand column.
#' @param group Optional column naming the section each estimate belongs to.
#'   Sections are drawn as facets with a shared axis.
#' @param label Optional column overriding `term` for display, for example a
#'   formatted "Age, per year" instead of a variable name.
#' @param log_scale Plot the axis on a log scale, which is what ratios need so
#'   that a halving and a doubling are the same distance.
#' @param ref_line Value of the reference line. Defaults to 1 when
#'   `log_scale = TRUE` and 0 otherwise.
#' @param estimate_label Column heading for the estimate table.
#' @param p_label Column heading for the p-value column.
#' @param show_table Print the estimate and p-value columns.
#' @param digits Significant digits for the printed numbers.
#' @param xlab,title Axis and plot labels.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object, or a composed panel when `show_table = TRUE`,
#'   as with the risk table of [plot_KMCurve()]. Both print and save the same
#'   way.
#'
#' @seealso [gfplot_spec()] to build the same figure as a value. The companion
#'   package `clinstats` produces the estimates this draws.
#' @export
#' @examples
#' effects <- data.frame(
#'   term = c("Age, per year", "Stage III vs II", "MSI-high"),
#'   hr = c(1.02, 1.84, 0.62),
#'   lower = c(0.99, 1.51, 0.44),
#'   upper = c(1.05, 2.24, 0.88),
#'   p = c(0.21, 4.1e-07, 0.008)
#' )
#' p <- plot_forest(
#'   effects,
#'   term = "term", estimate = "hr", lower = "lower", upper = "upper",
#'   p = "p", log_scale = TRUE
#' )
#'
#' # Straight from a clinstats table
#' \donttest{
#' if (requireNamespace("clinstats", quietly = TRUE)) {
#'   tbl <- clinstats::cox_table(
#'     clinstats::clin_crc,
#'     time = "rfs.delay", event = "rfs.event",
#'     factors = c("sex", "age", "tnm.stage"), multivariable = "none"
#'   )
#'   p <- plot_forest(
#'     tbl,
#'     term = "term", estimate = "hr_univariable",
#'     lower = "univ_ci_lower", upper = "univ_ci_upper", p = "univ_p",
#'     log_scale = TRUE
#'   )
#' }
#' }
plot_forest <- function(data, term, estimate, lower, upper, p = NULL,
                        group = NULL, label = NULL,
                        log_scale = FALSE, ref_line = NULL,
                        estimate_label = "Estimate (95% CI)",
                        p_label = "P",
                        show_table = TRUE, digits = 2,
                        xlab = NULL, title = NULL, font = "Arial") {
  check_columns(data, c(term, estimate, lower, upper))
  for (optional in c(p, group, label)) {
    if (!is.null(optional)) {
      check_columns(data, optional)
    }
  }

  plot_df <- forest_prepare(
    data, term, estimate, lower, upper, p = p, group = group, label = label
  )
  if (any(plot_df$lower > plot_df$upper)) {
    cli::cli_abort(c(
      "Some confidence intervals have a lower limit above the upper limit.",
      i = "Check the {.arg lower} and {.arg upper} columns."
    ))
  }
  if (isTRUE(log_scale) && any(plot_df$lower <= 0, na.rm = TRUE)) {
    cli::cli_abort(c(
      "A log axis needs positive confidence limits.",
      i = "Set {.code log_scale = FALSE}, or use a difference scale for these estimates."
    ))
  }

  if (is.null(ref_line)) {
    ref_line <- if (isTRUE(log_scale)) 1 else 0
  }
  if (is.null(xlab)) {
    xlab <- if (isTRUE(log_scale)) "Estimate (log scale)" else "Estimate"
  }

  colors <- gfplot_colors(c("primary", "reference_line", "muted", "text"))

  p <- ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data$estimate, y = .data$row)
  ) +
    ggplot2::geom_vline(
      xintercept = ref_line,
      colour = unname(colors[["reference_line"]]),
      linetype = "dashed",
      linewidth = 0.4
    ) +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = .data$lower, xmax = .data$upper),
      orientation = "y",
      width = 0.18,
      colour = unname(colors[["primary"]]),
      linewidth = 0.5
    ) +
    ggplot2::geom_point(
      size = 2, colour = unname(colors[["primary"]])
    ) +
    ggplot2::scale_y_continuous(
      breaks = plot_df$row,
      labels = plot_df$term,
      # Extra room above the top estimate for the table headings.
      expand = ggplot2::expansion(add = c(0.6, 1.5))
    ) +
    gfplot_theme(font = font, grid = FALSE, legend = "none") +
    ggplot2::theme(
      axis.title.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank()
    ) +
    ggplot2::labs(x = xlab, title = title)

  if (isTRUE(log_scale)) {
    p <- p + ggplot2::scale_x_log10()
  } else {
    p <- p + ggplot2::scale_x_continuous()
  }

  if (!is.null(group)) {
    p <- p +
      ggplot2::facet_grid(
        group ~ ., scales = "free_y", space = "free_y", switch = "y"
      ) +
      ggplot2::theme(
        strip.placement = "outside",
        strip.background = ggplot2::element_blank(),
        strip.text.y.left = ggplot2::element_text(
          angle = 0,
          face = "bold",
          hjust = 1,
          family = font,
          colour = unname(colors[["text"]])
        )
      )
  }

  if (!isTRUE(show_table)) {
    return(p)
  }

  # The numbers are a separate panel rather than text placed inside the plot:
  # their width is measured in characters, and a text layer would have to be
  # positioned in data units, which changes meaning between a linear and a log
  # axis. Composing two panels lets each use the coordinate system it needs.
  # plot_KMCurve() composes its risk table the same way.
  table_panel <- forest_table_panel(
    plot_df, digits, estimate_label, p_label, font
  )
  gfplot_assemble(
    cowplot::plot_grid(
      p + ggplot2::theme(
        plot.margin = ggplot2::margin(9, 4, 8, 10, unit = "pt")
      ),
      table_panel,
      ncol = 2,
      rel_widths = c(1, forest_table_width(plot_df, estimate_label, p_label)),
      align = "h",
      axis = "tb"
    ),
    font
  )
}

# Turn a table of estimates into the frame the plot and the number panel
# share. Rows without an interval are dropped with a notice, and the first
# supplied term becomes the top row, which is how a table reads.
forest_prepare <- function(data, term, estimate, lower, upper, p = NULL,
                           group = NULL, label = NULL) {
  plot_df <- data.frame(
    term = as.character(data[[term]]),
    estimate = as.numeric(data[[estimate]]),
    lower = as.numeric(data[[lower]]),
    upper = as.numeric(data[[upper]]),
    stringsAsFactors = FALSE
  )
  if (!is.null(label)) {
    plot_df$term <- as.character(data[[label]])
  }
  if (!is.null(p)) {
    plot_df$p <- suppressWarnings(as.numeric(data[[p]]))
  }
  if (!is.null(group)) {
    plot_df$group <- as.character(data[[group]])
  }

  usable <- stats::complete.cases(plot_df[, c("estimate", "lower", "upper")])
  if (!all(usable)) {
    cli::cli_inform(
      "Dropping {sum(!usable)} row{?s} with an incomplete estimate or interval."
    )
    plot_df <- plot_df[usable, , drop = FALSE]
  }
  if (nrow(plot_df) == 0) {
    cli::cli_abort(
      "No estimate has both a point value and a confidence interval."
    )
  }
  plot_df$row <- rev(seq_len(nrow(plot_df)))
  plot_df
}

# Width of the number panel relative to the plot panel, estimated from the
# widest printed cell so the two panels keep their proportions at any size.
forest_table_width <- function(plot_df, estimate_label, p_label) {
  estimate_width <- max(nchar(sprintf("%.2f (%.2f-%.2f)",
    plot_df$estimate, plot_df$lower, plot_df$upper)))
  if (nzchar(estimate_label)) {
    estimate_width <- max(estimate_width, nchar(estimate_label))
  }
  total <- estimate_width
  if (!is.null(plot_df$p)) {
    p_width <- max(
      nchar(format_p_values(plot_df$p)),
      if (nzchar(p_label)) nchar(p_label) else 0L
    )
    total <- estimate_width + 2 + p_width
  }
  # The panel needs to be about as wide as its text; the main plot keeps the
  # rest, with a floor so the intervals stay readable.
  max(0.22, min(0.55, total / (total + 34)))
}

# The numbers column, drawn as its own panel with the same row positions as
# the plot so the two line up.
#
# Column x positions and the panel width are both derived from character
# counts, so the columns keep their proportions as the text grows. The x scale
# runs 0 to 1 across the panel; a column placed at the character offset of its
# first character lands where it would in a fixed-width table.
forest_table_panel <- function(plot_df, digits, estimate_label, p_label, font) {
  text_color <- unname(gfplot_colors("text"))
  estimate_text <- sprintf(
    paste0("%.", digits, "f (%.", digits, "f-%.", digits, "f)"),
    plot_df$estimate, plot_df$lower, plot_df$upper
  )
  estimate_chars <- max(
    nchar(estimate_text),
    if (nzchar(estimate_label)) nchar(estimate_label) else 0L
  )
  # Two spaces between columns, then the p-value column.
  p_offset <- (estimate_chars + 2)
  total_chars <- estimate_chars + 2
  if (!is.null(plot_df$p)) {
    p_chars <- max(
      nchar(format_p_values(plot_df$p)),
      if (nzchar(p_label)) nchar(p_label) else 0L
    )
    total_chars <- p_offset + p_chars
  }
  p_x <- if (is.null(plot_df$p)) NA_real_ else p_offset / total_chars
  head_x <- 0

  rows <- data.frame(
    row = plot_df$row,
    estimate = estimate_text,
    stringsAsFactors = FALSE
  )
  if (!is.null(plot_df$p)) {
    rows$p <- format_p_values(plot_df$p)
  }
  if (!is.null(plot_df$group)) {
    rows$group <- plot_df$group
  }

  panel <- ggplot2::ggplot(rows, ggplot2::aes(y = .data$row)) +
    gfplot_theme(font = font, grid = FALSE, border = FALSE, legend = "none") +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(9, 2, 8, 4, unit = "pt")
    )

  # A layer that does not carry the facet variable is drawn in every panel, so
  # the group column is included whenever the figure is faceted.
  add_text <- function(x, y, label, bold = FALSE, group = NULL) {
    layer_data <- data.frame(x = x, y = y, label = label)
    if (!is.null(group)) {
      layer_data$group <- group
    }
    ggplot2::geom_text(
      data = layer_data,
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
      hjust = 0, size = 3.1, family = font,
      fontface = if (bold) "bold" else "plain",
      colour = text_color, inherit.aes = FALSE
    )
  }

  groups <- rows$group
  # One heading per facet, placed just above that facet's top row.
  header <- if (is.null(groups)) {
    data.frame(y = max(rows$row) + 0.9)
  } else {
    tops <- tapply(rows$row, groups, max)
    data.frame(
      y = as.numeric(tops) + 0.9,
      group = names(tops),
      stringsAsFactors = FALSE
    )
  }
  header_group <- header$group

  if (nzchar(estimate_label)) {
    panel <- panel +
      add_text(head_x, header$y, estimate_label, bold = TRUE,
               group = header_group) +
      add_text(head_x, plot_df$row, estimate_text, group = groups)
  }
  if (!is.null(rows$p)) {
    if (nzchar(p_label)) {
      panel <- panel +
        add_text(p_x, header$y, p_label, bold = TRUE, group = header_group)
    }
    panel <- panel +
      add_text(p_x, plot_df$row, format_p_values(plot_df$p), group = groups)
  }

  panel <- panel +
    ggplot2::scale_x_continuous(limits = c(0, 1), expand = c(0, 0)) +
    ggplot2::scale_y_continuous(
      breaks = plot_df$row, labels = plot_df$term,
      expand = ggplot2::expansion(add = c(0.6, 1.5))
    )

  if (!is.null(rows$group)) {
    panel <- panel +
      ggplot2::facet_grid(
        group ~ ., scales = "free_y", space = "free_y"
      ) +
      ggplot2::theme(strip.text.y = ggplot2::element_blank())
  }
  panel
}

format_p_values <- function(p) {
  vapply(p, function(value) {
    if (is.na(value)) {
      return("")
    }
    if (value < 0.001) {
      "<0.001"
    } else {
      sprintf("%.3f", value)
    }
  }, character(1))
}

# Family hooks -----------------------------------------------------------

validate_forest_spec <- function(spec) {
  required <- c("data", "term", "estimate", "lower", "upper")
  missing <- setdiff(required, names(spec$args))
  if (length(missing) > 0) {
    cli::cli_abort(c(
      "The {.val forest} specification is missing {.arg {missing}}.",
      i = "Required arguments: {.val {required}}."
    ))
  }
  data <- spec$args$data
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }
  columns <- unlist(spec$args[c("term", "estimate", "lower", "upper")])
  columns <- c(columns, unlist(spec$args[c("p", "group", "label")]))
  check_columns(data, as.character(columns))
  spec
}

render_forest_spec <- function(spec) {
  args <- spec$args
  do.call(plot_forest, args)
}
