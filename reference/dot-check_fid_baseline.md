# Check the raw FID baseline

Check the raw FID baseline

## Usage

``` r
.check_fid_baseline(fid, tol_snr = 5)
```

## Arguments

- fid:

  List with numeric `rt` and `intensity` (at least 20 points), as in a
  `gcms_fid_exp$fid`.

- tol_snr:

  Tolerance, in multiples of the noise level, for the baseline offset at
  the start of the run and for departures from a straight line.

## Value

Invisibly, a list with `ok`, `offset` (fitted baseline at the first
point), `slope` (per minute), `curvature` (largest departure of the
baseline from the fitted line) and `noise`.

## Details

The baseline is estimated in ten equal blocks as the 10th percentile
(corrected for noise), which peaks barely affect, then fitted with a
line. Polyarc quantification assumes a baseline near zero or a straight
drift. A curved baseline warns with class
`moosaic-warning-fid_baseline_curved`; an offset beyond tolerance warns
with class `moosaic-warning-fid_baseline_offset`. The intensities are
never modified.
