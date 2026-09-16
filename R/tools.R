#' Colour palettes used by the plotting functions
#'
#' Returns a vector of journal-style colours. When `palette` is a vector of
#' length greater than one it is returned unchanged, so the argument can also
#' be used to pass colours through from a caller.
#'
#' @param palette Palette name: `"nature"`, `"jco"`, `"lancet"`, `"jama"`,
#'   `"jama_classic"`, `"house"` for the lab series ramp described in
#'   [gfplot_colors()], or any other value, which selects the ColorBrewer
#'   `"Set1"` palette.
#' @param n Number of colours to return.
#'
#' @return A character vector of colours.
#' @export
#' @examples
#' get_color("jama", 3)
#' get_color("house", 4)
#' get_color(c("#111111", "#222222"))
get_color <- function(palette, n = 6) {
  if (length(palette) > 1) {
    return(palette)
  }

  switch(tolower(palette),
    house = ,
    fenggaolab = {
      series <- unname(gfplot_colors("series"))
      if (n <= length(series)) {
        series[seq_len(n)]
      } else {
        grDevices::colorRampPalette(series)(n)
      }
    },
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
    cli::cli_abort(c(
      "Package {.pkg {package}} is required by this function.",
      i = "Install it with {.run install.packages(\"{package}\")}.",
      i = hint
    ))
  }
  invisible(TRUE)
}

# Which device routes can render this font in the current session? The answer
# comes from the font registries rather than from opening devices, so the
# check is cheap and has no side effects.

# Session state for hints that would otherwise repeat for every text element.
gfplot_state <- new.env(parent = emptyenv())

# cowplot::plot_grid() measures text against the PostScript font database while
# it assembles the risk table, which reports "font family 'Arial' not found in
# PostScript font database" once per text element -- 79 lines for a two-group
# curve. The measurement does not affect the figure, because rendering goes
# through the device the user chooses, and gfplot_save() selects a device that
# can render the font. The underlying fact is still worth stating, so the
# repeated warnings become one actionable message per session.
gfplot_font_hint_once <- function(font) {
  key <- paste0("font_hint_", font)
  if (isTRUE(gfplot_state[[key]])) {
    return(invisible(FALSE))
  }
  gfplot_state[[key]] <- TRUE
  cli::cli_inform(c(
    "The base {.fn pdf} device cannot render {.val {font}}, so it may substitute a fallback font in vector PDF output.",
    i = "Use {.run gfplot_save(plot, \"figure.pdf\")} to write through a device that can render it.",
    i = "Or run {.run gfplot_font_setup()} to register the font with the device."
  ))
  invisible(TRUE)
}

# Assemble a plot while muffling cowplot's repeated font-database probe, and
# report that probe once instead. Any other warning is left untouched.
gfplot_assemble <- function(code, font) {
  probed <- FALSE
  result <- withCallingHandlers(
    code,
    warning = function(w) {
      if (grepl("not found in PostScript font database", conditionMessage(w),
                fixed = TRUE)) {
        probed <<- TRUE
        invokeRestart("muffleWarning")
      }
    }
  )
  if (probed) {
    gfplot_font_hint_once(font)
  }
  result
}

gfplot_font_devices <- function(font = "Arial") {
  installed <- character()
  if (requireNamespace("systemfonts", quietly = TRUE)) {
    installed <- tryCatch(
      unique(systemfonts::system_fonts()$family),
      error = function(e) character()
    )
  } else if (requireNamespace("extrafont", quietly = TRUE)) {
    installed <- tryCatch(extrafont::fonts(), error = function(e) character())
  }
  on_system <- font %in% installed

  c(
    raster = on_system && requireNamespace("ragg", quietly = TRUE),
    quartz = on_system && isTRUE(capabilities("aqua")),
    pdf = font %in% names(grDevices::pdfFonts())
  )
}

#' Check which devices can render the figure font
#'
#' Figures produced by `gfplot` use Arial. The raster devices supplied by
#' \pkg{ragg} and the `quartz` device on macOS resolve system fonts such as
#' Arial directly, so most output needs no preparation at all. The base
#' `pdf()` device keeps its own font table and needs the family registered
#' with it, which \pkg{extrafont} does.
#'
#' This function reports which routes work in the current session and, when
#' vector PDF output would otherwise be unavailable, registers the font with
#' \pkg{extrafont} so that `pdf()` can use it.
#'
#' @param font Font family to check.
#' @param quiet Suppress the report.
#'
#' @return A named logical vector, invisibly, with one entry per device route:
#'   `raster` (\pkg{ragg} PNG/TIFF/JPEG), `quartz` (macOS PDF and screen),
#'   and `pdf` (base `pdf()`). These are the routes [gfplot_save()] chooses
#'   between.
#'
#' @seealso [gfplot_save()] to write a figure using a device that can render
#'   the font, and [plot_KMCurve()] for the `font` argument.
#' @export
#' @examples
#' gfplot_font_setup()
gfplot_font_setup <- function(font = "Arial", quiet = FALSE) {
  devices <- gfplot_font_devices(font)
  if (!devices[["pdf"]] && requireNamespace("extrafont", quietly = TRUE)) {
    tryCatch(
      {
        extrafont::loadfonts(quiet = TRUE)
        extrafont::loadfonts(device = "pdf", quiet = TRUE)
      },
      error = function(e) NULL
    )
    devices[["pdf"]] <- font %in% names(grDevices::pdfFonts())
  }

  if (!quiet) {
    yes_no <- function(x) if (isTRUE(x)) "yes" else "no"
    cli::cli_inform(c(
      "Figure font {.val {font}} can be rendered by:",
      "*" = "ragg raster devices (PNG, TIFF, JPEG): {yes_no(devices[['raster']])}",
      "*" = "quartz (macOS PDF and screen): {yes_no(devices[['quartz']])}",
      "*" = "base pdf(): {yes_no(devices[['pdf']])}",
      i = "gfplot_save() picks a route that can render the font."
    ))
  }
  invisible(devices)
}

