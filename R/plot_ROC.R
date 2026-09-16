#' Plot ROC curves for one or more markers
#'
#' Plots receiver operating characteristic curves with the area under the
#' curve and its confidence interval in the legend.
#'
#' @param scores Numeric vector, or a matrix or data frame with one column per
#'   marker.
#' @param labels Binary outcome, one value per observation.
#' @param force05 Flip markers whose area under the curve is below 0.5 so that
#'   every curve is plotted above the diagonal.
#' @param palette Palette name passed to [get_color()].
#' @param legend.pos Legend position: a position such as `"bottom"`, or an x/y
#'   coordinate pair in panel units for a legend inside the panel.
#' @param title Plot title.
#' @param font Font family used in the plot.
#' @param percent.style Label the axes as percentages.
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' set.seed(1)
#' scores <- cbind(marker1 = rnorm(80), marker2 = rnorm(80))
#' labels <- rep(c(0, 1), each = 40)
#' p <- plot_ROC(scores, labels)
plot_ROC <- function(scores, labels, force05 = FALSE, palette = "house",
                     legend.pos = "bottom", title = NULL, font = "Arial",
                     percent.style = FALSE) {
  multiple <- !is.null(dim(scores)) && ncol(scores) > 1
  markers <- if (multiple) {
    columns <- as.data.frame(scores, check.names = FALSE)
    stats::setNames(columns, colnames(scores))
  } else {
    list(scores = scores)
  }

  # pROC's "<" means "observations are positive when they are greater than or
  # equal to the threshold", so a higher score marks the positive class. That
  # is the convention 0.1.0 drew with, and it is what makes force05
  # meaningful. The same direction is used for the legend, so the printed
  # area under the curve always describes the curve that is drawn: 0.1.0 drew
  # the curve in this direction but read the legend from pROC's automatic
  # direction, so a reversed marker was drawn below the diagonal while the
  # legend reported the mirrored value.
  fit_roc <- function(x) pROC::roc(labels, x, direction = "<", quiet = TRUE)

  if (isTRUE(force05)) {
    aucs <- vapply(
      markers,
      function(x) as.numeric(pROC::auc(fit_roc(x))),
      numeric(1)
    )
    flipped <- aucs < 0.5
    if (any(flipped)) {
      markers[flipped] <- lapply(markers[flipped], function(x) -x)
    }
  }

  rocs <- lapply(markers, fit_roc)
  intervals <- lapply(rocs, function(roc) pROC::ci(roc)[c(2, 1, 3)])
  curves <- do.call(rbind, lapply(seq_along(rocs), function(i) {
    data.frame(
      FPR = 1 - rocs[[i]]$specificities,
      TPR = rocs[[i]]$sensitivities,
      group = names(markers)[i]
    )
  }))

  annot <- vapply(intervals, function(ci) {
    sprintf("AUC %.2f (%.2f-%.2f)", ci[1], ci[2], ci[3])
  }, character(1))
  if (multiple) {
    annot <- paste0(names(markers), "\n", annot)
  }

  p <- ggplot2::ggplot(
    curves,
    ggplot2::aes(x = .data$FPR, y = .data$TPR, color = .data$group)
  ) +
    ggplot2::geom_path() +
    ggplot2::labs(x = "1 - Specificity", y = "Sensitivity") +
    ggplot2::coord_equal(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE) +
    ggplot2::geom_abline(
      intercept = 0, slope = 1, color = "grey50", linetype = "dashed"
    ) +
    gfplot_theme(font = font) +
    ggplot2::scale_color_manual(
      labels = annot,
      values = get_color(palette, length(annot)),
      # The legend carries the area under the curve, so it is kept even for a
      # single marker.
      guide = gfplot_legend(annot, hide_single = FALSE)
    ) +
    ggplot2::theme(
      legend.position = legend.pos,
      legend.title = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5)
    ) +
    ggplot2::labs(title = title)
  if (is.null(title)) {
    p <- p + ggplot2::theme(legend.title = ggplot2::element_blank())
  }
  if (percent.style) {
    p <- p +
      ggplot2::xlab("False Positive") +
      ggplot2::ylab("True Positive") +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::scale_x_continuous(labels = scales::percent)
  }
  p
}

