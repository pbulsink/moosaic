I read through some more MCR-ALS papers. 
  - "For effective application of deconvolution tools like PARFAC2 and MCR-ALS a minimum acquisition rate of 10-20 Hz is recommended" doi: 10.1016/j.trac.2025.118286
  - There are multiple 'rotational ambiguities' that exist with MCR-ALS even after constraints such as non-negativity. "The idea of ambiguity states that there is not a unique solution and the original data set may be reproduced with the same fit quality using various combinations of concentraiton profile and spectrum sets" doi: 10.1016/j.trac.2025.118286 doi: 10.1016/B978-044452701-1.00051-X. 
    - These can be resolved by use of a algorithm called MCR-BANDS. doi: 10.1016/j.chemolab.2010.05.020
    - Some MSD spectral pretreatments may help doi:10.1007/s12161-014-9815-9
  - look at use of RMet which surrounds ALS package. doi:10.1016/j.chemolab.2019.103866, reference there for classification and identification
  - also look at (MatLab) autoGCMSDataAnal: software.tobaccodb.org/software/autogcmsdataanal and doi: 10.1016/j.chroma.2019.460787
  - Harynuk uses SVD for a ROI discovery doi: 10.1016/j.chroma.2022.463499
  - Synovec has a method called mzCompare which interfaces with MCR-ALS for improved deconvolution. They reconstruct a chromatogram for MCR-ALS which uses narrower peaks (more likely to be monolithic). This boosts the confiednce of library search signficantly. They validated their work too with synthetic data for sensitivity analysis. doi: 10.1016/j.talanta.2024.126453
    - use a constraint to assist MCR-ALS adjusted by doi: 10.1021/ac034301d

Ongoing work in moosaic might be able to include these as next-step and bolt-on capabilities. 