#' Fit one window by MCR-ALS
#'
#' @param D Numeric matrix, scans x m/z.
#' @param rank Integer; number of analyte components.
#' @param C0 Numeric matrix, scans x components: initial concentrations
#'   (see [build_constraints()]), background column last.
#' @param background `NULL`/`FALSE` for none, otherwise `C0` must hold a
#'   trailing background column (`rank + 1` columns).
#'
#' @return List with `concentration`, `spectra`, `residuals` and
#'   `diagnostics` (see `.als_diagnostics()`, plus `rss` and `rd`).
#'   Uses the `moosaic.als_maxiter`, `moosaic.als_thresh` and
#'   `moosaic.als_unimodal` options. Initial spectra come from the SVD
#'   (`.build_s0()`).
#'
#' @export
fit_window <- function(D, rank, C0, background = NULL) {
  has_bg <- isTRUE(background)
  n_comp <- rank + has_bg
  if (!is.matrix(C0) || ncol(C0) != n_comp) {
    .moosaic_abort(
      "{.arg C0} must have {n_comp} column{?s} for {.arg rank} = {rank}{if (has_bg) ' plus background'}, not {NCOL(C0)}.",
      class = "bad_argument"
    )
  }
  maxiter <- .get_moosaic_option("als_maxiter")
  rt <- seq_len(nrow(D))
  mz <- if (is.null(colnames(D))) seq_len(ncol(D)) else colnames(D)
  S0 <- .build_s0(D, n_comp)
  input <- .to_als_input(D, C0, S0, rt, suppressWarnings(as.numeric(mz)))
  raw <- .run_als(
    input,
    maxiter = maxiter,
    thresh = .get_moosaic_option("als_thresh"),
    unimodal = .get_moosaic_option("als_unimodal"),
    baseline = has_bg
  )
  out <- .from_als_output(raw, rt, mz, maxiter)
  dg <- .als_diagnostics(D, out$concentration, out$spectra, out)
  dg$rss <- out$rss
  dg$rd <- out$rd
  list(
    concentration = out$concentration,
    spectra = out$spectra,
    residuals = out$residuals,
    diagnostics = dg
  )
}
