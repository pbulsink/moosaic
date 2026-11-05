#' Suggest the internal reference peak
#'
#' @param peaks Peak table; see `.reference_peak_ok()`.
#' @param min_score,min_area_percent See `.reference_peak_ok()`.
#'
#' @return A list: `peak_index` (row, `NA` if none), `n_peaks`, `total_area`,
#'   `area_percent`, `score`, `name` and `approved`. `approved` is `TRUE` when
#'   the largest peak itself qualifies; otherwise the largest qualifying peak
#'   is returned.
#'
#' @keywords internal
.suggest_reference_peak <- function(
  peaks,
  min_score = .get_moosaic_option("min_match_factor"),
  min_area_percent = 0.001
) {
  total_area <- sum(peaks$area, na.rm = TRUE)
  ok <- .reference_peak_ok(peaks, min_score, min_area_percent)
  idx <- which.max(peaks$area)
  approved <- length(idx) == 1L && isTRUE(ok[idx])
  if (!approved) {
    qualifying <- which(ok)
    idx <- if (length(qualifying)) {
      qualifying[which.max(peaks$area[qualifying])]
    } else {
      NA_integer_
    }
  }
  found <- !is.na(idx)
  list(
    peak_index = idx,
    n_peaks = nrow(peaks),
    total_area = total_area,
    area_percent = if (found) peaks$area[idx] / total_area * 100 else NA_real_,
    score = if (found) peaks$score[idx] else NA_real_,
    name = if (found) peaks$name[idx] else NA_character_,
    approved = approved
  )
}
