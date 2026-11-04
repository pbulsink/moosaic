For the ALS package, what you ultimately need is a matrix:

D = RT × variables


where:

rows    = scans (retention times)
columns = m/z bins


and optionally an initial estimate of concentration profiles (C0) and spectra (S0).

Assuming chromConverter::read_chemstation_ms() returns scans with m/z and intensity vectors, I'd write a conversion layer that is independent of the deconvolution itself.

Build RT × m/z matrix
build_als_matrix <- function(
    ms,
    mz_min = 35,
    mz_max = 500,
    mz_bin = 1
) {

    mz_grid <- seq(
        mz_min,
        mz_max,
        by = mz_bin
    )

    n_scans <- length(ms$spectra)

    D <- matrix(
        0,
        nrow = n_scans,
        ncol = length(mz_grid)
    )

    for (i in seq_len(n_scans)) {

        sp <- ms$spectra[[i]]

        mz <- sp$mz
        int <- sp$intensity

        idx <- round(
            (mz - mz_min) / mz_bin
        ) + 1

        keep <- idx >= 1 &
            idx <= length(mz_grid)

        idx <- idx[keep]
        int <- int[keep]

        D[i, ] <- rowsum(
            int,
            idx,
            reorder = FALSE
        ) |>
            {
                tmp <- numeric(length(mz_grid))
                tmp[as.integer(rownames(.))] <- .
                tmp
            }
    }

    rownames(D) <- ms$rt

    colnames(D) <- paste0(
        "mz",
        mz_grid
    )

    list(
        D = D,
        rt = ms$rt,
        mz = mz_grid
    )
}


For nominal-mass EI data I'd start with:

mz_bin = 1


which corresponds naturally to NIST-style spectra.

Sparse matrix version

For fuel samples with long chromatograms, the dense matrix may become large.

Use Matrix:

library(Matrix)

build_sparse_matrix <- function(
    ms,
    mz_min = 35,
    mz_max = 500
) {

    mz_grid <- mz_min:mz_max

    I <- integer()
    J <- integer()
    X <- numeric()

    for(i in seq_along(ms$spectra)) {

        sp <- ms$spectra[[i]]

        idx <- round(sp$mz)

        keep <- idx >= mz_min &
            idx <= mz_max

        idx <- idx[keep]
        intensity <- sp$intensity[keep]

        I <- c(I, rep(i, length(idx)))
        J <- c(J, idx - mz_min + 1)
        X <- c(X, intensity)
    }

    sparseMatrix(
        i = I,
        j = J,
        x = X,
        dims = c(
            length(ms$spectra),
            length(mz_grid)
        )
    )
}


For local-window ALS this may not matter, but for whole-run storage it helps.

Extract a local window

I would almost never send a whole chromatogram to ALS.

extract_window <- function(
    D,
    rt,
    start_rt,
    end_rt
) {

    keep <- rt >= start_rt &
        rt <= end_rt

    D[keep, , drop = FALSE]
}


Usage:

D_local <- extract_window(
    D,
    rt,
    12.35,
    12.82
)

Build FID-derived C0

Suppose you have already aligned the FID.

build_C0 <- function(
    fid_rt,
    fid_signal,
    peak_centers,
    peak_width = 0.05
) {

    ncomp <- length(peak_centers)

    C0 <- matrix(
        0,
        nrow = length(fid_rt),
        ncol = ncomp
    )

    for(i in seq_len(ncomp)) {

        C0[, i] <-
            dnorm(
                fid_rt,
                mean = peak_centers[i],
                sd = peak_width
            )

        C0[, i] <-
            C0[, i] /
            max(C0[, i])
    }

    C0
}


Later, I'd replace this with actual FID peak segments rather than Gaussian approximations.

Initial spectral estimate S0

Simple SVD initialization:

build_S0 <- function(
    D,
    rank
) {

    sv <- svd(D)

    sv$v[, seq_len(rank), drop = FALSE]
}

Create ALS input object

Putting everything together:

prepare_als_input <- function(
    ms,
    fid,
    rank
) {

    x <- build_als_matrix(ms)

    D <- x$D

    S0 <- build_S0(
        D,
        rank
    )

    list(
        D = D,
        rt = x$rt,
        mz = x$mz,
        S0 = S0
    )
}

Typical workflow
ms <- chromConverter::read_chemstation_ms(
    "sample.ms"
)

fid <- chromConverter::read_chemstation_ch(
    "FID1A.ch"
)

als_data <- prepare_als_input(
    ms,
    fid,
    rank = 4
)

D  <- als_data$D
S0 <- als_data$S0


Then, for a specific FID-defined region:

D_local <- extract_window(
    D,
    als_data$rt,
    10.20,
    10.55
)

sv <- svd(D_local)

rank <- 3

S0 <- sv$v[, 1:rank]

C0 <- sv$u[, 1:rank]


which produces matrices in exactly the form expected by ALS-style bilinear decomposition:

D ≈ C S'


with:

D      scans × m/z
C      scans × components
S      m/z × components

