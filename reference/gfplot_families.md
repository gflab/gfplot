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
#> # A tibble: 16 × 8
#>    family         title    category type  status description function_name call 
#>    <chr>          <chr>    <chr>    <chr> <chr>  <chr>       <chr>         <chr>
#>  1 plot_PCA       Princip… Data ge… func… stable ""          plot_PCA      plot…
#>  2 plot_UMAP      UMAP pr… Data ge… func… stable ""          plot_UMAP     plot…
#>  3 plot_MulROC    ROC cur… Discrim… func… stable ""          plot_MulROC   plot…
#>  4 plot_ROC       ROC cur… Discrim… func… stable ""          plot_ROC      plot…
#>  5 plot_TimeROC   Time-de… Discrim… func… stable ""          plot_TimeROC  plot…
#>  6 forest         Forest … Effect … spec  stable "Effect es… plot_forest   plot…
#>  7 plot_lasso     Lasso c… Effect … func… stable ""          plot_lasso    plot…
#>  8 ggGSEA         Running… Enrichm… func… stable ""          ggGSEA        ggGS…
#>  9 plot_GO        Enriche… Enrichm… func… stable ""          plot_GO       plot…
#> 10 plot_immune    Immune … Enrichm… func… stable ""          plot_immune   plot…
#> 11 viewGSEA       Running… Enrichm… func… stable ""          viewGSEA      view…
#> 12 plot_Boxplot   Grouped… Sample-… func… stable ""          plot_Boxplot  plot…
#> 13 plot_RiskScore Patient… Sample-… func… stable ""          plot_RiskSco… plot…
#> 14 plot_barplot   Grouped… Sample-… func… stable ""          plot_barplot  plot…
#> 15 plot_cor       Correla… Sample-… func… stable ""          plot_cor      plot…
#> 16 plot_KMCurve   Grouped… Survival func… stable ""          plot_KMCurve  plot…
gfplot_families("Effect Estimate")
#> # A tibble: 2 × 8
#>   family     title         category type  status description function_name call 
#>   <chr>      <chr>         <chr>    <chr> <chr>  <chr>       <chr>         <chr>
#> 1 forest     Forest plot   Effect … spec  stable "Effect es… plot_forest   plot…
#> 2 plot_lasso Lasso coeffi… Effect … func… stable ""          plot_lasso    plot…
```
