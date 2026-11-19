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
  depth_frac = 0.02,
  width_frac = 0.18,
  noise = 0,
  noise_k = c(10, 5),
  slide_sigma = 3,
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

  Numeric; a second-derivative dip must have a prominence of at least
  this fraction of the apex's second-derivative depth.

- width_frac:

  Numeric; second-derivative filter length as a fraction of the peak
  width in points (adapts to peak width and sampling rate).

- noise:

  Numeric; white-noise SD of the unsmoothed signal. The dip prominence
  must also reach a sliding multiple of the noise propagated through the
  second-derivative filter (see Details). `0` disables the noise gate.

- noise_k:

  Numeric length 2; noise multiples at the apex and on the flank (from
  `slide_sigma` peak sigmas outward).

- slide_sigma:

  Numeric; distance from the apex, in peak sigmas, over which the
  multiple falls linearly from `noise_k[1]` to `noise_k[2]`.

- min_height:

  Numeric; minimum signal height at a shoulder.

## Value

Integer vector (possibly empty, sorted) of indices into `y` of
second-derivative dips inside the peak that are not explained by the
apex. Each marks an unresolved overlapping component.

## Details

A dip is a local minimum of the second derivative, measured by its
prominence (depth below the lower flanking maximum) rather than by its
sign, so a small component on the flank of a larger peak, where the
second derivative is positive, is still found. On synthetic Gaussians at
moderate noise, a 10% component 3 sigma from the apex is reliably found;
5% components, or components 2.5 sigma or less away, generally are not:
their dips are no larger than noise dips.

The noise gate slides with distance from the apex. Peak sigma is
estimated from the full width at half maximum (FWHM / 2.355) of `y`. A
dip `d` sigmas from the apex must reach
`k(d) = noise_k[1] + (noise_k[2] - noise_k[1]) * min(d / slide_sigma, 1)`
times the second-derivative noise. Ragged or flat tops near the apex are
held to a stricter standard than flank shoulders, where real minor
components appear.
