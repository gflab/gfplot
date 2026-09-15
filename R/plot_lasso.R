#' Plot lasso coefficient paths
#'
#' Draws the coefficient paths of a fitted `glmnet` model against the log
#' lambda sequence and labels the coefficients that remain non-zero at the
#' selected value of `s`.
#'
#' @param fit A fitted model from [glmnet::glmnet()].
#' @param s Selected value of the penalty parameter.
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("glmnet", quietly = TRUE)) {
#'   set.seed(1)
#'   x <- matrix(rnorm(100 * 5), nrow = 100)
#'   y <- rnorm(100) + x[, 1]
#'   p <- plot_lasso(glmnet::glmnet(x, y), s = 0.05)
#' }
#' }
plot_lasso <- function(fit, s) {
  beta <- stats::coef(fit)
  tmp <- as.data.frame(as.matrix(beta))
  obj <- stats::coef(fit, s = s)
  index <- obj@i + 1
  sig.genes <- obj@Dimnames[[1]][index]

  tmp$coef <- row.names(tmp)
  long <- tidyr::pivot_longer(
    tmp,
    cols = setdiff(names(tmp), "coef"),
    names_to = "step",
    values_to = "value"
  )
  long$step <- as.numeric(gsub("s", "", long$step))
  long$lambda <- fit$lambda[long$step + 1]
  long$norm <- apply(abs(beta[-1, , drop = FALSE]), 2, sum)[long$step + 1]

  long <- long[long$coef != "(Intercept)" & long$lambda >= s, , drop = FALSE]
  long$label <- NA_character_
  at_minimum <- long$lambda == min(long$lambda) & long$coef %in% sig.genes
  long$label[at_minimum] <- long$coef[at_minimum]

  lambda_range <- log10(max(long$lambda)) - log10(min(long$lambda))
  ggplot2::ggplot(
    long,
    ggplot2::aes(
      x = log10(.data$lambda), y = .data$value,
      color = .data$coef, label = .data$label
    )
  ) +
    ggplot2::geom_line() +
    ggplot2::xlab("Lambda (log scale)") +
    ggplot2::ylab("Coefficients") +
    ggplot2::guides(
      color = ggplot2::guide_legend(title = ""),
      linetype = ggplot2::guide_legend(title = "")
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      legend.key.width = ggplot2::unit(3, "lines"),
      legend.position = "none"
    ) +
    ggplot2::scale_x_reverse(
      limits = c(
        log10(max(long$lambda)),
        log10(min(long$lambda)) - 0.1 * lambda_range
      )
    ) +
    ggrepel::geom_text_repel(
      data = long[!is.na(long$label), , drop = FALSE],
      nudge_x = 1,
      segment.size = 0.2,
      segment.color = "grey50",
      direction = "y",
      hjust = 1
    )
}
