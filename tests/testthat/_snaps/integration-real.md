# real phenols-in-diesel run: process_sample() finds the target phenols

    {
      "type": "list",
      "attributes": {
        "names": {
          "type": "character",
          "attributes": {},
          "value": ["Peak No.", "Compound Name", "Retention Time"]
        },
        "row.names": {
          "type": "integer",
          "attributes": {},
          "value": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137]
        },
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["data.frame"]
        }
      },
      "value": [
        {
          "type": "integer",
          "attributes": {},
          "value": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137]
        },
        {
          "type": "character",
          "attributes": {},
          "value": ["Allene", "Hydroxyurea", "Carbon dioxide", "Propene", "Isobutane", "Isopropyl Alcohol", "Cyclohexane, ethyl-", "Cyclohexane, 1,1,3-trimethyl-", "Octane, 2-methyl-", "p-Xylene", "Octane, 3-methyl-", "cis-1-Ethyl-3-methyl-cyclohexane", "Nonane", "Octane, 2,6-dimethyl-", "Benzene, 1-ethyl-3-methyl-", "Nonane, 4-methyl-", "Nonane, 2-methyl-", "CITRONELLAL, DIHYDRO-", "Phenol", "Mesitylene", "Decane", "Benzene, 1,3-diethyl-", "Nonane, 2,6-dimethyl-", "Cyclohexane, (1-methylpropyl)-", "Phenol, 2-methyl-", "p-Cymene", "Phenol, 2-methoxy-", "Naphthalene, decahydro-2-methyl-", "Undecane", "Naphthalene, decahydro-2-methyl-", "Bicyclo[3.1.1]heptan-2-one, 3,6,6-trimethyl-", "Phenol, 2-ethyl-", "1H-Indene, 2,3-dihydro-4-methyl-", "cis-p-Mentha-2,8-dien-1-ol", "Benzeneacetaldehyde, .alpha.-ethyl-", "Tetradecane, 2,6,10-trimethyl-", "(+)-cis-Verbenol, trimethylacetate", "Benzene, 1-methyl-4-(1-methyl-2-propenyl)-", "Dodecane", "Undecane, 2,6-dimethyl-", "Cyclohexane, hexyl-", "Naphthalene, 1,2,3,4-tetrahydro-6-methyl-", "Tetradecane, 2,6,10-trimethyl-", "Naphthalene, 1,2,3,4-tetrahydro-5-methyl-", "Naphthalene, 1,2,3,4-tetrahydro-1,5-dimethyl-", "Tridecane", "3.alpha.,4.alpha.,9.beta.,11-Diepoxymuurolan-10-ol", "Naphthalene, 1,2,3,4-tetrahydro-2,6-dimethyl-", "Tricyclo[4.3.1.1<2,5", "Naphthalene, 1,2,3,4-tetrahydro-1,5-dimethyl-", "Perhydrophenalene, (3a.alpha., 6a.alpha., 9a.alpha., 9b.beta.)-", "Naphthalene, 5-ethyl-1,2,3,4-tetrahydro-", "Tridecane, 2-methyl-", "Naphthalene, 1,2,3,4-tetrahydro-1,5,7-trimethyl-", "Dodecane, 2,6,10-trimethyl-", "Naphthalene, 1,2,3,4-tetrahydro-5,7-dimethyl-", "Tetradecane", "Naphthalene, 1,2,3,4-tetrahydro-1,5,7-trimethyl-", "Tetradecane, 2,6,10-trimethyl-", "Pentadecane", "Unknown, Interpolated", "5.beta.,7.beta.H,10.alpha.-Eudesm-11-en-1.alpha.-ol", "Unknown, Interpolated", "Hexadecane", "5,6,6-Trimethyl-5-(3-oxobut-1-enyl)-1-oxaspiro[2.5]octan-4-one", "Unknown, Interpolated", "Unknown, Interpolated", "6-Isopropenyl-4,8a-dimethyl-1,2,3,5,6,7,8,8a-octahydro-naphthalen-2-ol", "Unknown, Interpolated", "Pentadecane, 2,6,10-trimethyl-", "Unknown, Interpolated", "Cyclopentane, undecyl-", "Unknown, Interpolated", "Hexadecane, 4-methyl-", "Heptadecane, 9-hexyl-", "Heptadecane", "(1aS,2R,6R,7R,7aR,7bR)-7,7a-Dimethyl-1a-prop-1-en-2-yl-2,4,5,6,7,7b-hexahydronaphtho[1,2-b]oxirene-2,6-diol, 2Ac derivative", "Octadecane", "7-Methyl-Z-tetradecen-1-ol acetate", "Nonadecane", "Eicosane", "Heneicosane", "Unknown, Interpolated", "11,14-Eicosadienoic acid, methyl ester", "Unknown, Interpolated", "Acetamide, N-[2-(3-ethyl-1-methyl-9H-carbazol-2-yl)ethyl]-N-methyl-", "Unknown, Interpolated", "Octadecane, 3-ethyl-5-(2-ethylbutyl)-", "Unknown, Interpolated", "Unknown, Interpolated", "Docosane", "1-Tricosanol", "Androstan-6-ol-17-one, 3-acetoxy-5.alpha.-chloro-", "Z-5-Methyl-6-heneicosen-11-one", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "11H-Benzo[b]fluorene", "Unknown, Interpolated", "Unknown, Interpolated", "Tricosane", "Unknown, Interpolated", "Unknown, Interpolated", "15-Isobutyl-(13.alpha.H)-isocopalane", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Tetracosane", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Pentacosane", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "2,4-Dihydroxy-3-methylbenzaldehyde, 2TMS", "Unknown, Interpolated", "4H-1-Benzopyran-4-one, 6,7-dimethoxy-3-phenyl-", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Unknown, Interpolated", "Cyclotrisiloxane, hexamethyl-", "Unknown, Extrapolated", "Unknown, Extrapolated", "Unknown, Extrapolated", "Unknown, Extrapolated", "Unknown, Extrapolated"]
        },
        {
          "type": "character",
          "attributes": {},
          "value": ["0.082", "0.087", "0.289", "1.467", "1.494", "1.673", "7.126", "7.297", "8.569", "8.726", "8.865", "9.639", "10.322", "12.021", "13.338", "13.473", "13.666", "14.003", "14.687", "15.060", "15.595", "16.458", "16.696", "17.109", "18.453", "19.465", "19.968", "20.121", "20.813", "21.236", "22.396", "22.647", "22.885", "23.047", "23.515", "23.969", "24.270", "24.872", "25.771", "26.333", "27.461", "28.545", "29.066", "29.637", "29.821", "30.433", "30.824", "31.053", "31.273", "32.046", "32.599", "32.707", "33.197", "33.449", "33.678", "34.096", "34.824", "36.330", "37.261", "38.960", "40.902", "42.048", "42.371", "42.830", "43.765", "43.913", "43.949", "43.999", "44.048", "44.345", "44.471", "44.583", "44.664", "44.857", "45.073", "45.990", "47.078", "48.624", "50.085", "50.921", "53.016", "54.953", "55.430", "55.627", "55.839", "55.938", "56.108", "56.257", "56.369", "56.571", "56.778", "57.133", "57.295", "57.412", "57.542", "57.637", "57.771", "57.812", "58.014", "58.190", "58.513", "59.084", "59.178", "59.331", "59.426", "59.552", "59.686", "59.916", "60.163", "60.244", "60.698", "60.842", "61.152", "61.759", "63.255", "72.335", "75.329", "77.464", "78.790", "80.822", "82.193", "83.272", "83.870", "84.468", "84.638", "85.398", "85.825", "86.243", "86.841", "87.515", "87.965", "88.302", "88.693", "89.659", "90.212", "90.653", "91.224"]
        }
      ]
    }

