# Detect deconvolution windows from the FID

Finds FID peaks with
[`detect_fid_peaks()`](https://pbulsink.github.io/moosaic/reference/detect_fid_peaks.md)
and merges them into padded windows.

## Usage

``` r
detect_fid_windows(exp)
```

## Arguments

- exp:

  A `gcms_fid_exp` object.

## Value

A tibble with `window_id`, `start_rt`, `end_rt` (FID time, min),
`n_peaks`, `peak_ids` and `n_scans` (MS scans inside the window after
removing the alignment delay). The peak table is attached as
`attr(, "peaks")`. `exp` is not modified.

## Details

Padding and merge gap come from the `moosaic.window_padding` and
`moosaic.window_merge_gap` options. A warning is issued for windows with
fewer than `moosaic.min_scans_per_window` scans.

## Examples

``` r
if (FALSE) { # \dontrun{
  windows <- detect_fid_windows(exp)
} # }
```
