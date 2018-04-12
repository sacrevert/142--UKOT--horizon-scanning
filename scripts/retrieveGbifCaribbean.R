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