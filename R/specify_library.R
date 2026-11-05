#' Specify library paths for spectral searching
#'
#' Sets `moosaic.library_path` to a list of NIST-format library directory paths.
#' Each path is checked to exist.
#'
#' @param paths Character vector or list of path strings to NIST library directories.
#'
#' @return Invisibly, the new library path setting.
#'
#' @examples
#' \dontrun{
#'   specify_library("C:/NIST23/MSSEARCH/mainlib/")
#'   specify_library(c("C:/NIST23/mainlib/", "C:/NIST23/replib/"))
#' }
#'
#' @export
specify_library <- function(paths) {
  if (!is.character(paths) && !is.list(paths)) {
    .moosaic_abort(
      "{.var paths} must be a character vector or list",
      class = "bad_input",
      call = rlang::caller_env()
    )
  }

  if (is.character(paths)) {
    paths <- as.list(paths)
  }

  # Check each path exists
  for (path in paths) {
    if (!dir.exists(path)) {
      .moosaic_abort(
        "library path {.path {path}} does not exist",
        class = "missing_path",
        call = rlang::caller_env()
      )
    }
  }

  set_moosaic_options(library_path = paths)
  invisible(getOption("moosaic.library_path"))
}
