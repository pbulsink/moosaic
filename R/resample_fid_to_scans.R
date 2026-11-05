#' Resample the FID onto the MS scan grid
#'
#' @param fid_rt,fid_intensity Numeric vectors; FID times (min) and signal.
#' @param scan_rt Numeric vector of at least two increasing scan times (min).
#' @param call Call environment for errors.
#'
#' @return Numeric vector, one value per scan: the mean of all FID points in
#'   the scan's interval. Each scan is assumed centred in its interval, so
#'   interval edges are the midpoints between neighbouring scan times (the
#'   first and last scans extend by half their adjacent step). A point on an
#'   edge belongs to the later scan. Scans with no FID points get `NA`;
#'   points outside the scan range are ignored.
#'
#' @details A boxcar mean, rather than point interpolation, keeps narrow FID
#'   peaks (about 14 FID points per scan) from being aliased.
#'
#' @keywords internal
.resample_fid_to_scans <- function(
  fid_rt,
  fid_intensity,
  scan_rt,
  call = rlang::caller_env()
) {
  n <- length(scan_rt)
  if (n < 2L || length(fid_rt) != length(fid_intensity)) {
    .moosaic_abort(
      "{.arg scan_rt} needs at least two scans and {.arg fid_rt} and {.arg fid_intensity} must be the same length.",
      class = "bad_argument",
      call = call
    )
  }
  edges <- c(
    scan_rt[1] - (scan_rt[2] - scan_rt[1]) / 2,
    (scan_rt[-1] + scan_rt[-n]) / 2,
    scan_rt[n] + (scan_rt[n] - scan_rt[n - 1L]) / 2
  )
  idx <- findInterval(fid_rt, edges)
  ok <- idx >= 1L & idx <= n
  out <- rep(NA_real_, n)
  if (any(ok)) {
    sums <- rowsum(fid_intensity[ok], idx[ok])
    counts <- tabulate(idx[ok], nbins = n)
    i <- as.integer(rownames(sums))
    out[i] <- sums[, 1] / counts[i]
  }
  out
}
