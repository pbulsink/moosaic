# Savitzky-Golay smoothing

Savitzky-Golay smoothing

## Usage

``` r
.smooth_signal(x, window, order = 3L, call = rlang::caller_env())
```

## Arguments

- x:

  Numeric vector.

- window:

  Odd integer; filter length in points (at least 3, at most
  `length(x)`).

- order:

  Integer; polynomial order.

- call:

  Call environment for errors.

## Value

Numeric vector, same length as `x`. Edges are handled by repeating the
end values.
