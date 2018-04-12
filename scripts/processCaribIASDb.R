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
