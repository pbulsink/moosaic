#' Print a gcms_fid_exp object
#'
#' @param x A `gcms_fid_exp` object.
#' @param ... Additional arguments (unused).
#'
#' @return Invisibly, x.
#'
#' @keywords internal
#' @export
print.gcms_fid_exp <- function(x, ...) {
  cat("GC-FID/MS Experiment\n")
  cat("Sample:", x$ms$metadata$sample_name %||% "unknown", "\n")
  cat("FID points:", length(x$fid$rt), "\n")
  cat("MS scans:", length(x$ms$rt), "\n")
  cat(
    "RT range:",
    sprintf("%.2f", min(x$ms$rt)),
    "-",
    sprintf("%.2f", max(x$ms$rt)),
    "min\n"
  )
  cat("Alignment delay:", x$alignment$delay %||% 0, "min\n")
  cat("Processing steps:", length(x$processing), "\n")

  invisible(x)
}
