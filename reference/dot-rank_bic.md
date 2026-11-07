# Rank estimate by BIC

Rank estimate by BIC

## Usage

``` r
.rank_bic(D, max_rank)
```

## Arguments

- D:

  Numeric matrix, scans x m/z.

- max_rank:

  Integer; largest rank considered.

## Value

Integer; the rank in `0:max_rank` minimising the BIC of a rank-k model
with iid Gaussian residuals, or `NA` when `D` has a single row or column
(not estimable). 0 for an all-zero matrix or pure noise.

## Details

Residual sums of squares come from the discarded singular values. The
residual is floored at (1e-6 times the largest singular value)^2 so that
floating-point noise in noiseless data does not drive the choice, and
ranks are limited to `min(dim(D)) - 1` so the model never fits exactly.
The free-parameter count is `k * (nrow + ncol - k)`.
