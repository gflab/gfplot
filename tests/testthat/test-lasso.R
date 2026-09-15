test_that("plot_lasso draws coefficient paths", {
  skip_if_not_installed("glmnet")
  set.seed(15)
  x <- matrix(stats::rnorm(120 * 6), nrow = 120)
  y <- x[, 1] - 0.5 * x[, 2] + stats::rnorm(120, sd = 0.5)
  fit <- glmnet::glmnet(x, y)

  plot <- plot_lasso(fit, s = 0.05)
  expect_s3_class(plot, "ggplot")
  expect_true(all(plot$data$lambda >= 0.05))
  expect_false(any(plot$data$coef == "(Intercept)"))
})
