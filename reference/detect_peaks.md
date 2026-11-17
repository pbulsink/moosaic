# Detect peaks in a chromatographic trace

Finds resolved peaks (local maxima) and, optionally, unresolved
shoulders (second-derivative minima) in an FID trace or a TIC.

## Usage

``` r
detect_peaks(
  trace,
  min_snr = NULL,
  smooth_window = NULL,
  include_shoulders = TRUE
)
```

## Arguments

- trace:

  List with numeric `rt` and `intensity` (e.g. `exp$fid`).

- min_snr:

  Numeric; minimum apex height as a multiple of the noise. `NULL` uses
  the `moosaic.peak_min_height_snr` option.

- smooth_window:

  Odd integer; Savitzky-Golay smoothing window in points for the
  detection copy. `NULL` uses the `moosaic.fid_smooth_window` option,
  which is tuned for the FID sampling rate.

- include_shoulders:

  Logical; if `TRUE`, each shoulder is returned as its own row.

## Value

A tibble, sorted by `apex_rt`, with columns:

- `peak_id`: integer, 1..n in retention order.

- `apex_rt`, `start_rt`, `end_rt`: apex and bounds (min).

- `height`: smoothed signal at the apex, above the estimated baseline.

- `has_shoulder`: logical; the resolved peak contains at least one
  unresolved shoulder. Always `FALSE` on shoulder rows.

- `is_shoulder`: logical; the row is a shoulder (apex at a
  second-derivative minimum) rather than a resolved maximum.

- `parent_id`: integer; for shoulder rows the `peak_id` of the resolved
  peak containing it, otherwise `NA`.

Zero rows when nothing is detected.

## Details

Detection runs on a smoothed, baseline-corrected copy; the input is
never modified. Maxima that do not rise at least half the SNR threshold
above their neighbouring valley are discarded as noise.

Shoulders are heuristic and conservative for noisy or narrow peaks. When
shoulders are returned, the parent peak's span is split between the apex
and its shoulders at the midpoints between neighbouring apexes, so rows
do not overlap and their union equals the parent's original span.

## Examples

``` r
rt <- seq(0, 2, length.out = 2000)
trace <- list(rt = rt, intensity = 100 * exp(-0.5 * ((rt - 1) / 0.03)^2))
detect_peaks(trace)
#> # A tibble: 1 × 8
#>   peak_id apex_rt start_rt end_rt height has_shoulder is_shoulder parent_id
#>     <int>   <dbl>    <dbl>  <dbl>  <dbl> <lgl>        <lgl>           <int>
#> 1       1    1.00    0.939   1.06   75.8 FALSE        FALSE              NA
```
