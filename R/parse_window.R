#' Normalise a window specification
#'
#' @param window A one-row data frame (e.g. a row of [detect_fid_windows()])
#'   or a list with numeric `start_rt` and `end_rt` (FID time, min) and an
#'   optional `window_id`.
#' @param call Call environment for errors.
#'
#' @return A list with `window_id` (`NA_integer_` if absent), `start_rt` and
#'   `end_rt`.
#'
#' @keywords internal
.parse_window <- function(window, call = rlang::caller_env()) {
  if (is.data.frame(window) && nrow(window) != 1L) {
    .moosaic_abort(
      "{.arg window} must be a single window (one row), not {nrow(window)} rows.",
      class = "bad_window",
      call = call
    )
  }
  start <- window[["start_rt"]]
  end <- window[["end_rt"]]
  if (
    !is.numeric(start) ||
      !is.numeric(end) ||
      length(start) != 1L ||
      length(end) != 1L ||
      is.na(start) ||
      is.na(end)
  ) {
    .moosaic_abort(
      "{.arg window} must have single numeric {.field start_rt} and {.field end_rt}.",
      class = "bad_window",
      call = call
    )
  }
  if (start > end) {
    .moosaic_abort(
      "Window start ({start}) must not exceed its end ({end}).",
      class = "bad_window",
      call = call
    )
  }
  id <- window[["window_id"]]
  list(
    window_id = if (is.null(id)) NA_integer_ else as.integer(id),
    start_rt = start,
    end_rt = end
  )
}
