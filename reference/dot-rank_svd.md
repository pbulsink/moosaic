# Rank estimate from cumulative explained variance

Rank estimate from cumulative explained variance

## Usage

``` r
.rank_svd(D, threshold, call = rlang::caller_env())
```

## Arguments

- D:

  Numeric matrix, scans x m/z.

- threshold:

  Numeric in (0, 1\]; fraction of total squared signal that the retained
  components must explain.

- call:

  Call environment for errors.

## Value

Integer; the smallest number of singular components whose cumulative
squared singular values reach `threshold` of the total, or 0 for an
all-zero matrix.

## Details

Uncentred, so a constant background counts towards the first component.
On noisy data the result grows with the noise; it is an upper-leaning
vote.
