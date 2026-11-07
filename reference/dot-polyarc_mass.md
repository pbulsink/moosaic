# Polyarc mass relative to a reference peak

Evaluates \$\$m_i = m_t \frac{F_i}{F_t} \frac{C_t}{C_i}
\frac{M_i}{M_t}\$\$ where `F` is the raw FID area, `C` the carbon count
and `M` the molar mass.

## Usage

``` r
.polyarc_mass(area, carbon, mw, ref_area, ref_carbon, ref_mw, ref_mass = 1)
```

## Arguments

- area, carbon, mw:

  FID area, carbon count and molar mass of the peaks.

- ref_area, ref_carbon, ref_mw:

  Same quantities for the reference peak.

- ref_mass:

  Mass (or amount) of the reference peak; 1 gives relative mass.

## Value

Numeric vector of masses on the scale of `ref_mass`. `NA` where `carbon`
is not positive or `ref_area` is not positive.
