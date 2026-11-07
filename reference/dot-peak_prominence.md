# Topographic prominence of peaks

Topographic prominence of peaks

## Usage

``` r
.peak_prominence(x, idx)
```

## Arguments

- x:

  Numeric vector.

- idx:

  Integer vector; indices of local maxima in `x`.

## Value

Numeric vector, one value per `idx`: the height of the peak above the
higher of its two bases. Each base is the lowest point reached walking
away from the peak until a higher point (or the end of `x`) is met.
