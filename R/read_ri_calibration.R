#' Read an RI calibration file
#'
#' @param path Path to a whitespace-delimited `.CAL` file with no header and
#'   one reference compound per line: `rt RI col3 col4 name`. The name may
#'   contain spaces.
#'
#' @return A tibble with `rt`, `ri`, `col3`, `col4` (numeric) and `name`.
#'
#' @details Blank lines are ignored. Aborts if the file is missing, a field
#'   is not numeric (the message names the line), there are fewer than two
#'   references, or `rt` or `ri` is not strictly increasing.
#'
#' @export
read_ri_calibration <- function(path) {
  call <- rlang::current_env()
  if (!is.character(path) || length(path) != 1L || !file.exists(path)) {
    .moosaic_abort(
      "RI calibration file {.path {path}} does not exist.",
      class = "missing_file",
      call = call
    )
  }
  lines <- readLines(path, warn = FALSE)
  keep <- which(nzchar(trimws(lines)))
  tokens <- strsplit(trimws(lines[keep]), "[[:space:]]+")
  rows <- lapply(seq_along(tokens), \(i) {
    tk <- tokens[[i]]
    num <- if (length(tk) >= 4L) suppressWarnings(as.numeric(tk[1:4])) else NA
    if (length(tk) < 4L || anyNA(num)) {
      .moosaic_abort(
        "RI calibration line {keep[i]} must start with four numeric fields.",
        class = "bad_calibration",
        call = call
      )
    }
    list(num = num, name = paste(tk[-(1:4)], collapse = " "))
  })
  num <- do.call(rbind, lapply(rows, `[[`, "num"))
  cal <- tibble::tibble(
    rt = num[, 1],
    ri = num[, 2],
    col3 = num[, 3],
    col4 = num[, 4],
    name = vapply(rows, `[[`, "", "name")
  )
  if (nrow(cal) < 2L) {
    .moosaic_abort(
      "RI calibration needs at least 2 reference rows, found {nrow(cal)}.",
      class = "bad_calibration",
      call = call
    )
  }
  if (any(diff(cal$rt) <= 0) || any(diff(cal$ri) <= 0)) {
    .moosaic_abort(
      "RI calibration {.field rt} and {.field ri} must both be strictly increasing.",
      class = "bad_calibration",
      call = call
    )
  }
  cal
}
