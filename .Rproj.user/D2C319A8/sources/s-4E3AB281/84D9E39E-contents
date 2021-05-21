#######################################################
# Data exploration and validation against other products
########################################################

# load required libraries
library(raster);library(tidyverse)
library(marcoUtils);library(vegan)
library(scales);library(RColorBrewer)
library(viridis)

# read in phenology data
read_csv("./data/phenodata.csv")->phenodat

#phenodat %>%
#  dplyr::select(x,y,y_2002) %>%
#  rasterFromXYZ() %>%
#  writeRaster("/home/marco/Desktop/test.tif",overwrite=T)

#phenodat %>%
  #dplyr::select(x,y,y_2002,y_2003,y_2004,y_2005,y_2006) %>%
  #drop_na(8:11) %>%
#  dplyr::select(x,y,y_2003) %>%
#  rasterFromXYZ() %>%
#  writeRaster(filename = "/home/marco/Desktop/Y_2003.tif")

#  rowwise() %>%
  
#  mutate(pheno_median = median(c_across(2:6))) %>%

    
#phenodat %>%
#    mutate(prop_forest = area/max(area)) %>%
#    filter(prop_forest > 0.60) %>%
#    inner_join(gedidat)->mydat
    
#read_delim("./results_tmp/gedi",delim = " ",col_names = F) %>%
#    rename(gedi = X1, cat = X2) %>%
#    filter(gedi > 0) %>%
#    group_by(cat) %>%
#    summarise(gedi = mean(gedi))->gedidat

#mydat %>%
#  mutate(gedi = log(gedi+100)) %>%
#  filter(gedi < 4.614) %>%
  #filter(prop_forest > 0.8) %>%
#  ggplot(aes(x=bio12,y=bio1,z=gedi))+
#  stat_summary_2d(fun = function(x) {if(length(x[!is.infinite(x)])>=5)(mean(x))else(NA)},bins = 35,na.rm = FALSE)+
#  theme_minimal()+scale_fill_distiller(palette = "RdYlBu",limits=c(4.605,4.614),oob=squish)+
#  xlab("Precipitation")+ylab("Temperature")+theme(axis.text=element_text(size=15),axis.title=element_text(size=20),
#                                                  plot.title=element_text(size=30,hjust=0.5))+ggtitle("Climate space-Global")


#    rasterFromXYZ() %>%
#    plot()
#    writeRaster(.,filename = "./tmp/propforest.tif")

  



# plot correlation between jetz's product and phenology one
read_delim("./results_tmp/jetzvsy2002",delim = " ",col_names = F) %>%
  rename(jetz = X1,cat = X2) %>%
  inner_join(phenodat) %>% 
  filter(y_2003 < 1250) %>% {.->>tmp}  %>%
  ggplot(aes(x=jetz,y=y_2003))+theme_minimal()+geom_bin2d(bins=60)+geom_smooth(method = "lm",color="red",size=1,
                                                                                          linetype="dashed",se=FALSE)+
  scale_fill_viridis()+xlab("Jetz - standard deviation of EVI (composite)")+ylab("Phenology dataset (Year 2003)")+
  ggtitle("Spearman rho = 0.36")+
  theme(legend.position = "none",axis.text = element_text(size=15,colour="black"),axis.title = element_text(size=20),
        plot.title = element_text(hjust = 0.5,size=20))->jetzcor

cor(tmp$jetz,tmp$y_2003,method = "spearman")

ggsave(jetzcor,filename="/mnt/data1tb/Dropbox/phenology/figures/May21/jetzcom.png",width=8,height = 8,dpi = 400)



