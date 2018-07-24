# 142--UKOT--horizon-scanning
Note that this is intended to be a starting point, and not a finished product. It is obviously the case that information from GBIF is not complete, and the outputs of this computational exercise are intended for scrutiny by both local and international experts.

## Caribbean
The work on producing an initial "long-list" of candidate invaders per Caribbean UKOT territory hosted here followed the following general process:
1. Retrieving and processing species data per country from GBIF (using `rgbif`) or from Caribbean IAS database.
2. Subsequently filtering these for known IAS or weedy species using a version of Randall's Global Weeds Compendium and a version of the Caribbean IAS database (plant names were harmonised using the TNRS service through the R package `taxize`).
3. Using pathway information from GATS and a separate NNSS report to provide lists of 'linked' countries per UKOT.
4. And, finally, bringing all of this together to produce lists of IAS and weeds that have been recorded in some of the pathway countries, but not in the UKOTs. This was done across all six UKOT territories, so that species that have already been recorded in some UKOTs, but may not have been in others, are still included.

Main outputs (17/04/2018): 
`outputs\comparisonCombined_v1.0.csv # species by country (by method) checklist`

`outputs\HSlists_fromCaribIASDb.csv # for each country, a list of IAS that have been recorded in a linked pathway country but not in the country itself (according to the source -- here, the Caribbean IAS Db)`

`outputs\HSlists_fromGbifAndRandall_incCaribDb.csv # for each country, a list of IAS that have been recorded in a linked pathway country but not in the country itself (according to the source -- here, GBIF [as of April 2018])`

## BIOT
The work on producing an initial "long-list" of candidate invaders for BIOT followed the following process:
1. Retrieving and processing species data for the Seychelles and the Maldives from GBIF (using `rgbif`).
2. Subsequently filtering these for known IAS or weedy species using a version of Randall's Global Weeds Compendium and a version of the Caribbean IAS database (plant names were harmonised using the TNRS service through the R package `taxize`).
3. Deleting alien plants already known on BIOT using the lists compiled as a part of a report on UKOT pathways by Gillian Key (who drew on CABI and Whistler, 1996)
4. Adding highly scoring plants from the Caribbean HS consensus workshop
4. Manual checks against the literature and expert/ecological knowledge

Main outputs (24/07/2018): 
`outputs\biotGbif_plants.Rdata) # BIOT GBIF data`

`outputs\biotGbif_plantsWeeds.csv) # BIOT plants flagged as potentially weedy by Randall or Caribbean IAS database`

`outputs\SC_MV_PlantsRandall_wide.csv # weedy plants (Randall/Carribean IAS db) from Maldives and Seychelles according to GBIF`