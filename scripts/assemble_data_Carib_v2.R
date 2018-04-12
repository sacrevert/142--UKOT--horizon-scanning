## v1, investigating paging options for overcoming the speciesKey.facetLimit max value, O.Pescott, 23.03.2018
## v0, Script for retrieving lists of taxa per country from GBIF (not as straightforward as you might think!), O.Pescott, 22.03.2018

rm(list = ls())
library(rgbif)
#library(taxize)
library(countrycode)

## take list of countries and download them
# read in country list for Caribbean island scan
CNlist <- read.csv(file = "data/CaribbeanOT_links_GATS_and_PA_v0.csv", stringsAsFactors = F)
# ISO 2 letter code used by rGBIF
CNlist$reporter2iso <- countrycode(CNlist$reporter, 'country.name', 'iso2c') # check any errors manually
CNlist$partner2iso <- countrycode(CNlist$partner, 'country.name', 'iso2c') # check any errors manually
write.csv(CNlist, file = "data/CaribbeanOT_links_GATS_and_PA_withISOs_v1.csv")

# reduced list in order to keep things sensible for the moment
CNlist2 <- read.csv(file = "data/CaribbeanOT_links_GATS_and_PA_withISOs_v1.csv", stringsAsFactors = F)
# Watch out, NA = Namibia in country ISO codes
countries <- unique(c(CNlist2$reporter2iso, CNlist2$partner2iso))

# Retrieve list for one country, and then apply function over country list
getSppLists <- function (country = country, ...) { # Need to restrict to exclude large countries when retrieving facetted searches from GBIF, because there will be too much information
  # Establish the minimum number of records to examine in order to capture all phyla and orders across all countries (Probably need to restrict this approach to the smaller countries local to a target location)

  cntFacet <- rgbif::count_facet(by='country', countries = country, removezeros = TRUE)
  # create list of all keys (and record counts) for taxa within listed countries
  # limit = 0 only refers to record downloads, not to information inspected on GBIF; facetLimit refers to the number of rows returned by 'group by' facet clause
  out1 <- tryCatch(rgbif::occ_search(country = country, # sum(cntFacet$V1) -- sum not really needed since change from running this for all countries once, but leave in for now
                     facet=c("speciesKey"), facetMincount = sum(cntFacet$V1), limit = 0, speciesKey.facetLimit = 99999), # not enough for large countries
           error = function(err) NULL)
  if (is.null(out1)) {NULL}
    else {
    # need to use speciesKey return in order to get the names and higher taxon information using rgbif::name_usage
    out2 <- as.data.frame(out1$facets$speciesKey)
    out3 <- list() # empty list for all the 
    out3 <- tryCatch(lapply(out2[,'name'], function(x) {tmp <- rgbif::name_usage(key = x, rank = c("phylum", "order"))
                                                if("order" %in% colnames(tmp$data) & "phylum" %in% colnames(tmp$data)) {tmp}
                                                else {}
                                                }), error = function(err) NULL) # get higher taxon information for later filtering, but avoid errors where the record was at a higher level than order
    if (is.null(out3)) {NULL}
      else {
      out4 <- do.call(rbind, lapply(lapply(out3, '[[', 'data'), function(x) as.data.frame(x[,c('scientificName','phylum','order')]))) # works even if list out4 has NULL elements
      out4$country <- rep(attr(out1, "args")$country, nrow(out4)) # add in country information
      print(paste("Retrieved and processed:", unique(out4$country)))
      return(out4) # return dataframe as long as no errors are picked up from GBIF
      }
    }
} # should probably update to allow selection by phylum, and warnings for hitting the 99999 buffer

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

# screen against list of natives/Weber/Randall/other (after parsing those lists against gbif name lookup functions)