# import land cover data and calculate simpson's index
read_delim("/media/marco/marcodata19/validationmetrics/pheno_grid_ESAvalues2002",delim = " ",col_names = F) %>%
  rename(lc=X1,cat=X2,area=X3) %>%
  mutate(lc = paste0("lc_",lc)) %>%
  pivot_wider(names_from = lc,values_from=area,values_fill=0) %>%
  mutate(S = diversity(.[2:13],index = "simpson"),H = diversity(.[2:13],index = "shannon"),invsimp = diversity(.[2:13],index = "invsimpson")) %>% {.->>lcdiv1}  %>%
  mutate(rowsum = rowSums(.[2:13])) %>%
  filter(rowsum > 0) %>%
  inner_join(phenodat %>%
                 mutate(prop_forest = area/30980073) %>%
                 filter(prop_forest > 0.8)) %>% {.->>tmp}  %>%
  ggplot(aes(x=S ,y=y_2003))+theme_minimal()+geom_bin2d(bins=30)+geom_smooth(method = "lm",color="red",size=1,
                                                                                        linetype="dashed",se=FALSE)+
  scale_fill_viridis(trans = "log")+xlab("Simpson's div. index from ESA CCI")+ylab("Phenology dataset (Year 2002)")+
  ggtitle("Spearman rho = 0.46")+
  theme(legend.position = "none",axis.text = element_text(size=15,colour="black"),axis.title = element_text(size=20),
        plot.title = element_text(hjust = 0.5,size=20))->esacci

cor(tmp$H,tmp$y_2003,method = "spearman")
cor(log(tmp$S),log(tmp$y_2003),method = "spearman")
cor(tmp$invsimp,tmp$y_2003,method = "spearman")

ggsave(esacci,filename="/mnt/data1tb/Dropbox/phenology/figures/May21/esacci.png",width=8,height = 8,dpi = 400)



#--------------------- Map production 



# Pheno Diversity map --------------------------------------------------------------------
#pheno_2002 %>%



grid5km %>%
  inner_join(phenodata) %>%
  dplyr::select(x,y,y_2003) %>%
  rasterFromXYZ(crs=latlon) %>%
  projectRaster(.,crs=CRS("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")) %>%
  rastertodf(.) %>%
  mutate(value1=cut(value,breaks=round(unique(quantile(value,probs = seq(0, 1, length.out = 7 + 1))),digits = 2))) %>%
  mutate(title = "Phenological Diversity 2003")->tmpdf

# create labels
str_replace(unique(tmpdf$value1),"]","") %>%
  str_replace("\\(","") %>%
  str_split_fixed(",",n=2) %>%
  as.data.frame() %>%
  as_tibble() %>%
  filter(V1!="") %>%
  mutate(V1=as.numeric(as.character(V1)),V2=as.numeric(as.character(V2))) %>%
  arrange(V1)->tmplabs

mylabs<-c(tmplabs[2:7,]$V1,paste0(">", tmplabs[1:6,]$V2[6]))

rev(brewer.pal(7,"Spectral"))->mypal

# smallest unit
tmpdf %>%
  mutate(value1=cut(value,breaks=round(unique(quantile(value,probs = seq(0, 1, length.out = 7 + 1))),digits = 2))) %>%
  #mutate(value2=as.factor(as.numeric(cut(value,breaks=breaksinfo)))) %>% 
  filter(!is.na(value1)) %>% {.->>tmp} %>%
  ggplot()+
  geom_sf(data=bbox_rb, colour='black',fill='black')+theme_classic()+
  geom_sf(data=wmap_rb, fill='grey70',size=0)+
  geom_sf(data=ocean_rb,fill='grey20',size=0)+
  geom_sf(data=wmap_rb, linetype="dotted", color="grey70",size=0.2)+
  geom_tile(data=,aes(x=x,y=y,fill=value1))+
  theme(legend.position="bottom",legend.title = element_blank(),
        legend.justification=c(0.5),legend.key.width=unit(2, "mm"),
        legend.text = element_text(size = rel(1)),
        strip.background = element_rect(colour = "white", fill = "white"),
        strip.text = element_text(size = rel(2), face = "bold"))+
  scale_fill_manual(labels =mylabs,values = mypal,
                    guide = guide_legend(direction = "horizontal",
                                         keyheight = unit(3, units = "mm"),keywidth = unit(150 / length(unique(tmp$value1)), 
                                                            units = "mm"),title.position = 'top',title.hjust = 0.5,label.hjust = 1,
                                         nrow = 1,byrow = T,reverse = F,label.position = "bottom"))+xlab("")+ylab("")+facet_wrap(~title)->p

ggsave(p,filename = "./figures/May21/pheno_2003c.png",height=9,width = 12,dpi=400)
  



