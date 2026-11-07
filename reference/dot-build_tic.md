# Build a total ion chromatogram from raw MS data

Fallback and cross-check for the `TIC` supplied in the data file.

## Usage

``` r
.build_tic(ms)
```

## Arguments

- ms:

  The `ms` slot of a `gcms_fid_exp`, with `data` (columns `rt`, `mz`,
  `intensity`) and `rt` (scan times).

## Value

Numeric vector, one summed intensity per element of `ms$rt`.
