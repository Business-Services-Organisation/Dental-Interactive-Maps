
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


library(leaflet)
library(lubridate)
library(htmlwidgets)
library(sp)
library(geojsonio)
library(rmapshaper)
library(RODBC)
library(proj4)

###Removes all objects from the current workspace (R memory). May prompt R to return memory to the operating system.
rm(list = ls())
gc()

### getwd in r - current working directory
file = getwd()

###read in geajson files created with using 'Shapefile to Geojson creation.R'
SOA_poly <- geojsonio::geojson_read(paste0(file,"/GeoJsons/SOA.geojson"), what = "sp")
lgd <- geojsonio::geojson_read(paste0(file,"/GeoJsons/LGD.geojson"), what = "sp")
lcg <- geojsonio::geojson_read(paste0(file,"/GeoJsons/LCG.geojson"), what = "sp")


###Read data from SQL which indicates dental registration rates for children and adults by Super Output Area.
dbconnection  <- odbcDriverConnect(c("Driver=SQL Server;Server=server_name; Database=database_name;Uid=" , Sys.getenv("USERNAME") , "; trusted_connection=yes"))
Dental_reg <-  sqlQuery(dbconnection,paste("SELECT * FROM Publication.DentalRegRateSOA
                                           where date = 202203;"))

###Set max reg rate to 1
Dental_reg$U18_RegRate = ifelse(Dental_reg$U18_RegRate>1,1,Dental_reg$U18_RegRate)
Dental_reg$O18_RegRate = ifelse(Dental_reg$O18_RegRate>1,1,Dental_reg$O18_RegRate)
Dental_reg$RegRate = ifelse(Dental_reg$RegRate>1,1,Dental_reg$RegRate)

###Merge Super Output Areas geojson and Dental Reg Rate data together 
soa_poly_dental <- merge(SOA_poly,Dental_reg[Dental_reg$date==202203,], by.x="SOA_CODE", by.y="SOA2001")

###create labels and colour formatting for leaflet map
labels <- sprintf(
  "
  <font face =arial size =3>SOA Code: </font> <font face =arial size =3 color =#E13737>%s</font> <br/>
  <font face =arial size =3>SOA Name: </font> <font face =arial size =3 color =#E13737>%s</font> <br/>
  <font face =arial size =3>Dental Registration Rate: </font> <br/>
  <font face =arial size =3> &emsp;     All Ages: &nbsp; </font>                  
  <font face =arial size =3 color =#E13737>%.0f%% </font> <br/>
  <font face =arial size =3> &emsp;    Children: &nbsp;     </font>               
  <font face =arial size =3 color =#E13737>%.0f%%  </font> <br/>
  <font face =arial size =3> &emsp;    Adults: &thinsp;&thinsp;&thinsp; &nbsp;    </font>
  <font face =arial size =3 color =#E13737>%.0f%% </font>",
  soa_poly_dental$SOA_CODE, soa_poly_dental$SOA_LABEL, soa_poly_dental$RegRate*100,soa_poly_dental$U18_RegRate*100,soa_poly_dental$O18_RegRate*100
) %>% lapply(htmltools::HTML)


# create pallette for thematic map
pal_dur <- colorNumeric(palette = "YlOrRd", domain = c(20,100), reverse = TRUE)


##Create interative map
m <- leaflet() %>%
  
  addTiles(group = "Open Street Map") %>%
  
  addPolygons(data = soa_poly_dental,
              color = "white",
              weight = 0.5,
              smoothFactor = 0.5,
              opacity = 0.3,
              fillOpacity = 0.7,
              fillColor = ~pal_dur(RegRate*100),
              highlightOptions = highlightOptions(
                color = "#666",
                weight = 5),
              label = labels,
              labelOptions = labelOptions(
                opacity = 0.7,
                direction = "left",
                offset = c(-15, 0)),
              group = "All Ages") %>%
  
  
  addPolygons(data = soa_poly_dental,
              color = "white",
              weight = 0.5,
              smoothFactor = 0.5,
              opacity = 0.3,
              fillOpacity = 0.7,
              fillColor = ~pal_dur(U18_RegRate*100),
              highlightOptions = highlightOptions(
                color = "#666",
                weight = 5),
              label = labels,
              labelOptions = labelOptions(
                opacity = 0.7,
                direction = "left",
                offset = c(-15, 0)),
              group = "Children") %>%
  
  
  addPolygons(data = soa_poly_dental,
              color = "white",
              weight = 0.5,
              smoothFactor = 0.5,
              opacity = 0.3,
              fillOpacity = 0.7,
              fillColor = ~pal_dur(O18_RegRate*100),
              highlightOptions = highlightOptions(
                color = "#666",
                weight = 5),
              label = labels,
              labelOptions = labelOptions(
                opacity = 0.7,
                direction = "left",
                offset = c(-15, 0)),
              group = "Adults") %>%
  
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
  
  addLayersControl(baseGroups = c("All Ages", "Children", "Adults"),
                   overlayGroups =c("Trust Boundaries","LGD Boundaries" ) ,
                   options = layersControlOptions(collapsed = FALSE, autoZIndex = TRUE))   %>%
  hideGroup("Trust Boundaries") %>% hideGroup("LGD Boundaries")%>%
  
  addLegend(pal = pal_dur, values = c(20,100), opacity = 1, title = "Registration %") 


#save map as widget
saveWidget(m, file="DentalRegSOAMar22.html",title = "Dental Registration Rate by SOA March 2022",
           selfcontained = TRUE)
