# Apply a detector delay to MS retention times

Apply a detector delay to MS retention times

## Usage

``` r
.apply_alignment(rt, delay)
```

## Arguments

- rt:

  Numeric vector of MS retention times (min).

- delay:

  Numeric; delay of the MS relative to the FID (min).

## Value

Numeric vector `rt - delay`, on the FID time axis. `rt` itself is not
modified.
