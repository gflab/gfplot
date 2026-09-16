# Companion curves to the ROC plot.
#
# A discrimination figure answers "can the model rank patients?". These three
# answer the questions that follow: how does it behave when the positive class
# is rare (precision-recall), is it honest about the level it predicts
# (calibration), and does acting on it do more good than harm (decision
# curve). They share the binary-outcome handling of plot_ROC().

#' Precision-recall curve
#'
#' Precision against recall for a binary outcome. On an imbalanced outcome the
#' ROC curve can look encouraging while precision stays low, which is what
#' this plot exposes: it is the recommended companion when the event is rare.
#'
#' @inheritParams plot_ROC
#' @param positive Percentile of the scores above which the positive class is
#'   expected. Used only to draw the no-skill reference line, which is the
#'   prevalence of the positive class.
#' @param show_auc Print the area under the curve, computed by the trapezoid
#'   rule, in the legend.
#'
#' @return A `ggplot` object.
#'
#' @seealso [plot_ROC()] for discrimination, [plot_calibration()] for the level
#'   of the predictions.
#' @export
#' @examples
#' set.seed(1)
#' outcome <- rbinom(200, 1, 0.15)
#' score <- outcome * 0.8 + rnorm(200)
#' p <- plot_pr_curve(score, outcome)
plot_pr_curve <- function(scores, labels, positive = NULL,
                          palette = "house", title = NULL, font = "Arial",
                          show_auc = TRUE) {
  markers <- gfplot_marker_list(scores)
  y <- resolve_binary_outcome(labels, positive)
  check_length(markers[[1]], y, "scores", "labels")
  ok <- !is.na(y)
  for (name in names(markers)) {
    ok <- ok & !is.na(markers[[name]])
  }
  if (sum(ok) < 2 || length(unique(y[ok])) < 2) {
    cli::cli_abort("At least one observation from each outcome class is required.")
  }
  prevalence <- sum(y[ok] == 1) / sum(ok)

  curves <- do.call(rbind, lapply(names(markers), function(name) {
    gfplot_precision_recall(markers[[name]][ok], y[ok], name)
  }))
  annot <- vapply(names(markers), function(name) {
    part <- curves[curves$group == name, , drop = FALSE]
    if (!isTRUE(show_auc)) {
      return(name)
    }
    # Trapezoid rule over recall, ordered by increasing recall.
    part <- part[order(part$recall), , drop = FALSE]
    area <- sum(
      diff(part$recall) *
        (utils::head(part$precision, -1) + utils::tail(part$precision, -1)) / 2
    )
    sprintf("%s\nAUC %.2f", name, area)
  }, character(1))

  colors <- gfplot_colors("series")
  p <- ggplot2::ggplot(
    curves,
    ggplot2::aes(x = .data$recall, y = .data$precision, colour = .data$group)
  ) +
    ggplot2::geom_hline(
      yintercept = prevalence,
      colour = unname(gfplot_colors("reference_line")),
      linetype = "dashed",
      linewidth = 0.4
    ) +
    ggplot2::geom_path(linewidth = 0.9) +
    ggplot2::scale_colour_manual(
      labels = annot,
      values = rep(unname(colors), length.out = length(annot)),
      guide = gfplot_legend(annot)
    ) +
    ggplot2::coord_equal(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE) +
    gfplot_theme(font = font) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) +
    ggplot2::labs(
      x = "Recall (sensitivity)",
      y = "Precision (positive predictive value)",
      title = title
    )
  p
}

# Precision and recall across every score threshold.
gfplot_precision_recall <- function(score, outcome, group) {
  order_index <- order(score, decreasing = TRUE)
  score <- score[order_index]
  outcome <- outcome[order_index]
  positives <- cumsum(outcome == 1)
  predicted <- seq_along(outcome)
  total_positive <- sum(outcome == 1)
  data.frame(
    recall = positives / total_positive,
    precision = positives / predicted,
    group = group,
    stringsAsFactors = FALSE
  )
}

