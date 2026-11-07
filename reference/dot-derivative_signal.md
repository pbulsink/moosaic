# Savitzky-Golay derivative of a signal

Savitzky-Golay derivative of a signal

## Usage

``` r
.derivative_signal(
  x,
  rt,
  order = 1L,
  window = 7L,
  poly_order = max(3L, order),
  call = rlang::caller_env()
)
```

## Arguments

- x:

  Numeric vector.

- rt:

  Numeric vector of x positions (min), same length as `x`, evenly
  spaced.

- order:

  Integer; derivative order (1 or 2).

- window:

  Odd integer; filter length in points.

- poly_order:

  Integer; local polynomial order (at least `order`).

- call:

  Call environment for errors.

## Value

Numeric vector, same length as `x`, in units of `x` per `rt^order`.
Values within half a window of either end are less reliable.