# Jetz map ----------------------------------------------------------------

grid5km %>%
  inner_join(read_delim("./results_tmp/jetzvsy2002",delim = " ",col_names = F) %>%
               rename(jetz = X1,cat = X2)) %>%
  
  dplyr::select(x,y,y_2003) %>%
  rasterFromXYZ(crs=latlon) %>%
  projectRaster(.,crs=CRS("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")) %>%
  rastertodf(.) %>%
  mutate(value1=cut(value,breaks=round(unique(quantile(value,probs = seq(0, 1, length.out = 7 + 1))),digits = 2))) %>%
  mutate(title = "Phenological Diversity 2003")->tmpdf


# create labels
str_replace(unique(tmpdf$value1),"]","") %>%
  str_replace("\\(","") %>%
  str_split_fixed(",",n=2) %>%
  as.data.frame() %>%
  as_tibble() %>%
  filter(V1!="") %>%
  mutate(V1=as.numeric(as.character(V1)),V2=as.numeric(as.character(V2))) %>%
  arrange(V1)->tmplabs

mylabs<-c(tmplabs[2:7,]$V1,paste0(">", tmplabs[1:6,]$V2[6]))

rev(brewer.pal(7,"Spectral"))->mypal

# smallest unit
tmpdf %>%
  mutate(value1=cut(value,breaks=round(unique(quantile(value,probs = seq(0, 1, length.out = 7 + 1))),digits = 2))) %>%
  #mutate(value2=as.factor(as.numeric(cut(value,breaks=breaksinfo)))) %>% 
  filter(!is.na(value1)) %>% {.->>tmp} %>%
  ggplot()+
  geom_sf(data=bbox_rb, colour='black',fill='black')+theme_classic()+
  geom_sf(data=wmap_rb, fill='grey70',size=0)+
  geom_sf(data=ocean_rb,fill='grey20',size=0)+
  geom_sf(data=wmap_rb, linetype="dotted", color="grey70",size=0.2)+
  geom_tile(data=,aes(x=x,y=y,fill=value1))+
  theme(legend.position="bottom",legend.title = element_blank(),
        legend.justification=c(0.5),legend.key.width=unit(2, "mm"),
        legend.text = element_text(size = rel(1)),
        strip.background = element_rect(colour = "white", fill = "white"),
        strip.text = element_text(size = rel(2), face = "bold"))+
  scale_fill_manual(labels =mylabs,values = mypal,
                    guide = guide_legend(direction = "horizontal",
                                         keyheight = unit(3, units = "mm"),keywidth = unit(150 / length(unique(tmp$value1)), 
                                                                                           units = "mm"),title.position = 'top',title.hjust = 0.5,label.hjust = 1,
                                         nrow = 1,byrow = T,reverse = F,label.position = "bottom"))+xlab("")+ylab("")+facet_wrap(~title)->p1

ggsave(p1,filename = "./figures/May21/jetz_sd.png",height=9,width = 12,dpi=400)

# ESA CCI map -------------------------------------------------------------
grid5km %>%
  inner_join(lcdiv1 %>%
               dplyr::select(S,cat)) %>%
  #left_join(lcdiv1 %>%
               #dplyr::select(S,cat)) %>%
  #mutate(S = ifelse(is.na(S),0,S)) %>%
  dplyr::select(-c(cat)) %>%
  rasterFromXYZ(crs = latlon) %>%
  projectRaster(.,crs=CRS("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")) %>%
  rastertodf(.) %>%
  as_tibble() %>%
  #mutate(value1=cut(value,breaks=round(unique(quantile(value,probs = seq(0, 1, length.out = 7 + 1))),digits = 2),include.lowest=T)) %>%
  mutate(value1 = cut(value,breaks=c(0.00,0.01,0.11,0.26,0.35,0.41,0.52,0.82),include.lowest = T)) %>%
  mutate(title = "ESA CCI forest classes")->tmpdf

tmpdf %>% pull(value)->value
round(unique(quantile(value,probs = seq(0, 1, length.out = 7 + 1))),digits = 2)
cut(value,breaks=round(unique(quantile(value,probs = seq(0, 1, length.out = 7 + 1))),digits = 2),include.lowest=T) %>%
  summary()

