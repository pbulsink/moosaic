#' Split a FID window into contiguous per-component segments
#'
#' @param fid_window List with numeric `rt` and `intensity` of equal length
#'   (see `.extract_fid_window()`).
#' @param n Integer; number of segments.
#' @param call Call environment for errors.
#'
#' @return Data frame with `segment`, `start`, `end` (scan indices) and `apex`.
#'   Segments partition the window; each valley point belongs to the segment on
#'   its left.
#'
#' @details The `n` most prominent local maxima are kept and the window is cut
#'   at the lowest point between neighbouring maxima. If there are fewer than
#'   `n` maxima (e.g. an unresolved shoulder), the widest segment is
#'   repeatedly cut at its midpoint and a message is issued.
#'
#' @keywords internal
.segment_fid_window <- function(fid_window, n, call = rlang::caller_env()) {
  if (
    !is.list(fid_window) ||
      !all(c("rt", "intensity") %in% names(fid_window)) ||
      length(fid_window$rt) != length(fid_window$intensity)
  ) {
    .moosaic_abort(
      "{.arg fid_window} must be a list with equal-length {.field rt} and {.field intensity}.",
      class = "bad_argument",
      call = call
    )
  }
  N <- length(fid_window$rt)
  if (
    !is.numeric(n) ||
      length(n) != 1L ||
      is.na(n) ||
      n < 1 ||
      n != round(n) ||
      n > N
  ) {
    .moosaic_abort(
      "{.arg n} must be a whole number between 1 and the number of scans ({N}).",
      class = "bad_argument",
      call = call
    )
  }
  ok <- !is.na(fid_window$intensity)
  if (sum(ok) < 2L) {
    .moosaic_abort(
      "{.arg fid_window} needs at least 2 non-missing points.",
      class = "bad_argument",
      call = call
    )
  }
  y <- stats::approx(
    fid_window$rt[ok],
    fid_window$intensity[ok],
    fid_window$rt,
    rule = 2
  )$y

  peaks <- .find_local_maxima(y)
  if (length(peaks) > n) {
    keep <- order(.peak_prominence(y, peaks), decreasing = TRUE)[seq_len(n)]
    peaks <- sort(peaks[keep])
  }
  valleys <- integer()
  for (k in seq_len(max(length(peaks) - 1L, 0L))) {
    rng <- peaks[k]:peaks[k + 1L]
    valleys <- c(valleys, peaks[k] - 1L + which.min(y[rng]))
  }
  starts <- c(1L, valleys + 1L)
  ends <- c(valleys, N)

  if (length(starts) < n) {
    .moosaic_inform(
      "Window has {length(starts)} resolvable peak{?s}; splitting the widest segment to reach {n} segment{?s}."
    )
    while (length(starts) < n) {
      w <- which.max(ends - starts)
      mid <- starts[w] + (ends[w] - starts[w] + 1L) %/% 2L - 1L
      starts <- append(starts, mid + 1L, after = w)
      ends <- append(ends, mid, after = w - 1L)
    }
  }

  data.frame(
    segment = seq_along(starts),
    start = as.integer(starts),
    end = as.integer(ends),
    apex = as.integer(mapply(\(s, e) s - 1L + which.max(y[s:e]), starts, ends))
  )
}
