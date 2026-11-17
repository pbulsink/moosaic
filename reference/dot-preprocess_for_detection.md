# Prepare a detection copy of a chromatographic trace

Smooths then baseline-corrects a copy of a trace (FID or TIC). The input
is not modified; use the raw trace for integration.

## Usage

``` r
.preprocess_for_detection(trace, smooth_window = NULL)
```

## Arguments

- trace:

  List with numeric `rt` and `intensity` (e.g. the `fid` slot of a
  `gcms_fid_exp`, or a TIC).

- smooth_window:

  Odd integer; Savitzky-Golay window in points. `NULL` uses the
  `moosaic.fid_smooth_window` option.

## Value

List with `rt`, `intensity` (smoothed, baseline-corrected) and `noise`
(white-noise SD estimated from the unsmoothed trace).

## Details

The baseline method comes from the `moosaic.fid_baseline_method` option.
The window is in points, so traces sampled at different rates need
different windows for the same smoothing in time.
