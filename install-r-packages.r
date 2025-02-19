#!/usr/bin/env Rscript

# List of packages to ensure are installed
required_packages <- c("renv")

# Check and install required packages
new_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(new_packages) > 0) {
  install.packages(new_packages)
}

packages <- c(
  "AER@1.2-14",
  "BH@1.87.0-1",
  "BiocManager@1.30.25",
  "DBI@1.2.3",
  "FNN@1.1.3",
  "IRkernel@1.3.2",         # required for jupyter R kernel
  "Matrix@1.7-1",
  "R.methodsS3@1.8.2",
  "R.oo@1.27.0",
  "R.utils@2.12.3",
  "RCSF@1.0.2",
  "RColorBrewer@1.1-3",
  "RCurl@1.98-1.16",
  "RNetCDF@2.9-2",
  "broom@1.0.7",
  "crosstalk@1.2.1",
  "data.table@1.16.4",
  "devtools@2.4.5",
  "dichromat@2.0-0.1",
  "e1071@1.7-16",
  "forcats@1.0.0",
  "future@1.32.0",
  "geoR@1.9-4",
  "geosphere@1.5-20",
  "ggplot2@3.5.1",
  "ggthemes@5.1.0",
  "gstat@2.1-2",
  "haven@2.5.4",
  "here@1.0.1",
  "hms@1.1.3",
  "htmlwidgets@1.6.4",
  "jsonlite@1.8.9",
  "leaflet@2.2.2",
  "lfe@3.1.0",
  "lpSolve@5.6.23",
  "lubridate@1.9.4",
  "magic@1.6-1",
  "mapdata@2.3.1",
  "mapproj@1.2.11",
  "mapview@2.11.2",
  "markdown@1.13",
  "matrixStats@1.4.1",
  "ncdf4@1.23",
  "nlme@3.1-166",
  "ottr@1.5.1",
  "proj4@1.0-14",
  "proto@1.0.0",
  "rapportools@1.1",
  "raster@3.6-30",
  "rdrobust@2.2",
  "readr@2.1.5",
  "readxl@1.4.3",
  "rematch@2.0.0",
  "remotes@2.5.0",
  "repr@1.1.7",
  "reprex@2.1.1",
  "reticulate@1.40.0",
  "rlas@1.8.0",
  "rpart@4.1.23",
  "rsconnect@1.3.3",
  "satellite@1.0.5",
  "sp@2.1-4",
  "spacetime@1.3-2",
  "spatialreg@1.3-6",
  "spatstat@3.3-0",
  "spatstat.data@3.1-4",
  "spdep@1.3-8",
  "splancs@2.01-45",
  "stargazer@5.2.3",
  "summarytools@1.0.1",
  "svglite@2.1.3",
  "tidyr@1.3.1",
  "tidyverse@2.0.0",
  "tmap@3.3-4",
  "tmaptools@3.1-1",
  "utf8@1.2.4",
  "uuid@1.2-1",
  "vroom@1.6.5",
  "whoami@1.3.0",
  "withr@3.0.2"
)

renv::install(packages)

# Posit Package Manager currently has no binary BioConductor packages.
#BiocManager::install("rhdf5")
#BiocManager::install("Rhdf5lib")
