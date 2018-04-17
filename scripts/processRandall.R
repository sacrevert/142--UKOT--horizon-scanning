## Script to finish processing Randall CSV and match to CoL using taxize package
# 09.04.2018, O.L. Pescott
# Weed list originally from https://www.invasivespeciesinfo.gov/resources/listsintl.shtml and processed using Notepadd++ and sed (in cygwin)
# to extract the following (see W:\PYWELL_SHARED\Pywell Projects\BRC\Oli Pescott\142 UKOT Horizon Scanning\_Methods\plant_technical_work\rProj_UKOT\data\regexp_for_Randall.txt)
rm(list=ls())
library(taxize)
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
#taxa_syns_COL <- taxize::synonyms(x = full_info$acceptedname, db = "col") # should use authority here really

# combine GBIF id with full_info
full_info$GBIF_id <- GBIF_id
full_info_UNI <- unique(full_info[,c(2:3,5:8)])
full_info_UNI <- full_info_UNI[order(full_info_UNI$acceptedname),]
row.names(full_info_UNI) <- 1:nrow(full_info_UNI)
# only keep matched names
full_info_UNI <- full_info_UNI[!is.na(full_info_UNI$GBIF_id),]
full_info_UNI <- full_info_UNI[,c(3,4,2,5:6)] # drop first column and reorder slightly

# write fully matched Randall data out
#write.csv(full_info_UNI, file = "outputs/randallCleanMatch.csv", row.names = F)

## Update in order to add the invasives from the Caribbean IAS Db to this Randall list
# 17 04 2018, OL Pescott
randallClean <- read.csv(file = "outputs/randallCleanMatch.csv", header = T, stringsAsFactors = F)
# read in Carib IAS Db info and process (as in compare_islandsCaribIASDb.R, ~L6-L9)
# previously processed IAS Db for Caribbean (see processCaribIASDb.R)
iasDbPl_ALL_Std <- read.csv(file = "outputs/IASCaribDb_Plants_longform_FINAL.csv", header = T, stringsAsFactors = F)[,c(2:7)] # avoid uncessary 1st column of row numbers
iasDbPl_ALL_Std$Species.Name <- gsub("\n", " ", x = iasDbPl_ALL_Std$Species.Name)
iasDbPl_ALL_Std$Species.Name <- gsub("[-(-^0-9)]$", "", x = iasDbPl_ALL_Std$Species.Name) # remove any non-alphabetic character from end of string
# filter to invasives
iasDbPl_ALL_invs <- iasDbPl_ALL_Std[iasDbPl_ALL_Std$status=="invasive",]
# remove genus levels
iasDbPl_ALL_invsSpp <- iasDbPl_ALL_invs[!grepl("spp", iasDbPl_ALL_invs$Species.Name),]

# Process via tnrs and get_gbif so that we have the same info as for Randall
full_infoCaribIAS <- taxize::tnrs(query = iasDbPl_ALL_invsSpp$Species.Name, source = "iPlant_TNRS", splitby = 100, sleep = 5, code = "ICBN")
# remove blanks
full_infoCaribIAS <- full_infoCaribIAS[!full_infoCaribIAS$acceptedname=="",]
# get GBIF ids for accepted names
GBIF_idCaribIAS <- taxize::get_gbifid(full_infoCaribIAS$acceptedname, rows = 1, phylum = "Tracheophyta", rank = "species")
full_infoCaribIAS$GBIF_id <- GBIF_idCaribIAS
full_infoCaribIAS_UNI <- unique(full_infoCaribIAS[,c(2:3,5:8)])
full_infoCaribIAS_UNI <- full_infoCaribIAS_UNI[order(full_infoCaribIAS_UNI$acceptedname),]
row.names(full_infoCaribIAS_UNI) <- 1:nrow(full_infoCaribIAS_UNI)
full_infoCaribIAS_UNI <- full_infoCaribIAS_UNI[,c(3,4,2,5:6)] # drop first column and reorder slightly

# Combine with previously processed Randall data
full_infov2 <- rbind(randallClean, full_infoCaribIAS_UNI)
full_infov2 <- unique(full_infov2)
#write.csv(full_infov2, file = "outputs/randallCleanMatch_incCaribDb.csv", row.names = F)

### END