library(raster);library(sf)
library(tidyverse)

# get two rasters
raster("./problematic_areas/Y_2003_481.tif")->lowh
raster("./problematic_areas/Y_2003_520.tif")->highh

rasterToPolygons(lowh) %>%
  st_as_sf() %>%
  mutate(polyID = 1:length(geometry)) %>%
  st_write("./problematic_areas/low_481_p.shp")

rasterToPolygons(highh) %>%
  st_as_sf() %>%
  mutate(polyID = 1:length(geometry)) %>%
  st_write("./problematic_areas/high_520_p.shp")

# delete current files from asset bucket
system('gsutil -m rm "gs://marco_g_assets/*"')

list.files("./problematic_areas") %>%
  .[!str_detect(.,".tif")]->filel

for (i in 1:length(filel)){
  # upload to google cloud
  system(command = paste0("gsutil cp /mnt/data1tb/Dropbox/phenology/problematic_areas/", filel[i], " gs://marco_g_assets/"))
}

system(command = paste0("earthengine upload table --asset_id=users/marcogirardello/problematic_areas/low_481_p gs://marco_g_assets/low_481_p.shp"))
system(command = paste0("earthengine upload table --asset_id=users/marcogirardello/problematic_areas/high_520_p gs://marco_g_assets/high_520_p.shp"))

       

paste0("earthengine upload table --asset_id=users/marcogirardello/problematic_areas/ ",filel[i]," gs://marco_g_assets/",filel[i],".shp")


# results
stack("./problematic_areas/Y_2003_2291_high_multiband.tif")  %>%
  rastertodf() %>%
  as_tibble() %>%
  mutate(pixelno = 1:length(x)) %>%
  pivot_longer(names_to = "time",values_to ="value",cols=contains("NDVI")) %>%
  mutate(time = as.numeric(str_remove_all(time,"value.X|_NDVI")))->p_548_zero_tmp 

p_548_zero_tmp  %>%
  group_by(time) %>%
  summarise(mean = mean(value),std =sd(value))->p_548_zero


stack("./problematic_areas/Y_2003_2291_high_multiband_mincriterion.tif")  %>%
  rastertodf() %>%
  as_tibble() %>%
  mutate(pixelno = 1:length(x)) %>%
  pivot_longer(names_to = "time",values_to ="value",cols=contains("NDVI")) %>%
  mutate(time = as.numeric(str_remove_all(time,"value.X|_NDVI")))->p_548_min_tmp  

p_548_min_tmp %>%
  group_by(time) %>%
  summarise(mean = mean(value),std =sd(value))->p_548_min


ggplot()+geom_line(data=p_548_zero_tmp ,aes(x=time,y=value,group=pixelno),colour="black",alpha=0.2,size=0.2)+
  geom_line(data = p_548_zero,aes(x=time,y=mean),colour="blue",size=1.5)+theme_minimal()+
  geom_errorbar(data=p_548_zero,aes(x=time,y=mean,ymin=mean-std, ymax=mean+std,colour="red"),
                width=.2,position=position_dodge(.9),colour="red",size=0.9,linetype="dashed")+
  theme(axis.title = element_text(size=20),axis.text = element_text(size=17),
        plot.title = element_text(size=20,hjust = 0.5))+ylab("NDVI")+xlab("Time")+
  ggtitle(paste0("zero NDVI rule PHENODIV = ",
                 as.character(round(mean(p_548_zero$std)*10000,digits = 3))))->myp

ggsave(myp,filename = "./problematic_areas/p2291zero.png",height = 8,width = 8,dpi = 400) 



ggplot()+geom_line(data=p_548_min_tmp ,aes(x=time,y=value,group=pixelno),colour="black",alpha=0.2,size=0.2)+
  geom_line(data = p_548_min,aes(x=time,y=mean),colour="blue",size=1.5)+theme_minimal()+
  geom_errorbar(data=p_548_min,aes(x=time,y=mean,ymin=mean-std, ymax=mean+std,colour="red"),
                width=.2,position=position_dodge(.9),colour="red",size=0.9,linetype="dashed")+
  theme(axis.title = element_text(size=20),axis.text = element_text(size=17),
        plot.title = element_text(size=20,hjust = 0.5))+ylab("NDVI")+xlab("Time")+
  ggtitle(paste0("minimum NDVI rule PHENODIV = ",
                 as.character(round(mean(p_548_min$std)*10000,digits = 3))))->myp

ggsave(myp,filename = "./problematic_areas/p2291min.png",height = 8,width = 8,dpi = 400)  
  

  
  
dd %>%
    ggplot()+geom_line(aes(x=time,y=value))+theme_minimal()+facet_wrap(~pixelno)
  
dd %>%
  ggplot()+geom_boxplot(aes(x=factor(pixelno),y=time))

st_read("./problematic_areas/high_520_p.shp") %>%
  filter(polyID==548)

dd %>%
  group_by(x,y) %>%
  