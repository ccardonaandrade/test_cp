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

setwd("C:/Users/ccard/Dropbox/AidColombia")

#PROJECTS START AND END DATES
PROJ<-data.table(read.csv("data/projects.csv", header = TRUE))
PROJ<-PROJ[,c(1,15,16)]


LOCATIONS<-data.table(read.csv("data/locations.csv", header = TRUE))
LOCATIONS<-LOCATIONS[,c(1,6,7)]
LOCATIONS<-left_join(LOCATIONS,PROJ)

LOCATIONS<-LOCATIONS[, cell := .GRP, by =c("latitude","longitude")]

LOCATIONS<-LOCATIONS[,initial:=min(transactions_start_year),by=cell]

