library(marcoUtils);library(sf)
library(raster);library(fasterize)
library(tidyverse)

raster(extent(world),crs=latlon,res=0.05)->myr
fasterize(world,myr,field = "scalerank")->worldr
rastertodf(worldr) %>%
  mutate(value=y) %>%
  rasterFromXYZ(crs=latlon) %>%
  writeRaster("./gridGEE/latitudinal_mask.tif",overwrite = TRUE)
