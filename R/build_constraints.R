#' Build FID-derived initial concentration profiles
#'
#' Segments the FID window into one region per component and uses the measured
#' FID in each region as the starting concentration profile for MCR-ALS.
#'
#' @param fid_window List with `rt` and `intensity` of equal length: the FID
#'   resampled onto the window's scans (see `.extract_fid_window()`).
#' @param rank Integer; number of analyte components.
#' @param background `NULL` (default) or `FALSE` for none; `TRUE` for a flat
#'   background column; or a numeric vector with one value per scan for a
#'   custom background profile.
#'
#' @return A list with `C0` (scans x components matrix, columns scaled to a
#'   maximum of 1, zero outside their segment, non-negative; background column
#'   last), `segments` (see `.segment_fid_window()`) and `background_col`
#'   (column index, or `NA`).
#'
#' @export
build_constraints <- function(fid_window, rank, background = NULL) {
  call <- rlang::current_env()
  segs <- .segment_fid_window(fid_window, rank, call = call)
  N <- length(fid_window$rt)

  bg <- NULL
  if (isTRUE(background)) {
    bg <- .background_profile(N)
  } else if (is.numeric(background) && length(background) == N) {
    bg <- background
  } else if (!is.null(background) && !isFALSE(background)) {
    .moosaic_abort(
      "{.arg background} must be {.code NULL}, a logical flag, or a numeric vector with one value per scan.",
      class = "bad_argument"
    )
  }

  ok <- !is.na(fid_window$intensity)
  y <- stats::approx(
    fid_window$rt[ok],
    fid_window$intensity[ok],
    fid_window$rt,
    rule = 2
  )$y
  y <- pmax(y, 0)

  C0 <- matrix(0, N, nrow(segs))
  for (k in seq_len(nrow(segs))) {
    idx <- segs$start[k]:segs$end[k]
    C0[idx, k] <- y[idx]
  }
  C0 <- .normalize_columns(C0)

  background_col <- NA_integer_
  if (!is.null(bg)) {
    C0 <- cbind(C0, .normalize_columns(matrix(pmax(bg, 0), N)))
    background_col <- ncol(C0)
  }

  list(C0 = C0, segments = segs, background_col = background_col)
}
