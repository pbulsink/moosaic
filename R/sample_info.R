#' Sample metadata for quantification and reports
#'
#' @param sample_id Sample identifier (single string).
#' @param sample_name,project_code Optional descriptive strings.
#' @param analyst Character vector of analysts; joined with `"/"`.
#' @param density Sample density (g/mL), positive.
#' @param methanol_wt_pct,water_wt_pct Methanol and water content (wt%), from
#'   0 to 100, not seen by GC.
#' @param dilution Dilution factor, positive; scales external calibration
#'   amounts.
#' @param report_date Report date.
#'
#' @return An object of class `moosaic_sample`: a list of the validated
#'   arguments.
#'
#' @examples
#' sample_info("S1", density = 0.85, analyst = c("A", "B"))
#'
#' @export
sample_info <- function(
  sample_id,
  sample_name = "",
  project_code = "",
  analyst = "",
  density = 1,
  methanol_wt_pct = 0,
  water_wt_pct = 0,
  dilution = 1,
  report_date = Sys.Date()
) {
  call <- rlang::current_env()
  num_ok <- \(x, lo, hi, open = FALSE) {
    is.numeric(x) &&
      length(x) == 1L &&
      is.finite(x) &&
      (x > lo || (!open && x == lo)) &&
      x <= hi
  }
  bad <- \(arg, what) {
    .moosaic_abort(
      "{.arg {arg}} must be {what}.",
      class = "bad_argument",
      call = call
    )
  }
  if (!is.character(sample_id) || length(sample_id) != 1L || is.na(sample_id)) {
    bad("sample_id", "a single string")
  }
  if (!num_ok(density, 0, Inf, open = TRUE)) {
    bad("density", "a positive number")
  }
  if (!num_ok(dilution, 0, Inf, open = TRUE)) {
    bad("dilution", "a positive number")
  }
  if (!num_ok(methanol_wt_pct, 0, 100)) {
    bad("methanol_wt_pct", "a number between 0 and 100")
  }
  if (!num_ok(water_wt_pct, 0, 100)) {
    bad("water_wt_pct", "a number between 0 and 100")
  }
  structure(
    list(
      sample_id = sample_id,
      sample_name = sample_name,
      project_code = project_code,
      analyst = paste(analyst, collapse = "/"),
      density = density,
      methanol_wt_pct = methanol_wt_pct,
      water_wt_pct = water_wt_pct,
      dilution = dilution,
      report_date = as.Date(report_date)
    ),
    class = "moosaic_sample"
  )
}
