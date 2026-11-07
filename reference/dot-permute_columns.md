# Permute each column of a matrix independently

Permute each column of a matrix independently

## Usage

``` r
.permute_columns(X)
```

## Arguments

- X:

  Numeric matrix.

## Value

Matrix of the same dimensions with the entries of every column shuffled
independently. Uses the random number generator.

## Details

One sort of column index plus uniform noise shuffles all columns at
once, which is faster than calling
[`sample()`](https://rdrr.io/r/base/sample.html) per column.
