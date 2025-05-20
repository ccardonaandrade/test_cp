


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
PANEL<-data.table(read_dta(file="panel.dta"))

COLOMBIA=left_join(PANEL,COL)
cols <- c("0" = "dodgerblue2", "1" = "darkred")
COLOMBIA$treat=as.factor(COLOMBIA$treat)

world <- ne_countries(scale = "medium", returnclass = "sf")
COLOMBIA <- st_as_sf(COLOMBIA)


p<-ggplot(data = world) + geom_sf() + geom_sf(data = COLOMBIA[year=2006,], aes(fill=treat)) + 
  coord_sf(xlim = c(-85, -67), ylim = c(-5, 15), expand = FALSE) + 
  theme(panel.grid.major = element_blank(),axis.title.y=element_blank(), axis.ticks.y = element_blank(),axis.text.y = element_blank(), axis.title.x=element_blank(), axis.ticks.x = element_blank(),axis.text.x = element_blank(),legend.title=element_blank(), legend.position = c(0.2, 0.2), legend.background = element_rect(fill = "gray92"),legend.key = element_rect( fill = "gray92"))


p+scale_fill_manual(values = cols,  labels = c("Out Sample", "In Sample")) 


COL2006<- COLOMBIA %>%
  filter(year==2011) 

setwd("C:/Users/ccard/Dropbox/AidColombia/GIF")

p<-COLOMBIA %>%
  filter(year==2016) %>% 
  #mutate(pop_cut = cut_number(pop_gpw_sum, 10)) %>% 
  ggplot(aes(fill =  treat)) + 
  geom_sf()  + theme(panel.grid.major = element_blank(),axis.title.y=element_blank(), axis.ticks.y = element_blank(),axis.text.y = element_blank(), axis.title.x=element_blank(), axis.ticks.x = element_blank(),axis.text.x = element_blank(),legend.title=element_blank(), legend.position = c(0.2, 0.2), legend.background = element_rect(fill = "gray92"),legend.key = element_rect( fill = "gray92"))  + geom_sf(data = world, fill = "transparent") + 
  coord_sf(xlim = c(-85, -67), ylim = c(-5, 15), expand = FALSE) + 
  labs( x="",y="", title = "AID 2016") 
p+scale_fill_manual(values = cols,  labels = c("Without Project", "With Project"))  



ggsave("aid2016.png", width = 6, height = 8, dpi = 700)


p<-COLOMBIA %>% 
  #mutate(pop_cut = cut_number(pop_gpw_sum, 10)) %>% 
  ggplot(aes(fill =  treat)) + 
  geom_sf()  + theme(panel.grid.major = element_blank(),axis.title.y=element_blank(), axis.ticks.y = element_blank(),axis.text.y = element_blank(), axis.title.x=element_blank(), axis.ticks.x = element_blank(),axis.text.x = element_blank(),legend.title=element_blank(), legend.position = c(0.2, 0.2), legend.background = element_rect(fill = "gray92"),legend.key = element_rect( fill = "gray92"))  + geom_sf(data = world, fill = "transparent") + 
  coord_sf(xlim = c(-85, -67), ylim = c(-5, 15), expand = FALSE) 

m<-p+scale_fill_manual(values = cols,  labels = c("Without Project", "With Project")) 
anim <- m + 
  transition_states(COLOMBIA$year,transition_length = 1, state_length = 7, wrap = TRUE) + labs(title = "AID Status {closest_state}")


image <- animate(anim)
anim_save("ethiopia.gif")
animate(anim, nframes = 12, device = "png",
        renderer = file_renderer("/Users/ccard/Dropbox/AidColombia/GIF", prefix = "eth", overwrite = TRUE))
