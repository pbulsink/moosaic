# Estimate formulas for unidentified peaks

Estimate formulas for unidentified peaks

## Usage

``` r
.interpolate_unknowns(peaks)
```

## Arguments

- peaks:

  Peak table (see
  [`.build_peak_table()`](https://pbulsink.github.io/moosaic/reference/dot-build_peak_table.md))
  ordered by retention time, with `identified`, `name`, `formula`, `mw`,
  `rt`, `ri` and the tracked element columns.

## Value

`peaks` with `origin` (`"library"`, `"interpolated"`, `"extrapolated"`
or `NA`) and, for unidentified peaks, estimated `C`, `H`, `O`,
`formula`, `mw` and a placeholder `name`.

## Details

Peaks between two identified peaks take the rounded linear interpolation
of C, H and O by position. Peaks after the last identified peak get a
carbon count from a linear fit of C against RI (against rt where RI is
missing) over the identified peaks, with the alkane hydrogen count and
no oxygen; peaks before the first copy its composition. Other elements
are set to zero. With nothing identified, a warning of class
`moosaic-warning-no_identified` is raised and no estimates are made.
