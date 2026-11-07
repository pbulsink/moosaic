# Prepare a detection copy of the FID trace

Smooths then baseline-corrects a copy of the FID. The input is not
modified; use the raw trace for integration.

## Usage

``` r
.preprocess_fid_for_detection(fid)
```

## Arguments

- fid:

  List with numeric `rt` and `intensity` (the `fid` slot of a
  `gcms_fid_exp`).

## Value

List with `rt`, `intensity` (smoothed, baseline-corrected) and `noise`
(white-noise SD estimated from the unsmoothed trace).

## Details

Window and baseline method come from the `moosaic.fid_smooth_window` and
`moosaic.fid_baseline_method` options.
