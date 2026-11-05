#' Governing calibration target for each peak
#'
#' @param peaks Tibble with an `O` (oxygen count) column.
#' @param matched Character vector from `.match_targets()`.
#' @param targets Tibble with columns `target` and `type`
#'   (`"hydrocarbon"` or `"oxygenate"`).
#'
#' @return Integer vector of row indices into `peaks`: the nearest preceding
#'   matched target of the same type (oxygenates use oxygenate targets), else
#'   the first matched target; `NA` when no target matched.
#'
#' @keywords internal
.assign_target_rows <- function(peaks, matched, targets) {
  type <- targets$type[match(matched, targets$target)]
  is_oxy <- !is.na(peaks$O) & peaks$O > 0
  hc_rows <- which(!is.na(matched) & type == "hydrocarbon")
  ox_rows <- which(!is.na(matched) & type == "oxygenate")
  pick <- \(i) {
    pool <- if (is_oxy[i] && length(ox_rows)) ox_rows else hc_rows
    if (!length(pool)) {
      pool <- ox_rows
    }
    if (!length(pool)) {
      return(NA_integer_)
    }
    preceding <- pool[pool <= i]
    if (length(preceding)) max(preceding) else min(pool)
  }
  vapply(seq_len(nrow(peaks)), pick, integer(1))
}
