# Extract metadata from a raw data object

Pulls attributes into a named list, excluding structural metadata like
`dim`.

## Usage

``` r
.extract_metadata(x)
```

## Arguments

- x:

  An object with attributes.

## Value

Named list of attributes (excluding `dim`, `dimnames`, `class`).
