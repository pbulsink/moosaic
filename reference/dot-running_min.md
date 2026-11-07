# Centred running minimum

Van Herk / Gil-Werman algorithm: cost independent of window size.

## Usage

``` r
.running_min(x, window)
```

## Arguments

- x:

  Numeric vector.

- window:

  Odd integer; window length in points.

## Value

Numeric vector, same length as `x`. Edges repeat the end values.
