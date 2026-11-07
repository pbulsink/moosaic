# Remove m/z channels with no signal

Remove m/z channels with no signal

## Usage

``` r
.drop_empty_mz(D)
```

## Arguments

- D:

  Numeric matrix, scans x m/z, with m/z labels as column names.

## Value

`D` without columns whose entries are all zero. Remaining columns keep
their names; the result has zero columns if nothing remains.
