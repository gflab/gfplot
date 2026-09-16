#' Plot a Kaplan-Meier curve with risk table and hazard ratio
#'
#' Draws survival curves for two or more groups, with an optional number-at-
#' risk table, the log-rank p-value, and, for two groups, the hazard ratio
#' from a univariable Cox model.
#'
#' @param clinical A survival object created by [survival::Surv()].
#' @param labels A vector of group labels, one per patient.
#' @param limit Optional follow-up limit; later observations are censored at
#'   the limit.
#' @param annot Optional extra annotation added to the plot.
#' @param color Optional vector of colours. A named vector also sets the group
#'   order.
#' @param font Font family used in the plot.
#' @param xlab,ylab,title Axis and plot labels.
#' @param legend.pos Legend position.
#' @param palette Palette name passed to [get_color()].
#' @param risk.table Draw the number-at-risk table.
#' @param risk.table.ratio Relative height of the risk table.
#' @param anno.pos Either `"bottom"` or `"top"`; where the annotations are
#'   placed.
#' @param anno.x.shift Horizontal position of the annotations when
#'   `anno.pos = "top"`.
#'
#' @return A `ggplot` object, or a `cowplot` grid when `risk.table = TRUE`.
#' @export
#' @examples
#' if (requireNamespace("survminer", quietly = TRUE)) {
#'   fit_data <- survival::lung
#'   p <- plot_KMCurve(
#'     survival::Surv(fit_data$time, fit_data$status == 2),
#'     factor(fit_data$sex),
#'     risk.table = FALSE
#'   )
#' }
plot_KMCurve <- function(clinical, labels, limit = NULL, annot = NULL,
                         color = NULL, font = "Arial", xlab = "Follow up",
                         ylab = "Survival Probability", title = NULL,
                         legend.pos = "top", palette = "house",
                         risk.table = TRUE, risk.table.ratio = 0.4,
                         anno.pos = "bottom", anno.x.shift = 0.5) {
  gfplot_require("survminer")

  time <- clinical[, 1]
  event <- clinical[, 2] == 1
  if (!is.null(limit)) {
    event[time > limit] <- FALSE
    time[time > limit] <- limit
  }
  df <- data.frame(futime = time, fustat = event, group = labels)
  surv <- survival::survfit(survival::Surv(futime, fustat) ~ group, data = df)
  survstats <- survival::survdiff(
    survival::Surv(futime, fustat) ~ group,
    data = df
  )
  survstats$p.value <- 1 - stats::pchisq(
    survstats$chisq,
    length(survstats$n) - 1
  )

  complete <- !(is.na(time) | is.na(event))
  if (!is.null(color)) {
    if (!is.null(names(color))) {
      labels <- factor(labels, levels = names(color))
    }
  } else {
    group_levels <- unique(as.character(labels[complete]))
    color <- if (identical(tolower(palette), "house")) {
      unname(gfplot_group_colors(group_levels))
    } else {
      get_color(palette, n = length(group_levels))
    }
  }

  if (is.factor(labels)) {
    legend.labs <- as.character(stats::na.omit(levels(droplevels(labels[complete]))))
  } else if (is.logical(labels)) {
    labels <- factor(labels, levels = c(FALSE, TRUE))
    legend.labs <- as.character(stats::na.omit(levels(droplevels(labels))))
  } else {
    legend.labs <- as.character(stats::na.omit(unique(labels[complete])))
    labels <- factor(labels, levels = legend.labs)
  }

  p <- survminer::ggsurvplot(
    surv,
    data = df,
    xlab = xlab,
    ylab = ylab,
    palette = color,
    legend = legend.pos,
    legend.labs = legend.labs,
    risk.table = risk.table,
    risk.table.y.text = FALSE,
    ggtheme = gfplot_theme(font = font)
  )
  p$plot <- p$plot + ggplot2::ggtitle(title) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5),
      text = ggplot2::element_text(family = font),
      title = ggplot2::element_text(family = font),
      axis.text.x = ggplot2::element_text(family = font),
      legend.title = ggplot2::element_blank()
    )

  anno.text <- ifelse(
    survstats$p.value == 0,
    "italic(P)<1%*%10^{-22}",
    paste0(
      "italic(P)==",
      gfplot_scientific_label(survstats$p.value, 3)
    )
  )
  anno.y.shift <- 0
  if (length(legend.labs) == 2) {
    hr <- cox_hazard_ratio(
      labels[complete],
      time[complete],
      event[complete]
    )
    anno.text <- c(
      anno.text,
      sprintf("HR == %3.2f~(%3.2f - %3.2f)", hr[1], hr[2], hr[3])
    )
    anno.y.shift <- c(anno.y.shift + 0.15, 0)
  }
  if (!is.null(annot)) {
    anno.text <- c(anno.text, annot)
    anno.y.shift <- c(anno.y.shift + 0.15, 0)
  }

  if (identical(anno.pos, "bottom")) {
    p$plot <- p$plot + ggplot2::annotate(
      "text",
      family = font,
      x = 0,
      y = anno.y.shift,
      label = anno.text,
      hjust = 0,
      vjust = 0,
      parse = TRUE
    )
  } else {
    p$plot <- p$plot + ggplot2::annotate(
      "text",
      family = font,
      x = anno.x.shift * max(time, na.rm = TRUE),
      y = 0.85 + anno.y.shift,
      label = anno.text,
      hjust = 0,
      vjust = 2,
      parse = TRUE
    )
  }

  if (risk.table) {
    p$table <- p$table + ggplot2::theme(
      text = ggplot2::element_text(family = font),
      title = ggplot2::element_text(family = font),
      axis.text = ggplot2::element_text(family = font),
      axis.title.y = ggplot2::element_blank()
    )
    return(gfplot_assemble(
      cowplot::plot_grid(
        plotlist = list(
          p$plot + ggplot2::theme(axis.title.x = ggplot2::element_blank()),
          p$table + ggplot2::labs(x = xlab)
        ),
        labels = "",
        ncol = 1,
        align = "v",
        rel_heights = c(1, risk.table.ratio)
      ),
      font
    ))
  }
  p$plot
}

# Hazard ratio, lower, and upper confidence limit for a two-group comparison.
# Replaces the previous survcomp::hazard.ratio() call with a univariable Cox
# model so that the package does not depend on a Bioconductor package.
cox_hazard_ratio <- function(group, time, event) {
  fit <- survival::coxph(
    survival::Surv(time, event) ~ factor(group)
  )
  ci <- summary(fit)$conf.int
  c(ci[1, 1], ci[1, 3], ci[1, 4])
}
