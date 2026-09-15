# Build event indicators for one or more follow-up limits

Turns a two-column clinical matrix into a matrix of event indicators,
with one column per follow-up limit. Observations beyond a limit are
censored at that limit.

## Usage

``` r
generate_time_event(clinical, limits, labels = NULL)
```

## Arguments

- clinical:

  Two-column object: follow-up time and event indicator.

- limits:

  Numeric vector of follow-up limits.

- labels:

  Optional column names for the resulting matrix.

## Value

A matrix with one column per limit.

## Examples

``` r
clinical <- cbind(time = c(1, 5, 10), event = c(1, 0, 1))
generate_time_event(clinical, limits = c(3, 6), labels = c("year3", "year6"))
#>      year3 year6
#> [1,]  TRUE  TRUE
#> [2,] FALSE FALSE
#> [3,] FALSE FALSE
```
