#' Validate a gcms_fid_exp object
#'
#' Internal validation function; aborts if structure is invalid.
#'
#' @param x An object to validate.
#' @param call Call environment for error messages.
#'
#' @return Invisibly, x if valid.
#'
#' @keywords internal
.validate_gcms_fid_exp <- function(x, call = rlang::caller_env()) {
  if (!is.list(x) || !identical(class(x), "gcms_fid_exp")) {
    .moosaic_abort("invalid gcms_fid_exp object", call = call)
  }

  # Check required slots
  if (!all(c("ms", "fid", "alignment", "processing") %in% names(x))) {
    .moosaic_abort(
      "gcms_fid_exp missing required slots",
      class = "bad_structure",
      call = call
    )
  }

  # Validate MS
  ms <- x$ms
  if (!all(c("data", "rt", "tic", "metadata") %in% names(ms))) {
    .moosaic_abort("MS missing required elements", call = call)
  }
  if (!is.numeric(ms$rt) || is.unsorted(ms$rt)) {
    .moosaic_abort(
      "MS rt must be numeric and sorted",
      class = "bad_structure",
      call = call
    )
  }
  if (length(ms$rt) != length(ms$tic)) {
    .moosaic_abort(
      "MS rt and tic length mismatch",
      class = "bad_structure",
      call = call
    )
  }
  if (!all(ms$tic >= 0)) {
    .moosaic_abort("MS tic must be non-negative", call = call)
  }

  # Validate FID
  fid <- x$fid
  if (!all(c("rt", "intensity", "metadata") %in% names(fid))) {
    .moosaic_abort("FID missing required elements", call = call)
  }
  if (!is.numeric(fid$rt) || !is.numeric(fid$intensity)) {
    .moosaic_abort("FID rt and intensity must be numeric", call = call)
  }
  if (length(fid$rt) != length(fid$intensity)) {
    .moosaic_abort("FID rt and intensity length mismatch", call = call)
  }
  if (is.unsorted(fid$rt)) {
    .moosaic_abort(
      "FID rt must be sorted",
      class = "bad_structure",
      call = call
    )
  }

  # Validate alignment
  if (!is.list(x$alignment)) {
    .moosaic_abort("alignment must be a list", call = call)
  }

  invisible(x)
}
