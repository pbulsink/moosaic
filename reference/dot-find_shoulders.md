# Find shoulders from a second derivative

Find shoulders from a second derivative

## Usage

``` r
.find_shoulders(d2, apex_idx = integer(), min_prominence = 0, tol = 2L)
```

## Arguments

- d2:

  Numeric vector; second derivative of a peak region.

- apex_idx:

  Integer vector; indices of known apexes in `d2`.

- min_prominence:

  Numeric; a local minimum of `d2` counts when it dips at least this far
  below the lower of its two flanking maxima (the topographic prominence
  of `-d2`). The minimum need not be negative, so a minor component
  riding on the convex flank of a larger peak is found.

- tol:

  Integer; minima within `tol` points of an apex belong to that apex and
  are not shoulders.

## Value

Integer vector of indices of local minima of `d2` that are prominent
enough and not explained by an apex. Each is an unresolved overlapping
component.
