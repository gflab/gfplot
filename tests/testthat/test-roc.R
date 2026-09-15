test_that("plot_ROC handles a single marker", {
  set.seed(2)
  scores <- c(rnorm(50), rnorm(50, 1))
  labels <- rep(c(0, 1), each = 50)

  expect_s3_class(plot_ROC(scores, labels), "ggplot")
  expect_s3_class(plot_ROC(scores, labels, percent.style = TRUE), "ggplot")
})

test_that("plot_ROC handles several markers", {
  set.seed(3)
  scores <- cbind(
    marker1 = c(rnorm(50), rnorm(50, 1)),
    marker2 = c(rnorm(50), rnorm(50, 0.5))
  )
  labels <- rep(c(0, 1), each = 50)

  plot <- plot_ROC(scores, labels, title = "Two markers")
  expect_s3_class(plot, "ggplot")
})

test_that("plot_MulROC plots one curve per cohort", {
  set.seed(4)
  scores <- list(
    cohortA = c(rnorm(40), rnorm(40, 1)),
    cohortB = c(rnorm(40), rnorm(40, 0.8))
  )
  labels <- list(
    rep(c(0, 1), each = 40),
    rep(c(0, 1), each = 40)
  )

  plot <- plot_MulROC(scores, labels)
  expect_s3_class(plot, "ggplot")
  expect_s3_class(plot_MulROC(scores, labels, color = c("red", "blue")), "ggplot")
})

test_that("plot_TimeROC requires the survivalROC back end", {
  set.seed(5)
  clinical <- survival::Surv(stats::rexp(80), stats::rbinom(80, 1, 0.6))
  marker <- stats::rnorm(80)

  if (requireNamespace("survivalROC", quietly = TRUE)) {
    plot <- plot_TimeROC(marker, clinical, c(1, 2), c("t1", "t2"))
    expect_s3_class(plot, "ggplot")
  } else {
    expect_error(
      plot_TimeROC(marker, clinical, c(1, 2), c("t1", "t2")),
      "survivalROC"
    )
  }
})
