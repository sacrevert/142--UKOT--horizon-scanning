#### Use retrieve_GBIF_checklists() function to get full species lists for each country specified
#### Here, applied to mostly Caribbean territories linked to UKOTs in the area via various (mainly trading) pathways
# 12.04.18, O.L. Pescott
#rm(list=ls())
library(countrycode) # could probably have used isocodes function from rgbif

# load function
source(file = "scripts/retrieve_GBIF_checklists.R") # takes list of ISO (2 digit) codes
#

## take list of countries and download them
# read in country list for Caribbean island scan
#CNlist <- read.csv(file = "data/CaribbeanOT_links_GATS_and_PA_v0.csv", stringsAsFactors = F)
# ISO 2 letter code used by rGBIF
#CNlist$reporter2iso <- countrycode(CNlist$reporter, 'country.name', 'iso2c') # check any errors manually
#CNlist$partner2iso <- countrycode(CNlist$partner, 'country.name', 'iso2c') # check any errors manually
#write.csv(CNlist, file = "data/CaribbeanOT_links_GATS_and_PA_withISOs_v1.csv")

# reduced list in order to keep things sensible for the moment (manually edited -- I know, sorry!)
CNlist2 <- read.csv(file = "data/CaribbeanOT_links_GATS_and_PA_withISOs_v1.csv", stringsAsFactors = F)
# Watch out, NA = Namibia in country ISO codes
countries <- unique(c(CNlist2$reporter2iso, CNlist2$partner2iso))

## Take list of countries and download...
ptm <- proc.time()
allCountries <- list()
### SLOW (run overnight!) ###
allCountries <- lapply(countries, function(x) getSppLists(country = x))
names(allCountries) <- countries # all labels to list elements
save(allCountries, file = "outputs/allCountries_v4.Rdata")
time.elapsed <- ptm - proc.time()

# Rerun Columbia, as it failed when in batch
COdata <- getSppLists(country = c("CO"))
load(file = "outputs/allCountries_v4.Rdata")
allCountries$CO <- COdata # add to previously saved list
head(allCountries$CO)
# save new version
save(allCountries, file = "outputs/allCountries_v4.1.Rdata")

# ... and provide list of species present in sources but not in target.
load(file = "outputs/allCountries_v4.1.Rdata")

# screen against list of natives/Weber/Randall/other (after parsing those lists against gbif name lookup functions)
# load in Randall data and use a similar approach to compare_islandsCaribIASDb.R to compare lists.

randallClean <- read.csv(file = "outputs/randallCleanMatch.csv", header = T, stringsAsFactors = F)
randallClean$fullName <- paste(randallClean$matchedname, randallClean$authority) # create full name for matching

# filter GBIF data so that only plant stuff remains
extractPlants <- function(x) { x[x$phylum=="Tracheophyta" | x$phylum=="Bryophyta", ] } # just keep our lovely vascular plants and bryophytes
allCountries_Plants <- lapply(allCountries, extractPlants)
labelRandallPlants <- function(x) { merge(x = x, y = randallClean, by.x = "scientificName", by.y = "fullName", all.x = T, all.y = F) }
allCountries_PlantsRandall <- lapply(allCountries_Plants, labelRandallPlants)
# drop anything that wasn't in Randall
filterInRandall <- function(x) { x[complete.cases(x),] }
allCountries_PlantsRandallOnly <- lapply(allCountries_PlantsRandall, filterInRandall)

## OK, so now we have lists of GBIF-recorded plants per island, where we have only kept those that were in the 2003 version of Randall's GCW
## Now we do some processing to get to the same types of lists as we got for the IAS databases
# read in pathways connecting focal islands to other islands through trade and other pathways (simplied version)
CNlist2 <- read.csv(file = "data/CaribbeanOT_links_GATS_and_PA_withISOs_v1.csv", header = T, stringsAsFactors = F)
# fix a couple of issues with ISO codes
CNlist2[is.na(CNlist2$partner2iso),c(5,30)] # have a look at the ones that have NA, none of importance for the current task
# drop those lines
CNlist2_noNAs <- CNlist2[!is.na(CNlist2$partner2iso),]
# just extract the key info for the moment
CNlist2_noNAs <- CNlist2_noNAs[,c(3,5,28:30)] # focus, partner, source of pathway info, focal ISO, partner ISO

# based on function in compare_islandsCaribIASDb.R
getThreats2 <- function(country = country, db = db, ...){
  CNlist_tmp <- unique(CNlist2_noNAs[CNlist2_noNAs$reporter2iso==country,]$partner2iso) # get appropriate list of partner data
  # then need to compare the partner lists to the focal list -- could flatten the list, but that seems like a slow option...
  partnerSubList <- list()
  partnerSubList <- db[names(db) %in% CNlist_tmp] # just get sublists we want (taking advantage of the names we gave each list)
  focal <- db[names(db) == country] # focal country
  HS_data <- list() # empty list for receiving data
  HS_data <- lapply(partnerSubList, function(x) x[!(x$scientificName %in% focal$scientificName),]) # restrict to species not already recorded (according to GBIF) in focal country
  HS_data_df <- do.call(rbind, HS_data) # flatten
  # reduce to unique names (don't need every name replicated where it appears in multiple partner countries)
  HS_data_df <- unique(HS_data_df[,c(1,3,5:6)])
  return(HS_data_df) # return
}

# apply across countries of importance
AllHSGbifLists <- list() # create receiving list for HS threats for each focal island
AllHSGbifLists <- lapply(unique(CNlist2_noNAs$reporter2iso), function(x) getThreats2(country = x, db = allCountries_PlantsRandallOnly)) 
names(AllHSGbifLists) <- unique(CNlist2_noNAs$reporter2iso)
# flatten for writing out, but simplify rownames first so that they don't get too ugly and confusing
AllHSGbifLists <- lapply(AllHSGbifLists, function(x) { row.names(x) <- NULL; x })
AllHSGbifLists_df <- do.call(rbind, AllHSGbifLists)
head(AllHSGbifLists_df)
for (i in 1:nrow(AllHSGbifLists_df)){ # fill in new column of focal country names
        AllHSGbifLists_df$country_at_risk[i] <- substr(x = row.names(AllHSGbifLists_df)[i], start = 1, stop = 2)
        }
#write.csv(AllHSGbifLists_df, file = "outputs/HSlists_fromGbifAndRandall.csv", row.names = F)

# need to create wide form too

###
