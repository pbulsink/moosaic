fid_raw <- function(n = 40) {
  list(
    rt = seq_len(n) * 0.0045,
    intensity = 10 + 100 * dnorm(seq_len(n), 20, 5)
  )
}

fake_fit <- function(bg = FALSE) {
  n <- 40
  scan <- seq_len(n)
  C <- cbind(dnorm(scan, 14, 3), dnorm(scan, 26, 3))
  mz <- 50:60
  S <- cbind(
    setNames(dnorm(mz, 53, 1), mz),
    setNames(dnorm(mz, 58, 1), mz)
  )
  if (bg) {
    C <- cbind(C, 0.02)
    S <- cbind(S, setNames(ifelse(mz == 57, 1, 0.01), mz))
  }
  list(
    concentration = C,
    spectra = S,
    residuals = matrix(0, n, length(mz)),
    diagnostics = list(
      lack_of_fit = 1.5,
      explained_variance = rep(0.5, ncol(C)),
      converged = TRUE
    )
  )
}
fake_window <- list(window_id = 3L, start_rt = 0, end_rt = 1)
