### We have  lists from Danielle and previous work (GBIF, Caribbean database)
### and list from B.N. Manco (TCI, 12.05.2018), combine those here and condense so one row for species
# 14.05.2018, O.L. Pescott
#rm(list=ls())

dat1 <- read.csv(file = "outputs/comparisonCombined_v1.1.csv", header = T, stringsAsFactors = F)
datBNM <- read.csv(file = "outputs/comparisonCombined_v1.0_Manco_TC.csv", header = T, stringsAsFactors = F)
head(datBNM)
# drop columns to avoid duplication
datBNM <- datBNM[,c(1,8)]
# merge
dat2 <- merge(dat1, datBNM, by.x = "species", by.y = "species", all = T)
head(dat2); tail(dat2)
dat2 <- dat2[,c(1:7,9,8)] # rearrange

# remove duplicated rows first
dat3 <- aggregate(cbind(AI, BM, KY, MS, TC, VG, bnm_TC) ~ species, data = dat2, FUN = sum)
head(dat3)
dat3[,c(2:8)] <- ifelse(dat3[,c(2:8)]>0, 1, 0)

# keep note of discrepancies for TCI for later
dat3$TC_discrep <- dat3$TC - dat3$bnm_TC
dat3$TC <- NULL
names(dat3)[7] <- "TC" # promote assessment from BN Manco, TCI
head(dat3)
dat3 <- dat3[order(dat3$species),]

# there are still some synonymy issues (e.g. Panicum maximum is Urochlola maxima), sort these too
dat3names <- taxize::tnrs(query = dat3$species, source = "iPlant_TNRS", splitby = 100, sleep = 5, code = "ICBN")
# note that some names have no match...! 
dat4 <- merge(dat3, dat3names, by.x = "species", by.y = "submittedname", all.x = T, all.y = F)
## sort mismatches manually in v2.1
# write out
write.csv(dat4, file = "outputs/comparisonCombined_v2.0.csv", row.names = F)

## END