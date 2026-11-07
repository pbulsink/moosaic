# Test a peak for an unresolved shoulder

Test a peak for an unresolved shoulder

## Usage

``` r
.has_shoulder(y, rt, apex, start, end, depth_frac = 0.2, width_frac = 0.12)
```

## Arguments

- y:

  Numeric vector; smoothed, baseline-corrected signal.

- rt:

  Numeric vector of times, same length as `y`.

- apex, start, end:

  Integer indices of the peak apex and bounds in `y`.

- depth_frac:

  Numeric; a second-derivative minimum must reach this fraction of the
  deepest minimum in the peak to count.

- width_frac:

  Numeric; second-derivative filter length as a fraction of the peak
  width in points (adapts to peak width and sampling rate).

## Value

Logical; `TRUE` if the second derivative has a minimum within the peak
that is not explained by the apex.
