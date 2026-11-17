# Rank estimate by sequential pseudo F-ratios

Rank estimate by sequential pseudo F-ratios

## Usage

``` r
.rank_pfr(D, cutoff, max_rank, call = rlang::caller_env())
```

## Arguments

- D:

  Numeric matrix, scans x m/z.

- cutoff:

  Numeric in (0, 1); F-distribution probability a ratio must reach to
  count as signal.

- max_rank:

  Integer; largest rank considered.

- call:

  Call environment for errors.

## Value

Integer; the largest `k` (capped at `max_rank`) whose ratio \\s_k^2 /
s\_{k+1}^2\\ of consecutive squared singular values has an
F-distribution probability of at least `cutoff`. 0 when no ratio does or
`D` is all zero; `NA` when `D` has fewer than 3 rows or 2 columns.

## Details

Adapts the pseudo F-ratio of Giebelhaus et al. (2022,
[doi:10.1016/j.chroma.2022.463499](https://doi.org/10.1016/j.chroma.2022.463499)
), who compare \\s_1^2 / s_2^2\\ of a moving window against an F
distribution with `(w - 1, w - 2)` degrees of freedom, `w` being the
number of scans. Here the whole window is the moving window and every
consecutive ratio is tested. Two deviations from the paper, both chosen
on simulated windows:

- No autoscaling. Scaling every m/z channel to unit variance lets the
  many noise-only channels mask minor components.

- The rank is the last significant ratio, not the count of leading
  significant ones. Two noise singular values give ratios near 1, but a
  ratio between two signal components can also be small, so stopping at
  the first failure under-counts.

The F reference is a heuristic (the paper gives no proof), so `cutoff`
is a tuning value, not a significance level. Singular values below
`1e-6` of the largest are treated as zero.
