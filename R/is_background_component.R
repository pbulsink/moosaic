#' Is a component column-bleed, air or a flat baseline?
#'
#' @param C Numeric vector; concentration profile.
#' @param S Numeric vector; spectrum named by m/z.
#' @param flat_tol Relative range below which `C` counts as flat.
#'
#' @return Logical. `TRUE` when `C` is flat (range under `flat_tol` of its
#'   maximum) or the three strongest ions of `S` are all column bleed (73,
#'   207, 281, 355) or air (40, 44; only when at least `moosaic.mz_min`).
#'
#' @keywords internal
.is_background_component <- function(C, S, flat_tol = 0.05) {
  C <- as.numeric(C)
  mx <- max(C)
  if (mx <= 0 || diff(range(C)) / mx < flat_tol) {
    return(TRUE)
  }
  mz <- names(S)
  if (is.null(mz)) {
    return(FALSE)
  }
  bg <- c(73, 207, 281, 355)
  air <- c(40, 44)
  air <- air[air >= .get_moosaic_option("mz_min")]
  top <- as.numeric(mz[order(S, decreasing = TRUE)[1:min(3L, length(S))]])
  all(round(top) %in% c(bg, air))
}
