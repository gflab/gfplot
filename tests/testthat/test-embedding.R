test_that("plot_embedding computes the requested projection", {
  set.seed(1)
  data <- matrix(rnorm(40 * 10), nrow = 40)
  groups <- rep(c("A", "B"), each = 20)

  pca <- plot_embedding(data, groups, method = "pca")
  expect_s3_class(pca, "ggplot")
  # The variance explained is reported on the axes.
  expect_match(pca$labels$x, "^PC1 \\(")
  expect_match(pca$labels$y, "^PC2 \\(")

  supplied <- plot_embedding(
    cbind(rnorm(40), rnorm(40)), groups, method = "none"
  )
  expect_s3_class(supplied, "ggplot")
  expect_equal(supplied$labels$x, "Component 1")
})

test_that("plot_embedding marks the axes of each method", {
  skip_if_not_installed("umap")
  skip_if_not_installed("Rtsne")
  set.seed(2)
  # t-SNE needs perplexity below (n - 1) / 3, so 60 samples support 5.
  data <- matrix(rnorm(60 * 8), nrow = 60)
  groups <- rep(c("A", "B", "C"), each = 20)

  expect_equal(
    plot_embedding(data, groups, method = "umap")$labels$x, "UMAP 1"
  )
  expect_equal(
    plot_embedding(data, groups, method = "tsne", perplexity = 5)$labels$x,
    "t-SNE 1"
  )
})

test_that("t-SNE reports a perplexity the data cannot support", {
  skip_if_not_installed("Rtsne")
  set.seed(6)
  data <- matrix(rnorm(30 * 5), nrow = 30)
  groups <- rep(c("A", "B"), each = 15)

  # The default of 30 cannot work for 30 samples; the message must say so and
  # name a value that can.
  expect_error(
    plot_embedding(data, groups, method = "tsne"),
    "too large for 30 samples"
  )
  expect_error(
    plot_embedding(data, groups, method = "tsne"),
    "t-SNE needs perplexity below"
  )
  expect_s3_class(
    plot_embedding(data, groups, method = "tsne", perplexity = 5),
    "ggplot"
  )
})

test_that("an ellipse is drawn only for groups large enough to support one", {
  set.seed(3)
  data <- matrix(rnorm(30 * 5), nrow = 30)
  # One group has three samples, which cannot support a confidence ellipse.
  groups <- c(rep("A", 27), rep("B", 3))
  expect_message(
    plot <- plot_embedding(data, groups, method = "none", ellipse = TRUE),
    NA
  )
  # stat_ellipse() draws with the path geom, so the stat is what identifies it.
  stats <- vapply(plot$layers, function(l) class(l$stat)[1], character(1))
  expect_true(any(grepl("Ellipse", stats)))

  expect_message(
    plot_embedding(
      matrix(rnorm(4 * 5), nrow = 4), rep(c("A", "B"), 2),
      method = "none", ellipse = TRUE
    ),
    "fewer than four"
  )
})

test_that("group colours pair risk labels regardless of spelling", {
  set.seed(4)
  data <- cbind(rnorm(40), rnorm(40))
  plot <- plot_embedding(
    data, rep(c("Low risk", "High risk"), 20), method = "none"
  )
  # The scale answers in level order, which is alphabetical here.
  values <- plot$scales$get_scales("colour")$palette(2)
  expect_equal(unname(values["Low risk"]), unname(gfplot_colors("primary")))
  expect_equal(unname(values["High risk"]), unname(gfplot_colors("secondary")))
})

test_that("plot_embedding reports unusable input", {
  expect_error(
    plot_embedding(matrix(rnorm(20), nrow = 10), c("A", "B")),
    "one row per sample"
  )
  expect_error(
    plot_embedding(matrix(letters[1:20], nrow = 10), rep(c("A", "B"), 5)),
    "must be numeric"
  )
})

test_that("the wrappers agree with the general function", {
  set.seed(5)
  data <- matrix(rnorm(30 * 6), nrow = 30)
  groups <- rep(c("A", "B"), each = 15)

  expect_equal(
    plot_PCA(data, groups)$data,
    plot_embedding(data, groups, method = "pca")$data
  )
})
