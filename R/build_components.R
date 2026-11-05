#' Turn a window fit into components
#'
#' @param fit Result of [fit_window()].
#' @param fid_window List with `rt` and `intensity`: the **raw** FID on the
#'   window's scans.
#' @param window Window specification (see `.parse_window()`).
#' @param background Logical; the last fitted column is a background component.
#' @param call Call environment for errors.
#'
#' @return List of `moosaic_component` objects, one per fitted column. `rt` is
#'   the time of the maximum of the fitted profile; `area_fid` is the apportioned
#'   raw FID area (`NA` for background); `area_ms` is the area of the fitted
#'   profile scaled by the summed spectrum; `fid_ms_ratio` is their quotient;
#'   `residual` is the window's lack of fit (%).
#'
#' @keywords internal
.build_components <- function(
  fit,
  fid_window,
  window,
  background = FALSE,
  call = rlang::caller_env()
) {
  C <- fit$concentration
  S <- fit$spectra
  rt <- fid_window$rt
  if (nrow(C) != length(rt)) {
    .moosaic_abort(
      "Fit has {nrow(C)} scans but the FID window has {length(rt)}.",
      class = "bad_argument",
      call = call
    )
  }
  w <- .parse_window(window, call = call)
  is_bg <- rep(FALSE, ncol(C))
  if (isTRUE(background)) {
    is_bg[ncol(C)] <- TRUE
  }
  areas <- .apportion_fid_area(fid_window, C, is_bg, call = call)
  dg <- fit$diagnostics
  lapply(seq_len(ncol(C)), \(k) {
    spec <- S[, k]
    names(spec) <- rownames(S)
    area_ms <- .integrate_trapezoid(rt, C[, k] * sum(spec))
    .new_component(
      id = paste0("w", w$window_id, "_c", k),
      window_id = w$window_id,
      rt = rt[which.max(C[, k])],
      chromatogram = list(rt = rt, intensity = unname(C[, k])),
      spectrum = spec,
      area_fid = areas[k],
      area_ms = area_ms,
      fid_ms_ratio = if (is_bg[k]) NA_real_ else areas[k] / area_ms,
      residual = dg$lack_of_fit,
      explained_variance = dg$explained_variance[k],
      is_background = is_bg[k]
    )
  })
}