cut(value,breaks=c(0.00,0.01,0.11,0.26,0.35,0.41,0.52,0.82),include.lowest = T) %>%
  summary()

round(unique(quantile(value,probs = seq(0, 1, length.out = 7 + 1))),digits = 2)


# create labels
str_replace(unique(tmpdf$value1),"]","") %>%
  str_replace("\\(","") %>%
  str_split_fixed(",",n=2) %>%
  as.data.frame() %>%
  as_tibble() %>%
  mutate(V1=str_replace(V1,"\\[|\\]","")) %>%
  filter(V1!="") %>%
  mutate(V1=as.numeric(as.character(V1)),V2=as.numeric(as.character(V2))) %>%
  arrange(V1)->tmplabs

mylabs<-c(tmplabs[2:7,]$V1,paste0(">", tmplabs[1:7,]$V2[6]))

rev(brewer.pal(7,"Spectral"))->mypal

# smallest unit
tmpdf %>%
  #mutate(value1=cut(value,breaks=round(unique(quantile(value,probs = seq(0, 1, length.out = 6 + 1))),digits = 2),include.lowest=T)) %>%
  #mutate(value2=as.factor(as.numeric(cut(value,breaks=breaksinfo)))) %>% 
  filter(!is.na(value1)) %>% {.->>tmp} %>%
  ggplot()+
  geom_sf(data=bbox_rb, colour='black',fill='black')+theme_classic()+
  geom_sf(data=wmap_rb, fill='grey70',size=0)+
  geom_sf(data=ocean_rb,fill='grey20',size=0)+
  geom_sf(data=wmap_rb, linetype="dotted", color="grey70",size=0.2)+
  geom_tile(data=,aes(x=x,y=y,fill=value1))+
  theme(legend.position="bottom",legend.title = element_blank(),
        legend.justification=c(0.5),legend.key.width=unit(2, "mm"),
        legend.text = element_text(size = rel(1)),
        strip.background = element_rect(colour = "white", fill = "white"),
        strip.text = element_text(size = rel(2), face = "bold"))+
  scale_fill_manual(labels =mylabs,values = mypal,
                    guide = guide_legend(direction = "horizontal",
                                         keyheight = unit(3, units = "mm"),keywidth = unit(150 / length(unique(tmp$value1)), 
                                                                                           units = "mm"),title.position = 'top',title.hjust = 0.5,label.hjust = 1,
                                         nrow = 1,byrow = T,reverse = F,label.position = "bottom"))+xlab("")+ylab("")+facet_wrap(~title)->p2

ggsave(p2,filename = "./figures/May21/ESACCI_diversity.png",height=9,width = 12,dpi=400)




phenodat %>%
  filter(bio12 < 4500) %>%
  #dplyr::select(x,y,bio12) %>%
  #rasterFromXYZ() %>%
  #writeRaster(.,"/home/marco/Desktop/prec.tif")
  mutate(prop_forest = area/max(area)) %>%
  filter(prop_forest > 0.5) %>%
  ggplot(aes(x=bio1,y=bio12,z=y_2003))+
  stat_summary_2d(fun = function(x) {if(length(x[!is.infinite(x)])>=9)(mean(x))else(NA)},bins = 35,na.rm = FALSE)+
  theme_minimal()+
  scale_fill_distiller(palette = "RdYlBu",limits=c(3,150),oob=squish)+
  #scale_fill_distiller(palette = "RdYlBu",trans = "log",limits=c(3,800))+
  xlab("Temperature")+ylab("Precipitation")+theme(axis.text=element_text(size=15),axis.title=element_text(size=20),
                                                  plot.title=element_text(size=30,hjust=0.5))+ggtitle("Climate space-Global")->climspacep


ggsave(climspacep,filename = "./figures/May21/y_2003.png",width = 8,height = 8,dpi = 400)

phenodat %>%
  dplyr::select(x,y,y_2002) %>%
  rasterFromXYZ() %>%
  writeRaster(.,"/home/marco/Desktop/test.tif",overwrite=TRUE)

