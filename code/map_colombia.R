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

setwd("C:/Users/ccard/Downloads")

FACU<-data.table(read_dta(file="facultades.dta"))

setwd("C:/Users/ccard/Dropbox/AidColombia")

COL <- st_read("C:/Users/ccard/Dropbox/AidColombia/GADM/gadm36_COL_1.shp")
NAMES<-data.table(read_dta(file="C:/Users/ccard/Dropbox/AidColombia/gadm_with_muncodes.dta"))

NAMES<-unique(NAMES[,c(1,4)])
FACU<-left_join(FACU,NAMES)


COL<-left_join(COL,FACU)

world <- ne_countries(scale = "medium", returnclass = "sf")

ggplot(data = world) + geom_sf() + geom_sf(data = COL, aes(fill=Perc)) + 
  coord_sf(xlim = c(-80, -66.5), ylim = c(-5, 13), expand = FALSE) + 
  theme(panel.grid.major = element_blank(),axis.title.y=element_blank(), axis.ticks.y = element_blank(),axis.text.y = element_blank(), axis.title.x=element_blank(), axis.ticks.x = element_blank(),axis.text.x = element_blank(),legend.title=element_blank(), legend.position = c(0.10, 0.90), legend.background = element_rect(fill = "gray92"),legend.key = element_rect( fill = "gray92"),legend.key.size = unit(0.5, "cm")) +scale_fill_continuous(low="thistle2", high="darkred", 
                                                                                                                                                                                                                                                                                                                                                                                                                                                          guide="colorbar",na.value="white",
                                                                                                                                                                                                                                                                                                                                                                                                                                                          name="",breaks=c(0,0.1,0.2,0.3,0.4)) 


ggsave("percentage.png", width = 6, height = 8, dpi = 700)

COL$facultades[is.na(COL$facultades)]<-15


cols <- c("1" = "darkslategray1", "4"="deepskyblue2", "14" = "blue2", "15" ="white")
COL$facultades=as.factor(COL$facultades)

p<-ggplot(data = world) + geom_sf() + geom_sf(data = COL, aes(fill=facultades)) + 
  coord_sf(xlim = c(-80, -66.5), ylim = c(-5, 13), expand = FALSE) + 
  theme(panel.grid.major = element_blank(),axis.title.y=element_blank(), axis.ticks.y = element_blank(),axis.text.y = element_blank(), axis.title.x=element_blank(), axis.ticks.x = element_blank(),axis.text.x = element_blank(),legend.title=element_blank(), legend.position = c(0.125, 0.90), legend.background = element_rect(fill = "gray92"),legend.key = element_rect( fill = "gray92"),legend.key.size = unit(0.5, "cm")) 
p+scale_fill_manual(values = cols,  labels = c("1", "4", "14", "No Info")) 
ggsave("facultades.png", width = 6, height = 8, dpi = 700)
