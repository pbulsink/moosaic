# Split a FID window into contiguous per-component segments

Split a FID window into contiguous per-component segments

## Usage

``` r
.segment_fid_window(fid_window, n, call = rlang::caller_env())
```

## Arguments

- fid_window:

  List with numeric `rt` and `intensity` of equal length (see
  [`.extract_fid_window()`](https://pbulsink.github.io/moosaic/reference/dot-extract_fid_window.md)).

- n:

  Integer; number of segments.

- call:

  Call environment for errors.

## Value

Data frame with `segment`, `start`, `end` (scan indices) and `apex`.
Segments partition the window; each valley point belongs to the segment
on its left.

## Details

The `n` most prominent local maxima are kept and the window is cut at
the lowest point between neighbouring maxima. If there are fewer than
`n` maxima (e.g. an unresolved shoulder), the widest segment is
repeatedly cut at its midpoint and a message is issued.
