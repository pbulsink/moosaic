# Subset matrix rows to a retention-time window

Subset matrix rows to a retention-time window

## Usage

``` r
.subset_rt(D, rt, start_rt, end_rt, call = rlang::caller_env())
```

## Arguments

- D:

  Numeric matrix, one row per scan.

- rt:

  Numeric vector of scan times, `length(rt) == nrow(D)`.

- start_rt, end_rt:

  Numeric; inclusive window bounds (min).

- call:

  Call environment for errors.

## Value

A list with `D` (rows in window) and `rt`.
