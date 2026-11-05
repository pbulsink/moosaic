#' Build the argument list for `ALS::als()`
#'
#' @param D Numeric matrix, scans x m/z.
#' @param C0 Numeric matrix, scans x components (initial concentrations).
#' @param S0 Numeric matrix, m/z x components (initial spectra).
#' @param rt,mz Numeric vectors; scan times and m/z values.
#' @param call Call environment for errors.
#'
#' @return Named list `CList`, `PsiList`, `S`, `x`, `x2`.
#'
#' @keywords internal
.to_als_input <- function(D, C0, S0, rt, mz, call = rlang::caller_env()) {
  ok <- nrow(C0) == nrow(D) &&
    nrow(S0) == ncol(D) &&
    ncol(C0) == ncol(S0) &&
    length(rt) == nrow(D) &&
    length(mz) == ncol(D)
  if (!ok) {
    .moosaic_abort(
      "{.arg D}, {.arg C0}, {.arg S0}, {.arg rt} and {.arg mz} have inconsistent dimensions.",
      class = "bad_argument",
      call = call
    )
  }
  list(
    CList = list(unname(C0)),
    PsiList = list(unname(D)),
    S = unname(S0),
    x = rt,
    x2 = mz
  )
}
