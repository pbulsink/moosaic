# Detect peaks in an FID trace

Detect peaks in an FID trace

## Usage

``` r
detect_fid_peaks(fid, min_snr = NULL)
```

## Arguments

- fid:

  List with numeric `rt` and `intensity` (e.g. `exp$fid`).

- min_snr:

  Numeric; minimum apex height as a multiple of the noise. `NULL` uses
  the `moosaic.peak_min_height_snr` option.

## Value

A tibble with columns `peak_id`, `apex_rt`, `start_rt`, `end_rt`,
`height` (above the estimated baseline) and `shoulder` (logical; the
second derivative shows an unresolved extra component inside the peak;
heuristic, and conservative for noisy or narrow peaks). Zero rows when
nothing is detected.

## Details

Detection runs on a smoothed, baseline-corrected copy; the input is
never modified. Maxima that do not rise at least half the SNR threshold
above their neighbouring valley are discarded as noise.

## Examples

``` r
rt <- seq(0, 2, length.out = 2000)
fid <- list(rt = rt, intensity = 100 * exp(-0.5 * ((rt - 1) / 0.03)^2))
detect_fid_peaks(fid)
#> # A tibble: 1 × 6
#>   peak_id apex_rt start_rt end_rt height shoulder
#>     <int>   <dbl>    <dbl>  <dbl>  <dbl> <lgl>   
#> 1       1    1.00    0.939   1.06   75.8 FALSE   
```
