#' Generate synthetic GC-FID/MS experiment data for testing
#'
#' Creates a known-truth `gcms_fid_exp` object with specified components,
#' retention times, and noise levels. Mirroring real sampling rates
#' (FID @ 50 Hz, MS @ 0.27 s scans).
#'
#' @param n_comp Integer; number of analyte components (plus optional background).
#' @param centers Numeric vector; retention times (min) of component centers.
#' @param widths Numeric vector; component widths (min) at half-height.
#' @param spectra List of numeric vectors; each component's m/z spectrum
#'   (names are m/z values, values are normalized intensities 0–1).
#' @param carbons Integer vector; number of carbon atoms per component (for quantification).
#' @param delay Numeric; MS detector delay relative to FID (min).
#' @param noise Numeric; standard deviation of Gaussian noise added to D and FID.
#' @param fid_hz Numeric; FID sampling rate (default 50 Hz).
#' @param scan_s Numeric; MS scan duration (default 0.27 s).
#' @param seed Integer; random seed for reproducibility.
#' @param duration Numeric; run length (min). Shorter runs are much faster.
#'
#' @return A `gcms_fid_exp` object with ground truth stored in `$processing$synthetic_truth`.
#'
#' @keywords internal
make_synthetic_run <- function(
  n_comp,
  centers,
  widths,
  spectra,
  carbons,
  delay = 0,
  noise = 0,
  fid_hz = 50,
  scan_s = 0.27,
  seed = NULL,
  duration = 120
) {
  if (!is.null(seed)) {
    set.seed(seed)
  }

  # Validate inputs
  if (
    length(centers) != n_comp ||
      length(widths) != n_comp ||
      length(spectra) != n_comp ||
      length(carbons) != n_comp
  ) {
    .moosaic_abort(
      "lengths of centers, widths, spectra, and carbons must equal n_comp",
      class = "bad_input"
    )
  }

  # Sampling rates
  fid_step <- 1 / fid_hz # seconds per point
  fid_step_min <- fid_step / 60 # convert to min
  scan_step_min <- scan_s / 60

  # Build FID trace over `duration` minutes
  fid_rt <- seq(-fid_step_min, duration, by = fid_step_min)
  fid_intensity <- numeric(length(fid_rt))

  # Add each component as Gaussian
  for (i in seq_len(n_comp)) {
    sigma <- widths[i] / (2 * sqrt(2 * log(2))) # FWHM -> sigma
    fid_intensity <- fid_intensity +
      100 * exp(-0.5 * ((fid_rt - centers[i]) / sigma)^2)
  }

  # Add baseline drift (small linear trend)
  fid_intensity <- fid_intensity + 5 + 0.02 * fid_rt

  # Add noise
  if (noise > 0) {
    fid_intensity <- fid_intensity + rnorm(length(fid_intensity), sd = noise)
  }

  # Build MS scans (aligned to scan grid, then apply delay)
  scan_rt_nominal <- seq(0.001, duration, by = scan_step_min)
  scan_rt <- scan_rt_nominal + delay
  n_scans <- length(scan_rt)

  # Build m/z grid from all spectra
  all_mz <- sort(unique(unlist(lapply(spectra, function(s) {
    as.numeric(names(s))
  }))))
  n_mz <- length(all_mz)

  # Allocate D (scans x m/z)
  D <- matrix(0, nrow = n_scans, ncol = n_mz)
  colnames(D) <- as.character(all_mz)

  # Add each component to D
  for (i in seq_len(n_comp)) {
    sigma <- widths[i] / (2 * sqrt(2 * log(2)))
    # Peak envelope across scans
    peak_envelope <- 1000 * exp(-0.5 * ((scan_rt_nominal - centers[i]) / sigma)^2)

    # Component spectrum
    spec <- spectra[[i]]
    for (j in seq_along(all_mz)) {
      mz <- all_mz[j]
      if (as.character(mz) %in% names(spec)) {
        intensity <- spec[as.character(mz)]
        D[, j] <- D[, j] + peak_envelope * intensity
      }
    }
  }

  # Add noise
  if (noise > 0) {
    D <- D +
      matrix(rnorm(n_scans * n_mz, sd = noise), nrow = n_scans, ncol = n_mz)
  }

  D <- pmax(D, 0) # Ensure non-negative

  # Compute TIC
  tic <- rowSums(D)

  # Build MS structure
  ms <- list(
    data = matrix(NA, nrow = 0, ncol = 3), # Placeholder; will be rebuilt
    rt = scan_rt,
    tic = tic,
    metadata = list(
      sample_name = "synthetic_test",
      detector_id = "5975 GCMS",
      detector_range = 2000,
      source_file = "synthetic"
    )
  )

  # Rebuild MS long format for consistency
  nz <- which(D > 0, arr.ind = TRUE)
  nz <- nz[order(nz[, 1], nz[, 2]), , drop = FALSE]
  long_data <- data.frame(
    rt = scan_rt[nz[, 1]],
    mz = all_mz[nz[, 2]],
    intensity = D[nz]
  )
  ms$data <- as.matrix(long_data)

  # Build FID structure
  fid <- list(
    rt = fid_rt,
    intensity = fid_intensity,
    metadata = list(
      sample_name = "synthetic_test",
      units = "pA",
      detector_range = 2000,
      intensity_multiplier = 1,
      source_file = "synthetic"
    )
  )

  # Create the experiment object
  exp <- .new_gcms_fid_exp(
    ms = ms,
    fid = fid,
    alignment = list(
      delay = delay,
      engine = "synthetic",
      score = NA,
      validated = FALSE
    ),
    processing = list(
      synthetic_truth = list(
        n_comp = n_comp,
        centers = centers,
        widths = widths,
        carbons = carbons,
        spectra = spectra,
        noise = noise,
        fid_rt = fid_rt,
        scan_rt = scan_rt,
        D_noiseless = D, # Store for comparison
        tic_noiseless = tic
      )
    )
  )

  .validate_gcms_fid_exp(exp)
  exp
}
