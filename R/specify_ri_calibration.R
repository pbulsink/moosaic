#' Specify RI calibration file
#'
#' Sets `moosaic.ri_calibration_path` and validates the file exists and is readable.
#'
#' @param path Character; path to `.CAL` file.
#'
#' @return Invisibly, the new path setting.
#'
#' @examples
#' \dontrun{
#'   specify_ri_calibration("ONSITE.CAL")
#' }
#'
#' @export
specify_ri_calibration <- function(path) {
  if (!file.exists(path)) {
    .moosaic_abort(
      "RI calibration file {.path {path}} does not exist",
      class = "missing_file",
      call = rlang::caller_env()
    )
  }

  set_moosaic_options(ri_calibration_path = path)
  invisible(getOption("moosaic.ri_calibration_path"))
}
