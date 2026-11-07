# Robust noise estimate

Robust noise estimate

## Usage

``` r
.estimate_noise(x)
```

## Arguments

- x:

  Numeric vector.

## Value

Single number: the standard deviation of white noise implied by the
median absolute deviation of first differences. Insensitive to peaks and
slow drift.
