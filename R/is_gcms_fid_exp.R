#' Check if object is a gcms_fid_exp
#'
#' @param x Object to test.
#'
#' @return Logical.
#'
#' @examples
#' is_gcms_fid_exp(list())  # FALSE
#'
#' @export
is_gcms_fid_exp <- function(x) {
  identical(class(x), "gcms_fid_exp")
}
