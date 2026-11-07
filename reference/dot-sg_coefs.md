# Savitzky-Golay filter coefficients

Savitzky-Golay filter coefficients

## Usage

``` r
.sg_coefs(window, order = 3L, deriv = 0L, call = rlang::caller_env())
```

## Arguments

- window:

  Odd integer; filter length in points.

- order:

  Integer; polynomial order, must be less than `window`.

- deriv:

  Integer; derivative order (0 = smoothing), at most `order`.

- call:

  Call environment for errors.

## Value

Numeric vector of length `window`, ordered for use with
[`stats::filter()`](https://rdrr.io/r/stats/filter.html) (convolution).
For `deriv > 0` the result is per unit point spacing; divide by
`dt^deriv` to obtain derivatives per unit of x.
