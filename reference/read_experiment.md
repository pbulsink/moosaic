# Read a GC-FID/MS experiment from ChemStation files

Reads `.ms` and `.ch` files using chromConverter and constructs a
validated `gcms_fid_exp` object.

## Usage

``` r
read_experiment(ms_file, fid_file)
```

## Arguments

- ms_file:

  Character; path to ChemStation `.ms` file.

- fid_file:

  Character; path to ChemStation `.ch` file.

## Value

A `gcms_fid_exp` object.

## Examples

``` r
if (FALSE) { # \dontrun{
  exp <- read_experiment("sample.ms", "sample.ch")
} # }
```
