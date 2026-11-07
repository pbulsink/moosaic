# Create a gcms_fid_exp object from raw data

High-level constructor for a GC-FID/MS experiment from MS and FID
matrices.

## Usage

``` r
gcms_fid_exp(
  ms_data,
  fid_rt,
  fid_intensity,
  ms_metadata = list(),
  fid_metadata = list()
)
```

## Arguments

- ms_data:

  Numeric matrix with columns `rt`, `mz`, `intensity` (long format), or
  matrix with row scans, column m/z (dense format) with `rt` and `tic`
  as attributes.

- fid_rt:

  Numeric vector; FID retention times (min).

- fid_intensity:

  Numeric vector; FID intensities (pA).

- ms_metadata:

  List; metadata for MS detector.

- fid_metadata:

  List; metadata for FID detector.

## Value

A `gcms_fid_exp` object.

## Examples

``` r
if (FALSE) { # \dontrun{
  # From long-format MS data
  exp <- gcms_fid_exp(
    ms_data = ms_long,  # matrix: rt, mz, intensity
    fid_rt = fid$rt,
    fid_intensity = fid$intensity,
    ms_metadata = list(sample_name = "sample1"),
    fid_metadata = list(units = "pA")
  )
} # }
```
