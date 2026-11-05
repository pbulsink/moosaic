#' Read a GC-FID/MS experiment from ChemStation files
#'
#' Reads `.ms` and `.ch` files using chromConverter and constructs
#' a validated `gcms_fid_exp` object.
#'
#' @param ms_file Character; path to ChemStation `.ms` file.
#' @param fid_file Character; path to ChemStation `.ch` file.
#'
#' @return A `gcms_fid_exp` object.
#'
#' @examples
#' \dontrun{
#'   exp <- read_experiment("sample.ms", "sample.ch")
#' }
#'
#' @export
read_experiment <- function(ms_file, fid_file) {
  if (!file.exists(ms_file)) {
    .moosaic_abort(
      "MS file {.path {ms_file}} not found",
      class = "file_not_found",
      call = rlang::caller_env()
    )
  }
  if (!file.exists(fid_file)) {
    .moosaic_abort(
      "FID file {.path {fid_file}} not found",
      class = "file_not_found",
      call = rlang::caller_env()
    )
  }

  # Use chromConverter to read
  ms_raw <- chromConverter::read_chemstation_ms(
    ms_file,
    data_format = "long",
    format_out = "matrix"
  )
  fid_raw <- chromConverter::read_chemstation_ch(fid_file, scale = TRUE)

  # Standardize to internal structure
  ms <- .standardize_ms(ms_raw, call = rlang::caller_env())
  fid <- .standardize_fid(fid_raw, call = rlang::caller_env())

  # Extract metadata from attributes
  ms$metadata <- .extract_metadata(ms_raw)
  fid$metadata <- .extract_metadata(fid_raw)

  # Add file sources to metadata
  ms$metadata$source_file <- ms_file
  fid$metadata$source_file <- fid_file

  exp <- .new_gcms_fid_exp(
    ms = ms,
    fid = fid,
    alignment = list(delay = 0, engine = NULL, score = NA, validated = FALSE),
    processing = list(
      read_experiment = list(ms_file = ms_file, fid_file = fid_file)
    )
  )

  .validate_gcms_fid_exp(exp, call = rlang::caller_env())
  exp
}
