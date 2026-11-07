# Penalty for unexpected elements in a formula

Penalty for unexpected elements in a formula

## Usage

``` r
.element_penalty(
  formula,
  penalties,
  allowed,
  default = 100,
  call = rlang::caller_env()
)
```

## Arguments

- formula:

  Character vector of formulas; `NA` gives no penalty.

- penalties:

  Named numeric vector: penalty per atom of an element.

- allowed:

  Character vector of elements that may occur unpenalised.

- default:

  Penalty per atom of an element that is neither in `penalties` nor in
  `allowed`.

- call:

  Call environment for errors.

## Value

Numeric vector. Each atom of an element in `penalties` adds that
element's penalty; each atom of an element in neither `penalties` nor
`allowed` adds `default`. Aborts on an unrecognised element symbol.
