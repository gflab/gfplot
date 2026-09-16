# The house style, in one place.
#
# Every plotting function draws on these three pieces instead of restating
# colours, type sizes, and legend behaviour locally. The vocabulary follows
# the lab display standard: colours are addressed by semantic role rather than
# by hex value, so a figure says "this is the model curve" rather than "this is
# #0B4F6C", and the whole suite can be retuned from one place.

`%||%` <- function(x, y) if (is.null(x)) y else x

# Canonical colours by role. `model_curve`/`primary` marks the curve or group a
# figure is about, `comparator_curve`/`secondary` marks what it is compared
# against, and the remaining roles cover additional series plus supporting
# elements such as reference lines and grid lines.
gfplot_palette_default <- function() {
  c(
    primary = "#0B4F6C",
    secondary = "#2A9D8F",
    tertiary = "#B84A3A",
    quaternary = "#D99A2B",
    violet = "#6F63B6",
    neutral_mid = "#767676",
    neutral = "#4D4D4D",
    light = "#F2F5F7",
    muted = "#64748B",
    text = "#13293D",
    grid = "#E6EDF2",
    background = "#FFFFFF"
  )
}

# Aliases so callers can name a role the way their figure describes it.
gfplot_palette_aliases <- function() {
  c(
    model_curve = "primary",
    comparator_curve = "secondary",
    series_3 = "tertiary",
    series_4 = "quaternary",
    series_5 = "violet",
    series_6 = "neutral_mid",
    reference_line = "neutral",
    highlight_band = "light",
    subtitle = "muted",
    axis_line = "text",
    grid_line = "grid",
    figure_background = "background"
  )
}

# The order in which series colours are handed out. It matches the role order
# of the display standard, so a two-group figure uses primary then secondary
# and a six-series figure walks the full ramp.
gfplot_palette_order <- function() {
  c(
    "primary", "secondary", "tertiary",
    "quaternary", "violet", "neutral_mid"
  )
}

#' House colours by semantic role
#'
#' Returns the colours `gfplot` uses, addressed by role rather than by hex
#' value. Override any role for a session with
#' `options(gfplot.palette = list(primary = "#123456"))`, which is how the
#' suite is retuned without editing figures.
#'
#' @param role Colour roles to return. Use `"all"` for every role, or
#'   `"series"` for the ordered ramp that multi-series figures walk. Aliases
#'   such as `"model_curve"`, `"comparator_curve"`, and `"reference_line"` map
#'   onto the same roles.
#'
#' @return A named character vector of colours.
#'
#' @seealso [get_color()] for journal palettes and [gfplot_theme()] for the
#'   type and grid settings that go with these colours.
#' @export
#' @examples
#' gfplot_colors("primary")
#' gfplot_colors(c("model_curve", "comparator_curve"))
#' gfplot_colors("series")
gfplot_colors <- function(role = "all") {
  palette <- utils::modifyList(
    as.list(gfplot_palette_default()),
    getOption("gfplot.palette", list())
  )
  aliases <- gfplot_palette_aliases()

  # Resolves a vector of roles to canonical palette keys. Hex values pass
  # through untouched so a caller can name a colour directly.
  resolve <- function(values) {
    vapply(values, function(value) {
      value <- trimws(as.character(value))
      if (!nzchar(value)) {
        return(NA_character_)
      }
      if (startsWith(value, "#")) {
        return(value)
      }
      # `[[` on a named vector errors when the name is absent, so look the
      # alias up by position instead.
      if (value %in% names(aliases)) {
        return(unname(aliases[[which(names(aliases) == value)[1]]]))
      }
      value
    }, character(1), USE.NAMES = FALSE)
  }

  if (identical(role, "series")) {
    values <- vapply(gfplot_palette_order(), function(key) {
      palette[[key]] %||% NA_character_
    }, character(1))
    return(stats::setNames(values, gfplot_palette_order()))
  }

  if (identical(role, "all")) {
    return(stats::setNames(
      vapply(names(palette), function(key) palette[[key]], character(1)),
      names(palette)
    ))
  }

  keys <- resolve(role)
  # A hex value is a legal answer and is not a palette key, so it is only
  # unknown when it is neither.
  unknown <- is.na(keys) |
    !(keys %in% names(palette) | startsWith(ifelse(is.na(keys), "", keys), "#"))
  if (any(unknown)) {
    cli::cli_abort(c(
      "Unknown colour role{?s} {.val {role[unknown]}}.",
      i = "Available roles: {.val {c(names(palette), names(aliases))}}."
    ))
  }
  values <- vapply(seq_along(keys), function(i) {
    key <- keys[i]
    if (startsWith(key, "#")) {
      return(key)
    }
    palette[[which(names(palette) == key)[1]]]
  }, character(1))
  stats::setNames(values, role)
}

