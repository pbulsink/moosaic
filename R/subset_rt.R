#' Subset matrix rows to a retention-time window
#'
#' @param D Numeric matrix, one row per scan.
#' @param rt Numeric vector of scan times, `length(rt) == nrow(D)`.
#' @param start_rt,end_rt Numeric; inclusive window bounds (min).
#' @param call Call environment for errors.
#'
#' @return A list with `D` (rows in window) and `rt`.
#'
#' @keywords internal
.subset_rt <- function(D, rt, start_rt, end_rt, call = rlang::caller_env()) {
  if (start_rt > end_rt) {
    .moosaic_abort(
      "{.arg start_rt} ({start_rt}) must not exceed {.arg end_rt} ({end_rt}).",
      class = "bad_window",
      call = call
    )
  }
  idx <- which(rt >= start_rt & rt <= end_rt)
  if (length(idx) == 0L) {
    .moosaic_abort(
      "No scans between {start_rt} and {end_rt} min.",
      class = "empty_window",
      call = call
    )
  }
  list(D = D[idx, , drop = FALSE], rt = rt[idx])
}