#' Save a figure using a device that can render the requested font
#'
#' Writing an R figure with Arial is device dependent: the base `pdf()` device
#' needs the family registered with it, while the \pkg{ragg} raster devices
#' and the macOS `quartz` device resolve system fonts directly. This function
#' chooses a route that can render `font` for the requested file extension, so
#' a figure is written with the intended typeface instead of silently falling
#' back to a default.
#'
#' @param plot A `ggplot` object, or any object with a `print()` method that
#'   draws it.
#' @param filename Output path. The extension selects the device: `.png`,
#'   `.tiff`, `.jpg`, `.jpeg`, or `.pdf`.
#' @param width,height Size in inches.
#' @param dpi Resolution for raster output.
#' @param font Font family passed to the device unchanged.
#' @param ... Passed on to the device function.
#'
#' @return `filename`, invisibly.
#'
#' @seealso [gfplot_font_setup()] to see which devices can render a font.
#' @export
#' @examples
#' p <- plot_Boxplot(c(rnorm(20), rnorm(20, 1)), rep(c("A", "B"), each = 20))
#' path <- tempfile(fileext = ".png")
#' gfplot_save(p, path, width = 4, height = 3)
#' unlink(path)
gfplot_save <- function(plot, filename, width = 7, height = 5, dpi = 300,
                        font = "Arial", ...) {
  ext <- tolower(tools::file_ext(filename))
  if (!nzchar(ext)) {
    cli::cli_abort(c(
      "{.arg filename} needs a file extension.",
      i = "Use one of {.file .png}, {.file .tiff}, {.file .jpg}, or {.file .pdf}."
    ))
  }

  open_device <- switch(ext,
    png = function() gfplot_open_raster("png", filename, width, height, dpi, ...),
    tiff = ,
    tif = function() gfplot_open_raster("tiff", filename, width, height, dpi, ...),
    jpg = ,
    jpeg = function() gfplot_open_raster("jpeg", filename, width, height, dpi, ...),
    pdf = function() gfplot_open_pdf(filename, width, height, font, ...),
    cli::cli_abort(c(
      "Unsupported file extension {.val {ext}}.",
      i = "Use one of {.file .png}, {.file .tiff}, {.file .jpg}, or {.file .pdf}."
    ))
  )

  open_device()
  on.exit(grDevices::dev.off(), add = TRUE)
  print(plot)
  invisible(filename)
}

# Open a raster device, preferring ragg because it resolves system fonts.
gfplot_open_raster <- function(type, filename, width, height, dpi, ...) {
  if (requireNamespace("ragg", quietly = TRUE)) {
    device <- switch(type,
      png = ragg::agg_png,
      tiff = ragg::agg_tiff,
      jpeg = ragg::agg_jpeg
    )
    return(device(
      filename = filename, width = width, height = height,
      units = "in", res = dpi, ...
    ))
  }

  cli::cli_inform(c(
    "Using the base {.fn {type}} device, which does not resolve system fonts.",
    i = "Install {.pkg ragg} for figures that render Arial: {.run install.packages(\"ragg\")}."
  ))
  device <- switch(type,
    png = grDevices::png,
    tiff = grDevices::tiff,
    jpeg = grDevices::jpeg
  )
  device(
    filename = filename, width = width, height = height,
    units = "in", res = dpi, ...
  )
}

# Open a PDF device that can render the requested font. On macOS quartz
# resolves system fonts natively; elsewhere the base device is used and the
# font has to be registered with it first.
gfplot_open_pdf <- function(filename, width, height, font, ...) {
  devices <- gfplot_font_devices(font)
  if (devices[["quartz"]]) {
    return(grDevices::quartz(
      file = filename, type = "pdf", width = width, height = height, ...
    ))
  }
  if (!devices[["pdf"]]) {
    cli::cli_inform(c(
      "The base {.fn pdf} device cannot render {.val {font}} yet, so the file may use a fallback font.",
      i = "Run {.run gfplot_font_setup()} to register it, which needs {.pkg extrafont}."
    ))
  }
  grDevices::pdf(file = filename, width = width, height = height, ...)
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
    ggplot2::theme_set(gfplot_theme())
  }
}
