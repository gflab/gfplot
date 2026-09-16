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

test_that("plot_ROC reports the area under the curve it draws", {
  # A reversed marker is drawn below the diagonal, so the legend must report
  # the matching value. In 0.1.0 the curve came from one package and the
  # legend from another, and the two disagreed.
  set.seed(21)
  labels <- rep(c(0, 1), each = 60)
  reversed <- c(rnorm(60, 1), rnorm(60))

  plot <- plot_ROC(reversed, labels)
  drawn <- plot$data
  expect_true(mean(drawn$TPR) < mean(drawn$FPR))

  truth <- as.numeric(pROC::auc(
    pROC::roc(labels, reversed, direction = "<", quiet = TRUE)
  ))
  expect_lt(truth, 0.5)
  expect_match(plot$scales$scales[[1]]$labels, sprintf("%.2f", truth))
})

test_that("plot_ROC keeps a good marker above the diagonal", {
  set.seed(22)
  labels <- rep(c(0, 1), each = 60)
  good <- c(rnorm(60), rnorm(60, 1))

  plot <- plot_ROC(good, labels)
  expect_true(mean(plot$data$TPR) > mean(plot$data$FPR))
  truth <- as.numeric(pROC::auc(
    pROC::roc(labels, good, direction = "<", quiet = TRUE)
  ))
  expect_gt(truth, 0.5)
  expect_match(plot$scales$scales[[1]]$labels, sprintf("%.2f", truth))
})

test_that("force05 flips reversed markers so every curve rises", {
  set.seed(23)
  labels <- rep(c(0, 1), each = 60)
  scores <- cbind(
    good = c(rnorm(60), rnorm(60, 1)),
    reversed = c(rnorm(60, 1), rnorm(60))
  )

  plot <- plot_ROC(scores, labels, force05 = TRUE)
  rising <- vapply(split(plot$data, plot$data$group), function(d) {
    mean(d$TPR) > mean(d$FPR)
  }, logical(1))
  expect_true(all(rising))
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