#' Plot time-dependent ROC curves
#'
#' Plots survival ROC curves at one or more time points using the
#' Kaplan-Meier method of the `survivalROC` package.
#'
#' @param scores Numeric marker values.
#' @param survival A two-column survival object.
#' @param time_points Time points at which the curves are evaluated.
#' @param groups Labels for the curves, one per time point.
#' @param palette Palette name passed to [get_color()].
#' @inheritParams plot_ROC
#' @param title Plot title.
#' @param font Font family used in the plot.
#' @param percent.style Label the axes as percentages.
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("survivalROC", quietly = TRUE)) {
#'   set.seed(1)
#'   surv <- survival::Surv(rexp(100), rbinom(100, 1, 0.6))
#'   p <- plot_TimeROC(rnorm(100), surv, c(1, 2), c("year1", "year2"))
#' }
#' }
plot_TimeROC <- function(scores, survival, time_points, groups,
                         palette = "house", legend.pos = "bottom",
                         title = NULL, font = "Arial", percent.style = FALSE) {
  gfplot_require(
    "survivalROC",
    "Alternatively, timeROC::timeROC() provides a maintained estimator."
  )

  roc_at <- function(i) {
    survivalROC::survivalROC(
      Stime = survival[, 1],
      status = survival[, 2],
      marker = scores,
      predict.time = time_points[i],
      method = "KM"
    )
  }

  df.plot <- do.call(rbind, lapply(seq_along(time_points), function(i) {
    point <- roc_at(i)
    data.frame(FP = point$FP, TP = point$TP, group = groups[i])
  }))
  aucs <- vapply(seq_along(time_points), function(i) roc_at(i)$AUC, numeric(1))
  annot <- paste(groups, "AUC", sprintf("%.3f", aucs))

  p <- ggplot2::ggplot() +
    ggplot2::geom_line(
      data = df.plot,
      ggplot2::aes(.data$FP, .data$TP, color = .data$group)
    ) +
    ggplot2::labs(
      x = "False Positive", y = "True Positive", title = title
    ) +
    ggplot2::coord_equal(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE) +
    gfplot_theme(font = font) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5),
      legend.position = legend.pos,
      legend.title = ggplot2::element_blank()
    ) +
    ggplot2::scale_color_manual(
      labels = annot,
      values = get_color(palette, length(annot)),
      guide = gfplot_legend(annot, hide_single = FALSE)
    ) +
    ggplot2::geom_abline(
      intercept = 0, slope = 1, color = "grey50", linetype = "dashed"
    )

  if (percent.style) {
    p <- p +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::scale_x_continuous(labels = scales::percent)
  }
  p
}

#' Plot several ROC curves from separate datasets
#'
#' Each element of `scores` is matched with the corresponding element of
#' `labels`, which allows the curves to come from different cohorts or
#' endpoints rather than from different markers of the same cohort.
#'
#' @param scores A named list of numeric marker vectors.
#' @param labels A list of binary outcomes, one per element of `scores`.
#' @param palette Palette name passed to [get_color()].
#' @param color Optional vector of colours; overrides `palette`.
#' @inheritParams plot_ROC
#' @param title Plot title.
#' @param font Font family used in the plot.
#' @param percent.style Label the axes as percentages.
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' set.seed(1)
#' scores <- list(cohortA = rnorm(60), cohortB = rnorm(60))
#' labels <- list(rbinom(60, 1, 0.5), rbinom(60, 1, 0.5))
#' p <- plot_MulROC(scores, labels)
plot_MulROC <- function(scores, labels, palette = "house", color = NULL,
                        legend.pos = "bottom", title = NULL,
                        font = "Arial", percent.style = FALSE) {
  df.plot <- do.call(rbind, lapply(seq_along(scores), function(i) {
    index <- !is.na(scores[[i]])
    roc2 <- pROC::roc(labels[[i]][index], scores[[i]][index], quiet = TRUE)
    data.frame(
      FP = 1 - roc2$specificities,
      TP = roc2$sensitivities,
      group = names(scores)[i]
    )
  }))

  aucs <- t(vapply(seq_along(scores), function(i) {
    index <- !is.na(scores[[i]])
    roc2 <- pROC::roc(labels[[i]][index], scores[[i]][index], quiet = TRUE)
    pROC::ci(roc2)[c(2, 1, 3)]
  }, numeric(3)))
  width <- max(nchar(names(scores))) + 1
  annot <- paste0(
    sprintf(paste0("%-", width, "s"), names(scores)),
    "\t",
    sprintf("AUC %.2f", aucs[, 1])
  )

  color_value <- if (!is.null(color)) color else get_color(palette, length(annot))

  p <- ggplot2::ggplot() +
    ggplot2::geom_path(
      data = df.plot,
      ggplot2::aes(.data$FP, .data$TP, color = .data$group)
    ) +
    ggplot2::labs(
      x = "1 - Specificity", y = "Sensitivity", title = title
    ) +
    ggplot2::coord_equal() +
    gfplot_theme(font = font) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5),
      legend.position = legend.pos,
      legend.title = ggplot2::element_blank()
    ) +
    ggplot2::scale_color_manual(
      labels = annot,
      values = color_value,
      guide = gfplot_legend(annot, hide_single = FALSE)
    ) +
    ggplot2::geom_abline(
      intercept = 0, slope = 1, color = "grey50", linetype = "dashed"
    )

  if (percent.style) {
    p <- p +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::scale_x_continuous(labels = scales::percent)
  }
  p
}
