# Detect deconvolution windows from the FID

Finds FID peaks (including shoulders) with
[`detect_peaks()`](https://pbulsink.github.io/moosaic/reference/detect_peaks.md)
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
`n_peaks`, `peak_ids`, `n_scans` (MS scans inside the window after
removing the alignment delay) and `has_shoulder` (logical; any peak in
the window has an unresolved shoulder). The peak table is attached as
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
