# Standardize MS data to internal structure

Converts long-format or dense MS matrices to the internal
representation.

## Usage

``` r
.standardize_ms(raw, call = rlang::caller_env())
```

## Arguments

- raw:

  MS data from chromConverter or user input.

- call:

  Call environment for errors.

## Value

List with `data`, `rt`, `tic`.
