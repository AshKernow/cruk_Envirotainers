FROM rocker/rstudio:4.4.3

RUN apt-get update && \
    apt-get install -y libxml2 libz-dev libbz2-dev libglpk-dev libcairo2-dev

# Additional libraries needed by R packages
RUN apt-get install -y libxt-dev
RUN apt-get install -y liblzma-dev 

# Install bioconductor
RUN R --slave -e 'install.packages("BiocManager", lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install(version="3.19", ask = FALSE, lib="/usr/local/lib/R/site-library")'

# Install R packages
RUN R --slave -e 'BiocManager::install("AnnotationHub", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("batchelor", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("BiocParallel", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("BiocSingular", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("bluster", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("broom", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("Cairo", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("cluster", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("clustree", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("cowplot", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("devtools", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("DropletUtils", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("DT", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("dynamicTreeCut", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("edgeR", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("ensembldb", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("ggvenn", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("glue", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("harmony", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("igraph", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("knitr", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("leiden", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("miloR", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("NbClust", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("pak", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("patchwork", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("PCAtools", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("pheatmap", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("RColorBrewer", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("remotes", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("robustbase", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("scater", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("scran", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("sctransform", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("scuttle", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("Seurat", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("slingshot", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("tidyverse", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("tradeSeq", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("TSCAN", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'BiocManager::install("velociraptor", ask = FALSE, lib="/usr/local/lib/R/site-library")'
# End R packages

# Install R packages from github

RUN apt-get install -y libgdal-dev libgeos-dev libproj-dev
#RUN R --slave -e 'BiocManager::install("terra", ask = FALSE, lib="/usr/local/lib/R/site-library")'
RUN R --slave -e 'pak::pkg_install("drieslab/Giotto")'
