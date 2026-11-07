# Deconvolve one window

Extracts the window's MS matrix and FID, estimates the rank, builds FID
constraints, fits by MCR-ALS and assembles components.

## Usage

``` r
process_window(window, exp)
```

## Arguments

- window:

  A one-row data frame such as a row of
  [`detect_fid_windows()`](https://pbulsink.github.io/moosaic/reference/detect_fid_windows.md),
  or a list with `start_rt`, `end_rt` and optional `window_id`.

- exp:

  A `gcms_fid_exp` object, ideally after
  [`align_detectors()`](https://pbulsink.github.io/moosaic/reference/align_detectors.md).

## Value

A list of `moosaic_component` objects. A flat background component is
added last when `moosaic.background_component` is `TRUE`.
