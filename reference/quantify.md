# Quantify identified components (Polyarc)

Converts raw FID component areas to amounts using the Polyarc response
model \$\$m_i = m_t \frac{F_i}{F_t} \frac{C_t}{C_i} \frac{M_i}{M_t}\$\$
where `F` is the FID area, `C` the carbon count and `M` the molar mass.

## Usage

``` r
quantify(result, info, style = NULL, reference_peak = NULL)
```

## Arguments

- result:

  A `moosaic_result` after
  [`identify_components()`](https://pbulsink.github.io/moosaic/reference/identify_components.md).

- info:

  Sample metadata from
  [`sample_info()`](https://pbulsink.github.io/moosaic/reference/sample_info.md).

- style:

  `"internal"` (relative to a reference peak), or an external
  calibration curve: `"slope"`, `"slope_intercept"` or `"quadratic"`.
  `NULL` uses option `moosaic.quant_style`.

- reference_peak:

  Component id of the reference peak for `style = "internal"`; `NULL`
  picks the largest well-identified peak. Ignored for external styles.

## Value

`result` with a `peaks` tibble (one row per analyte component by
retention time: the peak table columns plus `origin`, `family`,
`solvent`, `amount_ug_ml`, `wt_pct`, `quant_basis` and
`calibration_target`) and a `quant` list (`style`, `reference_peak`,
`info`).

## Details

Only the raw (unsmoothed) FID component areas are used. Peaks without an
identification receive an estimated formula by interpolation along the
run (see
[`.interpolate_unknowns()`](https://pbulsink.github.io/moosaic/reference/dot-interpolate_unknowns.md)),
so every peak is quantified. With `"internal"`, amounts are normalised
to total `1e6 * density` ug/mL (100 wt%); the reference peak is marked
`"Target"`. With an external curve, calibration targets found in the
sample (matched by name) are read off their curve, scaled by the
dilution, and all other peaks are scaled from the nearest preceding
target of the same type (hydrocarbon or oxygenate). Calibration points
with a zero response are treated as below detection. Overlapping
components share the raw FID area according to the fitted profiles (see
[`.apportion_fid_area()`](https://pbulsink.github.io/moosaic/reference/dot-apportion_fid_area.md)).

## Examples

``` r
if (FALSE) { # \dontrun{
res <- identify_components(deconvolve_run(exp))
quantify(res, sample_info("S1", density = 0.85))$peaks
} # }
```
