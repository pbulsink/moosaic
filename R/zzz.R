#' moosaic: Multivariate Organic and Oxygenate Speciation and Analysis with Integrated Carbon detection
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

.onLoad <- function(libname, pkgname) {
  defaults <- .moosaic_default_options()
  # Only set options that are not already set (preserves .Rprofile customization)
  current <- options()
  to_set <- setdiff(names(defaults), names(current))
  if (length(to_set) > 0) {
    options(defaults[to_set])
  }
}
