# Build C/H/O formulas

Build C/H/O formulas

## Usage

``` r
.build_formula(c_n, h_n, o_n)
```

## Arguments

- c_n, h_n, o_n:

  Numeric vectors of carbon, hydrogen and oxygen counts.

## Value

Character vector of formulas such as `"C8H18"`; elements with a zero
count are omitted.
