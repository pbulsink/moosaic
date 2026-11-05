#' Total compound table
#'
#' @param x A `moosaic_result` after [quantify()].
#'
#' @return A tibble with one row per peak and columns `Peak No.`,
#'   `Compound Name`, `Retention Time` (text, minutes), `Compound Formula`,
#'   `Compound Molar Mass`, `Area (FID)`, `Amount (ug/mL)`,
#'   `Target or Relative`, `MS Match Score`, `Area (MS)`, `FID/MS Ratio`,
#'   `Rank Confidence`, `RI Delta` (observed minus library) and `Final Score`
#'   (match factor less RI and element penalties). Scores are `NA` for
#'   unidentified peaks.
#'
#' @examples
#' \dontrun{
#' total_compound_table(quantify(identified, sample_info("S1")))
#' }
#'
#' @export
total_compound_table <- function(x) {
  .require_quantified(x)
  p <- x$peaks
  tibble::tibble(
    `Peak No.` = seq_len(nrow(p)),
    `Compound Name` = p$name,
    `Retention Time` = format(round(p$rt, 3), trim = TRUE),
    `Compound Formula` = p$formula,
    `Compound Molar Mass` = round(p$mw, 3),
    `Area (FID)` = p$area,
    `Amount (ug/mL)` = round(p$amount_ug_ml, 3),
    `Target or Relative` = p$quant_basis,
    `MS Match Score` = p$score,
    `Area (MS)` = p$area_ms,
    `FID/MS Ratio` = p$fid_ms_ratio,
    `Rank Confidence` = p$rank_confidence,
    `RI Delta` = p$ri_delta,
    `Final Score` = p$final_score
  )
}
