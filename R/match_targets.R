#' Match peak names to calibration targets
#'
#' @param names Character vector of peak names.
#' @param targets Tibble with columns `target` and `synonyms`.
#'
#' @return Character vector of matched target names, `NA` where none match.
#'
#' @details Matching ignores case and non-alphanumeric characters and uses
#'   both the target name and its synonym.
#'
#' @keywords internal
.match_targets <- function(names, targets) {
  key <- \(x) gsub("[^a-z0-9]", "", tolower(ifelse(is.na(x), "", x)))
  lookup <- stats::setNames(
    rep(targets$target, 2L),
    c(key(targets$target), key(targets$synonyms))
  )
  lookup <- lookup[nzchar(names(lookup))]
  unname(lookup[key(names)])
}
