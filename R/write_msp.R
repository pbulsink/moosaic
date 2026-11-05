#' Write components to an MSP file
#'
#' @param components A list of `moosaic_component` objects or a
#'   `moosaic_result`. Background components are skipped.
#' @param path Output file.
#'
#' @return `path`, invisibly. Each block has `NAME`, `RETENTION_TIME`,
#'   `RETENTION_INDEX` (when the component has an `ri`), `Num Peaks` and
#'   `mz intensity` lines, intensities scaled to a maximum of 999.
#'
#' @export
write_msp <- function(components, path) {
  if (inherits(components, "moosaic_result")) {
    components <- components$components
  }
  call <- rlang::current_env()
  components <- Filter(\(x) !isTRUE(x$is_background), components)
  lines <- unlist(lapply(components, \(cmp) {
    q <- .component_to_query(cmp, cmp$ri, call = call)
    c(
      paste0("NAME: ", q$name),
      paste0("RETENTION_TIME: ", format(cmp$rt, digits = 6)),
      if (!is.null(q$retention_index)) {
        paste0("RETENTION_INDEX: ", format(q$retention_index, digits = 6))
      },
      paste0("Num Peaks: ", length(q$mz)),
      paste(format(q$mz, trim = TRUE), q$intst),
      ""
    )
  }))
  writeLines(as.character(lines), path)
  invisible(path)
}
