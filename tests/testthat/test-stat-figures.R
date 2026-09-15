test_that("plot_barplot summarises groups and supports comparisons", {
  set.seed(9)
  value <- c(rnorm(30), rnorm(30, 1))
  group <- rep(c("A", "B"), each = 30)

  expect_s3_class(plot_barplot(value, group), "ggplot")
  expect_s3_class(
    plot_barplot(value, group, comparisons = list(c("A", "B")), ylab = "Score"),
    "ggplot"
  )
})

test_that("plot_cor applies group colours", {
  set.seed(10)
  x <- rnorm(60)
  y <- x + rnorm(60, sd = 0.5)
  groups <- rep(c("A", "B", "C"), each = 20)

  plain <- plot_cor(x, y)
  grouped <- plot_cor(x, y, groups = groups)
  expect_s3_class(plain, "ggplot")
  expect_s3_class(grouped, "ggplot")
  expect_equal(length(unique(grouped$data$groups)), 3L)
})

test_that("plot_PCA reports variance explained", {
  set.seed(11)
  data <- matrix(rnorm(20 * 10), nrow = 20)
  labs <- rep(c("A", "B"), each = 10)

  plot <- plot_PCA(data, labs)
  expect_s3_class(plot, "ggplot")
  expect_match(plot$labels$x, "^PC1 \\(")
  expect_match(plot$labels$y, "^PC2 \\(")
})

test_that("plot_UMAP requires the umap back end", {
  set.seed(12)
  data <- matrix(rnorm(20 * 5), nrow = 20)
  labs <- rep(c("A", "B"), each = 10)

  if (requireNamespace("umap", quietly = TRUE)) {
    expect_s3_class(plot_UMAP(data, labs), "ggplot")
  } else {
    expect_error(plot_UMAP(data, labs), "umap")
  }
})

test_that("plot_RiskScore orders patients by risk", {
  set.seed(13)
  rs <- stats::rnorm(40)
  event <- stats::rbinom(40, 1, 0.4)

  plot <- plot_RiskScore(rs, event)
  expect_s3_class(plot, "ggplot")
  expect_false(is.unsorted(plot$data$rs))
  expect_equal(nlevels(plot$data$event), 2L)

  logical_plot <- plot_RiskScore(rs, event == 1)
  expect_equal(
    levels(logical_plot$data$event),
    c("Dead/Recurrence", "Disease free")
  )
})

test_that("plot_Boxplot handles factor and non-factor groups", {
  set.seed(14)
  value <- c(rnorm(25), rnorm(25, 1))
  label <- rep(c("A", "B"), each = 25)

  expect_s3_class(plot_Boxplot(value, label), "ggplot")
  expect_s3_class(plot_Boxplot(value, factor(label), title = "Test"), "ggplot")
})
