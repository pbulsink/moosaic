# Build FID-derived initial concentration profiles

Segments the FID window into one region per component and uses the
measured FID in each region as the starting concentration profile for
MCR-ALS.

## Usage

``` r
build_constraints(fid_window, rank, background = NULL)
```

## Arguments

- fid_window:

  List with `rt` and `intensity` of equal length: the FID resampled onto
  the window's scans (see
  [`.extract_fid_window()`](https://pbulsink.github.io/moosaic/reference/dot-extract_fid_window.md)).

- rank:

  Integer; number of analyte components.

- background:

  `NULL` (default) or `FALSE` for none; `TRUE` for a flat background
  column; or a numeric vector with one value per scan for a custom
  background profile.

## Value

A list with `C0` (scans x components matrix, columns scaled to a maximum
of 1, zero outside their segment, non-negative; background column last),
`segments` (see
[`.segment_fid_window()`](https://pbulsink.github.io/moosaic/reference/dot-segment_fid_window.md))
and `background_col` (column index, or `NA`).
