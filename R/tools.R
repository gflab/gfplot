#' Colour palettes used by the plotting functions
#'
#' Returns a vector of journal-style colours. When `palette` is a vector of
#' length greater than one it is returned unchanged, so the argument can also
#' be used to pass colours through from a caller.
#'
#' @param palette Palette name: `"nature"`, `"jco"`, `"lancet"`, `"jama"`,
#'   `"jama_classic"`, or any other value, which selects the ColorBrewer
#'   `"Set1"` palette.
#' @param n Number of colours to return.
#'
#' @return A character vector of colours.
#' @export
#' @examples
#' get_color("jama", 3)
#' get_color(c("#111111", "#222222"))
get_color <- function(palette, n = 6) {
  if (length(palette) > 1) {
    return(palette)
  }

  switch(tolower(palette),
    nature = {
      (ggsci::pal_npg("nrc"))(n)
    },
    jco = {
      (ggsci::pal_jco("default"))(n)
    },
    lancet = {
      (ggsci::pal_lancet("lanonc"))(n)
    },
    jama = {
      ggsci::pal_jama()(n)
    },
    jama_classic = {
      utils::head(
        c(
          "#164870", "#10B4F3", "#FAA935", "#2D292A", "#87AAB9",
          "#CAC27E", "#818282"
        ),
        n
      )
    },
    RColorBrewer::brewer.pal(n, "Set1")
  )
}

#' Build event indicators for one or more follow-up limits
#'
#' Turns a two-column clinical matrix into a matrix of event indicators, with
#' one column per follow-up limit. Observations beyond a limit are censored at
#' that limit.
#'
#' @param clinical Two-column object: follow-up time and event indicator.
#' @param limits Numeric vector of follow-up limits.
#' @param labels Optional column names for the resulting matrix.
#'
#' @return A matrix with one column per limit.
#' @export
#' @examples
#' clinical <- cbind(time = c(1, 5, 10), event = c(1, 0, 1))
#' generate_time_event(clinical, limits = c(3, 6), labels = c("year3", "year6"))
generate_time_event <- function(clinical, limits, labels = NULL) {
  time <- clinical[, 1]
  event <- clinical[, 2] == 1
  df <- sapply(limits, function(limit) {
    res <- event
    res[time > limit] <- FALSE
    res
  })
  colnames(df) <- labels
  df
}

# Report a missing optional dependency with an actionable message.
gfplot_require <- function(package, hint = NULL) {
  if (!requireNamespace(package, quietly = TRUE)) {
    message <- sprintf(
      "Package '%s' is required by this function. Install it with install.packages(\"%s\").",
      package, package
    )
    if (!is.null(hint)) {
      message <- paste(message, hint)
    }
    stop(message, call. = FALSE)
  }
  invisible(TRUE)
}

#' Prepare the Arial font family for figure output
#'
#' Figures produced by `gfplot` use Arial. On macOS the `quartz` device
#' resolves Arial directly. PDF and PostScript output need the font to be
#' registered with the device, which `extrafont` does; this function runs the
#' registration and reports whether Arial is then available.
#'
#' Run `extrafont::font_import()` once, before the first call to this
#' function, to add system fonts to the `extrafont` database.
#'
#' @param quiet Suppress progress output.
#'
#' @return `TRUE` when Arial is registered for the current device, `FALSE`
#'   otherwise, invisibly.
#'
#' @seealso [plot_KMCurve()] for the `font` argument.
#' @export
#' @examples
#' \dontrun{
#' extrafont::font_import()
#' gfplot_font_setup()
#' }
gfplot_font_setup <- function(quiet = FALSE) {
  if (!requireNamespace("extrafont", quietly = TRUE)) {
    if (!quiet) {
      message(
        "Package 'extrafont' is required to register Arial for PDF output. ",
        "Install it with install.packages(\"extrafont\")."
      )
    }
    return(invisible(FALSE))
  }
  tryCatch(
    {
      extrafont::loadfonts(quiet = TRUE)
      extrafont::loadfonts(device = "pdf", quiet = TRUE)
    },
    error = function(e) NULL
  )
  available <- isTRUE(tryCatch(
    "Arial" %in% extrafont::fonts(),
    error = function(e) FALSE
  ))
  if (!quiet) {
    if (available) {
      message("Arial is registered for figure output.")
    } else {
      message(
        "Arial is still not available. Run extrafont::font_import() once, ",
        "then call gfplot_font_setup() again."
      )
    }
  }
  invisible(available)
}

# Render a p-value as a plotmath expression with scientific notation.
gfplot_scientific_label <- function(value, digits = 3) {
  text <- format(value, digits = digits, scientific = TRUE)
  text <- gsub("^(.*)e", "'\\1'e", text)
  text <- gsub("e", "%*%10^", text)
  parse(text = text)
}

.onLoad <- function(libname, pkgname) {
  if (isTRUE(getOption("gfplot.set_theme", TRUE))) {
    ggplot2::theme_set(cowplot::theme_cowplot())
  }
}
