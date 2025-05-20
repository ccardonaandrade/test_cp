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


#########################

setwd("C:/Users/ccard/Dropbox/AidColombia")

#Importing the data
NAMES<-data.table(read_dta(file="muni_codes_projects.dta"))

#Ordering by muni_code
NAMES<-NAMES[order(muni_code)]
NAMES<-NAMES[,first:=min(initial),by=muni_code]
NAMES<-NAMES[,last:=max(end),by=muni_code]
NAMES<-NAMES[,!c(2,3)]

#We need just the first year
FIRST<-unique(NAMES[,c(1,2)])
LAST<-unique(NAMES[,c(1,3)])


#Keeping the years
YEARS<- unique(LAST[,setnames(LAST,"last", "first")][,c(2)])
YEARS <-rbind(unique(FIRST[,c(2)]),YEARS)
YEARS<-YEARS[order(first)]
PANEL<-data.table(unique(NAMES[,c(1)]),YEARS)
#For crossing. This comes from tidyr
PANEL<-crossing(unique(NAMES[,c(1)]),YEARS)
setnames(PANEL,"first","year")

FIRST<-FIRST[,match1:=1]
LAST<-LAST[,match2:=1]

setnames(LAST,"first", "year")
setnames(FIRST,"first", "year")


PANEL<-left_join(PANEL,FIRST, by=c("muni_code", "year"))
PANEL$match1[is.na(PANEL$match1)]<-0  
PANEL<-left_join(PANEL,LAST, by=c("muni_code", "year"))
PANEL$match2[is.na(PANEL$match2)]<-0  

PANEL<-as.data.table(PANEL)


PANEL<-PANEL[match1==1,fyear:=year]
PANEL<-PANEL[match2==1,lyear:=year]
PANEL<-PANEL[,fyear:=min(fyear, na.rm=TRUE),by=muni_code]
PANEL<-PANEL[,lyear:=min(lyear, na.rm=TRUE),by=muni_code]
PANEL<-PANEL[match1==1,treat:=1]
PANEL<-PANEL[match2==1,treat:=1]
PANEL<-PANEL[fyear<year & year<lyear,treat:=1]
PANEL<-PANEL[is.na(treat),treat:=0]

PANEL<-PANEL[,c(1,2,7)]

GADM<-data.table(read_dta(file="gadm_with_muncodes.dta"))

MUNI<-unique(PANEL[,c(1)])            
MUNI<-MUNI[,sample:=1]            

GADM<-left_join(GADM,MUNI)
GADM<-GADM[is.na(sample), c(3)]
GADM<-crossing(GADM,YEARS)
GADM<-as.data.table(GADM)
GADM<-GADM[,treat:=0]
setnames(GADM,"first","year")
PANEL<-rbind(PANEL,GADM)
PANEL<-PANEL[order(muni_code,year)]

rm(GADM,LAST,MUNI,NAMES, FIRST)


COL <- st_read("GADM/gadm36_COL_2.shp")
NAMES<-data.table(read_dta(file="gadm_with_muncodes.dta"))
COL<-left_join(COL,NAMES)


COLOMBIA<-left_join(PANEL,COL)
cols <- c("0" = "dodgerblue2", "1" = "darkred")
COLOMBIA$treat=as.factor(COLOMBIA$treat)
world <- ne_countries(scale = "medium", returnclass = "sf")
COLOMBIA <- st_as_sf(COLOMBIA)


setwd("C:/Users/ccard/Dropbox/AidColombia/GIF")

for (i in unique(PANEL$year)) {
  p<-COLOMBIA %>%
    filter(year== i) %>% 
    #mutate(pop_cut = cut_number(pop_gpw_sum, 10)) %>% 
    ggplot(aes(fill =  treat)) + 
    geom_sf()  + theme(panel.grid.major = element_blank(),axis.title.y=element_blank(), axis.ticks.y = element_blank(),axis.text.y = element_blank(), axis.title.x=element_blank(), axis.ticks.x = element_blank(),axis.text.x = element_blank(),legend.title=element_blank(), legend.position = c(0.2, 0.2), legend.background = element_rect(fill = "gray92"),legend.key = element_rect( fill = "gray92"))  + geom_sf(data = world, fill = "transparent") + 
    coord_sf(xlim = c(-85, -67), ylim = c(-5, 15), expand = FALSE) + 
    labs( x="",y="", title = paste0("Aid ", i, sep = "")) 
  p+scale_fill_manual(values = cols,  labels = c("Without Project", "With Project"))  
  ggsave(paste0("aid", i,".png", sep = ""), width = 6, height = 8, dpi = 700)
  }

