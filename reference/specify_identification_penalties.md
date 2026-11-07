# Specify identification penalties

Configures RI and element-based penalties for candidate scoring.

## Usage

``` r
specify_identification_penalties(
  ri_grace = NULL,
  ri_penalty_per_unit = NULL,
  element_penalties = NULL,
  allowed_elements = NULL,
  disallowed_element_penalty = NULL
)
```

## Arguments

- ri_grace:

  Integer; RI value within this range incurs zero penalty (default from
  options).

- ri_penalty_per_unit:

  Numeric; penalty per RI unit outside grace range (default from
  options).

- element_penalties:

  Named numeric vector; penalties for each element (default from
  options).

- allowed_elements:

  Character vector; elements allowed in formulas (default from options).

- disallowed_element_penalty:

  Numeric; penalty per atom of an element that is neither allowed nor in
  `element_penalties` (default from options).

## Value

Invisibly, previous option values.

## Examples

``` r
if (FALSE) { # \dontrun{
  specify_identification_penalties(
    ri_grace = 15,
    element_penalties = c(N = 50, S = 100)
  )
} # }
```
