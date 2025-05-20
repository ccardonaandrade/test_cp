


install.packages("rlang")
library(haven)
library(data.table)
library(foreign)
library(countrycode)
library(plyr)
library(operators)
library(dplyr)
library(tidyverse)
library(sp) 
library(rgeos)
library(rgdal)

library("rnaturalearth")
library("rnaturalearthdata")
library(sf)
library("ggspatial")
library(spdep)
library(vroom)
library(states)
library(raster)
library(gganimate)

library(transformr)
#https://github.com/thomasp85/transformr
library(magick)


setwd("C:/Users/ccard/Dropbox/AidColombia")


COL <- st_read("GADM/gadm36_COL_2.shp")
NAMES<-data.table(read_dta(file="gadm_with_muncodes.dta"))
COL<-left_join(COL,NAMES)

PROJECTS<-data.table(read_dta(file="locations.dta"))
PROJECTS$latitude <- PROJECTS$lat
PROJECTS$longitude <- PROJECTS$lon


PROJECTS$lat <- as.character(PROJECTS$lat)
PROJECTS$lon <- as.character(PROJECTS$lon)
PROJECTS <- st_as_sf(PROJECTS , coords = c("lon", "lat"))


st_crs(PROJECTS) <- st_crs(COL)
#The option left_false is for just the matched sample
MERGE<-st_join(COL,PROJECTS, left= FALSE)
NEEDED<-as.data.table(MERGE)
NEEDED<-unique(NEEDED[,c(14,15)])

write.dta(NEEDED, "muni_codes_projects.dta")



MERGE=as.data.table(MERGE)
MERGE=MERGE[,c(1,2,3,4,5,6,7)]
MERGE=MERGE[,sample:=1]

COL<-left_join(COL,MERGE)
COL$sample[is.na(COL$sample)]<-0  


cols <- c("0" = "dodgerblue2", "1" = "darkred")
COL$sample=as.factor(COL$sample)

world <- ne_countries(scale = "medium", returnclass = "sf")
p<-ggplot(data = world) + geom_sf() + geom_sf(data = COL, aes(fill=sample)) + 
  coord_sf(xlim = c(-85, -67), ylim = c(-5, 15), expand = FALSE) + 
  theme(panel.grid.major = element_blank(),axis.title.y=element_blank(), axis.ticks.y = element_blank(),axis.text.y = element_blank(), axis.title.x=element_blank(), axis.ticks.x = element_blank(),axis.text.x = element_blank(),legend.title=element_blank(), legend.position = c(0.2, 0.2), legend.background = element_rect(fill = "gray92"),legend.key = element_rect( fill = "gray92"))
p+scale_fill_manual(values = cols,  labels = c("Out Sample", "In Sample")) 

CELL=as.data.table(PROJECTS[,c(1,4,5)])


f<-ggplot(data = world) + geom_sf() + geom_sf(data = COL, aes()) + 
  coord_sf(xlim = c(-85, -67), ylim = c(-5, 15), expand = FALSE) + 
  theme(panel.grid.major = element_blank(),axis.title.y=element_blank(), axis.ticks.y = element_blank(),axis.text.y = element_blank(), axis.title.x=element_blank(), axis.ticks.x = element_blank(),axis.text.x = element_blank(),legend.title=element_blank(), legend.position = c(0.2, 0.2), legend.background = element_rect(fill = "gray92"),legend.key = element_rect( fill = "gray92"))  + geom_point(data = CELL[cell==184], aes(x = longitude, y = latitude), size = 0.5, 
                                                                                                                                                                                                                                                                                                                                                                                                            shape = 23, fill = "darkred")
d<-ggplot(data = world) + geom_sf() + geom_sf(data = COL, aes()) + 
  coord_sf(xlim = c(-85, -67), ylim = c(-5, 15), expand = FALSE) + 
  theme(panel.grid.major = element_blank(),axis.title.y=element_blank(), axis.ticks.y = element_blank(),axis.text.y = element_blank(), axis.title.x=element_blank(), axis.ticks.x = element_blank(),axis.text.x = element_blank(),legend.title=element_blank(), legend.position = c(0.2, 0.2), legend.background = element_rect(fill = "gray92"),legend.key = element_rect( fill = "gray92"))  