# Find peak boundaries around an apex

Find peak boundaries around an apex

## Usage

``` r
.find_peak_bounds(x, apex_idx, floor = 0, tol = 0)
```

## Arguments

- x:

  Numeric vector (baseline-corrected, smoothed).

- apex_idx:

  Integer; index of the apex.

- floor:

  Numeric; stop once the signal reaches this level.

- tol:

  Numeric; noise tolerance. A side stops when the signal climbs more
  than `tol` above the lowest point seen so far on that side, so small
  noise bumps do not end the walk early.

## Value

Named integer vector `c(start, end)`. Each side walks downhill and stops
at the lowest point before a rise of more than `tol` (a valley), at the
first point at or below `floor`, or at the end of the vector.
