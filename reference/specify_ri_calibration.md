# Specify RI calibration file

Sets `moosaic.ri_calibration_path` and validates the file exists and is
readable.

## Usage

``` r
specify_ri_calibration(path)
```

## Arguments

- path:

  Character; path to `.CAL` file.

## Value

Invisibly, the new path setting.

## Examples

``` r
if (FALSE) { # \dontrun{
  specify_ri_calibration("ONSITE.CAL")
} # }
```
