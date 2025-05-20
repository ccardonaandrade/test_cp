


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

LOCATIONS<-data.table(read.csv("data/locations.csv", header = TRUE))
LOCATIONS<-unique(LOCATIONS[,c(6,7)])
LOCATIONS$lat<-LOCATIONS$latitude
LOCATIONS$lon<-LOCATIONS$longitude


LOCATIONS$lat <- as.character(LOCATIONS$lat)
LOCATIONS$lon <- as.character(LOCATIONS$lon)
LOCATIONS <- st_as_sf(LOCATIONS , coords = c("lon", "lat"))


COL <- st_read("GADM/gadm36_COL_2.shp")
NAMES<-data.table(read_dta(file="gadm_with_muncodes.dta"))
COL<-left_join(COL,NAMES)


st_crs(LOCATIONS) <- st_crs(COL)
#The option left_false is for just the matched sample
MERGE<-st_join(COL,LOCATIONS, left= FALSE)
NEEDED<-as.data.table(MERGE)
NEEDED<-NEEDED[,c(14,15,16)]
