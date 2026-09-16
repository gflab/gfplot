# List the figures gfplot can draw

Returns an index of the available figure families with the category they
belong to and how to call them. Families with `type = "spec"` are driven
by
[`gfplot_spec()`](https://gflab.github.io/gfplot/reference/gfplot_spec.md)
and
[`gfplot_render()`](https://gflab.github.io/gfplot/reference/gfplot_render.md);
families with `type = "function"` are called directly.

## Usage

``` r
gfplot_families(category = NULL)
```

## Arguments

- category:

  Optional category to filter by.

## Value

A tibble with one row per family: the family name, its title and
category, whether it is driven by a specification, the function that
draws it, and an example call.

## See also

[`gfplot_spec()`](https://gflab.github.io/gfplot/reference/gfplot_spec.md)
to build a figure programmatically.

## Examples

``` r
gfplot_families()
#> # A tibble: 27 × 8
#>    family         title    category type  status description function_name call 
#>    <chr>          <chr>    <chr>    <chr> <chr>  <chr>       <chr>         <chr>
#>  1 waterfall      Waterfa… Clinica… spec  stable "Patients … plot_waterfa… plot…
#>  2 decision_curve Decisio… Clinica… spec  stable "Net benef… plot_decisio… plot…
#>  3 embedding      Embeddi… Data Ge… spec  stable "Grouped s… plot_embeddi… plot…
#>  4 plot_PCA       Princip… Data Ge… func… stable ""          plot_PCA      plot…
#>  5 plot_UMAP      UMAP pr… Data Ge… func… stable ""          plot_UMAP     plot…
#>  6 plot_tsne      t-SNE p… Data Ge… func… stable ""          plot_tsne     plot…
#>  7 plot_MulROC    ROC cur… Discrim… func… stable ""          plot_MulROC   plot…
#>  8 plot_ROC       ROC cur… Discrim… func… stable ""          plot_ROC      plot…
#>  9 plot_TimeROC   Time-de… Discrim… func… stable ""          plot_TimeROC  plot…
#> 10 forest         Forest … Effect … spec  stable "Effect es… plot_forest   plot…
#> # ℹ 17 more rows
gfplot_families("Effect Estimate")
#> # A tibble: 2 × 8
#>   family     title         category type  status description function_name call 
#>   <chr>      <chr>         <chr>    <chr> <chr>  <chr>       <chr>         <chr>
#> 1 forest     Forest plot   Effect … spec  stable "Effect es… plot_forest   plot…
#> 2 plot_lasso Lasso coeffi… Effect … func… stable ""          plot_lasso    plot…
```
