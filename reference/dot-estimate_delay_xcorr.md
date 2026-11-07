# Estimate detector delay by cross-correlation

Estimate detector delay by cross-correlation

## Usage

``` r
.estimate_delay_xcorr(fid, tic, max_delay, step)
```

## Arguments

- fid, tic:

  Lists with numeric `rt` and `intensity` (min).

- max_delay:

  Numeric; largest delay magnitude searched (min).

- step:

  Numeric; common grid spacing (min).

## Value

A list with `delay` (min; positive when MS times are later than FID
times) and `score` (normalised correlation at the best lag).

## Details

Both traces are linearly interpolated onto a common grid over their
overlapping range, baseline-corrected and cross-correlated over lags
within `max_delay`. The peak is refined by a parabola through the best
lag and its neighbours.
