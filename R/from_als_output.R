#' Convert an `ALS::als()` result to moosaic structures
#'
#' @param fit Result of `ALS::als()`, optionally with a `trace` element.
#' @param rt,mz Numeric vectors used as dimnames.
#' @param maxiter Integer; iteration limit used.
#'
#' @return List with `concentration`, `spectra`, `residuals`, `rss`, `iter`,
#'   `converged` (`iter < maxiter`), `rd` (relative RSS decrease per iteration
#'   parsed from the trace; may be negative) and `rd_final`.
#'
#' @keywords internal
.from_als_output <- function(fit, rt, mz, maxiter) {
  C <- fit$CList[[1]]
  S <- fit$S
  dimnames(C) <- list(as.character(rt), NULL)
  dimnames(S) <- list(as.character(mz), NULL)
  R <- fit$resid[[1]]
  dimnames(R) <- list(as.character(rt), as.character(mz))
  rd <- numeric()
  if (!is.null(fit$trace)) {
    m <- regmatches(
      fit$trace,
      regexpr("RD: *-?[0-9.eE+-]+", fit$trace)
    )
    rd <- as.numeric(sub("RD: *", "", m))
  }
  list(
    concentration = C,
    spectra = S,
    residuals = R,
    rss = fit$rss,
    iter = fit$iter,
    converged = fit$iter < maxiter,
    rd = rd,
    rd_final = if (length(rd)) rd[length(rd)] else NA_real_
  )
}
