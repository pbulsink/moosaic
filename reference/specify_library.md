# Specify library paths for spectral searching

Sets `moosaic.library_path` to a list of NIST-format library directory
paths. Each path is checked to exist.

## Usage

``` r
specify_library(paths)
```

## Arguments

- paths:

  Character vector or list of path strings to NIST library directories.

## Value

Invisibly, the new library path setting.

## Examples

``` r
if (FALSE) { # \dontrun{
  specify_library("C:/NIST23/MSSEARCH/mainlib/")
  specify_library(c("C:/NIST23/mainlib/", "C:/NIST23/replib/"))
} # }
```
