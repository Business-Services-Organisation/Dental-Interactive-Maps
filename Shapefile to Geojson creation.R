#Code to change downloaded shapefile to geojson

############################.
### Uncomment and install libraries below required for the maps the first time you run it.

#install.packages("rgdal")
#install.packages("rgeos")
# install.packages("haven")
# install.packages("leaflet")
# install.packages("htmltools")
# install.packages("stringr")
# install.packages("lubridate")
# install.packages("htmlwidgets")
# install.packages("raster")
# install.packages("sp")
# install.packages("spdplyr")
# install.packages("geojsonio")
# install.packages("rmapshaper")
# install.packages("RODBC")
# install.packages("proj4")
# install.packages("ggplot2")


library(stringr)
library(rgdal)
library(geojsonio)
library(rmapshaper)
library(proj4)
library(rgeos)
library(raster)


###Removes all objects from the current workspace (R memory). May prompt R to return memory to the operating system.
rm(list = ls())
gc()

### getwd in r - current working directory
file = getwd()


### Using https://www.opendatani.gov.uk/dataset?q=boundary download the required shapefiles and save into a folder in the current work directory.
### The following lines only need run the first time as its creating smaller geojson files from shapefiles.

LGD_poly <- readOGR(dsn=paste0(file,"/OSNI_Open_Data_Largescale_Boundaries__Local_Government_Districts_2012"), layer="OSNI_Open_Data_Largescale_Boundaries__Local_Government_Districts_2012")
LGD_P <-spTransform(LGD_poly,CRS("+proj=longlat +datum=WGS84"))
LGD_poly_json<-geojson_json(LGD_P)
LGDpoly_simplify <-ms_simplify(LGD_poly_json)
geojson_write(LGDpoly_simplify, file = "GeoJsons/LGD.geojson")

LCG_poly <- readOGR(dsn=paste0(file,"/2017trustBoundary"), layer="dohTrustBoundary")
LCG_P <-spTransform(LCG_poly,CRS("+proj=longlat +datum=WGS84"))
LCG_poly_json<-geojson_json(LCG_P)
LCGpoly_simplify <-ms_simplify(LCG_poly_json)
geojson_write(LCGpoly_simplify, file = "GeoJsons/LCG.geojson")

NI_poly <- readOGR(dsn=paste0(file,"/OSNI_Open_Data_Largescale_Boundaries_NI_Outline"), layer="OSNI_Open_Data_-_Largescale_Boundaries_-_NI_Outline")
NI_P <-spTransform(NI_poly,CRS("+proj=longlat +datum=WGS84"))
NI_poly_json<-geojson_json(NI_P)
NIpoly_simplify <-ms_simplify(NI_poly_json)
geojson_write(NIpoly_simplify, file = "GeoJsons/NI.geojson")

rm(LGD_poly, LGD_P,LGD_poly_json,LGDpoly_simplify,LCG_poly, LCG_P,LCG_poly_json,LCGpoly_simplify)
rm(NI_poly, NI_P,NI_poly_json,NIpoly_simplify)
gc()

SA_poly <- readOGR(dsn=paste0(file,"/SA2011 shapefile"), layer="SA2011")
SA_P <- spTransform(SA_poly,CRS("+proj=longlat +datum=WGS84"))

lough_poly <- readOGR(dsn=paste0(file,"/NI Loughs"), layer="Neagh_Erne_Strangford_IslandMagee")
lough_P <- spTransform(lough_poly,CRS("+proj=longlat +datum=WGS84"))
lough_P <- lough_poly[lough_poly$Name != "Strangford",]
lough_P <- lough_poly[lough_poly$Name != "Island Magee",]

lough_poly2 <- readOGR(dsn=paste0(file,"/NI Loughs"), layer="Neagh_Erne_Strangford_IslandMagee")
lough_P2 <- spTransform(lough_poly,CRS("+proj=longlat +datum=WGS84"))
lough_P2 <- lough_poly[lough_poly$Name != "Strangford",]
lough_P2 <- lough_poly[lough_poly$Name != "Island Magee",]

SAlough_P <- SA_P - lough_P -lough_P2

SA_poly_json<-geojson_json(SAlough_P)

rm(lough_poly, lough_poly2, SA_poly, SA_P)

SApoly_simplify <-ms_simplify(SA_poly_json)
geojson_write(SApoly_simplify, file = "GeoJsons/SA.geojson")

SOA_poly <- readOGR(dsn=paste0(file,"/SOA NI version"), layer="SOA2011")
SOA_P <- spTransform(SOA_poly,CRS("+proj=longlat +datum=WGS84"))

SOAlough_P <- SOA_P - lough_P -lough_P2

SOA_poly_json<-geojson_json(SOAlough_P)

rm(SOA_poly, SOA_P)

SOApoly_simplify <-ms_simplify(SOA_poly_json)
geojson_write(SOApoly_simplify, file = "SOA.geojson")
