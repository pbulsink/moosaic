# Find local maxima

Find local maxima

## Usage

``` r
.find_local_maxima(x, min_height = -Inf)
```

## Arguments

- x:

  Numeric vector.

- min_height:

  Numeric; minimum value for a maximum to be reported.

## Value

Integer vector of indices where `x` rises into a point and does not rise
beyond it (the first point of a flat top). End points are never
reported.
