test_that("gfplot_families indexes what the package can draw", {
  families <- gfplot_families()
  expect_s3_class(families, "tbl_df")
  expect_true(all(c(
    "family", "category", "type", "function_name", "call"
  ) %in% names(families)))
  expect_true("forest" %in% families$family)
  # The function-based families are listed too, so the index is complete.
  expect_true(all(c("plot_KMCurve", "plot_ROC", "plot_forest") %in% families$function_name))
  expect_true(all(families$type %in% c("spec", "function")))
  # Every family names the function a user would call.
  expect_false(anyNA(families$function_name))
})

test_that("gfplot_families filters by category", {
  effects <- gfplot_families("Effect Estimate")
  expect_gt(nrow(effects), 0)
  expect_true(all(effects$category == "Effect Estimate"))
  expect_true("forest" %in% effects$family)

  expect_error(gfplot_families("No Such Category"), "No figure family matches")
})

test_that("a specification validates and reports its family", {
  effects <- data.frame(
    term = c("A", "B"), hr = c(1.2, 0.8),
    lower = c(1.0, 0.6), upper = c(1.4, 1.0)
  )
  spec <- gfplot_spec(
    "forest", data = effects, term = "term",
    estimate = "hr", lower = "lower", upper = "upper"
  )
  expect_s3_class(spec, "gfplot_spec")
  expect_equal(spec$family, "forest")
  expect_equal(spec$version, 1L)
  expect_message(print(spec), "forest")
})

test_that("a specification reports what it is missing", {
  effects <- data.frame(term = "A", hr = 1.2, lower = 1.0, upper = 1.4)
  expect_error(
    gfplot_spec("forest", data = effects, term = "term", estimate = "hr"),
    "missing"
  )
  expect_error(
    gfplot_spec("forest", data = effects, term = "nope",
                estimate = "hr", lower = "lower", upper = "upper"),
    "missing the column"
  )
  expect_error(gfplot_spec("not-a-family"), "Unknown figure family")
  expect_error(
    gfplot_spec("forest", data = "not a data frame", term = "a",
                estimate = "b", lower = "c", upper = "d"),
    "must be a data frame"
  )
})

test_that("gfplot_render draws a specification", {
  effects <- data.frame(
    term = c("A", "B"), hr = c(1.2, 0.8),
    lower = c(1.0, 0.6), upper = c(1.4, 1.0)
  )
  spec <- gfplot_spec(
    "forest", data = effects, term = "term",
    estimate = "hr", lower = "lower", upper = "upper", show_table = FALSE
  )
  plot <- gfplot_render(spec)
  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(plot$data), 2L)

  direct <- plot_forest(
    effects, term = "term", estimate = "hr",
    lower = "lower", upper = "upper", show_table = FALSE
  )
  # The specification path and the function path draw the same figure.
  expect_equal(plot$data, direct$data)
})

test_that("gfplot_render rejects anything that is not a specification", {
  expect_error(gfplot_render(list(family = "forest")), "must be a figure specification")
  expect_error(gfplot_render("forest"), "must be a figure specification")
})
