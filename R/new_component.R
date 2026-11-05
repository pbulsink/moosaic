#' Construct a component
#'
#' @param id,window_id,rt,chromatogram,spectrum,area_fid,area_ms,fid_ms_ratio,residual,explained_variance,is_background
#'   Component fields; see `.build_components()`.
#'
#' @return An object of class `moosaic_component` (a list).
#'
#' @keywords internal
.new_component <- function(
  id,
  window_id,
  rt,
  chromatogram,
  spectrum,
  area_fid,
  area_ms,
  fid_ms_ratio,
  residual,
  explained_variance,
  is_background
) {
  structure(
    list(
      id = id,
      window_id = window_id,
      rt = rt,
      chromatogram = chromatogram,
      spectrum = spectrum,
      area_fid = area_fid,
      area_ms = area_ms,
      fid_ms_ratio = fid_ms_ratio,
      residual = residual,
      explained_variance = explained_variance,
      is_background = is_background
    ),
    class = "moosaic_component"
  )
}
