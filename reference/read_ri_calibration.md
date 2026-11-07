# Read an RI calibration file

Read an RI calibration file

## Usage

``` r
read_ri_calibration(path)
```

## Arguments

- path:

  Path to a whitespace-delimited `.CAL` file with no header and one
  reference compound per line: `rt RI col3 col4 name`. The name may
  contain spaces.

## Value

A tibble with `rt`, `ri`, `col3`, `col4` (numeric) and `name`.

## Details

Blank lines are ignored. Aborts if the file is missing, a field is not
numeric (the message names the line), there are fewer than two
references, or `rt` or `ri` is not strictly increasing.
