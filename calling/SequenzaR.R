#!/usr/bin/env Rscript


library(sequenza)

args = commandArgs(trailingOnly=TRUE)
workdir = args[1]
tumor = args[2]


data.file = paste0(workdir, "/" ,tumor, ".out.small.seqz.gz")

test <- sequenza.extract(data.file, verbose = FALSE, chromosome.list =   c(1:22,"X","Y"))
CP <- sequenza.fit(test)
sequenza.results(sequenza.extract = test,
    cp.table = CP, sample.id = tumor,
    out.dir=paste0(workdir, "/Sequenza/", tumor ))
 
