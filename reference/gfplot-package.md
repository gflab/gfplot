# gfplot: publication-ready figures for cancer bioinformatics

The package collects plotting helpers for figures that recur in cancer
bioinformatics: survival curves, ROC and time-dependent ROC curves, risk
scores, dimensionality-reduction projections, boxplots, correlation
plots, lasso coefficient paths, enrichment plots, and
immune-infiltration radar charts.

## Figure style

`gfplot` is opinionated about presentation. Figures use Arial and the
[`cowplot::theme_cowplot()`](https://wilkelab.org/cowplot/reference/theme_cowplot.html)
theme, which is the lab standard for publication output. Loading the
package therefore sets the global `ggplot2` theme to `theme_cowplot()`
as the session baseline: attaching `gfplot` is a statement that this
style is the intended default, so every figure in the session —
including figures drawn by other packages — starts from the same look.

This is a deliberate choice rather than an incidental side effect. Set
`options(gfplot.set_theme = FALSE)` before
[`library(gfplot)`](https://github.com/gflab/gfplot) to keep an existing
theme;
[`ggplot2::theme_set()`](https://ggplot2.tidyverse.org/reference/get_theme.html)
can also be called afterwards to choose a different baseline.

Font and colour follow the same principle. Arial is the default on every
plotting function, and
[`get_color()`](https://gflab.github.io/gfplot/reference/get_color.md)
returns journal palettes, so figures are consistent across a manuscript
without per-figure tuning. See
[`gfplot_save()`](https://gflab.github.io/gfplot/reference/gfplot_save.md)
for writing files that render the font correctly.

## See also

Useful links:

- <https://github.com/gflab/gfplot>

- <https://gflab.github.io/gfplot/>

- Report bugs at <https://github.com/gflab/gfplot/issues>

## Author

**Maintainer**: Feng Gao <gaofeng21cn@gmail.com>

Authors:

- Feng Gao <gaofeng21cn@gmail.com>
