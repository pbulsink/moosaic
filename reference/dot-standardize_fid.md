# Standardize FID data to internal structure

Converts FID matrix/data.frame to the internal representation.

## Usage

``` r
.standardize_fid(raw, call = rlang::caller_env())
```

## Arguments

- raw:

  FID data from chromConverter or user input.

- call:

  Call environment for errors.

## Value

List with `rt`, `intensity`.
