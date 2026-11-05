#' Centred running minimum
#'
#' Van Herk / Gil-Werman algorithm: cost independent of window size.
#'
#' @param x Numeric vector.
#' @param window Odd integer; window length in points.
#'
#' @return Numeric vector, same length as `x`. Edges repeat the end values.
#'
#' @keywords internal
.running_min <- function(x, window) {
  n <- length(x)
  h <- (window - 1) / 2
  xp <- c(rep(x[1], h), x, rep(x[n], h))
  len <- length(xp)
  m <- ceiling(len / window) * window
  mat <- matrix(c(xp, rep(Inf, m - len)), nrow = window)
  fwd <- as.vector(apply(mat, 2, cummin))
  bwd <- as.vector(apply(mat, 2, \(v) rev(cummin(rev(v)))))
  i <- seq_len(n)
  pmin(bwd[i], fwd[i + window - 1])
}
