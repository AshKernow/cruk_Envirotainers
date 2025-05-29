#!/usr/bin/env Rscript
library(scuttle)
library(velociraptor)
sce1 <- mockSCE()
sce2 <- mockSCE()

spliced <- counts(sce1)
unspliced <- counts(sce2)

out <- scvelo(list(X=spliced, spliced=spliced, unspliced=unspliced))