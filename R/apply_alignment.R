#' Apply a detector delay to MS retention times
#'
#' @param rt Numeric vector of MS retention times (min).
#' @param delay Numeric; delay of the MS relative to the FID (min).
#'
#' @return Numeric vector `rt - delay`, on the FID time axis. `rt` itself is
#'   not modified.
#'
#' @keywords internal
.apply_alignment <- function(rt, delay) {
  rt - delay
}
