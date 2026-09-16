test_that("plot_heatmap draws one tile per cell", {
  m <- matrix(rnorm(20), nrow = 4, dimnames = list(
    paste0("r", 1:4), paste0("c", 1:5)
  ))
  plot <- plot_heatmap(m)

  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(plot$data), 20L)
  expect_equal(levels(plot$data$row), rev(rownames(m)))
  expect_equal(levels(plot$data$column), colnames(m))
})

test_that("a diverging scale centres on the midpoint", {
  # A cell exactly at the midpoint must take the middle colour, which is what
  # makes a diverging scale read as diverging.
  m <- matrix(c(-2, 0, 2), nrow = 1,
              dimnames = list("row", c("low", "mid", "high")))
  plot <- plot_heatmap(m, diverging = TRUE, midpoint = 0)
  built <- ggplot2::ggplot_build(plot)$data[[1]]
  built <- built[order(built$x), , drop = FALSE]
  expect_equal(built$fill[2], "#F7F7F7")

  # Equal distances from the midpoint take the two ends of the scale, which is
  # what makes the colours comparable across the two directions.
  symmetric <- plot_heatmap(
    matrix(c(-1, 1), nrow = 1, dimnames = list("row", c("negative", "positive"))),
    diverging = TRUE, midpoint = 0
  )
  built_symmetric <- ggplot2::ggplot_build(symmetric)$data[[1]]
  built_symmetric <- built_symmetric[order(built_symmetric$x), , drop = FALSE]
  expect_equal(built_symmetric$fill[1], "#2A6F97")
  expect_equal(built_symmetric$fill[2], "#B84A3A")
})

test_that("rows and columns can be ordered explicitly or by clustering", {
  m <- matrix(rnorm(36), nrow = 6,
              dimnames = list(letters[1:6], LETTERS[1:6]))

  explicit <- plot_heatmap(m, row_order = c("c", "a", "b", "d", "e", "f"))
  expect_equal(levels(explicit$data$row), rev(c("c", "a", "b", "d", "e", "f")))

  clustered <- plot_heatmap(m, row_order = "cluster")
  expect_s3_class(clustered, "ggplot")
  expect_equal(nrow(clustered$data), 36L)

  by_value <- plot_heatmap(m, column_order = "value")
  expect_s3_class(by_value, "ggplot")
})

test_that("missing values are drawn as missing, not as zero", {
  m <- matrix(c(1, NA, 3, 4), nrow = 2)
  plot <- plot_heatmap(m)
  fill <- plot$scales$get_scales("fill")
  expect_equal(fill$na.value, "grey92")
  expect_true(anyNA(plot$data$value))
})

test_that("plot_confusion takes counts or two label vectors", {
  predicted <- c(0, 0, 1, 1, 1, 0)
  actual <- c(0, 1, 1, 1, 0, 0)
  from_labels <- plot_confusion(predicted, actual)

  expect_s3_class(from_labels, "ggplot")
  expect_s3_class(from_labels$data, "data.frame")
  expect_equal(sum(from_labels$data$count), length(predicted))

  counts <- table(predicted = predicted, actual = actual)
  from_table <- plot_confusion(actual = counts)
  expect_equal(sum(from_table$data$count), sum(counts))
})

test_that("the positive class is placed on the right and on top", {
  set.seed(1)
  actual <- rbinom(200, 1, 0.4)
  predicted <- actual
  plot <- plot_confusion(predicted, actual, positive = 1)

  levels_used <- levels(plot$data$actual)
  expect_equal(levels_used, c("Negative", "Positive"))
  # The true positives are the positive/positive cell.
  tp <- plot$data[plot$data$predicted == "Positive" &
                    plot$data$actual == "Positive", , drop = FALSE]
  expect_equal(tp$count, sum(actual == 1))
  # Row percentages, so each actual class sums to 100.
  expect_equal(
    sum(plot$data$percent[plot$data$actual == "Positive"]),
    100, tolerance = 1e-8
  )
})

test_that("plot_confusion reports what it cannot draw", {
  # Three predicted classes cannot form a two-by-two table.
  expect_error(
    plot_confusion(c(1, 1, 2, 2, 3, 3), c(1, 2, 1, 2, 1, 2)),
    "two-by-two"
  )
  expect_error(plot_confusion(), "Supply either")
  expect_error(
    plot_confusion(c(1, 2, 3), c(1, 2)),
    "same length"
  )
})

test_that("the printed label follows the requested form", {
  set.seed(2)
  actual <- rbinom(200, 1, 0.5)
  predicted <- ifelse(runif(200) < 0.8, actual, 1 - actual)

  counts <- plot_confusion(predicted, actual, show = "count")
  expect_false(any(grepl("%", counts$data$label)))

  percent <- plot_confusion(predicted, actual, show = "percent")
  expect_true(all(grepl("%", percent$data$label)))

  both <- plot_confusion(predicted, actual, show = "both")
  expect_true(all(grepl("\n", both$data$label)))
})
