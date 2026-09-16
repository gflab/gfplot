#' Cumulative incidence of competing events
#'
#' The probability of each event type over follow-up, in the presence of
#' competing events. When a patient can experience one of several mutually
#' exclusive events, a Kaplan-Meier estimate of any single one is biased
#' upward, because patients who had a competing event are still counted as
#' being at risk of the event of interest. The cumulative incidence function
#' accounts for them.
#'
#' @param time Follow-up times.
#' @param status Event type per patient. The first level is the event of
#'   interest, `0` is censoring, and any further levels are competing events.
#'   A factor with a `0` level, a numeric code vector, or a character vector
#'   are all accepted.
#' @param group Optional grouping vector, giving one panel per group.
#' @param event Optional event type to plot. By default every event type is
#'   drawn.
#' @param conf_int Draw pointwise confidence bands.
#' @param palette Palette name passed to [get_color()].
#' @param xlab,ylab,title Axis and plot labels.
#' @param legend_title Legend title.
#' @param font Font family used in the plot.
#'
#' @return A `ggplot` object.
#'
#' @seealso [plot_KMCurve()] for a single event where no competing risk
#'   applies.
#' @export
#' @examples
#' set.seed(1)
#' time <- rexp(200)
#' status <- sample(c(0, 1, 2), 200, replace = TRUE, prob = c(0.4, 0.4, 0.2))
#' p <- plot_cumulative_incidence(time, status, group = rep(c("A", "B"), 100))
plot_cumulative_incidence <- function(time, status, group = NULL, event = NULL,
                                      conf_int = FALSE, palette = "house",
                                      xlab = "Follow up",
                                      ylab = "Cumulative incidence",
                                      title = NULL, legend_title = NULL,
                                      font = "Arial") {
  check_numeric(time, "time")
  check_length(time, status, "time", "status")
  if (!is.null(group)) {
    check_length(time, group, "time", "group")
  }

  status <- gfplot_event_factor(status)
  keep <- !is.na(time) & !is.na(status)
  if (!is.null(group)) {
    keep <- keep & !is.na(group)
  }
  if (sum(keep) < 3) {
    cli::cli_abort("At least three complete observations are required.")
  }
  time <- time[keep]
  status <- droplevels(status[keep])
  group <- if (is.null(group)) NULL else droplevels(as.factor(group[keep]))

  event_levels <- setdiff(levels(status), "0")
  if (length(event_levels) == 0) {
    cli::cli_abort(c(
      "{.arg status} has no event types.",
      i = "Use {.val 0} for censoring and a distinct value for each event type."
    ))
  }
  if (!is.null(event)) {
    event <- as.character(event)
    if (!all(event %in% event_levels)) {
      cli::cli_abort(c(
        "{.arg event} names a type that is not in {.arg status}.",
        i = "Available types: {.val {event_levels}}."
      ))
    }
    event_levels <- event
  }

  # A multi-state survfit gives the transition probability into each event,
  # which is the cumulative incidence for that event.
  fit <- if (is.null(group)) {
    survival::survfit(survival::Surv(time, status) ~ 1)
  } else {
    survival::survfit(survival::Surv(time, status) ~ group)
  }
  curves <- gfplot_incidence_curves(fit, event_levels, group)

  colors <- gfplot_colors("series")
  p <- ggplot2::ggplot(
    curves,
    ggplot2::aes(
      x = .data$time, y = .data$incidence,
      colour = .data$series, linetype = .data$event
    )
  ) +
    ggplot2::geom_step(linewidth = 0.8)
  if (isTRUE(conf_int)) {
    p <- p + ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data$lower, ymax = .data$upper, fill = .data$series),
      alpha = 0.15, colour = NA, outline.type = "both"
    ) +
      ggplot2::scale_fill_manual(values = rep(unname(colors), 6), guide = "none")
  }
  p +
    ggplot2::scale_colour_manual(
      values = rep(unname(colors), 6),
      guide = gfplot_legend(unique(curves$series))
    ) +
    ggplot2::scale_linetype_discrete(
      name = legend_title %||% if (length(event_levels) > 1) "Event" else NULL,
      guide = if (length(event_levels) > 1) {
        ggplot2::guide_legend(title.position = "top")
      } else {
        "none"
      }
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, NA), expand = ggplot2::expansion(mult = c(0, 0.05))
    ) +
    gfplot_theme(font = font) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) +
    ggplot2::labs(x = xlab, y = ylab, title = title)
}

# Accept a factor, a numeric code, or a character vector as the event type,
# with 0 always meaning censoring.
gfplot_event_factor <- function(status) {
  if (is.factor(status)) {
    if (!"0" %in% levels(status)) {
      levels(status) <- c(levels(status), "0")
    }
    return(factor(as.character(status), levels = sort(unique(c("0", levels(status))))))
  }
  if (!is.numeric(status) && !is.character(status)) {
    cli::cli_abort("{.arg status} must be numeric, character, or a factor.")
  }
  values <- as.character(status)
  levels_sorted <- sort(unique(values[!is.na(values)]))
  if (!"0" %in% levels_sorted) {
    levels_sorted <- c("0", levels_sorted)
  }
  factor(values, levels = levels_sorted)
}

# Turn a multi-state survfit into one row per group, event type, and time.
#
# Columns of `pstate` line up with `states`, whose first entry is the
# starting state rather than an event, so an event is read by matching its
# name. A two-level status is fitted the same way and gives the same numbers
# as the classic Kaplan-Meier complement, so there is one path here rather
# than two.
gfplot_incidence_curves <- function(fit, event_levels, group) {
  states <- fit$states
  if (is.null(states) || is.null(fit$pstate)) {
    cli::cli_abort("The survival fit did not produce a multi-state estimate.")
  }
  strata <- if (is.null(fit$strata)) {
    stats::setNames(length(fit$time), "All")
  } else {
    fit$strata
  }
  strata_labels <- sub("^[^=]*=", "", names(strata))

  rows <- list()
  for (index in seq_along(strata)) {
    span <- gfplot_strata_span(strata, index)
    for (state in event_levels) {
      column <- match(state, states)
      if (is.na(column)) {
        next
      }
      rows[[length(rows) + 1]] <- data.frame(
        time = fit$time[span],
        series = strata_labels[index],
        event = state,
        incidence = fit$pstate[span, column],
        lower = if (!is.null(fit$lower)) fit$lower[span, column] else NA_real_,
        upper = if (!is.null(fit$upper)) fit$upper[span, column] else NA_real_,
        stringsAsFactors = FALSE
      )
    }
  }
  do.call(rbind, rows)
}

gfplot_strata_span <- function(strata, index) {
  start <- cumsum(c(1L, strata))[index]
  size <- strata[[index]]
  start:(start + size - 1L)
}
