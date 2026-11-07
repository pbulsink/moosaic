# Compute nominal m/z bin index

Compute nominal m/z bin index

## Usage

``` r
.bin_mz(mz, mz_min, mz_bin, call = rlang::caller_env())
```

## Arguments

- mz:

  Numeric vector of (possibly fractional) m/z values.

- mz_min:

  Numeric; m/z value at the centre of bin 1.

- mz_bin:

  Numeric; bin width.

- call:

  Call environment for errors.

## Value

Integer vector of bin indices, `round((mz - mz_min) / mz_bin) + 1`.
Values below 1 or above the last bin are not flagged here; callers
filter on the valid range.

## Details

Bins are centred on multiples of `mz_bin` from `mz_min`, so 39.9 maps to
the bin of 40 when `mz_bin = 1`.
