#' Components as a tibble
#'
#' @param components A list of `moosaic_component` objects or a
#'   `moosaic_result`.
#'
#' @return A tibble with one row per component and the component fields as
#'   columns (`chromatogram` and `spectrum` are list-columns).
#'
#' @export
components_to_tibble <- function(components) {
  if (inherits(components, "moosaic_result")) {
    components <- components$components
  }
  if (
    !is.list(components) ||
      !all(vapply(components, inherits, logical(1), "moosaic_component"))
  ) {
    .moosaic_abort(
      "{.arg components} must be a list of components or a {.cls moosaic_result}.",
      class = "bad_argument"
    )
  }
  col <- \(f, type) vapply(components, \(x) x[[f]], type)
  tibble::tibble(
    id = col("id", character(1)),
    window_id = col("window_id", integer(1)),
    rt = col("rt", numeric(1)),
    chromatogram = lapply(components, \(x) x$chromatogram),
    spectrum = lapply(components, \(x) x$spectrum),
    area_fid = col("area_fid", numeric(1)),
    area_ms = col("area_ms", numeric(1)),
    fid_ms_ratio = col("fid_ms_ratio", numeric(1)),
    residual = col("residual", numeric(1)),
    explained_variance = col("explained_variance", numeric(1)),
    is_background = col("is_background", logical(1))
  )
}
