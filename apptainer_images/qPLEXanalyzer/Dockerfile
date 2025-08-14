FROM rocker/r-base:4.5.1

RUN apt-get update && \
    apt-get install -y libxml2 libz-dev libbz2-dev libglpk-dev libcairo2-dev

# Additional libraries needed by R packages
RUN apt-get install -y libxt-dev
RUN apt-get install -y liblzma-dev 

# Install bioconductor
RUN R --slave -e 'install.packages("BiocManager", lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install(version="3.21", ask = FALSE, lib="/usr/local/lib/R/site-library")'

# Install R packages
RUN R --slave -e 'BiocManager::install("AnnotationHub", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("Cairo", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("DT", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("RColorBrewer", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("devtools", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("edgeR", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("ensembldb", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("ggvenn", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("knitr", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("patchwork", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("tidyverse", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("Biostrings", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("qPLEXanalyzer", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("readxl", ask = FALSE, lib="/usr/local/lib/R/site-library")'


# End R packages