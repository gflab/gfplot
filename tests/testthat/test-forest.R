forest_effects <- function() {
  data.frame(
    term = c("Age, per year", "Male sex", "Stage III vs II", "MSI-high"),
    hr = c(1.02, 1.14, 1.84, 0.62),
    lower = c(0.99, 0.97, 1.51, 0.44),
    upper = c(1.05, 1.35, 2.24, 0.88),
    p = c(0.21, 0.12, 4.1e-07, 0.008),
    group = c("Clinical", "Clinical", "Clinical", "Molecular"),
    stringsAsFactors = FALSE
  )
}

test_that("plot_forest draws estimates with intervals", {
  effects <- forest_effects()
  plot <- plot_forest(
    effects,
    term = "term", estimate = "hr", lower = "lower", upper = "upper",
    show_table = FALSE
  )
  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(plot$data), 4L)
})

test_that("a log axis is used for ratios and a linear axis for differences", {
  effects <- forest_effects()
  ratio <- plot_forest(
    effects, term = "term", estimate = "hr", lower = "lower",
    upper = "upper", log_scale = TRUE, show_table = FALSE
  )
  # ggplot2 reports the transformation rather than a distinct scale class.
  expect_equal(ratio$scales$get_scales("x")$trans$name, "log-10")

  differences <- data.frame(
    term = c("A", "B"), diff = c(-1.5, 2.4),
    lower = c(-2.5, 0.8), upper = c(-0.4, 4.1)
  )
  linear <- plot_forest(
    differences, term = "term", estimate = "diff",
    lower = "lower", upper = "upper", show_table = FALSE
  )
  expect_equal(linear$scales$get_scales("x")$trans$name, "identity")
  # A difference scale may cross zero, and the reference line follows it.
  expect_equal(linear$layers[[1]]$data$xintercept, 0)
})

test_that("plot_forest reports unusable input instead of drawing it", {
  effects <- forest_effects()
  expect_error(
    plot_forest(effects, term = "nope", estimate = "hr",
                lower = "lower", upper = "upper"),
    "missing the column"
  )
  expect_error(
    plot_forest(effects, term = "term", estimate = "hr",
                lower = "lower", upper = "upper", log_scale = TRUE,
                show_table = FALSE),
    NA
  )

  negative <- effects
  negative$lower[1] <- -0.5
  expect_error(
    plot_forest(negative, term = "term", estimate = "hr",
                lower = "lower", upper = "upper", log_scale = TRUE,
                show_table = FALSE),
    "positive confidence limits"
  )

  inverted <- effects
  inverted$lower[1] <- 1.5
  inverted$upper[1] <- 0.9
  expect_error(
    plot_forest(inverted, term = "term", estimate = "hr",
                lower = "lower", upper = "upper"),
    "lower limit above the upper"
  )
})

test_that("rows with an incomplete interval are dropped with a notice", {
  effects <- forest_effects()
  effects$upper[2] <- NA
  expect_message(
    plot <- plot_forest(
      effects, term = "term", estimate = "hr", lower = "lower",
      upper = "upper", show_table = FALSE
    ),
    "Dropping 1 row"
  )
  expect_equal(nrow(plot$data), 3L)
})

test_that("the table is a composed panel, as with the risk table", {
  effects <- forest_effects()
  with_table <- plot_forest(
    effects, term = "term", estimate = "hr", lower = "lower",
    upper = "upper", p = "p"
  )
  # cowplot::plot_grid() returns a drawable ggplot object built from the two
  # panels, so it accepts the same print and save path as a single plot.
  expect_s3_class(with_table, "gg")
  expect_silent(ggplot2::ggplot_build(with_table))

  without <- plot_forest(
    effects, term = "term", estimate = "hr", lower = "lower",
    upper = "upper", p = "p", show_table = FALSE
  )
  expect_s3_class(without, "ggplot")
})

test_that("grouping facets the plot and keeps headings per section", {
  effects <- forest_effects()
  plot <- plot_forest(
    effects, term = "term", estimate = "hr", lower = "lower",
    upper = "upper", p = "p", group = "group", show_table = FALSE
  )
  expect_s3_class(plot, "ggplot")
  expect_s3_class(plot$facet, "FacetGrid")

  # The table rows carry the facet variable, so a row is drawn in its own
  # panel rather than repeated across all of them.
  prepared <- gfplot:::forest_prepare(
    effects, "term", "hr", "lower", "upper", p = "p", group = "group"
  )
  table_panel <- gfplot:::forest_table_panel(
    prepared, 2, "Estimate (95% CI)", "P", "Arial"
  )
  expect_true("group" %in% names(table_panel$data))
  expect_equal(nrow(table_panel$data), 4L)
})

test_that("p-values are formatted the way a table reads", {
  expect_equal(
    gfplot:::format_p_values(c(0.21, 0.0004, 0.008, NA)),
    c("0.210", "<0.001", "0.008", "")
  )
})

test_that("plot_forest reads a clinstats table without reshaping", {
  skip_if_not_installed("clinstats")
  table <- clinstats::cox_table(
    clinstats::clin_crc,
    time = "rfs.delay", event = "rfs.event",
    factors = c("sex", "age", "tnm.stage"),
    multivariable = "none"
  )
  plot <- plot_forest(
    table,
    term = "term", estimate = "hr_univariable",
    lower = "univ_ci_lower", upper = "univ_ci_upper", p = "univ_p",
    log_scale = TRUE
  )
  expect_s3_class(plot, "gg")
  expect_equal(nrow(plot$plot$data), 3L)
})
