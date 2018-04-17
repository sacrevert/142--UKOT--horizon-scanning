# 142--UKOT--horizon-scanning
Note that this is intended to be a starting point, and not a finished product. It is obviously the case that information from GBIF is not complete, and the outputs of this computational exercise are intended for scrutiny by both local and international experts.
## Caribbean
The work on producing an initial "long-list" of candidate invaders per Caribbean UKOT territory hosted here followed the following general process:
1. Retrieving and processing species data per country from GBIF.
Scripts:
2. Subsequently filtering these for known IAS or weedy species using a version of Rod Randall's Global Weeds Compendium and a vesion of the Caribbean IAS database (plant names were harmonised using the TNRS service through the R package taxize).
Scripts:
3. Using pathway information from GATS and a separate NNSS report to provide lists of 'linked' countries per UKOT.
Scripts:
4. And, finally, bringing all of this together to produce lists of IAS and weeds that have been recorded in some of the pathway countries, but not in the UKOTs. This was done across all six UKOT territories, so that species that have already been recorded in some UKOTs, but may not have been in others, are still included.
Scripts:
