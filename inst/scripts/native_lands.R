library(geojsonsf)
library(httr)
library(sf)
library(dplyr)
sf_use_s2(FALSE)

# Get extent (polygon) of NCC accomplishments
ncc_extent <- read_sf("inst/extdata/achievements/NCC_Accomplishments_April_2022.shp")  %>%
  st_transform(crs = st_crs(4326)) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  st_bbox() %>%
  st_as_sfc() %>%
  st_as_sf()

# Add an id column
ncc_extent$id=1:length(ncc_extent)

# Convert sf to geoJSON
geoJ <-  sf_geojson(ncc_extent)

# Create POST request
url <- "https://native-land.ca/wp-json/nativeland/v1/api/index.php"
body <- paste0('{"maps" : "territories", "polygon_geojson" :', geoJ, '}')
r <- POST(url, body = body)

# Request content (geoJSON polygons that intersect NCC extent)
native_lands <- content(r, "text")

# Convert to sf
native_lands_sf <- geojson_sf(native_lands) %>%
  st_zm() %>%
  st_make_valid()

# Read-in Canada shp
canada <-  read_sf("inst/extdata/native_lands/canada_wgs.shp")

# Intersect native lands with Canada
int_native_lands <-  st_intersection(native_lands_sf, canada)
# Subset native lands with intersection ID
native_lands_canada <- native_lands_sf[native_lands_sf$ID %in% int_native_lands$ID, ]

# Write to disk
write_sf(native_lands_canada, "inst/extdata/native_lands/native_lands_canada.geojson")
