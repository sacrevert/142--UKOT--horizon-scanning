### Compare known BIOT non-natives to Caribbean list
# 24.07.2018, O.L. Pescott
#rm(list=ls())

# Data from Key (2016) -- non-natives known on BIOT
dat <- read.csv(file = "data/knownBIOTPlants.csv", header = T, stringsAsFactors = F)
# add standard name courtesy of TNRS
datStdnames <- taxize::tnrs(query = dat$Species, source = "iPlant_TNRS", splitby = 10, sleep = 1, code = "ICBN")
datStdnames$BIOT <- "Y"

# pre-workshop final Caribbean data for comparison (names previously standardised in the same way)
datCarib <- read.csv(file = "outputs/comparisonCombined_v2.2.csv", header = T, stringsAsFactors = F)
head(datCarib)
head(datStdnames)
# fix one error (should stop using tnrs! better options exist!) See work with Gabrielle
datStdnames[datStdnames$submittedname=="Alocasia macrorrhiza",]$acceptedname <- "Alocasia macrorrhizos"

# check status in Caribbean
dat2 <- merge(datStdnames, datCarib, by.x = "acceptedname", by.y = "acceptedname", all.x = T, all.y = T)

# write out comparison
write.csv(dat2, file = "outputs/BIOT_Carib_comparison_v1.0.csv", row.names = F)

## Get BIOT data from GBIF
biotGbif <- getSppLists(country = "IO")
# limit to plants
biotGbif_Plants <- biotGbif[biotGbif$phylum=="Tracheophyta" | biotGbif$phylum=="Bryophyta", ]
#save(biotGbif_Plants, file = "outputs/biotGbif_plants.Rdata")
#write.csv(biotGbif_Plants, file = "outputs/biotGbif_plants.csv", row.names = F)

## Maybe also get Maldives and Seychelles lists and screen against Carib DB and Randall again?
countries = c("SC", "MV")
otherGbif <- lapply(countries, function(x) getSppLists(country = x))
extractPlants <- function(x) { x[x$phylum=="Tracheophyta" | x$phylum=="Bryophyta", ] } # just keep vascular plants and bryophytes
otherGbif_Plants <- lapply(otherGbif, extractPlants) # apply across list
#save(otherGbif_Plants, file = "outputs/SC_MV_Gbifplants.Rdata")

# screen against list of natives/Weber/Randall/other (after parsing those lists against gbif name lookup functions)
# load in Randall data and use a similar approach to compare_islandsCaribIASDb.R to compare lists.
## Update to include names from Carib IAS Db (randallCleanMatch_incCaribDb.csv)
randallClean <- read.csv(file = "outputs/randallCleanMatch_incCaribDb.csv", header = T, stringsAsFactors = F)
randallClean$fullName <- paste(randallClean$matchedname, randallClean$authority) # create full name for matching

# label BIOT plants with weedy status
biotGbif_plantsWeeds <- merge(x = biotGbif_Plants, y = randallClean, by.x = "scientificName", by.y = "fullName", all.x = T, all.y = F) # label weedy plants by merge
#######################
biotGbif_plantsWeeds ## Plants that are already in BIOT, according to GBIF, and which are weedy 
#write.csv(biotGbif_plantsWeeds, file = "outputs/biotGbif_plantsWeeds.csv", row.names =F)
#######################


# label Seychelles and Maldivian plants with weedy status
labelRandallPlants <- function(x) { merge(x = x, y = randallClean, by.x = "scientificName", by.y = "fullName", all.x = T, all.y = F) } # label weedy plants by merge
SC_MV_PlantsRandall <- lapply(otherGbif_Plants, labelRandallPlants) # apply across lists
# drop anything that wasn't in composite weed list
filterInRandall <- function(x) { x[complete.cases(x),] }
SC_MV_PlantsRandallonly <- lapply(SC_MV_PlantsRandall, filterInRandall)
# combine to df
SC_MV_PlantsRandallonly_df <- do.call(rbind, SC_MV_PlantsRandallonly)
SC_MV_PlantsRandall_wide <- reshape2::dcast(SC_MV_PlantsRandallonly_df, matchedname ~ country, length)

# write out
########################
# weedy plants found on Maldives and on Seychelles from GBIF
########################
write.csv(SC_MV_PlantsRandall_wide, file = "outputs/SC_MV_PlantsRandall_wide.csv", row.names = F)

#######
# Check long list (compiled of Maldives and Seychelles weeds plus Caribbean high scorers) against BIOT gbif data
biotLL <- read.csv(file = "outputs/biotLongList.csv", header = T)
biotLLnames <- taxize::tnrs(query = biotLL$speciesName, source = "iPlant_TNRS", splitby = 10, sleep = 1, code = "ICBN")

# merge with BIOT gbif data
biotLLnames$fullName <- paste(biotLLnames$matchedname, biotLLnames$authority)
biotLLnames_GBIFchk <- merge(biotLLnames, biotGbif_Plants, by.x = "fullName", by.y = "scientificName", all.x = T, all.y = F)
write.csv(biotLLnames_GBIFchk, file = "outputs/biotLLnames_GBIFchk.csv", row.names = F)
