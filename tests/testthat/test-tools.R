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

test_that("gfplot_font_setup reports whether Arial can be registered", {
  skip_if_not_installed("extrafont")
  expect_type(gfplot_font_setup(quiet = TRUE), "logical")
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