#' Calibration curve
#'
#' Predicted probability against the observed proportion of events. A model
#' whose points sit on the diagonal predicts the level it claims; one above
#' the diagonal under-predicts risk and one below over-predicts.
#'
#' @param probability Predicted probabilities, or a matrix or data frame with
#'   one column per model.
#' @param outcome Binary outcome, one value per observation.
#' @param positive Value of `outcome` that represents the event.
#' @param bins Number of groups to divide the predictions into. Quantile bins
#'   are used, so every point rests on a similar number of observations.
#' @param smooth Draw a loess curve through the points instead of connecting
#'   them.
#' @param show_ci Draw binomial confidence intervals for each point.
#' @param palette Palette name passed to [get_color()].
#' @param ci_level Confidence level of the intervals.
#' @param xlab,ylab,title Axis and plot labels.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#'
#' @seealso [plot_ROC()] for discrimination, [plot_decision_curve()] for
#'   whether acting on the predictions helps.
#' @export
#' @examples
#' set.seed(1)
#' outcome <- rbinom(200, 1, 0.4)
#' probability <- plogis(rnorm(200) + outcome * 0.5)
#' p <- plot_calibration(probability, outcome)
plot_calibration <- function(probability, outcome, positive = NULL,
                             bins = 10, smooth = FALSE, show_ci = TRUE,
                             palette = "house", ci_level = 0.95,
                             xlab = "Predicted probability",
                             ylab = "Observed proportion",
                             title = NULL, font = "Arial") {
  markers <- gfplot_marker_list(probability, arg = "probability")
  y <- resolve_binary_outcome(outcome, positive)
  check_length(markers[[1]], y, "probability", "outcome")
  if (bins < 2) {
    cli::cli_abort("{.arg bins} must be at least 2.")
  }

  curves <- do.call(rbind, lapply(names(markers), function(name) {
    gfplot_calibration_bins(markers[[name]], y, name, bins, ci_level)
  }))
  annotated <- vapply(names(markers), function(name) {
    n <- sum(!is.na(markers[[name]]) & !is.na(y))
    sprintf("%s (n = %d)", name, n)
  }, character(1))

  colors <- gfplot_colors("series")
  p <- ggplot2::ggplot(
    curves,
    ggplot2::aes(
      x = .data$predicted, y = .data$observed, colour = .data$group
    )
  ) +
    ggplot2::geom_abline(
      intercept = 0, slope = 1,
      colour = unname(gfplot_colors("reference_line")),
      linetype = "dashed",
      linewidth = 0.4
    )
  if (isTRUE(show_ci)) {
    p <- p + ggplot2::geom_errorbar(
      ggplot2::aes(ymin = .data$lower, ymax = .data$upper),
      width = 0, linewidth = 0.4
    )
  }
  p <- if (isTRUE(smooth)) {
    p + ggplot2::geom_smooth(
      method = "loess", formula = y ~ x, se = FALSE, linewidth = 0.9
    )
  } else {
    p + ggplot2::geom_line(linewidth = 0.9) + ggplot2::geom_point(size = 1.6)
  }
  p +
    ggplot2::scale_colour_manual(
      labels = annotated,
      values = rep(unname(colors), length.out = length(annotated)),
      guide = gfplot_legend(annotated)
    ) +
    ggplot2::coord_equal(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE) +
    gfplot_theme(font = font) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) +
    ggplot2::labs(x = xlab, y = ylab, title = title)
}

# Bin the predictions and summarise the observed proportion in each bin.
gfplot_calibration_bins <- function(probability, outcome, group, bins,
                                    ci_level) {
  keep <- !is.na(probability) & !is.na(outcome)
  probability <- probability[keep]
  outcome <- outcome[keep]
  if (length(probability) < bins) {
    cli::cli_abort(c(
      "Not enough observations for {bins} bins.",
      i = "There are {length(probability)} usable observations."
    ))
  }

  # Quantile bins keep a similar number of observations in each point, which
  # is what makes the intervals comparable across the curve.
  breaks <- unique(stats::quantile(
    probability, probs = seq(0, 1, length.out = bins + 1), na.rm = TRUE
  ))
  if (length(breaks) < 3) {
    cli::cli_abort(c(
      "{.arg probability} takes too few distinct values to bin.",
      i = "Use fewer bins, or supply continuous probabilities."
    ))
  }
  group_index <- cut(probability, breaks = breaks, include.lowest = TRUE)

  predicted <- tapply(probability, group_index, mean)
  observed <- tapply(outcome, group_index, mean)
  counts <- tapply(outcome, group_index, length)
  z <- stats::qnorm(1 - (1 - ci_level) / 2)
  standard_error <- sqrt(observed * (1 - observed) / counts)

  data.frame(
    predicted = as.numeric(predicted),
    observed = as.numeric(observed),
    lower = pmax(0, as.numeric(observed - z * standard_error)),
    upper = pmin(1, as.numeric(observed + z * standard_error)),
    n = as.integer(counts),
    group = group,
    stringsAsFactors = FALSE
  )
}

