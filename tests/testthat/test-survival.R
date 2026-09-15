test_that("plot_KMCurve returns a plot for two groups", {
  skip_if_not_installed("survminer")
  lung <- survival::lung
  keep <- stats::complete.cases(lung[, c("time", "status", "sex")])
  clinical <- survival::Surv(lung$time[keep], lung$status[keep] == 2)
  labels <- factor(lung$sex[keep], labels = c("Male", "Female"))

  plot <- plot_KMCurve(clinical, labels, risk.table = FALSE)
  expect_s3_class(plot, "ggplot")
})

test_that("plot_KMCurve can build the risk table layout", {
  skip_if_not_installed("survminer")
  lung <- survival::lung
  keep <- stats::complete.cases(lung[, c("time", "status", "sex")])
  clinical <- survival::Surv(lung$time[keep], lung$status[keep] == 2)

  plot <- plot_KMCurve(clinical, factor(lung$sex[keep]), risk.table = TRUE)
  expect_s3_class(plot, "ggplot")
})

test_that("hazard ratios come from a univariable Cox model", {
  set.seed(7)
  group <- factor(rep(c("A", "B"), each = 60))
  time <- c(stats::rexp(60, 0.1), stats::rexp(60, 0.2))
  event <- stats::rbinom(120, 1, 0.8)

  hr <- gfplot:::cox_hazard_ratio(group, time, event)
  reference <- survival::coxph(survival::Surv(time, event) ~ group)
  ci <- summary(reference)$conf.int

  expect_equal(hr[1], ci[1, 1])
  expect_equal(hr[2], ci[1, 3])
  expect_equal(hr[3], ci[1, 4])
})

test_that("logical and character groups are accepted", {
  skip_if_not_installed("survminer")
  set.seed(8)
  group <- stats::rbinom(80, 1, 0.5)
  time <- stats::rexp(80, rate = ifelse(group == 1, 0.08, 0.16))
  event <- stats::rbinom(80, 1, 0.7)
  clinical <- survival::Surv(time, event)

  expect_s3_class(
    plot_KMCurve(clinical, group == 1, risk.table = FALSE),
    "ggplot"
  )
  expect_s3_class(
    plot_KMCurve(clinical, ifelse(group == 1, "high", "low"),
                 risk.table = FALSE),
    "ggplot"
  )
})
