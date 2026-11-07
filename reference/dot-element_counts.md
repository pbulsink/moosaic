# Tracked element counts for formulas

Tracked element counts for formulas

## Usage

``` r
.element_counts(formula)
```

## Arguments

- formula:

  Character vector of molecular formulas.

## Value

A tibble with one row per formula and one numeric column per tracked
element (`C`, `H`, `N`, `O`, `F`, `Cl`, `Br`, `I`, `P`, `S`, `B`, `Si`).
Rows are `NA` for an `NA` formula; other elements are ignored.
