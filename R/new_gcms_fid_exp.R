#' Create a new gcms_fid_exp object (internal constructor)
#'
#' Internal function to construct the core data structure.
#' Use [gcms_fid_exp()] or [read_experiment()] to build objects in user code.
#'
#' @param ms List with elements `data` (matrix, rt, tic), `metadata`.
#' @param fid List with elements `rt`, `intensity`, `metadata`.
#' @param alignment List with elements `delay`, `engine`, `score`, `validated`.
#' @param processing List (log of steps and parameters).
#'
#' @return An object of class `gcms_fid_exp`.
#'
#' @keywords internal
.new_gcms_fid_exp <- function(ms, fid, alignment, processing) {
  structure(
    list(
      ms = ms,
      fid = fid,
      alignment = alignment,
      processing = processing
    ),
    class = "gcms_fid_exp"
  )
}
