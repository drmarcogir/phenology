library(raster);library(tidyverse)
library(marcoUtils);library(sf)

raster("./tmpgeotif/final_5km.tif")->f5km

rasterToPolygons(f5km) %>% st_as_sf() %>% 
  mutate(polyID = 1:length(final_5km)) %>%
  st_write("./gridGEE/small5km.shp",delete_layer =TRUE)

system("gsutil cp /mnt/data1tb/Dropbox/phenology/gridGEE/small5km.shp gs://marco_g_assets/")
system("gsutil cp /mnt/data1tb/Dropbox/phenology/gridGEE/small5km.dbf gs://marco_g_assets/")
system("gsutil cp /mnt/data1tb/Dropbox/phenology/gridGEE/small5km.prj gs://marco_g_assets/")
system("gsutil cp /mnt/data1tb/Dropbox/phenology/gridGEE/small5km.shx gs://marco_g_assets/")

system("earthengine upload table --asset_id=users/marcogirardello/phenoutils/small5km gs://marco_g_assets/small5km.shp")

as.data.frame(f5km,xy = T,na.rm=FALSE) %>%
  mutate(id = 1:length(final_5km)) %>%
  rasterFromXYZ(crs = latlon) %>%
  writeRaster(.,filename = "./tmpgeotif/gridfinal1.tif")


as.data.frame(f5km,xy = T,na.rm=FALSE) %>%
  mutate(id = 1:length(final_5km)) %>%
  dplyr::select(x,y,id) %>%
  rasterFromXYZ(crs = latlon) %>%
  writeRaster(.,filename = "./tmpgeotif/gridfinal.tif")

system("r.in.gdal in=/mnt/data1tb/Dropbox/phenology/tmpgeotif/gridfinal.tif out=gridfinal --o ")
system("g.region raster=gridfinal res=0.05 -pga")
system("r.mapcalc 'gridfinal1 = int(gridfinal)'")


system("r.in.gdal in=/mnt/data1tb/Dropbox/phenology/tmpgeotif/ndvi_500m.tif out=ndvi500m --o ")

system("g.region res=0.00416200894444445 -pag")


res<-NULL

for (i in 30:30){
  print(i)
  system(command = paste0('r.mask raster=gridfinal1 maskcats=',i,' --quiet'))
  for (y in 1:46){
    timeslice = y
    system(command = paste0("r.out.gdal in=ndvi500m.",y," out=tmp.tif --o --quiet"))
    rastertodf(raster("tmp.tif")) %>%
      mutate(time = timeslice,tile5km = i)->dat
    bind_rows(dat,res)->res
  }
  system("r.mask -r --quiet")
}


res %>%
  group_by(tile5km,time) %>%
  summarise(count = n()) %>%
  print(n =200)


res %>%
  #filter(tile5km==2) %>%
  #filter(time > 11) %>%
  arrange(x,y,time) %>%
  group_by(x,y,time) %>%
  summarise(valuecum = cumsum(value)) %>%
  mutate(valuecum = (valuecum/max(valuecum))*mean(valuecum)) %>%
  summarise(sd = sd(valuecum)) %>%
  pull(sd) %>%
  mean()*10000


res %>%
  filter(tile5km==2) %>%
  arrange(x,y,time) %>%
  group_by(x,y,time) %>%
  summarise(valuecum = cumsum(value))->tmp

tmp %>% 
  ungroup() %>%
  dplyr::select(x,y) %>%
  unique() %>%
  mutate(pixelid = 1:length(x)) %>%
  inner_join(tmp) %>%
  group_by(pixelid) %>%
  summarise(min = min(time)) %>%
  
  

  group_by(x,y) %>%
  mutate(id = )
  
  mutate(valuecum = (valuecum/max(valuecum))*mean(valuecum)) %>%
  summarise(sd = sd(valuecum)) %>%
  pull(sd) %>%
  mean()*10000


tmp %>%
  


stack("/mnt/data1tb/alessandro_metric/tempfilt/img_31_5km.tif")->cum500m
as.data.frame(cum500m) %>%
  pivot_longer(1:47)->dat

dat %>%
  mutate(name = str_remove_all(name,"X|_NDVI")) %>%
  mutate(time = as.numeric(name))->dat1

dat1 %>%
  group_by(time) %>%
  mutate(pixelid = 1:length(time)) %>%
  dplyr::select(-c(name))->dd

dd %>%
  filter(!is.na(value)) %>%
  group_by(pixelid) %>%
  summarise(time = min(time)) %>%
  filter(time == 1) %>%
  dplyr::select(pixelid) %>%
  inner_join(dd)->dd1
  
dd1 %>%
  group_by(time) %>%
  mutate(sd = sd(value,na.rm = FALSE)) %>%
  pull(sd) %>%
  mean(na.rm = TRUE)*10000

dd1 %>%
  #filter(value < 0.1) %>%
  ggplot()+aes(x=time,y=value,group=pixelid)+geom_line()
