# The annotation is added before the points, so it is not the last layer.
# Find the layer that carries a text label instead of relying on order.
plot_label <- function(plot) {
  labels <- vapply(plot$layers, function(layer) {
    label <- layer$aes_params$label
    if (is.null(label)) NA_character_ else as.character(label)
  }, character(1))
  labels <- labels[!is.na(labels)]
  if (length(labels) == 0) NA_character_ else labels[1]
}

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

test_that("plot_cor annotates the Pearson correlation and its p-value", {
  set.seed(31)
  x <- rnorm(50)
  y <- 0.7 * x + rnorm(50, sd = 0.5)
  reference <- stats::cor.test(x, y)

  plot <- plot_cor(x, y)
  annotation <- plot_label(plot)
  expect_type(annotation, "character")
  expect_match(annotation, sprintf("%.3f", unname(reference$estimate)))
  # The p-value is formatted by the function, and very small values are
  # reported as a bound, so only its presence is asserted here.
  expect_match(annotation, "P")
  expect_false(grepl("NA", annotation, fixed = TRUE))
})

test_that("plot_cor handles missing values and degenerate input", {
  set.seed(32)
  x <- rnorm(30)
  y <- x + rnorm(30, sd = 0.5)
  x[c(2, 5)] <- NA

  expect_s3_class(plot_cor(x, y), "ggplot")

  # A constant vector has no correlation to estimate; the annotation must
  # degrade instead of failing the whole plot.
  constant <- rep(1, 30)
  plot <- plot_cor(constant, y)
  expect_s3_class(plot, "ggplot")
  expect_match(plot_label(plot), "NA")
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
