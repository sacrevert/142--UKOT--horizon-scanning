### WD has compared EU, Cyprus and GB long lists to Koppen-Geiger climate regions
### compare to existing list to add in additional species that are in any Koppen-Geiger 'A'-zone
# 18.05.2018, O.L. Pescott
#rm(list=ls())

# read in previous 'final' list
dat <- read.csv(file = "outputs/comparisonCombined_v2.2.csv", header = T, stringsAsFactors = F)
# read in WD list
datWd <- read.csv(file = "data/priorSpeciesAllLists_KGclimate_WD.csv", header = T, stringsAsFactors = F)
datWdAzone <- datWd[!is.na(datWd$Any_A),]
datWdAzone <- datWdAzone[,c(1,2,12)]

# add standard name
datWdnames <- taxize::tnrs(query = datWdAzone$name, source = "iPlant_TNRS", splitby = 10, sleep = 1, code = "ICBN")
# fix some omissions
datWdnames[datWdnames$submittedname=="Azolla mexicana",]$acceptedname <- "Azolla mexicana"
datWdnames[datWdnames$submittedname=="Eichornia crassipes",]$acceptedname <- "Eichornia crassipes"
datWdnames[datWdnames$submittedname=="Eleagnus x ebbingei",]$acceptedname <- "Eleagnus x submacrophylla"
datWdnames[datWdnames$submittedname=="Jasminum simplicifolium",]$acceptedname <- "Jasminum simplicifolium"
datWdnames[datWdnames$submittedname=="Opuntia maxima",]$acceptedname <- "Opuntia maxima"
datWdnames[datWdnames$submittedname=="Teline monspeliensis",]$acceptedname <- "Genista monspessulana"
datWdnames <- datWdnames[,c(1,2)]
names(datWdnames) <- c("origName", "TNRSacceptedname")
# match
datWdmatch <- merge(datWdnames, dat[,c(1:10)], by.x = "TNRSacceptedname", by.y = "acceptedname", all.x = T, all.y = F)
# names without match
datWdmatch <- datWdmatch[is.na(datWdmatch$uri),]
datWdmatch <- datWdmatch[,c(1:2)]
datWdmatch$new <- "Y"
datWdFINAL <- merge(datWd, datWdmatch, by.x = "name", by.y = "origName", all.x = T)
datWdFINAL <- datWdFINAL[order(datWdFINAL$Any_A),]

# write out list of names that we can add to the master sheet
write.csv(datWdFINAL, file = "outputs/priorSpecies_KGclimate_toAdd.csv")
