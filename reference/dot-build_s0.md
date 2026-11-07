# Initial spectra estimate from SVD

Initial spectra estimate from SVD

## Usage

``` r
.build_s0(D, rank, call = rlang::caller_env())
```

## Arguments

- D:

  Numeric matrix, scans x m/z.

- rank:

  Integer; number of components.

- call:

  Call environment for errors.

## Value

Numeric matrix, `ncol(D)` x `rank`, non-negative with each column scaled
to a maximum of 1 (all-zero columns stay zero).

## Details

Uses the absolute values of the leading right singular vectors.
