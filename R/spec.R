# The plot specification layer.
#
# gfplot%27s plotting functions take R objects and draw immediately. That is the
# right interface for a person at a prompt, and it stays. A specification adds
# a second, programmatic entry point: the arguments of a figure become a value
# that can be validated, printed, serialised, and rendered later.
#
# The reason to have both is that a figure is often produced somewhere other
# than where it is decided. A pipeline, a report template, or an agent has the
# numbers and a description of the chart it wants; a specification is the
# thing it hands over.

# Families whose arguments are captured in a specification and drawn by
# gfplot_render(). Each entry owns its validation and its drawing, so adding a
# family is adding an entry rather than editing a dispatcher.
gfplot_family_registry <- function() {
  list(
    forest = list(
      title = "Forest plot",
      category = "Effect Estimate",
      status = "stable",
      function_name = "plot_forest",
      description = paste(
        "Effect estimates with confidence intervals, optionally grouped and",
        "with an estimate table on the right."
      ),
      arguments = c("data", "term", "estimate", "lower", "upper"),
      validate = validate_forest_spec,
      render = render_forest_spec
    )
  )
}

# Families that are functions rather than specifications. They are listed so
# that gfplot_families() is a complete index of what the package can draw, and
# so that a future migration has an obvious place to land.
gfplot_function_families <- function() {
  list(
    c("plot_KMCurve", "Survival", "Grouped Kaplan-Meier curve with a risk table"),
    c("plot_ROC", "Discrimination", "ROC curves with areas under the curve"),
    c("plot_TimeROC", "Discrimination", "Time-dependent ROC curves"),
    c("plot_MulROC", "Discrimination", "ROC curves from separate cohorts"),
    c("plot_RiskScore", "Sample-level", "Patients ordered by risk score"),
    c("plot_Boxplot", "Sample-level", "Grouped boxplot"),
    c("plot_barplot", "Sample-level", "Grouped bar plot of means"),
    c("plot_cor", "Sample-level", "Correlation scatter with regression"),
    c("plot_PCA", "Data geometry", "Principal component projection"),
    c("plot_UMAP", "Data geometry", "UMAP projection"),
    c("plot_lasso", "Effect Estimate", "Lasso coefficient paths"),
    c("plot_GO", "Enrichment", "Enriched term dot plot"),
    c("plot_immune", "Enrichment", "Immune infiltration radar chart"),
    c("viewGSEA", "Enrichment", "Running enrichment score"),
    c("ggGSEA", "Enrichment", "Running enrichment score from a ranked list")
  )
}

#' List the figures gfplot can draw
#'
#' Returns an index of the available figure families with the category they
#' belong to and how to call them. Families with `type = "spec"` are driven by
#' `gfplot_spec()` and `gfplot_render()`; families with `type = "function"` are
#' called directly.
#'
#' @param category Optional category to filter by.
#'
#' @return A tibble with one row per family: the family name, its title and
#'   category, whether it is driven by a specification, the function that
#'   draws it, and an example call.
#'
#' @seealso [gfplot_spec()] to build a figure programmatically.
#' @export
#' @examples
#' gfplot_families()
#' gfplot_families("Effect Estimate")
gfplot_families <- function(category = NULL) {
  registry <- gfplot_family_registry()
  spec_rows <- lapply(names(registry), function(name) {
    entry <- registry[[name]]
    tibble::tibble(
      family = name,
      title = entry$title,
      category = entry$category,
      type = "spec",
      status = entry$status %||% "stable",
      description = entry$description %||% "",
      function_name = entry$function_name %||% NA_character_,
      call = if (!is.null(entry$function_name)) {
        paste0(entry$function_name, "(...)")
      } else {
        paste0("gfplot_spec(\"", name, "\", ...)")
      }
    )
  })
  function_rows <- lapply(gfplot_function_families(), function(row) {
    tibble::tibble(
      family = row[[1]],
      title = row[[3]],
      category = row[[2]],
      type = "function",
      status = "stable",
      description = "",
      function_name = row[[1]],
      call = paste0(row[[1]], "(...)")
    )
  })

  out <- do.call(rbind, c(spec_rows, function_rows))
  if (!is.null(category)) {
    out <- out[out$category %in% category, , drop = FALSE]
    if (nrow(out) == 0) {
      cli::cli_abort(c(
        "No figure family matches {.val {category}}.",
        i = "Available categories: {.val {unique(gfplot_families()$category)}}."
      ))
    }
  }
  out[order(out$category, out$family), , drop = FALSE]
}

