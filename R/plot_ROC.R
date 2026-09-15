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
#' @param legend.pos Legend position as an x/y coordinate pair.
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
plot_ROC <- function(scores, labels, force05 = FALSE, palette = "jama",
                     legend.pos = c(0.2, 0.15), title = NULL, font = "Arial",
                     percent.style = FALSE) {
  msmdat1 <- precrec::mmdata(scores, labels, modnames = colnames(scores))
  mmcurves <- precrec::evalmod(msmdat1)
  auc_table <- precrec::auc(mmcurves)
  inds <- auc_table$auc[auc_table$curvetypes == "ROC"] < 0.5
  if (!force05) {
    inds <- FALSE
  }
  if (any(inds)) {
    if (length(inds) == 1) {
      scores <- -scores
    } else {
      scores[, inds] <- -scores[, inds]
    }
    msmdat1 <- precrec::mmdata(scores, labels, modnames = colnames(scores))
    mmcurves <- precrec::evalmod(msmdat1)
  }

  multiple <- !is.null(dim(scores)) && ncol(scores) > 1
  if (multiple) {
    # Iterate over columns explicitly: sapply() would walk the individual
    # elements of a matrix rather than its columns.
    aucs <- t(vapply(seq_len(ncol(scores)), function(i) {
      roc2 <- pROC::roc(labels, scores[, i], quiet = TRUE)
      pROC::ci(roc2)[c(2, 1, 3)]
    }, numeric(3)))
    annot <- sprintf(
      "%s\nAUC %.2f (%.2f-%.2f)",
      colnames(scores), aucs[, 1], aucs[, 2], aucs[, 3]
    )
  } else {
    roc2 <- pROC::roc(labels, scores, quiet = TRUE)
    aucs <- pROC::ci(roc2)[c(2, 1, 3)]
    annot <- sprintf("AUC %.2f (%.2f-%.2f)", aucs[1], aucs[2], aucs[3])
  }

  # precrec 0.14 passes an internal `raw_curves` argument through `...` to
  # ggplot2::fortify(), which ggplot2 4.0 reports as an unused argument. The
  # result is unaffected, so the spurious warning is suppressed to keep the
  # plot layout identical to the 0.1.0 figures.
  p <- suppressWarnings(ggplot2::autoplot(mmcurves, "ROC")) +
    cowplot::theme_cowplot(font_family = font) +
    ggplot2::scale_color_manual(
      labels = annot,
      values = get_color(palette, length(annot))
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
#' @param legend.pos Legend position as an x/y coordinate pair.
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
                         palette = "jama", legend.pos = c(0.4, 0.15),
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
    ggplot2::coord_equal() +
    cowplot::theme_cowplot(font_family = font) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5),
      legend.position = legend.pos,
      legend.title = ggplot2::element_blank()
    ) +
    ggplot2::scale_color_manual(
      labels = annot,
      values = get_color(palette, length(annot))
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
#' @param legend.pos Legend position as an x/y coordinate pair.
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
plot_MulROC <- function(scores, labels, palette = "jama_classic", color = NULL,
                        legend.pos = c(0.4, 0.15), title = NULL,
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
    cowplot::theme_cowplot(font_family = font) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5),
      legend.position = legend.pos,
      legend.title = ggplot2::element_blank()
    ) +
    ggplot2::scale_color_manual(labels = annot, values = color_value) +
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
