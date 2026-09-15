#' Plot a running enrichment score for an HTSanalyzeR2 result
#'
#' Updated version of the `viewGSEA()` helper distributed with
#' `HTSanalyzeR2`.
#'
#' @param object An `HTSanalyzeR2` result object.
#' @param gscName Name of the gene set collection.
#' @param gsName Name of the gene set.
#' @param title Plot title.
#'
#' @return A `ggplot` object.
#' @export
viewGSEA <- function(object, gscName, gsName, title = "") {
  gfplot_require("DOSE")
  gseaScores <- utils::getFromNamespace("gseaScores", "DOSE")

  df <- gseaScores(
    object@geneList,
    object@listOfGeneSetCollections[[gscName]][[gsName]],
    fortify = TRUE
  )
  df$ymin <- 0
  df$ymax <- 0
  pos <- df$position == 1
  h <- diff(range(df$runningScore)) / 20
  df$ymin[pos] <- -h
  df$ymax[pos] <- h
  df$geneList <- object@geneList
  gsdata <- df

  color <- "#DAB546"
  color.line <- "firebrick"
  color.vline <- "steelblue"

  p <- ggplot2::ggplot(gsdata, ggplot2::aes(x = .data$x)) +
    DOSE::theme_dose() +
    ggplot2::xlab("Position in the Ranked List of Genes")
  p.res <- p +
    ggplot2::geom_linerange(
      ggplot2::aes(ymin = .data$ymin, ymax = .data$ymax),
      color = color
    ) +
    ggplot2::geom_line(
      ggplot2::aes(y = .data$runningScore),
      color = color.line, linewidth = 1
    )

  rr <- object@result$GSEA.results[[gscName]]
  enrichmentScore <- rr[rr$Gene.Set.Term == gsName, "Observed.score"]
  es.df <- data.frame(
    es = which.min(abs(p$data$runningScore - enrichmentScore))
  )
  p.res <- p.res +
    ggplot2::geom_vline(
      data = es.df,
      ggplot2::aes(xintercept = .data$es),
      colour = color.vline, linetype = "dashed"
    ) +
    ggplot2::ylab("Enrichment Score") +
    ggplot2::geom_hline(yintercept = 0)

  p.value <- rr[rr$Gene.Set.Term == gsName, "Adjusted.Pvalue"]
  p.res <- add_enrichment_annotation(p.res, enrichmentScore, p.value, p$data)
  p.res + ggplot2::ggtitle(title)
}

#' Plot a running enrichment score for a ranked gene list
#'
#' Computes the enrichment score with `DOSE::gseaScores()` and the p-value
#' with `fgsea`, then draws the running score with the leading-edge position.
#'
#' @param input Named numeric vector of ranked statistics.
#' @param gs Gene set: a character vector of gene names.
#' @param title Plot title.
#'
#' @return A `ggplot` object.
#' @export
ggGSEA <- function(input, gs, title = "") {
  gfplot_require("DOSE")
  gfplot_require("fgsea")
  gseaScores <- utils::getFromNamespace("gseaScores", "DOSE")

  df <- gseaScores(input, gs, fortify = TRUE)
  enrichmentScore <- gseaScores(input, gs)$ES

  set.seed(100)
  fgseaRes <- fgsea::fgsea(
    pathways = list(group = gs),
    stats = input,
    nperm = 10000
  )
  p.value <- fgseaRes$pval

  df$ymin <- 0
  df$ymax <- 0
  pos <- df$position == 1
  h <- diff(range(df$runningScore)) / 20
  df$ymin[pos] <- -h
  df$ymax[pos] <- h
  df$geneList <- input
  gsdata <- df

  color <- "#DAB546"
  color.line <- "firebrick"
  color.vline <- "steelblue"

  p <- ggplot2::ggplot(gsdata, ggplot2::aes(x = .data$x)) +
    DOSE::theme_dose() +
    ggplot2::xlab("Position")
  p.res <- p +
    ggplot2::geom_linerange(
      ggplot2::aes(ymin = .data$ymin, ymax = .data$ymax),
      color = color
    ) +
    ggplot2::geom_line(
      ggplot2::aes(y = .data$runningScore),
      color = color.line, linewidth = 1
    )

  es.df <- data.frame(
    es = which.min(abs(p$data$runningScore - enrichmentScore))
  )
  p.res <- p.res +
    ggplot2::geom_vline(
      data = es.df,
      ggplot2::aes(xintercept = .data$es),
      colour = color.vline, linetype = "dashed"
    ) +
    ggplot2::ylab("Enrichment Score") +
    ggplot2::geom_hline(yintercept = 0)

  p.res <- add_enrichment_annotation(p.res, enrichmentScore, p.value, p$data)
  p.res + ggplot2::ggtitle(title)
}

# Place the enrichment score and p-value annotation, which is anchored either
# to the top-right or to the left of the curve depending on the sign of the
# enrichment score.
add_enrichment_annotation <- function(p, enrichmentScore, p.value, data) {
  label_p <- ifelse(
    p.value == 0,
    "italic(P)<1%*%10^{-4}",
    paste0("italic(P)==", gfplot_scientific_label(p.value, 3))
  )
  label_es <- paste("ES:", signif(enrichmentScore, 3))
  if (enrichmentScore > 0) {
    p +
      ggplot2::annotate(
        "text", x = Inf, y = Inf, label = label_es,
        hjust = 1.5, vjust = 2
      ) +
      ggplot2::annotate(
        "text", x = Inf, y = Inf, label = label_p,
        hjust = 1, vjust = 3, parse = TRUE
      )
  } else {
    p +
      ggplot2::annotate(
        "text", x = 0, y = enrichmentScore, label = label_es,
        hjust = 0, vjust = -1
      ) +
      ggplot2::annotate(
        "text", x = 0, y = enrichmentScore, label = label_p,
        hjust = 0, vjust = -2, parse = TRUE
      )
  }
}
