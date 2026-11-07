# Trapezoidal integral

Trapezoidal integral

## Usage

``` r
.integrate_trapezoid(x, y, call = rlang::caller_env())
```

## Arguments

- x, y:

  Numeric vectors of equal length; `x` ascending, not necessarily evenly
  spaced. Pairs with a missing value are dropped.

- call:

  Call environment for errors.

## Value

Numeric scalar; 0 when fewer than two usable points remain.
