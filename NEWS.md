# moosaic 0.0.0.9000

* `deconvolve_run()` supports optional progress reporting and retains localized components by non-overlapping apex ownership, with core-only FID integration to avoid counting overlapping context twice.
* `detect_fid_windows()` localizes crowded merged regions using new `window_max_width` (0.5 min) and `window_max_peaks` (4) options. Both accept `Inf` to restore legacy merging. Fit intervals retain padding and at least two available MS scans.
* `identify_components()` reports the searchable component count and displays a progress bar when `verbose = TRUE`, preserving the batched library search.
