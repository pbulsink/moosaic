#' Default report file name and path check
#'
#' @param info A `moosaic_sample`.
#' @param ext File extension without the dot.
#' @param path Candidate path (`NULL` or a single string).
#' @param call Call environment for errors.
#'
#' @return `.report_path()`: `"{project_code}_{sample_id}_GC-MS-FID.{ext}"`.
#'   `.check_report_path()`: `NULL`, invisibly; aborts with class
#'   `bad_argument` unless `path` is `NULL` or a single string.
#'
#' @keywords internal
.report_path <- function(info, ext) {
  sprintf("%s_%s_GC-MS-FID.%s", info$project_code, info$sample_id, ext)
}

#' @rdname dot-report_path
#' @keywords internal
.check_report_path <- function(path, call = rlang::caller_env()) {
  ok <- is.null(path) ||
    (is.character(path) && length(path) == 1L && !is.na(path))
  if (!ok) {
    .moosaic_abort(
      "{.arg path} must be {.code NULL} or a single string.",
      class = "bad_argument",
      call = call
    )
  }
  invisible(NULL)
}