#' Decision curve
#'
#' Net benefit across decision thresholds. Net benefit weights the true
#' positives a model finds against the false positives it costs, at the
#' threshold probability a clinician would use to act. It is the figure that
#' answers whether using the model is better than treating everyone or no one.
#'
#' @inheritParams plot_calibration
#' @param thresholds Decision thresholds to evaluate. Defaults to 0.01 to 0.5,
#'   which covers the range used in most clinical decisions.
#' @param treat_all Draw the reference curve for treating every patient.
#' @param treat_none Draw the reference line for treating no patient.
#'
#' @return A `ggplot` object.
#'
#' @seealso [plot_calibration()] for whether the predicted levels are honest.
#' @export
#' @examples
#' set.seed(1)
#' outcome <- rbinom(300, 1, 0.3)
#' probability <- plogis(rnorm(300) + outcome)
#' p <- plot_decision_curve(probability, outcome)
plot_decision_curve <- function(probability, outcome, positive = NULL,
                                thresholds = seq(0.01, 0.5, by = 0.01),
                                treat_all = TRUE, treat_none = TRUE,
                                palette = "house",
                                xlab = "Threshold probability",
                                ylab = "Net benefit",
                                title = NULL, font = "Arial") {
  markers <- gfplot_marker_list(probability, arg = "probability")
  y <- resolve_binary_outcome(outcome, positive)
  check_length(markers[[1]], y, "probability", "outcome")
  if (any(thresholds <= 0 | thresholds >= 1)) {
    cli::cli_abort("{.arg thresholds} must be strictly between 0 and 1.")
  }

  curves <- do.call(rbind, lapply(names(markers), function(name) {
    p <- markers[[name]]
    keep <- !is.na(p) & !is.na(y)
    net_benefit <- vapply(thresholds, function(threshold) {
      gfplot_net_benefit(p[keep], y[keep], threshold)
    }, numeric(1))
    data.frame(
      net_benefit = net_benefit,
      threshold = thresholds,
      group = name,
      stringsAsFactors = FALSE
    )
  }))

  n <- sum(!is.na(y))
  colors <- gfplot_colors("series")
  reference_rows <- list()
  if (isTRUE(treat_all)) {
    reference_rows$all <- data.frame(
      threshold = thresholds,
      net_benefit = vapply(thresholds, function(threshold) {
        gfplot_net_benefit(rep(1, n), y[!is.na(y)], threshold)
      }, numeric(1)),
      group = "Treat all",
      stringsAsFactors = FALSE
    )
  }
  if (isTRUE(treat_none)) {
    reference_rows$none <- data.frame(
      threshold = thresholds, net_benefit = 0, group = "Treat none",
      stringsAsFactors = FALSE
    )
  }

  annotated <- c(
    stats::setNames(names(markers), names(markers)),
    if (isTRUE(treat_all)) c("Treat all" = "Treat all") else NULL,
    if (isTRUE(treat_none)) c("Treat none" = "Treat none") else NULL
  )
  p <- ggplot2::ggplot(
    curves,
    ggplot2::aes(
      x = .data$threshold, y = .data$net_benefit, colour = .data$group
    )
  ) +
    ggplot2::geom_path(linewidth = 0.9)
  if (length(reference_rows) > 0) {
    reference <- do.call(rbind, reference_rows)
    p <- p + ggplot2::geom_line(
      data = reference,
      ggplot2::aes(
        x = .data$threshold, y = .data$net_benefit, colour = .data$group
      ),
      linetype = "dashed",
      linewidth = 0.5
    )
  }
  p +
    ggplot2::scale_colour_manual(
      labels = unname(annotated),
      values = c(
        rep(unname(colors), length.out = length(markers)),
        rep(unname(gfplot_colors("reference_line")), length(reference_rows))
      ),
      guide = gfplot_legend(names(annotated))
    ) +
    gfplot_theme(font = font) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) +
    ggplot2::labs(x = xlab, y = ylab, title = title)
}

# Net benefit at one threshold: the true positive rate less the false
# positive rate weighted by the odds of the threshold.
gfplot_net_benefit <- function(probability, outcome, threshold) {
  n <- length(outcome)
  if (n == 0) {
    return(NA_real_)
  }
  positive <- probability >= threshold
  true_positive <- sum(positive & outcome == 1)
  false_positive <- sum(positive & outcome == 0)
  true_positive / n - false_positive / n * (threshold / (1 - threshold))
}

# Accept either one marker or several, and name them, so the plotting
# functions do not each repeat the handling.
gfplot_marker_list <- function(x, arg = "scores") {
  if (is.null(dim(x))) {
    if (!is.numeric(x)) {
      cli::cli_abort("{.arg {arg}} must be numeric.")
    }
    return(stats::setNames(list(x), arg))
  }
  frame <- as.data.frame(x, check.names = FALSE)
  if (ncol(frame) == 0) {
    cli::cli_abort("{.arg {arg}} has no columns.")
  }
  for (name in names(frame)) {
    if (!is.numeric(frame[[name]])) {
      cli::cli_abort("Column {.val {name}} of {.arg {arg}} must be numeric.")
    }
  }
  as.list(frame)
}
