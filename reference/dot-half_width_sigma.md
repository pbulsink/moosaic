# Peak sigma from the full width at half maximum

Peak sigma from the full width at half maximum

## Usage

``` r
.half_width_sigma(y, apex, start, end)
```

## Arguments

- y:

  Numeric vector; smoothed, baseline-corrected signal.

- apex, start, end:

  Integer indices of the peak apex and bounds in `y`.

## Value

Numeric; Gaussian-equivalent sigma in points (FWHM / 2.355), at least 1.
When the signal does not fall to half height within the bounds, the
bound is used for that side.
