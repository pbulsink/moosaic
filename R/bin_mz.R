#' Compute nominal m/z bin index
#'
#' @param mz Numeric vector of (possibly fractional) m/z values.
#' @param mz_min Numeric; m/z value at the centre of bin 1.
#' @param mz_bin Numeric; bin width.
#' @param call Call environment for errors.
#'
#' @return Integer vector of bin indices, `round((mz - mz_min) / mz_bin) + 1`.
#'   Values below 1 or above the last bin are not flagged here; callers
#'   filter on the valid range.
#'
#' @details Bins are centred on multiples of `mz_bin` from `mz_min`, so 39.9
#'   maps to the bin of 40 when `mz_bin = 1`.
#'
#' @keywords internal
.bin_mz <- function(mz, mz_min, mz_bin, call = rlang::caller_env()) {
  if (!is.numeric(mz_bin) || length(mz_bin) != 1L || !(mz_bin > 0)) {
    .moosaic_abort(
      "{.arg mz_bin} must be a single positive number.",
      class = "bad_argument",
      call = call
    )
  }
  as.integer(round((mz - mz_min) / mz_bin) + 1)
}
