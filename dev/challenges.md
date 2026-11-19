# Challenge register

## 2026-11-19: crowded-run windowing

The live example had 1,819 FID detections merged into 63 windows, including
regions with hundreds of detections, while each fit allowed six analytes.
Localized cores (0.5 min, four apexes) produce 490 windows on that experiment.
One contextual interval initially contained a single scan; localized intervals
now expand to two available scans without changing ownership boundaries.

A noiseless 12-component crowded-chain regression recovers all 12 apexes and
their two-ion spectral ratios using the standard 99% SVD rank threshold.
At a deliberately stringent 99.999% threshold, neighboring tails inflate local
rank and can produce an extra split component and ALS non-convergence. Rank
selection and shifted duplicates remain separate challenges; core ownership is
not a spectral deduplication algorithm. The full example has not been refitted.

The fast suite also reports three existing noisy-shoulder sensitivity failures
in `test-detect_peaks.R` and two `process_sample()` errors from trailing empty
arguments in pre-existing progress-message changes. Those paths were not
modified by the localization work.
