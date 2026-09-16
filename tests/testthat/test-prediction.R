binary_case <- function(n = 300, prevalence = 0.3, seed = 1) {
  set.seed(seed)
  outcome <- rbinom(n, 1, prevalence)
  list(
    outcome = outcome,
    good = plogis(outcome * 1.5 + rnorm(n)),
    noise = runif(n)
  )
}

test_that("plot_pr_curve draws one curve per marker", {
  case <- binary_case()
  scores <- cbind(Good = case$good, Noise = case$noise)
  plot <- plot_pr_curve(scores, case$outcome)

  expect_s3_class(plot, "ggplot")
  expect_equal(length(unique(plot$data$group)), 2L)
  # Precision and recall are both proportions.
  expect_true(all(plot$data$precision >= 0 & plot$data$precision <= 1))
  expect_true(all(plot$data$recall >= 0 & plot$data$recall <= 1))
})

test_that("plot_pr_curve ranks a real signal above noise", {
  case <- binary_case(n = 600, prevalence = 0.2, seed = 2)
  plot <- plot_pr_curve(
    cbind(Good = case$good, Noise = case$noise), case$outcome
  )
  # The legend carries the area under each curve.
  labels <- plot$scales$get_scales("colour")$labels
  areas <- as.numeric(sub(".*AUC ([0-9.]+).*", "\\1", labels))
  expect_gt(areas[1], areas[2])
  expect_gt(areas[1], 0.5)
})

test_that("the no-skill reference is the prevalence, not one half", {
  case <- binary_case(n = 400, prevalence = 0.1, seed = 3)
  plot <- plot_pr_curve(case$good, case$outcome)
  reference <- plot$layers[[1]]
  expect_equal(reference$data$yintercept, mean(case$outcome), tolerance = 1e-12)
})

test_that("plot_calibration bins the predictions and reports the counts", {
  case <- binary_case(n = 500, seed = 4)
  plot <- plot_calibration(case$good, case$outcome, bins = 5)

  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(plot$data), 5L)
  expect_true(all(plot$data$observed >= 0 & plot$data$observed <= 1))
  expect_true(all(plot$data$lower <= plot$data$observed))
  expect_true(all(plot$data$upper >= plot$data$observed))
  # Quantile bins hold a similar number of observations each.
  expect_lt(max(plot$data$n) / min(plot$data$n), 2)
})

test_that("a well-calibrated model sits close to the diagonal", {
  set.seed(5)
  probability <- runif(2000)
  outcome <- rbinom(2000, 1, probability)
  plot <- plot_calibration(probability, outcome, bins = 10)
  expect_lt(max(abs(plot$data$observed - plot$data$predicted)), 0.12)
})

test_that("plot_calibration reports impossible input", {
  case <- binary_case(n = 50)
  expect_error(
    plot_calibration(case$good, case$outcome, bins = 1),
    "at least 2"
  )
  expect_error(
    plot_calibration(case$good[1:5], case$outcome[1:5], bins = 10),
    "Not enough observations"
  )
  expect_error(
    plot_calibration(rep(0.5, length(case$outcome)), case$outcome, bins = 5),
    "too few distinct values"
  )
})

test_that("net benefit matches its definition at a threshold", {
  # Three patients, one event, treating all of them.
  probability <- c(0.9, 0.9, 0.9)
  outcome <- c(1, 0, 0)
  threshold <- 0.2
  # 1/3 true positives less 2/3 false positives weighted by 0.2/0.8.
  expected <- 1 / 3 - (2 / 3) * (0.2 / 0.8)
  expect_equal(
    gfplot:::gfplot_net_benefit(probability, outcome, threshold),
    expected
  )
})

test_that("plot_decision_curve includes the two reference strategies", {
  case <- binary_case(n = 300, seed = 6)
  plot <- plot_decision_curve(case$good, case$outcome)

  expect_s3_class(plot, "ggplot")
  # The references are drawn from their own data, so they live in the layer
  # rather than in the plot-level data.
  reference <- plot$layers[[length(plot$layers)]]$data
  expect_true(all(c("Treat all", "Treat none") %in% reference$group))
  # Treat none has zero net benefit at every threshold.
  none <- reference[reference$group == "Treat none", , drop = FALSE]
  expect_true(all(none$net_benefit == 0))
})

test_that("a model with signal beats treating everyone", {
  case <- binary_case(n = 800, prevalence = 0.4, seed = 7)
  plot <- plot_decision_curve(case$good, case$outcome, thresholds = seq(0.2, 0.4, 0.05))
  model <- plot$data[plot$data$group == "good", , drop = FALSE]
  all_treat <- plot$data[plot$data$group == "Treat all", , drop = FALSE]
  expect_true(all(model$net_benefit >= all_treat$net_benefit - 0.02))
})

test_that("thresholds outside the unit interval are rejected", {
  case <- binary_case(n = 100)
  expect_error(
    plot_decision_curve(case$good, case$outcome, thresholds = c(0, 0.5)),
    "strictly between 0 and 1"
  )
  expect_error(
    plot_decision_curve(case$good, case$outcome, thresholds = 1),
    "strictly between 0 and 1"
  )
})

test_that("marker lists accept a vector, a matrix, and a data frame", {
  vector <- gfplot:::gfplot_marker_list(c(1, 2, 3))
  expect_length(vector, 1)
  expect_equal(vector[[1]], c(1, 2, 3))

  frame <- gfplot:::gfplot_marker_list(
    data.frame(A = c(1, 2), B = c(3, 4))
  )
  expect_equal(names(frame), c("A", "B"))

  matrix_input <- gfplot:::gfplot_marker_list(cbind(A = c(1, 2), B = c(3, 4)))
  expect_equal(names(matrix_input), c("A", "B"))

  expect_error(gfplot:::gfplot_marker_list("a"), "must be numeric")
  expect_error(
    gfplot:::gfplot_marker_list(data.frame(A = "a")),
    "must be numeric"
  )
})
