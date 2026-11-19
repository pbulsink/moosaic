#' Turn a window fit into components
#'
#' @param fit Result of [fit_window()].
#' @param fid_window List with `rt` and `intensity`: the **raw** FID on the
#'   window's scans.
#' @param window Window specification (see `.parse_window()`).
#' @param background Logical; the last fitted column is a background component.
#' @param call Call environment for errors.
#'
#' @return List of `moosaic_component` objects, one per retained column. `rt` is
#'   the time of the profile maximum; `area_fid` is the apportioned
#'   raw FID area (`NA` for background); `area_ms` is the area of the fitted
#'   profile scaled by the summed spectrum; `fid_ms_ratio` is their quotient;
#'   `residual` is the window's lack of fit (%).
#'
#' @details For localized windows, only apexes in the ownership core are kept
#'   (left closed, right open unless `core_last`). FID areas are apportioned
#'   among retained analytes within the core, interpolating its endpoints to
#'   avoid gaps or double integration. MS areas and profiles use the full fit.
#'
#' @keywords internal
.build_components <- function(
  fit,
  fid_window,
  window,
  background = FALSE,
  call = rlang::caller_env()
) {
  concentration <- fit$concentration
  spectra <- fit$spectra
  rt <- fid_window$rt
  if (nrow(concentration) != length(rt)) {
    .moosaic_abort(
      "Fit has {nrow(concentration)} scans but the FID window has {length(rt)}.",
      class = "bad_argument",
      call = call
    )
  }
  w <- .parse_window(window, call = call)
  is_bg <- rep(FALSE, ncol(concentration))
  if (isTRUE(background)) {
    is_bg[ncol(concentration)] <- TRUE
  }
  keep <- rep(TRUE, ncol(concentration))
  core_start <- window[["core_start_rt"]]
  core_end <- window[["core_end_rt"]]
  if (!is.null(core_start) && !is.null(core_end)) {
    apex <- rt[apply(concentration, 2L, which.max)]
    before_end <- apex < core_end |
      (isTRUE(window[["core_last"]]) & apex <= core_end)
    keep <- is_bg | (apex >= core_start & before_end)
  }
  concentration <- concentration[, keep, drop = FALSE]
  spectra <- spectra[, keep, drop = FALSE]
  is_bg <- is_bg[keep]
  area_fid <- fid_window
  area_concentration <- concentration
  if (!is.null(core_start) && !is.null(core_end) && ncol(concentration) > 0L) {
    core_rt <- sort(unique(c(
      max(min(rt), core_start),
      rt[rt > core_start & rt < core_end],
      min(max(rt), core_end)
    )))
    area_fid <- list(
      rt = core_rt,
      intensity = stats::approx(rt, fid_window$intensity, core_rt, rule = 2)$y
    )
    area_concentration <- matrix(
      vapply(
        seq_len(ncol(concentration)),
        function(k) {
          stats::approx(rt, concentration[, k], core_rt, rule = 2)$y
        },
        numeric(length(core_rt))
      ),
      nrow = length(core_rt)
    )
  }
  areas <- .apportion_fid_area(area_fid, area_concentration, is_bg, call = call)
  dg <- fit$diagnostics
  lapply(seq_len(ncol(concentration)), \(k) {
    spec <- spectra[, k]
    names(spec) <- rownames(spectra)
    area_ms <- .integrate_trapezoid(rt, concentration[, k] * sum(spec))
    .new_component(
      id = paste0("w", w$window_id, "_c", which(keep)[k]),
      window_id = w$window_id,
      rt = rt[which.max(concentration[, k])],
      chromatogram = list(rt = rt, intensity = unname(concentration[, k])),
      spectrum = spec,
      area_fid = areas[k],
      area_ms = area_ms,
      fid_ms_ratio = if (is_bg[k]) NA_real_ else areas[k] / area_ms,
      residual = dg$lack_of_fit,
      explained_variance = dg$explained_variance[which(keep)[k]],
      is_background = is_bg[k]
    )
  })
}
