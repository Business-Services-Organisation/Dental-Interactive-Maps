# Dental Interactive Maps

This repository includes a number of R scripts used to produce widget maps showing various aspects of Dental Services in Northern Ireland; including the locations of dental practices and the population weighted average distance to them, dental registration rates and dental treatment rates by children and adults from the BSO General Dental Services Statistics. 

Base data is read from SQL Server along with Geojson files. R scripts then uses leaflet and html widgets packages in RStudio to create the following maps. 

http://www.healthandcareni.net/maps/DentalRegSOAMar22.html \
http://www.healthandcareni.net/maps/DentalworkSOA2022Child.html \
http://www.healthandcareni.net/maps/DentalworkSOA2022Adults.html \
http://www.healthandcareni.net/maps/Distance_to_Nearest_Dental_Practice_22.html 


This is developed and maintained by Information Unit in Business Services Organisation Family Practitioner Service.

For more information on this code please contact <Info.BSO@hscni.net>



## Installation and use:


You will need to create the Geojson files in RStudio the first time you go to create the maps. The 'Shapefile to Geojson creation.R' should be run first. This only needs run the first time as it saves the geojson files in your local network directory.

Once these are created the following scripts are used to create the maps:  

* Distance to Nearest Dental Practice - SA level.R - shows the locations of dental practices and the population weighted average distance to them at Small areas level in Northern Ireland

* Registration Rates - SOA Level.R - shows the dental registration rates for children and adults in Northern Ireland at Super Output Area with Local Commissioning Group and Local Government District boundaries

* Children Treatment Rate map - SOA Level.R - shows the children dental treatment rates in Northern Ireland at Super Output Area with Local Commissioning Group and Local Government District boundaries

* Adult Treatment Rate map - SOA Level.R - shows the adult dental treatment rates in Northern Ireland at Super Output Area with Local Commissioning Group and Local Government District boundaries
