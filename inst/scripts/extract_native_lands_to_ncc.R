library(sf)
library(geojsonsf)
library(dplyr)
sf_use_s2(FALSE)

# Read-in NCC achievements layer
ncc <- read_sf(file.path("inst", "extdata", "achievements", "NCC_20221122.shp"))
ncc <- st_transform(ncc, crs = 4326)
ncc <- ncc %>% mutate(OBJECTID = row_number()) # Create unique ID for each row / polygon
ncc <- ncc %>% select(OBJECTID)

# Read-in and rename native-lands.ca layers
territories <- geojson_sf(file.path("inst", "extdata", "native_lands", "native_lands_territories.geojson")) %>%
  rename(c(description_TER = description, Name_TER = Name, color_TER = color,
           ID_TER = ID, Slug_TER = Slug, area_TER = area))

languages <- geojson_sf(file.path("inst", "extdata", "native_lands", "native_lands_languages.geojson")) %>%
  rename(c(description_LAN = description, Name_LAN = Name, color_LAN = color,
           ID_LAN = ID, Slug_LAN = Slug, area_LAN = area))

treaties <- geojson_sf(file.path("inst", "extdata", "native_lands", "native_lands_treaties.geojson")) %>%
  rename(c(description_TRE = description, Name_TRE = Name, color_TRE = color,
           ID_TRE = ID, Slug_TRE = Slug, area_TRE = area))

# Merge native-land layers
native_lands <- dplyr::bind_rows(list(territories,languages, treaties))
write_sf(native_lands, file.path("inst", "extdata", "native_lands", "native_lands_all.geojson"))

# Intersect layers & drop geometry
NCC_NL <- st_intersection(native_lands, ncc) %>%
  st_drop_geometry()

# Save as .csv table
write_sf(NCC_NL, file.path("inst", "extdata", "native_lands", "native_lands_ncc.csv"), encoding = "UTF-8")
