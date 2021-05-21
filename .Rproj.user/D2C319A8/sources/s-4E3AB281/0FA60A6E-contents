library(marcoUtils);library(phenoutils)
library(tidyverse);library(raster)
library(sf)

# import stuff into GRASS GIS and use grid
filel<-"/mnt/data1tb/Dropbox/phenology/tmpgeotif/y2003_countfilter_delta10v1.tif"

# read in phenological data
system(command = paste0("r.in.gdal in=", intif, " out=tmp --o"))
system(command = "g.region raster=grid_5km_mask_unchanged_500m")
system(command = c("r.stats -An in=grid_5km_mask_unchanged_500m,tmp  > tmpstats"))
read_delim("tmpstats", delim = " ", col_names = FALSE) %>% 
rename(cat = X1, pheno = X2) %>% mutate(year = 2003) -> phenodat

# join total forested area with phenological data
grid5km %>%
  inner_join(read_csv("./GRASSGIS_files/forestprop1",col_names = FALSE) %>%
               rename(cat =X1 , area = X2)) %>%
  inner_join(phenodat)->phenodat1

# filter by forested area
phenodat1 %>%
  mutate(prop_forest = area/max(area)) %>%
  filter(prop_forest > 0.8) %>%
  dplyr::select(x,y,pheno) %>%
  rasterFromXYZ()->myr 
ra <- aggregate(myr, fact=10,fun = mean)
myr[myr>0]<-1 
ra1 <- aggregate(myr, fact=10,fun = sum)
ra1[ra1<10]<-NA
mask(ra,ra1)->ra2

y <- disaggregate(myr, 10, method='bilinear')

#y <- focal(myr, w=matrix(1, 5, 5), mean)

plot(myr, interpolate=TRUE)

ra2 %>%
  writeRaster(.,"/home/marco/Desktop/test3.tif")
