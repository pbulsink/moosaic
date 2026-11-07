# Write components to an MSP file

Write components to an MSP file

## Usage

``` r
write_msp(components, path)
```

## Arguments

- components:

  A list of `moosaic_component` objects or a `moosaic_result`.
  Background components are skipped.

- path:

  Output file.

## Value

`path`, invisibly. Each block has `NAME`, `RETENTION_TIME`,
`RETENTION_INDEX` (when the component has an `ri`), `Num Peaks` and
`mz intensity` lines, intensities scaled to a maximum of 999.
