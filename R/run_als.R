#' Run `ALS::als()` quietly
#'
#' @param input List from `.to_als_input()`.
#' @param maxiter,thresh Passed to `ALS::als()`.
#' @param unimodal Logical; constrain concentration profiles to be unimodal.
#' @param baseline Logical; passed to `ALS::als()` (a flat background column
#'   is then not altered by the baseline treatment).
#' @param call Call environment for the warning.
#'
#' @return The `als()` result with an added `trace` element (the captured
#'   console output). Warns with class `als_not_converged` when `iter >=
#'   maxiter`; the result is still returned.
#'
#' @keywords internal
.run_als <- function(
  input,
  maxiter,
  thresh,
  unimodal,
  baseline,
  call = rlang::caller_env()
) {
  trace <- utils::capture.output(
    fit <- do.call(
      ALS::als,
      c(
        input,
        list(
          maxiter = maxiter,
          thresh = thresh,
          uniC = unimodal,
          baseline = baseline
        )
      )
    )
  )
  fit$trace <- trace
  if (fit$iter >= maxiter) {
    .moosaic_warn(
      "ALS did not converge within {maxiter} iteration{?s}.",
      class = "als_not_converged",
      call = call
    )
  }
  fit
}
