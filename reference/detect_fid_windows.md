# Detect deconvolution windows from the FID

Finds FID peaks (including shoulders) with
[`detect_peaks()`](https://pbulsink.github.io/moosaic/reference/detect_peaks.md)
and merges them into padded, localized windows with non-overlapping
ownership cores.

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
`attr(, "peaks")`. `exp` is not modified. Nonempty tables also contain
`core_start_rt`, `core_end_rt` and `core_last`; a shared boundary
belongs to the core on its right.

## Details

Padding and merge gap come from the `moosaic.window_padding` and
`moosaic.window_merge_gap` options. A warning is issued for windows with
fewer than `moosaic.min_scans_per_window` scans.
`moosaic.window_max_width` (default 0.5 min) limits core width and
`moosaic.window_max_peaks` (default 4) limits detected apexes per core,
except coincident apexes. Set both to `Inf` for legacy merged windows.
Localized fit intervals are expanded when necessary to include at least
two available MS scans; ownership cores are unchanged.

## Examples

``` r
if (FALSE) { # \dontrun{
  windows <- detect_fid_windows(exp)
} # }
```