# Map a vector of group labels onto series colours. Risk-group labels are
# matched case- and hyphen-insensitively so "Low Risk", "low-risk", and
# "Low risk" all take the same colour.
gfplot_group_colors <- function(labels) {
  groups <- unique(as.character(labels))
  groups <- groups[!is.na(groups)]
  series <- gfplot_colors("series")
  values <- rep(unname(series), length.out = length(groups))
  names(values) <- groups

  normalized <- tolower(gsub("[^a-z]", "", tolower(groups)))
  risk_roles <- list(
    primary = c("lowrisk", "low", "lown", "good", "favourable", "favorable"),
    secondary = c("highrisk", "high", "hrisk", "poor", "adverse"),
    tertiary = c("intermediate")
  )
  for (role in names(risk_roles)) {
    hit <- normalized %in% risk_roles[[role]]
    if (any(hit)) {
      values[hit] <- gfplot_colors(role)[[1]]
    }
  }
  values
}

#' House theme for publication figures
#'
#' The theme every `gfplot` figure is drawn with: bold axis titles, a thin
#' major grid, a panel border, and a horizontal legend under the panel. Sizes
#' derive from `base_size`, so one number rescales the figure.
#'
#' This theme is also the session baseline: attaching `gfplot` sets it as the
#' global `ggplot2` theme so that figures drawn by other packages match. Set
#' `options(gfplot.set_theme = FALSE)` before `library(gfplot)` to keep an
#' existing theme instead.
#'
#' @param base_size Base font size in points. Other sizes are derived from it.
#' @param font Font family. Defaults to Arial.
#' @param grid Draw the major grid.
#' @param border Draw the panel border.
#' @param legend Legend position, one of `"bottom"`, `"right"`, `"top"`,
#'   `"left"`, or `"none"`.
#' @param margin Plot margin in points, in the order top, right, bottom, left.
#'
#' @return A `ggplot2` theme object.
#'
#' @seealso [gfplot_colors()] for the colours that go with it.
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   gfplot_theme()
gfplot_theme <- function(base_size = 11, font = "Arial", grid = TRUE,
                         border = TRUE, legend = c(
                           "bottom", "right", "top", "left", "none"
                         ),
                         margin = c(9, 10, 8, 10)) {
  legend <- match.arg(legend)
  colors <- gfplot_colors("all")
  text_color <- unname(colors[["text"]])
  grid_color <- unname(colors[["grid"]])
  background <- unname(colors[["background"]])

  ggplot2::theme_bw(base_size = base_size, base_family = font) +
    ggplot2::theme(
      text = ggplot2::element_text(family = font, colour = text_color),
      axis.title = ggplot2::element_text(
        face = "bold",
        colour = text_color,
        size = max(7.8, base_size - 0.5)
      ),
      axis.text = ggplot2::element_text(
        colour = text_color,
        size = max(7, base_size - 1.8)
      ),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = if (isTRUE(grid)) {
        ggplot2::element_line(colour = grid_color, linewidth = 0.25)
      } else {
        ggplot2::element_blank()
      },
      panel.border = if (isTRUE(border)) {
        ggplot2::element_rect(
          colour = text_color, linewidth = 0.45, fill = NA
        )
      } else {
        ggplot2::element_blank()
      },
      panel.background = ggplot2::element_rect(fill = background, colour = NA),
      plot.background = ggplot2::element_rect(fill = background, colour = NA),
      legend.position = legend,
      legend.box = "horizontal",
      legend.title = ggplot2::element_blank(),
      legend.text = ggplot2::element_text(
        colour = text_color,
        size = max(7, base_size - 2)
      ),
      legend.key = ggplot2::element_blank(),
      legend.background = ggplot2::element_blank(),
      legend.box.background = ggplot2::element_blank(),
      strip.background = ggplot2::element_rect(
        fill = unname(colors[["light"]]),
        colour = grid_color,
        linewidth = 0.4
      ),
      strip.text = ggplot2::element_text(face = "bold", colour = text_color),
      plot.margin = ggplot2::margin(
        margin[1], margin[2], margin[3], margin[4], unit = "pt"
      )
    )
}

#' Legend layout for a set of series labels
#'
#' Legends in `gfplot` figures sit under the panel and wrap onto as many rows
#' as the number of series needs, so a wide legend does not squeeze the panel.
#'
#' @param labels Series labels the legend will show.
#' @param base_size Base font size, used to scale the legend keys.
#' @param hide_single Hide the legend when only one series is present, where it
#'   would only restate the axis. Set to `FALSE` when the legend carries
#'   information, as with the area under the curve printed by [plot_ROC()].
#'
#' @return A `ggplot2` guide specification, or `"none"` for a single series
#'   when `hide_single = TRUE`.
#'
#' @export
#' @examples
#' gfplot_legend(c("Low risk", "High risk"))
gfplot_legend <- function(labels, base_size = 11, hide_single = TRUE) {
  label_count <- length(unique(as.character(labels)))
  if (isTRUE(hide_single) && label_count < 2) {
    return("none")
  }
  rows <- if (label_count > 6) 3 else if (label_count > 3) 2 else 1
  ggplot2::guide_legend(
    nrow = rows,
    byrow = TRUE,
    override.aes = list(linewidth = 1.6),
    label.position = "right",
    label.hjust = 0,
    keywidth = ggplot2::unit(13, "pt"),
    keyheight = ggplot2::unit(6, "pt")
  )
}
