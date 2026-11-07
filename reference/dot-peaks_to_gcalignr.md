# Convert detected peaks to GCalignR input

Convert detected peaks to GCalignR input

## Usage

``` r
.peaks_to_gcalignr(fid_peaks, tic_peaks)
```

## Arguments

- fid_peaks, tic_peaks:

  Tibbles from
  [`detect_fid_peaks()`](https://pbulsink.github.io/moosaic/reference/detect_fid_peaks.md)
  (applied to the FID and the TIC respectively).

## Value

A named list of two data frames, `fid` and `tic`, each with numeric
columns `RT` (apex time, min) and `area`. `area` holds the peak height,
which is sufficient for the retention-time shift estimate.
