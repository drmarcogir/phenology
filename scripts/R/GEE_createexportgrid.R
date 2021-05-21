library(sf);library(marcoUtils)

# create bounding box
st_bbox(c(xmin =-178.2918491139962, xmax = 179.98940088600375, ymax =73.88593845172474, ymin = -61.42493117272831), 
        crs = st_crs(4326))->box
  
st_crop(world,box)->dat2

# create grid (this covers the entire globe)
st_make_grid(dat2, cellsize = 2.5, square = TRUE,crs=latlon,
             what = "polygons") %>%
  st_as_sf() %>%
  rename(geometry = x) %>%
  mutate(polyID = 1:length(geometry))->tmpgrid 
# filter grid only by forested areas
#  missing step needs reodoing
st_write(tmpgrid,"./gridGEE/tmpgrid.shp")



# missing tiles from basic grid!
tmpgrid %>%
  filter(polyID %in% c(3719,3575,3429,3569,3570,3714,3427,3571,3715,3859,3716,3287,2713,2714,2570,2571,2572,3160,3159,4296,4297,4298,4152,4153,3001,3002)) %>%
  mutate(polyID = 2040:(2039+26))->missing
  

# join together with old grid dataset
st_read("./gridGEE/fine_gridv1.shp") %>%
  bind_rows(missing) %>%
  st_write(.,"./gridGEE/fine_gridv2.shp",delete_layer = TRUE)

