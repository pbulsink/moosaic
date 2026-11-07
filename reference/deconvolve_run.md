# Deconvolve every FID window of a run

Deconvolve every FID window of a run

## Usage

``` r
deconvolve_run(exp)
```

## Arguments

- exp:

  A `gcms_fid_exp` object, ideally after
  [`align_detectors()`](https://pbulsink.github.io/moosaic/reference/align_detectors.md).

## Value

A `moosaic_result`: a list with `components` (all `moosaic_component`s,
in window order) and `windows` (the
[`detect_fid_windows()`](https://pbulsink.github.io/moosaic/reference/detect_fid_windows.md)
table).
