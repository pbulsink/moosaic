# Parse a molecular formula

Parse a molecular formula

## Usage

``` r
.parse_formula(formula, call = rlang::caller_env())
```

## Arguments

- formula:

  Single string such as `"C6H5Cl"`.

- call:

  Call environment for errors.

## Value

Named integer vector of atom counts, in order of first appearance.
Repeated elements are summed.
