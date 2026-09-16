test_that("journal size presets use the standard column widths", {
  presets <- gfplot:::gfplot_size_presets()
  expect_equal(unname(presets$single[["width"]]), 85 / 25.4, tolerance = 1e-8)
  expect_equal(unname(presets$onehalf[["width"]]), 114 / 25.4, tolerance = 1e-8)
  expect_equal(unname(presets$double[["width"]]), 170 / 25.4, tolerance = 1e-8)
  # A slide preset keeps its 16:9 shape.
  expect_equal(
    unname(presets$slide[["width"]] / presets$slide[["height"]]),
    16 / 9, tolerance = 1e-8
  )
})

test_that("an explicit dimension overrides the preset", {
  dimensions <- gfplot:::gfplot_dimensions("single", width = 4, height = NULL)
  expect_equal(dimensions$width, 4)
  expect_equal(dimensions$height, unname(gfplot:::gfplot_size_presets()$single[["height"]]))
})

test_that("without a preset the historical default still applies", {
  dimensions <- gfplot:::gfplot_dimensions(NULL, NULL, NULL)
  expect_equal(dimensions$width, 7)
  expect_equal(dimensions$height, 5)
})

test_that("an unknown size is reported with the available ones", {
  expect_error(gfplot:::gfplot_dimensions("poster", NULL, NULL), "Unknown size")
  expect_error(gfplot:::gfplot_dimensions("poster", NULL, NULL), "single")
})

test_that("gfplot_save writes the requested size", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("jsonlite")
  plot <- plot_Boxplot(c(rnorm(20), rnorm(20, 1)), rep(c("A", "B"), each = 20))
  path <- tempfile(fileext = ".png")
  on.exit(unlink(c(path, sub("[.]png$", ".provenance.json", path))), add = TRUE)

  gfplot_save(plot, path, size = "double", provenance = TRUE)
  record <- jsonlite::fromJSON(sub("[.]png$", ".provenance.json", path))
  expect_equal(record$output$width_in, 170 / 25.4, tolerance = 1e-6)
  expect_equal(record$output$format, "png")
})

test_that("provenance records what produced the figure", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("jsonlite")
  effects <- data.frame(
    term = c("A", "B"), hr = c(1.2, 0.8),
    lower = c(1.0, 0.6), upper = c(1.4, 1.0)
  )
  spec <- gfplot_spec(
    "forest", data = effects, term = "term",
    estimate = "hr", lower = "lower", upper = "upper", show_table = FALSE
  )
  path <- tempfile(fileext = ".png")
  json_path <- sub("[.]png$", ".provenance.json", path)
  on.exit(unlink(c(path, json_path)), add = TRUE)

  result <- gfplot_save(gfplot_render(spec), path, provenance = TRUE)
  expect_equal(attr(result, "provenance"), json_path)
  expect_true(file.exists(json_path))

  record <- jsonlite::fromJSON(json_path)
  expect_equal(record$schema, "gfplot.provenance.v1")
  expect_equal(record$figure$kind, "spec")
  expect_equal(record$figure$family, "forest")
  expect_equal(record$font, "Arial")
  expect_equal(record$environment$gfplot, as.character(utils::packageVersion("gfplot")))
  # R reports itself as "R version x.y.z" on a release and "R Under
  # development (unstable) (...)" on devel, and both are the true
  # environment the figure was drawn in, so the assertion is that the field
  # names R and carries a version rather than that it matches one wording.
  expect_match(record$environment$r, "^R ")
  expect_match(record$environment$r, "[0-9]+\\.[0-9]+")
  # The hash is of the closed file, so it has to be present and non-empty.
  if (requireNamespace("digest", quietly = TRUE)) {
    expect_equal(record$output$sha256, digest::digest(file = path, algo = "sha256"))
  }
})

test_that("provenance is off unless asked for", {
  skip_if_not_installed("ragg")
  plot <- plot_Boxplot(c(rnorm(20), rnorm(20, 1)), rep(c("A", "B"), each = 20))
  path <- tempfile(fileext = ".png")
  json_path <- sub("[.]png$", ".provenance.json", path)
  on.exit(unlink(path), add = TRUE)

  gfplot_save(plot, path)
  expect_true(file.exists(path))
  expect_false(file.exists(json_path))
})

test_that("the JSON writer emits the shapes provenance uses", {
  to_json <- gfplot:::gfplot_to_json
  expect_equal(to_json("a"), "\"a\"")
  expect_equal(to_json(1.5), "1.5")
  expect_equal(to_json(TRUE), "true")
  expect_equal(to_json(NA), "null")
  expect_equal(to_json(c("a", "b")), "[\"a\", \"b\"]")
  # Quotes and newlines are escaped rather than breaking the document.
  expect_equal(to_json("a\"b"), "\"a\\\"b\"")
  expect_equal(to_json("a\nb"), "\"a\\nb\"")
  expect_equal(to_json(list()), "{}")
})
