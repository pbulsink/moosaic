# Extract the MS data matrix for a window

Extract the MS data matrix for a window

## Usage

``` r
extract_ms_matrix(exp, window)
```

## Arguments

- exp:

  A `gcms_fid_exp` object, ideally after
  [`align_detectors()`](https://pbulsink.github.io/moosaic/reference/align_detectors.md).

- window:

  A one-row data frame such as a row of
  [`detect_fid_windows()`](https://pbulsink.github.io/moosaic/reference/detect_fid_windows.md),
  or a list with numeric `start_rt`, `end_rt` (FID time axis, min) and
  optional `window_id`.

## Value

A list with `D` (dense scans x m/z matrix), `rt` (scan times on the FID
axis, i.e. MS time minus the alignment delay), `mz` (bin-centre m/z of
the retained columns) and `window_id`.

## Details

Scans whose aligned time lies in the window (inclusive) are kept. Only
the window's rows are densified, and m/z channels with no signal in the
window are removed. The m/z range and binning come from the
`moosaic.mz_min`, `moosaic.mz_max` and `moosaic.mz_bin` options. Aborts
with class `empty_window` if no scans fall inside the window.

## Examples

``` r
if (FALSE) { # \dontrun{
  windows <- detect_fid_windows(exp)
  m <- extract_ms_matrix(exp, windows[1, ])
} # }
```
