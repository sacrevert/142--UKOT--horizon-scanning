## Script for processing the country information from the Caribbean IAS database that I previously converted from a PDF using tabula (Windows version)
# 10.04.2018, O.L. Pescott
rm(list=ls())

iasDb <- read.csv(file = "data/tabula-IASCaribDbReduced_FINAL.csv", header = T, stringsAsFactors = F)
