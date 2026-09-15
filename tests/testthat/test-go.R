test_that("plot_GO orders terms by gene ratio", {
  gsea <- data.frame(
    term_name = c("Term A", "Term B", "Term C"),
    p_value = c(0.001, 0.01, 0.05),
    intersection_size = c(5, 10, 2),
    query_size = c(50, 50, 50)
  )
  plot <- plot_GO(gsea, n = 2)

  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(plot$data), 2L)
  expect_true(all(diff(plot$data$GeneRatio) >= 0))
})

test_that("enrichment plots require their back ends", {
  skip_if(requireNamespace("DOSE", quietly = TRUE))
  expect_error(
    ggGSEA(stats::setNames(stats::rnorm(100), paste0("g", 1:100)), paste0("g", 1:10)),
    "DOSE"
  )
})

test_that("plot_immune requires ggradar", {
  skip_if_not_installed("ggradar")
  res <- data.frame(
    cell = c("B cell", "T cell"),
    s1 = c(1, 2), s2 = c(2, 3), s3 = c(3, 4), s4 = c(4, 5),
    check.names = FALSE
  )
  group <- c(s1 = "A", s2 = "A", s3 = "B", s4 = "B")
  expect_s3_class(plot_immune(res, group), "ggplot")
})
