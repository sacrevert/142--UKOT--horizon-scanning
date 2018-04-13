## Script for processing the country information from the Caribbean IAS database that I previously converted from a PDF using tabula (Windows version)
# 10.04.2018, O.L. Pescott
rm(list=ls())
library(reshape2)
library(tidytext)
library(magrittr)

iasDb <- read.csv(file = "data/tabula-IASCaribDbReduced_FINAL.csv", header = T, stringsAsFactors = F)
# restrict to plant rows
iasDbPl <- iasDb[grep("Plant", iasDb$Organism.Type),]
iasDbPl <- iasDbPl[,c(1:2,5:7)] # drop unnecessary columns
iasDbPl_ex <- iasDbPl[,c(1:4)] # exotic information
iasDbPl_inv <- iasDbPl[,c(1:3,5)] # invasive information
# there are a couple of comma separated rather than semi-colon separated lists: change these
iasDbPl_inv$Invasive.in <- gsub(pattern = ",", replacement = ";", x = iasDbPl_inv$Invasive.in)
iasDbPl_ex$Exotic.in <- gsub(pattern = ",", replacement = ";", x = iasDbPl_ex$Exotic.in)

# see https://stackoverflow.com/questions/19711211/melt-strsplit-or-opposite-to-aggregate/19712009?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
# pipe data frames to unnest_tokens() then send to new object
iasDbPl_exExp <- iasDbPl_ex %>% 
                    unnest_tokens(country, Exotic.in, token = "regex", pattern = ";") 
iasDbPl_invExp <- iasDbPl_inv %>% 
                    unnest_tokens(country, Invasive.in, token = "regex", pattern = ";")

# create separate status columns
iasDbPl_exExp$status <- "exotic"
iasDbPl_invExp$status <- "invasive"
iasDbPl_ALL <- rbind(iasDbPl_exExp, iasDbPl_invExp) # combine
iasDbPl_ALL <- iasDbPl_ALL[!(iasDbPl_ALL$country=="\n"),] # note that spaces are encoded by \n in the country field
iasDbPl_ALL <- iasDbPl_ALL[order(iasDbPl_ALL$Species.Name),] 
iasDbPl_ALL$country <- gsub("\n", " ", x = iasDbPl_ALL$country) # but then need to trim spaces from the fronts!
iasDbPl_ALL$country <- trimws(x = iasDbPl_ALL$country, which = 'l')
row.names(iasDbPl_ALL) <- 1:nrow(iasDbPl_ALL) # there were a couple of entrise in the country field that were comma separated...

allCountries <- data.frame(country = unique(iasDbPl_ALL$country))
allCountries$standardName_1 <- rangeBuilder::standardizeCountry(allCountries$country, fuzzyDist = 10)
write.csv(allCountries, file = "outputs/makeCountryNameLookup.csv")
allcountries_FIN <- read.csv(file = "outputs/CountryNameLookup_FINAL.csv", header = T, stringsAsFactors = F)
# join back
iasDbPl_ALL_Std <- merge(iasDbPl_ALL, allcountries_FIN[,c(2:3)], by.x = "country", by.y = "country", all.x = T, all.y = F)
# create extra rows for where standardName_1 still contains multiple countries
sortCountries <- iasDbPl_ALL_Std[grep(";", iasDbPl_ALL_Std$standardName_1),]
# delete from existing df
iasDbPl_ALL_Std <- iasDbPl_ALL_Std[!grepl(";", iasDbPl_ALL_Std$standardName_1),]
# expand rows with ; in subset
sortCountriesExp <- sortCountries %>% 
                        unnest_tokens(standardName_1, standardName_1, token = "regex", pattern = ";") # one odd result, still combinin st lucia and USVI...
names(sortCountriesExp)[6] <- "standardName_1"
# recombine
iasDbPl_ALL_Std <- rbind(iasDbPl_ALL_Std, sortCountriesExp)
iasDbPl_ALL_Std <- iasDbPl_ALL_Std[,-c(1)]
names(sortCountriesExp)[5] <- "country"

