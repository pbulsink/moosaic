#' Flag solvent peaks
#'
#' @param name Character vector of peak names.
#' @param solvents Character vector of solvent names.
#'
#' @return Logical vector; matching ignores case and non-alphanumeric
#'   characters.
#'
#' @keywords internal
.is_solvent <- function(name, solvents = solvent_names) {
  key <- \(x) gsub("[^a-z0-9]", "", tolower(ifelse(is.na(x), "", x)))
  key(name) %in% key(solvents)
}
