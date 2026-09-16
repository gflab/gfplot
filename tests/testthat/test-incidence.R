test_that("cumulative incidence is drawn per group and event type", {
  set.seed(1)
  time <- rexp(300)
  status <- sample(c(0, 1, 2), 300, replace = TRUE, prob = c(0.4, 0.4, 0.2))
  plot <- plot_cumulative_incidence(
    time, status, group = rep(c("A", "B"), 150)
  )

  expect_s3_class(plot, "ggplot")
  expect_equal(sort(unique(plot$data$series)), c("A", "B"))
  expect_equal(sort(unique(plot$data$event)), c("1", "2"))
  # A cumulative incidence is a probability.
  expect_true(all(plot$data$incidence >= 0 & plot$data$incidence <= 1))
})

test_that("a single event type matches the Kaplan-Meier complement", {
  set.seed(2)
  time <- rexp(300)
  status <- rbinom(300, 1, 0.6)
  plot <- plot_cumulative_incidence(time, status)

  km <- survival::survfit(survival::Surv(time, status) ~ 1)
  # Both are functions of time; compare at the largest shared time.
  at_end <- max(plot$data$time)
  reference <- max(1 - km$surv[km$time <= at_end])
  expect_equal(max(plot$data$incidence), reference, tolerance = 1e-10)
})

test_that("a competing event lowers the incidence of the event of interest", {
  # With no competing event every event is of type 1; adding type 2 must not
  # raise the cumulative incidence of type 1.
  set.seed(3)
  time <- rexp(400)
  single <- plot_cumulative_incidence(time, rbinom(400, 1, 0.7))
  status <- ifelse(runif(400) < 0.3, 2, rbinom(400, 1, 0.7))
  competing <- plot_cumulative_incidence(time, status, event = "1")

  expect_lt(max(competing$data$incidence), max(single$data$incidence))
})

test_that("status accepts a factor, a code vector, and characters", {
  set.seed(4)
  time <- rexp(120)
  codes <- sample(c(0, 1, 2), 120, replace = TRUE)

  from_codes <- plot_cumulative_incidence(time, codes)
  from_factor <- plot_cumulative_incidence(time, factor(codes, levels = c(0, 1, 2)))
  from_character <- plot_cumulative_incidence(time, as.character(codes))

  at_end <- function(plot) {
    part <- plot$data[plot$data$event == "1", , drop = FALSE]
    part$incidence[which.max(part$time)]
  }
  expect_equal(at_end(from_codes), at_end(from_factor))
  expect_equal(at_end(from_codes), at_end(from_character))
})

test_that("plot_cumulative_incidence reports unusable input", {
  time <- rexp(50)
  expect_error(
    plot_cumulative_incidence(time, rep(0, 50)),
    "no event types"
  )
  expect_error(
    plot_cumulative_incidence(time, rep(1, 50), event = "9"),
    "not in"
  )
  expect_error(
    plot_cumulative_incidence(time, rep(1, 49)),
    "same length"
  )
})
