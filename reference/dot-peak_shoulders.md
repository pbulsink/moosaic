# Locate unresolved shoulders within a peak

Locate unresolved shoulders within a peak

## Usage

``` r
.peak_shoulders(
  y,
  rt,
  apex,
  start,
  end,
  depth_frac = 0.2,
  width_frac = 0.12,
  noise = 0,
  noise_k = 3,
  min_height = 0
)
```

## Arguments

- y:

  Numeric vector; smoothed, baseline-corrected signal.

- rt:

  Numeric vector of times, same length as `y`.

- apex, start, end:

  Integer indices of the peak apex and bounds in `y`.

- depth_frac:

  Numeric; a second-derivative minimum must reach this fraction of the
  deepest minimum in the peak to count.

- width_frac:

  Numeric; second-derivative filter length as a fraction of the peak
  width in points (adapts to peak width and sampling rate).

- noise:

  Numeric; white-noise SD of the unsmoothed signal. A minimum must also
  be deeper than `noise_k` times the noise propagated through the
  second-derivative filter, and the signal at the shoulder must be at
  least `min_height`. The default `0` disables both checks.

- noise_k:

  Numeric; multiple of the second-derivative noise SD.

- min_height:

  Numeric; minimum signal height at a shoulder.

## Value

Integer vector (possibly empty, sorted) of indices into `y` of
second-derivative minima inside the peak that are not explained by the
apex. Each marks an unresolved overlapping component.
