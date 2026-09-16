test_that("get_color returns the requested number of colours", {
  expect_length(get_color("jama_classic", 4), 4)
  expect_length(get_color("jama", 3), 3)
  expect_length(get_color("nature", 2), 2)
  expect_length(get_color("unknown-palette", 3), 3)
  expect_equal(get_color(c("#111111", "#222222")), c("#111111", "#222222"))
})

test_that("generate_time_event censors observations beyond each limit", {
  clinical <- cbind(time = c(1, 5, 10), event = c(1, 0, 1))
  result <- generate_time_event(clinical, limits = c(3, 6), labels = c("y3", "y6"))

  expect_equal(colnames(result), c("y3", "y6"))
  expect_equal(result[, "y3"], c(TRUE, FALSE, FALSE))
  expect_equal(result[, "y6"], c(TRUE, FALSE, FALSE))
})

test_that("optional dependencies report an actionable error", {
  expect_true(gfplot:::gfplot_require("stats"))
  expect_error(
    gfplot:::gfplot_require("definitely-not-a-package"),
    "install\\.packages"
  )
})

test_that("Arial is the default font for every plotting function", {
  defaults <- list(
    plot_KMCurve = formals(plot_KMCurve)$font,
    plot_ROC = formals(plot_ROC)$font,
    plot_TimeROC = formals(plot_TimeROC)$font,
    plot_MulROC = formals(plot_MulROC)$font,
    plot_barplot = formals(plot_barplot)$font,
    plot_RiskScore = formals(plot_RiskScore)$font,
    plot_Boxplot = formals(plot_Boxplot)$font,
    plot_GO = formals(plot_GO)$font
  )
  expect_true(all(vapply(defaults, identical, logical(1), "Arial")))
})

test_that("gfplot_font_setup reports one entry per device route", {
  devices <- gfplot_font_setup(quiet = TRUE)
  expect_type(devices, "logical")
  expect_named(devices, c("raster", "quartz", "pdf"), ignore.order = TRUE)
  expect_false(anyNA(devices))
})

test_that("gfplot_font_setup reports the device table when not quiet", {
  expect_message(gfplot_font_setup(), "ragg raster devices")
})

test_that("a missing optional back end reports an actionable error", {
  expect_error(
    gfplot:::gfplot_require("definitely-not-a-package", hint = "Extra context."),
    "install.packages"
  )
  expect_error(
    gfplot:::gfplot_require("definitely-not-a-package", hint = "Extra context."),
    "Extra context"
  )
})

test_that("gfplot_save writes figures that render the figure font", {
  skip_if_not_installed("ragg")
  plot <- plot_Boxplot(c(rnorm(20), rnorm(20, 1)), rep(c("A", "B"), each = 20))

  png_path <- tempfile(fileext = ".png")
  expect_silent(gfplot_save(plot, png_path, width = 4, height = 3))
  expect_true(file.exists(png_path))
  expect_gt(file.size(png_path), 0)
  # The device is always closed again, even when drawing fails part way
  # through.
  expect_equal(unname(grDevices::dev.cur()), 1L)
  unlink(png_path)
})

test_that("gfplot_save validates the file extension", {
  plot <- plot_Boxplot(c(rnorm(20), rnorm(20, 1)), rep(c("A", "B"), each = 20))
  expect_error(gfplot_save(plot, tempfile()), "extension")
  expect_error(gfplot_save(plot, tempfile(fileext = ".bmp")), "Unsupported")
})

test_that("figures render once the requested font is available", {
  skip_if_not(arial_renderable(), "Arial is not registered for this device")

  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path)
  on.exit({
    grDevices::dev.off()
    unlink(path)
  }, add = TRUE)
  expect_silent(
    print(plot_Boxplot(c(rnorm(20), rnorm(20, 1)), rep(c("A", "B"), each = 20)))
  )
})
