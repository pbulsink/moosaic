# FID signal resampled onto a window's MS scans

FID signal resampled onto a window's MS scans

## Usage

``` r
.extract_fid_window(exp, window, raw = FALSE, call = rlang::caller_env())
```

## Arguments

- exp:

  A `gcms_fid_exp` object.

- window:

  A window (see
  [`extract_ms_matrix()`](https://pbulsink.github.io/moosaic/reference/extract_ms_matrix.md)).

- raw:

  Logical. `TRUE` uses the raw FID; `FALSE` (default) uses the smoothed,
  baseline-corrected detection copy.

- call:

  Call environment for errors.

## Value

A list with `rt` (aligned scan times, identical to
`extract_ms_matrix()$rt`) and `intensity` (boxcar-mean FID per scan, so
one value per row of `D`).

## Details

The detection copy is computed from the whole trace on every call, which
is the dominant cost for long runs. `exp` is not modified.
