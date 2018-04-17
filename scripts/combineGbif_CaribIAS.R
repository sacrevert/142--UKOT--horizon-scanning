#### We have tables of IAS versus species for both the GBIF and Carib IAS datasets
#### combine to allow for comparisons and final sorting for HS spreadsheet
# 17.04.18, O.L. Pescott
#rm(list=ls())

## Gbif data
GbifDat <- read.csv(file = "outputs/HSlists_fromGbif_WIDEform.csv", header = T, stringsAsFactors = F)
## Carib IAS Db data
CaribIASDat <- read.csv(file = "outputs/HSlists_fromCaribIASDb_WIDEform.csv", header = T, stringsAsFactors = F)
head(GbifDat); head(CaribIASDat)
GbifDat$origin <- "gbif"
CaribIASDat$origin <- "caribdb"

allDat <- rbind(GbifDat, CaribIASDat)
allDat <- allDat[order(allDat$species),]
row.names(allDat) <- 1:nrow(allDat)

#write.csv(allDat, file = "outputs/comparisonCombined_v1.0.csv", row.names = F)

### END
