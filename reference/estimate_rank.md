# Estimate the number of components in a window

Combines several independent estimates of the chemical rank of a
window's data matrix by majority vote.

## Usage

``` r
estimate_rank(D, fid = NULL, methods = NULL, max_rank = NULL)
```

## Arguments

- D:

  Numeric matrix without missing values, scans x m/z (see
  [`extract_ms_matrix()`](https://pbulsink.github.io/moosaic/reference/extract_ms_matrix.md)).

- fid:

  Optional list with numeric `rt` and `intensity`, one value per row of
  `D` (see
  [`.extract_fid_window()`](https://pbulsink.github.io/moosaic/reference/dot-extract_fid_window.md)).
  Required when `"fid"` is in `methods`.

- methods:

  Character vector, any of `"fid"`, `"svd"`, `"bic"`, `"pa"`. `NULL`
  uses the `moosaic.rank_methods` option.

- max_rank:

  Positive integer upper limit. `NULL` uses the `moosaic.rank_max`
  option. Reduced to `min(dim(D))` with a message if larger.

## Value

A list with `rank` (integer, at least 1), `confidence` (share of usable
votes equal to `rank`, in 0 to 1) and `votes` (named integer vector, one
entry per method, `NA` when a method could not vote).

## Details

Parallel analysis (`"pa"`) is skipped when at least two of the other
methods gave a usable vote and all of them agree; `votes` then has no
`pa` entry. Votes above `max_rank` are capped. If the consensus is 0 (no
method finds signal), `rank` is 1, `confidence` is the share of votes
equal to 1, and a message of class `no_signal` is emitted. The `"svd"`,
`"bic"` and `"pa"` methods read their settings from
`moosaic.svd_var_threshold` and `moosaic.pa_iterations`. `"pa"` uses
random permutations; call
[`set.seed()`](https://rdrr.io/r/base/Random.html) first for
reproducible results. The optional background component is added later,
not here.

## Examples

``` r
set.seed(2615)
scan <- 1:40
C <- cbind(exp(-0.5 * ((scan - 12) / 3)^2), exp(-0.5 * ((scan - 22) / 3)^2))
S <- cbind(exp(-0.5 * ((1:30 - 8) / 3)^2), exp(-0.5 * ((1:30 - 20) / 3)^2))
D <- 100 * C %*% t(S)
estimate_rank(D, list(rt = scan, intensity = rowSums(C)))
#> $rank
#> [1] 2
#> 
#> $confidence
#> [1] 1
#> 
#> $votes
#> fid svd bic 
#>   2   2   2 
#> 
```