#' Build a figure specification
#'
#' Captures the data and the settings for one figure as a value, validates
#' them, and returns an object that [gfplot_render()] turns into a `ggplot`.
#' Use this when the figure is decided in one place and drawn in another, or
#' when a specification needs to be stored, compared, or passed across a
#' process boundary.
#'
#' Call `gfplot_families()` for the available families and their required
#' arguments.
#'
#' @param family Figure family, for example `"forest"`.
#' @param ... Family-specific arguments. For `"forest"`: `data`, `term`,
#'   `estimate`, `lower`, and `upper`, plus the optional settings documented in
#'   [plot_forest()].
#'
#' @return An object of class `gfplot_spec`.
#'
#' @seealso [gfplot_render()], [plot_forest()]
#' @export
#' @examples
#' effects <- data.frame(
#'   term = c("Age", "Stage III"),
#'   hr = c(1.02, 1.84),
#'   lower = c(0.99, 1.51),
#'   upper = c(1.05, 2.24)
#' )
#' spec <- gfplot_spec(
#'   "forest",
#'   data = effects, term = "term",
#'   estimate = "hr", lower = "lower", upper = "upper"
#' )
#' spec
gfplot_spec <- function(family, ...) {
  registry <- gfplot_family_registry()
  family <- as.character(family)
  if (length(family) != 1 || !nzchar(family)) {
    cli::cli_abort("{.arg family} must be a single family name.")
  }
  if (!family %in% names(registry)) {
    cli::cli_abort(c(
      "Unknown figure family {.val {family}}.",
      i = "Families that build a specification: {.val {names(registry)}}.",
      i = "See {.run gfplot_families()} for every family."
    ))
  }

  entry <- registry[[family]]
  spec <- list(family = family, args = list(...), version = 1L)
  spec <- entry$validate(spec)
  structure(spec, class = c("gfplot_spec", "list"))
}

#' @export
print.gfplot_spec <- function(x, ...) {
  entry <- gfplot_family_registry()[[x$family]]
  cli::cli_inform(c(
    "<gfplot_spec>",
    "*" = "family: {.val {x$family}} ({entry$title})",
    "*" = "arguments: {.val {names(x$args)}}"
  ))
  invisible(x)
}

#' Draw a figure from a specification
#'
#' @param spec A specification from [gfplot_spec()].
#'
#' @return A `ggplot` object, ready to print or pass to [gfplot_save()].
#'
#' @seealso [gfplot_spec()]
#' @export
#' @examples
#' effects <- data.frame(
#'   term = c("Age", "Stage III"),
#'   hr = c(1.02, 1.84),
#'   lower = c(0.99, 1.51),
#'   upper = c(1.05, 2.24)
#' )
#' p <- gfplot_render(gfplot_spec(
#'   "forest",
#'   data = effects, term = "term",
#'   estimate = "hr", lower = "lower", upper = "upper"
#' ))
gfplot_render <- function(spec) {
  if (!inherits(spec, "gfplot_spec")) {
    cli::cli_abort(c(
      "{.arg spec} must be a figure specification.",
      i = "Build one with {.run gfplot_spec(\"forest\", ...)}."
    ))
  }
  entry <- gfplot_family_registry()[[spec$family]]
  if (is.null(entry)) {
    cli::cli_abort("Unknown figure family {.val {spec$family}}.")
  }
  entry$render(spec)
}

# Internal helpers shared by family validators ---------------------------

# Pull an argument out of a specification with a clear error when it is absent.
spec_arg <- function(spec, name, required = TRUE, default = NULL) {
  if (!name %in% names(spec$args)) {
    if (isTRUE(required)) {
      entry <- gfplot_family_registry()[[spec$family]]
      cli::cli_abort(c(
        "The {.val {spec$family}} specification is missing {.arg {name}}.",
        i = "Required arguments: {.val {entry$arguments}}."
      ))
    }
    return(default)
  }
  spec$args[[name]]
}
