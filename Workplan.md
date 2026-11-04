# Processing Flow:

Read MS & FID (ChromConverter R package)
↓
Align detectors (GCAlignR or internal)
↓
Find FID regions
↓
Extract local MS windows
↓
Estimate rank
↓
Build FID constraints
↓
MCR-ALS deconvolution on windowed pieces (ALS R package)
↓
Export spectra
↓
MSPepSearch (R package MSPepSearch, libraries as .msp or .msl format)
↓
RI & elemental filtering
↓
Quantification (polyarc)
↓
Report

Notes:
Refer to C:/Users/pbulsink/Documents/fidms for quantification (via the fidms.md file) and final reporting. Ignore MS compound type (ASTM D2425) work in that repo. Bring the required code here, do not use it as a dependency
Use cli::cli_abort() and family for communicating to user.
Use extensive function documentation, including for internal functions. 
Write only one function per R file.
Follow r-coding and tdd workflow skills.
Data conversion may have to happend from time to time based on the package requirements. Refer to als-data-prep.md for guidance on that phase. 
User configurable settings (related to library location, MSPepSearch parameters, any parameters from this code) should all be saved to one R file and loaded in as `options('moosaic.[param]' = 'foo')` for user customization. Add functions for updating the options (`specify_library <- function(path){options('moosaic.library_path' = path)}`).


# Specifics: 

Read in data and store as a structure:
```
read_experiment <- function(
    ms_file,
    fid_file
) {

    ms <- chromConverter::read_chemstation_ms(
        ms_file
    )

    fid <- chromConverter::read_chemstation_ch(
        fid_file
    )

    structure(
        list(
            ms = ms,
            fid = fid
        ),
        class = "gcms_fid_exp"
    )
}
```
A data storage structure should be like:
```
experiment
├─ ms
│   ├─ scans
│   ├─ rt
│   └─ metadata
├─ fid
│   ├─ rt
│   └─ intensity
└─ alignment
```

# Signal Pre-Processing:
FID can be signal processed to provide input to MSD data, but maybe for quantification we need less processing. 
FID is used for peak detection, window generation, component count estimation, chromatographic constraints and can be baseline corrected, smoothed, and have derivatives and peak fitting calculations performed to aid in that goal. 
FID is later used for quantification and at that time can only be integrated to reduce changes in smoothing. For Polyarc, the baseline must remain at zero (or a linear baseline from start to finish). 
MSD is used for peak detection, spectral decomposition, quantitative assistance, and library searching and thus smoothing, baseline correction and denoising should be avoided to reduce loss of sensitivity for trace components. 

## pseudocode:
```
deconvolve_run <- function(exp) {

    exp <- align_detectors(exp)

    windows <- detect_fid_windows(exp)

    results <- lapply(
        windows,
        process_window,
        exp = exp
    )

    identify_components(results)
}

align_detectors <- function(exp) {

    tic <- build_tic(exp$ms)

    delay <- estimate_delay(
        fid = exp$fid,
        tic = tic
    )

    exp$alignment$delay <- delay

    exp
}

``` 
A later add on is to validate that alignment has happened correctly by comparing peak areas to ensure matching hasn't solved big-little little-big pairs

## deconvolving
Rather than deconvolving every peak independently:

R
detect_fid_windows <- function(exp) {
    peaks <- detect_fid_peaks(
        exp$fid
    )
 
    merge_overlapping_peaks(
        peaks
    )
}
```
Output:

Plain Text
window 1
5.10 - 5.35
 
window 2
5.32 - 5.61
 
window 3
11.4 - 11.9

Once windows are had we can extract ms_matrix from each window:
```
extract_ms_matrix <- function(
    exp,
    window
)
```
Returning  a vector of `list(D, rt, mz)` where D = RT × m/z

# Rank Estimation
This is where things get more mathematical. For each D we find the rank, with as many algorithms as we'd like to use. 
```
estimate_rank <- function(D,fid)
```
internally:

```
rank_fid()
rank_svd()
rank_bic()
rank_pa()
```

Then, `consensus_rank()` returns `list(rank = 3,confidence = 0.82)`.

# FID constraints (needing to figure this out a bunch): 
Instead of constraints being `dnorm(...)`, use actual FID substructure.
```
build_constraints <- function(
    fid_window,
    rank
)
```
returns
```
R
C0
```
where

columns = initial chromatograms derived from measured FID signal, Not idealized Gaussians.

# ALS interface

I'd hide the implementation in internal functions
```
fit_window <- function(
D,
rank,
C0
)
```
returns
```
list(
concentration,
spectra,
residuals,
diagnostics
)
```
Internally:
a) Initialize C
b) Estimate S
c) Apply constraints
d) Estimate C
e) Apply constraints
Repeat

Background handling

This is where I differ from many preprocessing pipelines.

Rather than:

Plain Text
MS matrix
↓
baseline correction
↓
ALS

I'd support:

Plain Text
MS matrix
↓
ALS
↓
background component

So if the data contain:

Plain Text
siloxanes
column bleed
vacuum background
air

the model is allowed to discover them.

Something like:

R
rank <- estimated_rank + 1

where the extra component is available for background.

Later diagnostics can decide if it was used.

Component object

Each recovered component:

R
component

contains

R
list(
 
id,
 
rt,
 
chromatogram,
 
spectrum,
 
area_fid,
 
area_ms,
 
residual,
 
explained_variance
)

Notice I'd store both:

Plain Text
FID area
MS area

This could become a very valuable QC metric.

Identification
R
annotate_component <- function(
component
)

Workflow:

Plain Text
Spectrum
↓
MSP export
↓
MSPepSearch
↓
Candidate list
↓
RI penalties
↓
Element penalties (get from default parameters)
↓
Final score

Where RI and element penalties can be defined (apply penalty of X per heteroatom or for y*RI units away from MS match outside of grace window)

