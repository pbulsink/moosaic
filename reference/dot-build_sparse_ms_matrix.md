# Build a sparse scan-by-m/z matrix

Build a sparse scan-by-m/z matrix

## Usage

``` r
.build_sparse_ms_matrix(ms, mz_min, mz_max, mz_bin, call = rlang::caller_env())
```

## Arguments

- ms:

  The `ms` slot of a `gcms_fid_exp` (`data`, `rt`, ...), where `data`
  has columns `rt`, `mz`, `intensity`.

- mz_min, mz_max, mz_bin:

  Numeric; m/z range and bin width.

- call:

  Call environment for errors.

## Value

A `dgCMatrix` with one row per scan in `ms$rt` and one column per m/z
bin; column names are bin-centre m/z values. Intensities falling in the
same bin are summed; ions outside the range are dropped.
