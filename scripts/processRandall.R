## Script to finish processing Randall CSV and match to CoL using taxize package
# 09.04.2018, O.L. Pescott
# Weed list originally from https://www.invasivespeciesinfo.gov/resources/listsintl.shtml and processed using Notepadd++ and sed (in cygwin)
# to extract the following (see W:\PYWELL_SHARED\Pywell Projects\BRC\Oli Pescott\142 UKOT Horizon Scanning\_Methods\plant_technical_work\rProj_UKOT\data\regexp_for_Randall.txt)
rm(list=ls())
library(taxizedb)
library(rgbif)

randall <- read.csv(file = "data/randallCSV_postSED.csv", header = F, stringsAsFactors = F)
randall$species <- paste(randall$V1, randall$V2, sep = " ")

randall <- data.frame(name = randall[,c(3)])
randall <- unique(randall)

# TNRS stuff
# match to 'accepted names'
full_info <- taxize::tnrs(query = randall$name, source = "iPlant_TNRS", splitby = 100, sleep = 5, code = "ICBN") # uninformative errors with splitby = 30 and sleep = 1
# remove blanks
full_info <- full_info[!full_info$acceptedname=="",]
# get GBIF ids for accepted names
GBIF_id <- taxize::get_gbifid(full_info$acceptedname, rows = 1, phylum = "Tracheophyta", rank = "species")
# save workspace (10 04 2018, v0)

# explore synonymy (CoL only)
taxa_syns_COL <- taxize::synonyms(x = full_info$acceptedname, db = "col") # should use authority here really



# remplace comma with space using grep

# match to CoL

# then do work on IAS Caribbean database


