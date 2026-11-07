# Build a dense scan-by-m/z matrix from an experiment's MS data

Build a dense scan-by-m/z matrix from an experiment's MS data

## Usage

``` r
build_ms_matrix(
  ms,
  rt_range = NULL,
  mz_min = .get_moosaic_option("mz_min"),
  mz_max = .get_moosaic_option("mz_max"),
  mz_bin = .get_moosaic_option("mz_bin")
)
```

## Arguments

- ms:

  The `ms` slot of a `gcms_fid_exp`, or a `gcms_fid_exp` object.

- rt_range:

  Optional numeric length-2 vector (min); inclusive subset of scans.

- mz_min, mz_max, mz_bin:

  Numeric; default to the `moosaic.mz_min`, `moosaic.mz_max` and
  `moosaic.mz_bin` options.

## Value

A list with `D` (dense numeric matrix, scans x m/z bins), `rt` (scan
times) and `mz` (bin-centre m/z values).

## Details

Fractional m/z values are assigned to the nearest bin centre and
intensities within a bin are summed.

## Examples

``` r
ms <- list(
  data = cbind(
    rt = c(1, 1, 2),
    mz = c(40.1, 41.2, 40.2),
    intensity = c(10, 5, 8)
  ),
  rt = c(1, 2)
)
build_ms_matrix(ms, mz_min = 40, mz_max = 41, mz_bin = 1)
#> $D
#>      40 41
#> [1,] 10  5
#> [2,]  8  0
#> 
#> $rt
#> [1] 1 2
#> 
#> $mz
#> [1] 40 41
#> 
```
