# Resample the FID onto the MS scan grid

Resample the FID onto the MS scan grid

## Usage

``` r
.resample_fid_to_scans(
  fid_rt,
  fid_intensity,
  scan_rt,
  call = rlang::caller_env()
)
```

## Arguments

- fid_rt, fid_intensity:

  Numeric vectors; FID times (min) and signal.

- scan_rt:

  Numeric vector of at least two increasing scan times (min).

- call:

  Call environment for errors.

## Value

Numeric vector, one value per scan: the mean of all FID points in the
scan's interval. Each scan is assumed centred in its interval, so
interval edges are the midpoints between neighbouring scan times (the
first and last scans extend by half their adjacent step). A point on an
edge belongs to the later scan. Scans with no FID points get `NA`;
points outside the scan range are ignored.

## Details

A boxcar mean, rather than point interpolation, keeps narrow FID peaks
(about 14 FID points per scan) from being aliased.
