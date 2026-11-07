# Rank estimate by parallel analysis

Rank estimate by parallel analysis

## Usage

``` r
.rank_pa(D, iterations, max_rank, call = rlang::caller_env())
```

## Arguments

- D:

  Numeric matrix, scans x m/z.

- iterations:

  Positive integer; number of column-permuted copies.

- max_rank:

  Integer; largest rank considered.

- call:

  Call environment for errors.

## Value

Integer; the number of leading singular values of the column-centred `D`
that exceed the 95th percentile of the corresponding values from
`iterations` copies with each column independently permuted. 0 for an
all-zero matrix or pure noise. Uses the random number generator.

## Details

Permuting columns keeps each channel's distribution but destroys the
correlation between channels, so only structure shared across m/z
channels exceeds the reference.
