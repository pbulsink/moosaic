# Merge peaks into deconvolution windows

Merge peaks into deconvolution windows

## Usage

``` r
.merge_overlapping_peaks(peaks, padding, gap)
```

## Arguments

- peaks:

  Tibble from
  [`detect_fid_peaks()`](https://pbulsink.github.io/moosaic/reference/detect_fid_peaks.md).

- padding:

  Numeric; minutes added to each side of every peak.

- gap:

  Numeric; padded intervals separated by no more than this many minutes
  are merged.

## Value

A tibble with `window_id`, `start_rt`, `end_rt`, `n_peaks` and
`peak_ids` (list column). Zero rows when `peaks` has none.
