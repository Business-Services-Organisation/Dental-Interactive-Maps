
########################
### Uncomment and install libraries below required for the map the first time you run it.


# install.packages("leaflet")
# install.packages("lubridate")
# install.packages("htmlwidgets")
# install.packages("sp")
# install.packages("geojsonio")
# install.packages("rmapshaper")
# install.packages("RODBC")
# install.packages("proj4")
# install.packages("rgdal")


library(leaflet)
library(lubridate)
library(htmlwidgets)
library(sp)
library(geojsonio)
library(rmapshaper)
library(RODBC)
library(proj4)
library(rgdal)



##Removes all objects from the current workspace (R memory). May prompt R to return memory to the operating system.
rm(list = ls())
gc()

## getwd in r - current working directory
file = getwd()


###read in geajson files created with using 'Shapefile to Geojson creation.R'
SOA_poly <- geojsonio::geojson_read(paste0(file,"/GeoJsons/SOA.geojson"), what = "sp")
lgd <- geojsonio::geojson_read("GeoJsons/LGD.geojson", what = "sp")
lcg <- geojsonio::geojson_read("GeoJsons/LCG.geojson", what = "sp")


###Read data from SQL which indicates average distance to nearest dental practice by Small Areas.
dbconnection  <- odbcDriverConnect(c("Driver=SQL Server;Server=server_name; Database=database_name;Uid=" , Sys.getenv("USERNAME") , "; trusted_connection=yes"))
Dental_dist <-  sqlQuery(dbconnection,paste("SELECT * FROM Publication.Dental_Distance_to_Nearest_dentist_SA;"))

Dentist_location <-  sqlQuery(dbconnection,paste("SELECT s.*, p.lat,p.long  FROM [Publication].[dental_surgeries] s
                                                 left join [Publication].[Practices_locations] p on s.[cipher] = p.[Prem_ID]
                                                 where p.type = 'Dental' ;"))
Dentist_location<-Dentist_location[Dentist_location$Date  =='2022-03-31',]


coordinates(Dentist_location) <- cbind(Dentist_location$long , Dentist_location$lat)
#proj4string(Dentist_location) = CRS("+init=epsg:29902")
#proj4string(oph_location) = CRS("+init=epsg:29902")
#proj4string(oph_location) = CRS("+init=epsg:4326")
proj4string(Dentist_location) = CRS("+proj=longlat +datum=WGS84")
Dentist_location <- spTransform(Dentist_location,  CRS("+proj=longlat +datum=WGS84"))


###Merge Small Areas geojson and Average distances data together 
sa_poly_dental <- merge(SA_poly,Dental_dist[Dental_dist$Date==202203,], by="SA2011")


###create labels and colour formatting for leaflet map
labels <- sprintf(
  "<font face =arial size =3>SA Name: </font><font face =arial size =3 color =#E13737>%s</font> <br/>
  <font face =arial size =3>Average Distance (Miles): &nbsp; </font><font face =arial size =3 color =#E13737>%.1f </font>",
  sa_poly_dental$sa2011Name, sa_poly_dental$av_dist_miles) %>% lapply(htmltools::HTML)

Dentistlabels <- sprintf(
  "<font face =arial size =3>Address: </font><font face =arial size =3 color =#E13737>%s</font>   <br/>
  <font face =arial size =3>Postcode: </font><font face =arial size =3 color =#E13737>%s</font>",
  Dentist_location$AddressLine11, Dentist_location$Postcode1) %>% lapply(htmltools::HTML)

Dental_dist$distance_band <- factor(Dental_dist$distance_band, levels= c('0-1', '1-2', '2-3', '3-4', '4-5', '5+'))

# create pallette
pal <- c("#eff9fa", "#c2e8ed", "#95d7e0", "#5db3be", "#488b94", "#34636a")

factpal <- colorFactor(palette = c("#eff9fa", "#c2e8ed", "#95d7e0", "#5db3be", "#488b94", "#34636a"), domain = c('0-1', '1-2', '2-3', '3-4', '4-5', '5+'), reverse = FALSE)


##Create interative map

m <- leaflet() %>%
  
  addTiles(group = "Open Street Map") %>%
  
  addPolygons(data = sa_poly_dental,
              color = "white",
              weight = 0.5,
              smoothFactor = 0.5,
              opacity = 0.3,
              fillOpacity = 0.7,
              fillColor = ~factpal(distance_band),
              highlightOptions = highlightOptions(
                color = "#666",
                weight = 5),
              label = labels,
              labelOptions = labelOptions(
                opacity = 0.7,
                direction = "left",
                offset = c(-15, 0))) %>%
  
  addMarkers(data = Dentist_location , group = 'Dental Surgery Locations',
             labelOptions = labelOptions(
               opacity = 0.7,
               direction = "left",
               offset = c(-15, 0)))  %>%
  
  addPolylines(data = lcg,
               color = "black",
               weight = .8,
               #fillOpacity = 0,
               group = "Trust Boundaries") %>%
  
  
  addPolylines(data = lgd,
               color = "black",
               weight = .8,
               fillOpacity = 0,
               group = "LGD Boundaries") %>%
  
  addLayersControl( overlayGroups =c("Trust Boundaries","LGD Boundaries", "Dental Surgery Locations" ) ,
                    options = layersControlOptions(collapsed = FALSE, autoZIndex = TRUE))   %>%
  hideGroup("Trust Boundaries") %>% hideGroup("LGD Boundaries")%>% hideGroup("Dental Surgery Locations")%>%
  
  addLegend(pal = factpal, values = c('0-1', '1-2', '2-3', '3-4', '4-5', '5+'), opacity = 1, title = "Distance (Miles)") 


#save map as widget

saveWidget(m, file="Distance_to_Nearest_Dental_Practice_22.html",title = "Distance to Nearest Dental Practice 2021/2022",       selfcontained = TRUE)
