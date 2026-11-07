# Retention index penalty

Retention index penalty

## Usage

``` r
.ri_penalty(observed, library, grace, per_unit)
```

## Arguments

- observed, library:

  Numeric vectors of observed and library RI.

- grace:

  Differences up to this size are not penalised.

- per_unit:

  Penalty per RI unit beyond `grace`.

## Value

A tibble with `penalty` and `ri_missing` (`TRUE` where either RI is
`NA`; the penalty is then 0).
