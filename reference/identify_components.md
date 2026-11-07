# Identify the components of a deconvolved run

Computes each analyte component's RI, searches the spectral library once
for all of them, and scores the candidates as
`final = mf - ri_penalty - element_penalty`.

## Usage

``` r
identify_components(result, ri_cal = NULL)
```

## Arguments

- result:

  A `moosaic_result` (see
  [`deconvolve_run()`](https://pbulsink.github.io/moosaic/reference/deconvolve_run.md)).

- ri_cal:

  RI calibration; see
  [`annotate_component()`](https://pbulsink.github.io/moosaic/reference/annotate_component.md).

## Value

`result` with annotated components (`ri`, `hits`, `name`; background
components are left unannotated) and an `identifications` tibble of all
scored candidates.

## Details

The RI penalty is zero within `moosaic.ri_grace` of the library RI and
`moosaic.ri_penalty_per_unit` per unit beyond; it is zero (and flagged
in `ri_missing`) when either RI is missing. The element penalty comes
from `moosaic.element_penalties` (per atom); every atom of an element
that is neither listed there nor in `moosaic.allowed_elements` is also
penalised by `moosaic.disallowed_element_penalty` per atom.
