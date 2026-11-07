# Find shoulders from a second derivative

Find shoulders from a second derivative

## Usage

``` r
.find_shoulders(d2, apex_idx = integer(), min_depth = 0, tol = 2L)
```

## Arguments

- d2:

  Numeric vector; second derivative of a peak region.

- apex_idx:

  Integer vector; indices of known apexes in `d2`.

- min_depth:

  Numeric; a minimum of `d2` must be at or below `-min_depth` to count.

- tol:

  Integer; minima within `tol` points of an apex belong to that apex and
  are not shoulders.

## Value

Integer vector of indices of negative local minima of `d2` that are not
explained by an apex. Each is an unresolved overlapping component.
