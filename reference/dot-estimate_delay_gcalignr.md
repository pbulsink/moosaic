# Estimate detector delay with GCalignR

Estimate detector delay with GCalignR

## Usage

``` r
.estimate_delay_gcalignr(
  fid_peaks,
  tic_peaks,
  max_delay,
  step,
  call = rlang::caller_env()
)
```

## Arguments

- fid_peaks, tic_peaks:

  Peak tibbles from
  [`detect_fid_peaks()`](https://pbulsink.github.io/moosaic/reference/detect_fid_peaks.md)
  for the FID and the TIC.

- max_delay:

  Numeric; largest linear shift to consider (min).

- step:

  Numeric; shift search step (min).

- call:

  Call environment for errors.

## Value

Numeric; the delay (min) of the MS relative to the FID, positive when MS
retention times are later. The FID is the alignment reference.

## Details

Aborts with class `too_few_peaks` when either trace has fewer than two
peaks. GCalignR console output is suppressed.
