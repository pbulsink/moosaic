# Retention index from retention time

Retention index from retention time

## Usage

``` r
.compute_ri(rt, ri_cal, call = rlang::caller_env())
```

## Arguments

- rt:

  Numeric vector of retention times (min).

- ri_cal:

  Data frame with `rt` and `ri` of the reference compounds (see
  [`read_ri_calibration()`](https://pbulsink.github.io/moosaic/reference/read_ri_calibration.md)).

- call:

  Call environment for conditions.

## Value

Numeric vector of RI values, by piecewise linear interpolation between
neighbouring references (van den Dool and Kratz). Times outside the
calibrated range give `NA` with a warning, unless
`moosaic.ri_extrapolate` is `TRUE`, in which case the nearest two
references are extrapolated linearly.
