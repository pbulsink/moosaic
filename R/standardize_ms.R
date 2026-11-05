#' Standardize MS data to internal structure
#'
#' Converts long-format or dense MS matrices to the internal representation.
#'
#' @param raw MS data from chromConverter or user input.
#' @param call Call environment for errors.
#'
#' @return List with `data`, `rt`, `tic`.
#'
#' @keywords internal
.standardize_ms <- function(raw, call = rlang::caller_env()) {
  # Detect format
  if (is.matrix(raw) || is.data.frame(raw)) {
    # Check if long format (3 columns: rt, mz, intensity) or dense
    if (ncol(raw) == 3) {
      # Long format
      cnames <- tolower(colnames(raw))
      if (!all(c("rt", "mz", "intensity") %in% cnames)) {
        .moosaic_abort(
          "MS matrix must have columns: rt, mz, intensity",
          class = "bad_format",
          call = call
        )
      }
      data <- as.matrix(raw)
      # Extract unique rt values (scans)
      rt_col <- which(tolower(colnames(raw)) == "rt")
      int_col <- which(tolower(colnames(raw)) == "intensity")
      # rowsum() groups on exact rt and returns sorted unique groups
      tic_by_scan <- rowsum(as.numeric(data[, int_col]), data[, rt_col])
      rt <- as.numeric(rownames(tic_by_scan))
      tic <- as.numeric(tic_by_scan[, 1])
      return(list(data = data, rt = rt, tic = tic))
    } else {
      .moosaic_abort(
        "MS matrix must have 3 columns (rt, mz, intensity)",
        class = "bad_format",
        call = call
      )
    }
  }

  # Check if it's a list (chromConverter format)
  if (is.list(raw)) {
    if (!all(c("MS1", "TIC") %in% names(raw))) {
      .moosaic_abort(
        "MS list must have MS1 and TIC elements",
        class = "bad_format",
        call = call
      )
    }
    return(list(
      data = as.matrix(raw$MS1),
      rt = raw$rt %||% sort(unique(raw$MS1[, 1])),
      tic = raw$TIC[, 2]
    ))
  }

  .moosaic_abort(
    "MS data must be a matrix or list",
    class = "bad_format",
    call = call
  )
}
