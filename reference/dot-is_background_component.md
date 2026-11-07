# Is a component column-bleed, air or a flat baseline?

Is a component column-bleed, air or a flat baseline?

## Usage

``` r
.is_background_component(C, S, flat_tol = 0.05)
```

## Arguments

- C:

  Numeric vector; concentration profile.

- S:

  Numeric vector; spectrum named by m/z.

- flat_tol:

  Relative range below which `C` counts as flat.

## Value

Logical. `TRUE` when `C` is flat (range under `flat_tol` of its maximum)
or the three strongest ions of `S` are all column bleed (73, 207, 281,
355) or air (40, 44; only when at least `moosaic.mz_min`).
