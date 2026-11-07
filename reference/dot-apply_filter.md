# Apply a symmetric-support FIR filter with edge padding

Apply a symmetric-support FIR filter with edge padding

## Usage

``` r
.apply_filter(x, coefs)
```

## Arguments

- x:

  Numeric vector.

- coefs:

  Numeric vector of odd length, in
  [`stats::filter()`](https://rdrr.io/r/stats/filter.html) order.

## Value

Numeric vector, same length as `x`.
