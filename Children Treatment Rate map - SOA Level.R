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



##Removes all objects from the current workspace (R memory). May prompt R to return memory to the operating system.
rm(list = ls())
gc()

## getwd in r - current working directory
file = getwd()



###read in geajson files created with using 'Shapefile to Geojson creation.R'
SOA_poly <- geojsonio::geojson_read(paste0(file,"/GeoJsons/SOA.geojson"), what = "sp")
lgd <- geojsonio::geojson_read("GeoJsons/LGD.geojson", what = "sp")
lcg <- geojsonio::geojson_read("GeoJsons/LCG.geojson", what = "sp")


###Read data from SQL which indicates childrens dental treatment rate by Super Output Area.
dbconnection  <- odbcDriverConnect(c("Driver=SQL Server;Server=server_name; Database=database_name;Uid=" , Sys.getenv("USERNAME") , "; trusted_connection=yes"))
Dental_work <-  sqlQuery(dbconnection,paste("SELECT * FROM Publication.Dental_TreatmentRate_SOA
                                            where FinancialYear = '2021-22';"))


###Merge Super Output Areas geojson and Dental Treatment Rates for children data together 
soa_poly_dental <- merge(SOA_poly,Dental_work, by.x="SOA_CODE", by.y="SOA2001")


###create labels and colour formatting for leaflet map
labels <- sprintf(
  "<font face =arial size =3>SOA Code: </font><font face =arial size =3 color =#E13737>%s</font> <br/>
  <font face =arial size =3>SOA Name: </font><font face =arial size =3 color =#E13737>%s</font> <br/>
  <font face =arial size =3>Patients recieved a Filling/Extraction/Crown <br/>  in Financial Year per 1000 Registered: </font> <br/>
  <font face =arial size =3> &emsp;     All Ages: &nbsp; </font><font face =arial size =3 color =#E13737>%.0f </font> <br/>
  <font face =arial size =3> &emsp;    Children: &nbsp;    </font><font face =arial size =3 color =#E13737>%.0f  </font> <br/>
  <font face =arial size =3> &emsp;    Adults: &thinsp;&thinsp;&thinsp; &nbsp;    </font><font face =arial size =3 color =#E13737>%.0f </font>",
  soa_poly_dental$SOA_CODE, soa_poly_dental$SOA_LABEL, soa_poly_dental$Rate_perReg*1000,soa_poly_dental$U18_Rate_perReg*1000,soa_poly_dental$O18_Rate_perReg*1000
) %>% lapply(htmltools::HTML)


# create pallette for thematic
range <- c(50,300)
pal_dur <- colorNumeric(palette = "YlOrRd", domain = range)


##Create interative map
m <- leaflet() %>%
  
  addTiles(group = "Open Street Map") %>%
  
  # addPolygons(data = soa_poly_dental,
  #            color = "white",
  #           weight = 0.5,
  #          smoothFactor = 0.5,
  #         opacity = 0.3,
  #        fillOpacity = 0.7,
  #       fillColor = ~pal_dur(Rate_perReg*1000),
  #      highlightOptions = highlightOptions(
  #       color = "#666",
  ##      weight = 5),
#  label = labels,
# labelOptions = labelOptions(
#  opacity = 0.7,
# direction = "left",
#  offset = c(-15, 0)),
#      group = "All Ages") %>%


    addPolygons(data = soa_poly_dental,
             color = "white",
            weight = 0.5,
           smoothFactor = 0.5,
          opacity = 0.3,
       fillOpacity = 0.7,
        fillColor = ~pal_dur(U18_Rate_perReg*1000),
       highlightOptions = highlightOptions(
       color = "#666",
        weight = 5),
    label = labels,
  labelOptions = labelOptions(
    opacity = 0.7,
   direction = "left",
  offset = c(-15, 0)),
 group = "Children") %>%


#addPolygons(data = soa_poly_dental,
 #           color = "white",
  #          weight = 0.5,
   #         smoothFactor = 0.5,
    #        opacity = 0.3,
     #       fillOpacity = 0.7,
      #      fillColor = ~pal_dur(O18_Rate_perReg*1000),
       #     highlightOptions = highlightOptions(
        #      color = "#666",
         #     weight = 5),
          #  label = labels,
           # labelOptions = labelOptions(
            #  opacity = 0.7,
             # direction = "left",
              #offset = c(-15, 0)),
            #group = "Adults") %>%
  
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
  
  
  addLayersControl(  #baseGroups = c("Children"),
    overlayGroups =c("Trust Boundaries","LGD Boundaries" ) ,
    options = layersControlOptions(collapsed = FALSE, autoZIndex = TRUE))   %>%
  hideGroup("Trust Boundaries") %>% hideGroup("LGD Boundaries")%>%
  addLegend(pal = pal_dur, values = range, opacity = 1, title = "Children who received <br> Filling/Extraction/Crown <br> in 2021/22 per 1000 Registered", position="topright") 


#save map as widget
saveWidget(m, file="DentalworkSOA2022Child.html",title = "Dental Filling/Extraction/Crown Rate on Children by SOA 2021/22",   selfcontained = TRUE)


