# Scale matrix columns to a maximum of 1

Scale matrix columns to a maximum of 1

## Usage

``` r
.normalize_columns(M)
```

## Arguments

- M:

  Numeric matrix.

## Value

`M` with each column divided by its maximum. Columns whose maximum is
not positive are returned as zeros.
