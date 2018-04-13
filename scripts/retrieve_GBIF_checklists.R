#### Function for retrieving GBIF country-based checklists based on existing records
# 01.04.2018, OL Pescott

## v0, Script for retrieving lists of taxa per country from GBIF (not as straightforward as you might think!), O.Pescott, 22.03.2018
#rm(list = ls())

# Potential improvements:
# Allow for more arguments to be fed through to rgbif functions
# Allow for user to limit query to particular taxon groups
# Overcome harcoded 99,999 hard coded facet limit from rgbif
# Sys.sleep might stop the function failing to return when processing data for large countries/with lots of info (e.g. Colombia in the current example)?

# Retrieves list for one country, but can be applied over a list of country names
getSppLists <- function (country = country, ...) {
  # Establish the minimum number of records to examine in order to capture all phyla and orders across all countries (might need to restrict this approach to the smaller countries local to a target location)
  cntFacet <- rgbif::count_facet(by='country', countries = country, removezeros = TRUE)
  # create list of all keys (and record counts) for taxa within listed countries
  # limit = 0 only refers to record downloads, not to information inspected on GBIF; facetLimit refers to the number of rows returned by 'group by' facet clause
  out1 <- tryCatch(rgbif::occ_search(country = country, # sum(cntFacet$V1) -- sum not really needed since change from running this for all countries at once, but leave in for now
                     facet=c("speciesKey"), facetMincount = sum(cntFacet$V1), limit = 0, speciesKey.facetLimit = 99999), # might not be not enough for large countries
           error = function(err) NULL) # if it fails, return NULL. Means that when applied across countries the whole process will not fail
  if (is.null(out1)) {NULL} # move on (e.g. to next country in list is being used with an apply function) if this step has failed
    else {
    # need to use speciesKey return in order to get the names and higher taxon information using rgbif::name_usage
    out2 <- as.data.frame(out1$facets$speciesKey)
    out3 <- list() # empty list for all the 
    out3 <- tryCatch(lapply(out2[,'name'], function(x) {tmp <- rgbif::name_usage(key = x, rank = c("phylum", "order"))
                                                if("order" %in% colnames(tmp$data) & "phylum" %in% colnames(tmp$data)) {tmp}
                                                else {}
                                                }), error = function(err) NULL) # get higher taxon information for later filtering
    if (is.null(out3)) {NULL} # move on (e.g. to next country in list is being used with an apply function) if this step has failed
      else { # extract and simplify structure of data returned
      out4 <- do.call(rbind, lapply(lapply(out3, '[[', 'data'), function(x) as.data.frame(x[,c('scientificName','phylum','order')]))) # works even if list out4 has NULL elements
      out4$country <- rep(attr(out1, "args")$country, nrow(out4)) # add in country information to list item
      print(paste("Retrieved and processed:", unique(out4$country))) # add country info in terms of ISO 2 code
      return(out4) # return dataframe as long as no errors are picked up from GBIF
      }
    }
} # END
