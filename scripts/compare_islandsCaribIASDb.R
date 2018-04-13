## Script for comparing island level information with the process Caribbean IAS database
# 13/04/2018, OL Pescott
#rm(list=ls())

# previously processed IAS Db for Caribbean (see processCaribIASDb.R)
iasDbPl_ALL_Std <- read.csv(file = "outputs/IASCaribDb_Plants_longform_FINAL.csv", header = T, stringsAsFactors = F)[,c(2:7)] # avoid uncessary 1st column of row numbers

# read in pathways connecting focal islands to other islands through trade and other pathways (simplied version)
CNlist2 <- read.csv(file = "data/CaribbeanOT_links_GATS_and_PA_withISOs_v1.csv", header = T, stringsAsFactors = F)
# fix a couple of issues with ISO codes

CNlist2[is.na(CNlist2$partner2iso),c(5,30)] # have a look at the ones that have NA, none of importance for the current task
# drop those lines
CNlist2_noNAs <- CNlist2[!is.na(CNlist2$partner2iso),]

# just extract the key info for the moment
CNlist2_noNAs <- CNlist2_noNAs[,c(3,5,28:30)] # focus, partner, source of pathway info, focal ISO, partner ISO

# go through focal islands
ai <- CNlist2_noNAs[CNlist2_noNAs$reporter=="Anguilla",]
ai_UniPart <- unique(ai$partner2iso)
