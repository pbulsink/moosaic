#' Apply a symmetric-support FIR filter with edge padding
#'
#' @param x Numeric vector.
#' @param coefs Numeric vector of odd length, in [stats::filter()] order.
#'
#' @return Numeric vector, same length as `x`.
#'
#' @keywords internal
.apply_filter <- function(x, coefs) {
  h <- (length(coefs) - 1) / 2
  n <- length(x)
  xp <- c(rep(x[1], h), x, rep(x[n], h))
  out <- stats::filter(xp, coefs, sides = 2)
  as.numeric(out[h + seq_len(n)])
}
