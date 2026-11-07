# Molecular weight from atom counts

Molecular weight from atom counts

## Usage

``` r
.molecular_weight(counts, call = rlang::caller_env())
```

## Arguments

- counts:

  Named integer vector of atom counts (as from
  [`.parse_formula()`](https://pbulsink.github.io/moosaic/reference/dot-parse_formula.md)),
  or a list of such vectors.

- call:

  Call environment for errors.

## Value

Numeric vector of molecular weights (g/mol), one per element of
`counts`; `numeric(0)` for an empty list.

## Details

Atomic weights come from the ported `atomic_weights` table. An element
without an atomic weight aborts with class `moosaic-error-bad_formula`.
