#' Apportion raw FID area among fitted components
#'
#' @param fid_raw_window List with `rt` and `intensity` (raw FID on the
#'   window's scans).
#' @param C Numeric matrix, scans x components (fitted concentrations).
#' @param is_background Logical vector, one per column of `C`; `TRUE` columns
#'   take no share and get `NA`. Defaults to none.
#' @param call Call environment for errors.
#'
#' @return Numeric vector, one area per column of `C`. At each scan the raw
#'   FID is split in proportion to the non-background fitted signal, so the
#'   areas sum to the trapezoidal area of the raw FID (scans where all
#'   components are zero contribute nothing).
#'
#' @keywords internal
.apportion_fid_area <- function(
  fid_raw_window,
  C,
  is_background = NULL,
  call = rlang::caller_env()
) {
  if (nrow(C) != length(fid_raw_window$rt)) {
    .moosaic_abort(
      "{.arg C} has {nrow(C)} rows but the FID window has {length(fid_raw_window$rt)} scans.",
      class = "bad_argument",
      call = call
    )
  }
  is_background <- is_background %||% rep(FALSE, ncol(C))
  analyte <- C[, !is_background, drop = FALSE]
  tot <- rowSums(analyte)
  tot[tot <= 0] <- NA
  areas <- rep(NA_real_, ncol(C))
  areas[!is_background] <- vapply(
    seq_len(ncol(analyte)),
    \(k) {
      share <- analyte[, k] / tot
      share[is.na(share)] <- 0
      .integrate_trapezoid(
        fid_raw_window$rt,
        fid_raw_window$intensity * share,
        call = call
      )
    },
    numeric(1)
  )
  areas
}
