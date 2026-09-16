test_that("plot_volcano classifies features by both thresholds", {
  set.seed(1)
  effect <- c(-3, -0.2, 0.2, 3, 0)
  p_value <- c(0.0001, 0.0001, 0.0001, 0.0001, 0.9)
  plot <- plot_volcano(effect, p_value, paste0("g", 1:5))

  expect_s3_class(plot, "ggplot")
  classes <- plot$data$class[match(paste0("g", 1:5), plot$data$label)]
  expect_equal(as.character(classes), c("Down", "Not significant",
                                        "Not significant", "Up",
                                        "Not significant"))
})

test_that("plot_volcano labels only the most significant features", {
  set.seed(2)
  effect <- rnorm(500)
  p_value <- runif(500)^3

  few <- plot_volcano(effect, p_value, paste0("g", 1:500), label_top = 5)
  text_layer <- few$layers[[length(few$layers)]]
  expect_lte(nrow(text_layer$data), 5)

  none <- plot_volcano(effect, p_value, paste0("g", 1:500), label_top = 0)
  # Without labels the figure is the two threshold lines and the points.
  expect_equal(length(none$layers), 3L)
  expect_false(any(vapply(
    none$layers, function(l) grepl("Text", class(l$geom)[1]), logical(1)
  )))
})

test_that("plot_volcano reports unusable input", {
  expect_error(
    plot_volcano(c(1, 2), c(0.1), c("a", "b")),
    "same length"
  )
  expect_error(
    plot_volcano(c(1, 2), c(0.1, 0.2), c("a", "b"), p_threshold = 1),
    "strictly between 0 and 1"
  )
  expect_error(
    plot_volcano(c(1, 2), c(0.1, 0.2), c("a", "b"), effect_threshold = -1),
    "not be negative"
  )
  # Features without a usable p-value are dropped with a notice.
  expect_message(
    plot_volcano(c(1, 2, 3), c(0.1, 0, 0.3), c("a", "b", "c")),
    "Dropping 1 feature"
  )
})

test_that("plot_waterfall ranks patients and assigns response categories", {
  response <- c(-40, -25, -10, 5, 30, 60)
  plot <- plot_waterfall(response)

  expect_s3_class(plot, "ggplot")
  # First patient drawn is the largest response.
  expect_equal(plot$data$response[1], 60)
  expect_equal(plot$data$response, sort(response, decreasing = TRUE))
  # RECIST-style cut-offs: <= -30 partial response, > 20 progression.
  expect_equal(
    as.character(plot$data$category),
    c("Progressive disease", "Progressive disease", "Stable disease",
      "Stable disease", "Stable disease", "Partial response")
  )
})

test_that("plot_waterfall accepts explicit categories", {
  response <- c(10, 20, 30)
  plot <- plot_waterfall(response, category = c("A", "B", "B"))
  expect_equal(sort(unique(as.character(plot$data$category))), c("A", "B"))
})

test_that("plot_waterfall reports unusable input", {
  expect_error(plot_waterfall(c(1, 2, 3), patient = c("a", "b")), "same length")
  expect_message(plot_waterfall(c(1, 2, NA)), "Dropping 1 patient")
  expect_error(plot_waterfall(c(1, NA)), "At least two patients")
})

test_that("response categories follow the supplied thresholds", {
  response <- c(-50, -10, 10, 50)
  categories <- gfplot:::gfplot_response_category(
    response, c("Partial response" = -30, "Stable disease" = 20)
  )
  expect_equal(
    categories,
    c("Partial response", "Stable disease", "Stable disease",
      "Progressive disease")
  )
})
