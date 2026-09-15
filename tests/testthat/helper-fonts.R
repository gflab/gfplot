# Can the current session draw Arial on a file device? This distinguishes a
# machine with the font registered, where the package default renders, from a
# bare build environment, where the rendering test is skipped.
arial_renderable <- function() {
  path <- tempfile(fileext = ".pdf")
  warnings <- character()
  ok <- FALSE
  tryCatch(
    {
      grDevices::pdf(path)
      withCallingHandlers(
        {
          grid::grid.newpage()
          grid::grid.text("probe", gp = grid::gpar(fontfamily = "Arial"))
        },
        warning = function(w) {
          warnings <<- c(warnings, conditionMessage(w))
          invokeRestart("muffleWarning")
        }
      )
      grDevices::dev.off()
      ok <- length(warnings) == 0L
    },
    error = function(e) {
      if (grDevices::dev.cur() > 1) {
        try(grDevices::dev.off(), silent = TRUE)
      }
      ok <<- FALSE
    }
  )
  unlink(path)
  ok
}
