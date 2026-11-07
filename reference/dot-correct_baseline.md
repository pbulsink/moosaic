# Subtract an estimated baseline

Subtract an estimated baseline

## Usage

``` r
.correct_baseline(x, method = c("rolling_min", "none"), window = NULL)
```

## Arguments

- x:

  Numeric vector.

- method:

  One of `"rolling_min"` or `"none"`. `"rolling_min"` is a morphological
  opening (running minimum then running maximum) followed by a moving
  average, so features narrower than `window` are treated as signal and
  a linear drift is removed exactly.

- window:

  Odd integer; window in points. `NULL` uses about 5% of `length(x)`
  (minimum 11), which should exceed the base width of the widest peak.

## Value

Numeric vector, same length as `x`.
