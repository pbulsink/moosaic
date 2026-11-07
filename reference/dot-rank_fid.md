# Rank estimate from the FID trace

Rank estimate from the FID trace

## Usage

``` r
.rank_fid(fid, call = rlang::caller_env())
```

## Arguments

- fid:

  List with numeric `rt` and `intensity` of equal length: the FID
  resampled onto the window's scans (see
  [`.extract_fid_window()`](https://pbulsink.github.io/moosaic/reference/dot-extract_fid_window.md)).

- call:

  Call environment for errors.

## Value

Integer; the number of distinct peaks, or `NA` when fewer than 5
non-missing points are available. 0 for a flat, monotone or noise-only
trace.

## Details

Missing values are filled by linear interpolation. A local maximum
counts when its prominence is at least `moosaic.peak_min_height_snr`
times the noise and at least 5% of the trace range. Noise comes from
third differences, which remove smooth peak structure. Unresolved
shoulders are not visible to this method.
