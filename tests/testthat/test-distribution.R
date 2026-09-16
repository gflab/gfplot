test_that("plot_violin draws the requested layers", {
  set.seed(1)
  value <- c(rnorm(40), rnorm(40, 1))
  group <- rep(c("A", "B"), each = 40)

  both <- plot_violin(value, group, show = "both")
  expect_s3_class(both, "ggplot")
  # Violin, boxplot, points, and the count labels.
  geoms <- vapply(both$layers, function(layer) class(layer$geom)[1], character(1))
  expect_true(any(grepl("Violin", geoms)))
  expect_true(any(grepl("Boxplot", geoms)))

  violin_only <- plot_violin(value, group, show = "violin")
  expect_false(any(grepl("Boxplot", vapply(
    violin_only$layers, function(l) class(l$geom)[1], character(1)
  ))))
})

test_that("observations are drawn only when the group sizes allow it", {
  set.seed(2)
  many <- plot_violin(rnorm(1000), rep(c("A", "B"), 500), points_maximum = 300)
  geoms <- vapply(many$layers, function(l) class(l$geom)[1], character(1))
  expect_false(any(grepl("Point", geoms)))

  few <- plot_violin(rnorm(100), rep(c("A", "B"), 50), points_maximum = 300)
  geoms <- vapply(few$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("Point", geoms)))
})

test_that("the observation count is printed per group", {
  set.seed(3)
  value <- c(rnorm(30), rnorm(50))
  plot <- plot_violin(value, rep(c("A", "B"), c(30, 50)))
  text_layer <- plot$layers[[length(plot$layers)]]
  expect_equal(sort(text_layer$data$label), c("n = 30", "n = 50"))
})

test_that("plot_violin accepts an explicit group order", {
  set.seed(4)
  value <- c(rnorm(20), rnorm(20), rnorm(20))
  group <- rep(c("low", "mid", "high"), each = 20)
  plot <- plot_violin(value, group, order = c("low", "high", "mid"))
  expect_equal(levels(plot$data$group), c("low", "high", "mid"))

  expect_error(
    plot_violin(value, group, order = c("low", "mid")),
    "does not name every group"
  )
})

test_that("plot_violin reports unusable input", {
  expect_error(plot_violin("a", c(1, 2)), "must be numeric")
  expect_error(plot_violin(c(1, 2, 3), c("a", "b")), "same length")
  expect_message(
    plot_violin(c(1, 2, NA), c("a", "b", "c")),
    "Dropping 1 observation"
  )
})
