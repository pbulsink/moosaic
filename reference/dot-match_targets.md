# Match peak names to calibration targets

Match peak names to calibration targets

## Usage

``` r
.match_targets(names, targets)
```

## Arguments

- names:

  Character vector of peak names.

- targets:

  Tibble with columns `target` and `synonyms`.

## Value

Character vector of matched target names, `NA` where none match.

## Details

Matching ignores case and non-alphanumeric characters and uses both the
target name and its synonym.
