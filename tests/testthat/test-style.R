test_that("house colours resolve by role and by alias", {
  expect_equal(unname(gfplot_colors("primary")), "#0B4F6C")
  expect_equal(
    unname(gfplot_colors("model_curve")),
    unname(gfplot_colors("primary"))
  )
  expect_equal(
    unname(gfplot_colors("comparator_curve")),
    unname(gfplot_colors("secondary"))
  )
  expect_equal(
    unname(gfplot_colors("reference_line")),
    unname(gfplot_colors("neutral"))
  )
})

test_that("house colours accept a vector of roles and raw hex values", {
  both <- gfplot_colors(c("model_curve", "comparator_curve"))
  expect_length(both, 2)
  expect_equal(names(both), c("model_curve", "comparator_curve"))
  expect_equal(unname(both), c("#0B4F6C", "#2A9D8F"))

  mixed <- gfplot_colors(c("#123456", "primary"))
  expect_equal(unname(mixed), c("#123456", "#0B4F6C"))
})

test_that("house colours return a full palette and an ordered series ramp", {
  all_roles <- gfplot_colors("all")
  expect_type(all_roles, "character")
  expect_true(all(c("primary", "secondary", "text", "grid") %in% names(all_roles)))
  expect_true(all(grepl("^#", all_roles)))

  series <- gfplot_colors("series")
  expect_equal(
    unname(series),
    c("#0B4F6C", "#2A9D8F", "#B84A3A", "#D99A2B", "#6F63B6", "#767676")
  )
})

test_that("a session can retune the palette without editing figures", {
  withr::local_options(gfplot.palette = list(primary = "#123456"))
  expect_equal(unname(gfplot_colors("primary")), "#123456")
  expect_equal(
    unname(gfplot_colors("model_curve")),
    "#123456",
    info = "aliases follow an overridden role"
  )
  # A role that was not overridden keeps its default.
  expect_equal(unname(gfplot_colors("secondary")), "#2A9D8F")
})

test_that("an unknown colour role is reported with the available ones", {
  expect_error(gfplot_colors("not-a-role"), "Unknown colour role")
  expect_error(gfplot_colors("not-a-role"), "Available roles")
})

test_that("risk-group labels take paired colours regardless of spelling", {
  variants <- list(
    c("Low Risk", "High Risk"),
    c("low-risk", "high-risk"),
    c("Low risk", "High risk"),
    c("lowrisk", "highrisk")
  )
  for (labels in variants) {
    colors <- gfplot_group_colors(labels)
    expect_equal(unname(colors[1]), "#0B4F6C", info = labels[1])
    expect_equal(unname(colors[2]), "#2A9D8F", info = labels[2])
  }
})

test_that("ungrouped labels walk the series ramp", {
  colors <- gfplot_group_colors(c("A", "B", "C"))
  expect_equal(unname(colors), c("#0B4F6C", "#2A9D8F", "#B84A3A"))
  expect_equal(names(colors), c("A", "B", "C"))
})

test_that("the house theme carries the publication settings", {
  theme <- gfplot_theme(base_size = 11, font = "Arial")
  expect_s3_class(theme, "theme")
  # Bold axis titles, a panel border, and no minor grid.
  expect_equal(theme$axis.title$face, "bold")
  expect_s3_class(theme$panel.border, "element_rect")
  expect_s3_class(theme$panel.grid.minor, "element_blank")
  expect_equal(theme$text$family, "Arial")
  expect_equal(theme$legend.position, "bottom")
})

test_that("the theme scales with base_size and can drop chrome", {
  small <- gfplot_theme(base_size = 8)
  large <- gfplot_theme(base_size = 16)
  expect_lt(small$axis.text$size, large$axis.text$size)

  plain <- gfplot_theme(grid = FALSE, border = FALSE, legend = "none")
  expect_s3_class(plain$panel.grid.major, "element_blank")
  expect_s3_class(plain$panel.border, "element_blank")
  expect_equal(plain$legend.position, "none")
})

test_that("legends wrap by series count and hide a single series", {
  expect_identical(gfplot_legend("only"), "none")
  expect_identical(
    gfplot_legend(c("a", "b"), hide_single = FALSE),
    gfplot_legend(c("a", "b"))
  )

  # ggplot2 4.0 stores guide settings under `params`.
  row_count <- function(labels) gfplot_legend(labels)$params$nrow
  expect_equal(row_count(c("a", "b", "c")), 1)
  expect_equal(row_count(c("a", "b", "c", "d")), 2)
  expect_equal(row_count(paste0("s", 1:7)), 3)
})
