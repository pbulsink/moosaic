# Noise-free or noisy low-rank test data: scans x m/z with Gaussian elution
# profiles and Gaussian spectra, plus a matching FID trace (one value per scan).
make_lowrank <- function(
  rank,
  n_scan = 40L,
  n_mz = 30L,
  noise = 0,
  seed = NULL
) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  scan <- seq_len(n_scan)
  mz <- seq_len(n_mz)
  C <- vapply(
    c(12, 20, 28)[seq_len(rank)],
    \(m) exp(-0.5 * ((scan - m) / 3)^2),
    numeric(n_scan)
  )
  S <- vapply(
    c(6, 15, 24)[seq_len(rank)],
    \(m) exp(-0.5 * ((mz - m) / 3)^2),
    numeric(n_mz)
  )
  C <- matrix(C, n_scan)
  S <- matrix(S, n_mz)
  D <- 100 * C %*% t(S) + matrix(rnorm(n_scan * n_mz, sd = noise), n_scan)
  fid <- list(
    rt = scan * 0.0045,
    intensity = 100 * rowSums(C) + rnorm(n_scan, sd = noise)
  )
  list(D = D, fid = fid, C = C, S = S)
}
