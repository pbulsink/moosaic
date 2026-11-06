#' Standardize FID data to internal structure
#'
#' Converts FID matrix/data.frame to the internal representation.
#'
#' @param raw FID data from chromConverter or user input.
#' @param call Call environment for errors.
#'
#' @return List with `rt`, `intensity`.
#'
#' @keywords internal
.standardize_fid <- function(raw, call = rlang::caller_env()) {
  # chromConverter "wide" output: one intensity column, rt (min) in rownames
  if (is.matrix(raw) && ncol(raw) == 1L && !is.null(rownames(raw))) {
    rt <- suppressWarnings(as.numeric(rownames(raw)))
    if (!anyNA(rt)) {
      return(list(rt = rt, intensity = as.numeric(raw[, 1])))
    }
  }
  if (is.matrix(raw) || is.data.frame(raw)) {
    if (ncol(raw) != 2) {
      .moosaic_abort(
        "FID matrix must have 2 columns (rt, intensity)",
        class = "bad_format",
        call = call
      )
    }
    return(list(
      rt = as.numeric(raw[, 1]),
      intensity = as.numeric(raw[, 2])
    ))
  }

  if (is.list(raw)) {
    if (!all(c("rt", "intensity") %in% names(raw))) {
      .moosaic_abort(
        "FID list must have rt and intensity elements",
        class = "bad_format",
        call = call
      )
    }
    return(list(
      rt = as.numeric(raw$rt),
      intensity = as.numeric(raw$intensity)
    ))
  }

  .moosaic_abort(
    "FID data must be a matrix or list",
    class = "bad_format",
    call = call
  )
}
