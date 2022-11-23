library(geojsonsf)
library(httr)
library(sf)
library(dplyr)
sf_use_s2(FALSE)

# Get extent (polygon) of NCC accomplishments
ncc_extent <- read_sf("inst/extdata/achievements/NCC_20221122.shp")  %>%
  st_transform(crs = st_crs(4326)) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  st_bbox() %>%
  st_as_sfc() %>%
  st_as_sf()

# Add an id column
ncc_extent$id=1:length(ncc_extent)

# Convert sf to geoJSON
geoJ <-  sf_geojson(ncc_extent)

# Native-Land.ca map requests
map_request <- c("territories", "languages", "treaties")
for (request in map_request) {

  print(paste0("...", request))

  # Create POST request
  url <- "https://native-land.ca/wp-json/nativeland/v1/api/index.php"
  body <- paste0('{"maps" : "', request,'", "polygon_geojson" :', geoJ, '}')
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

  # Remove USA
  if (request == "treaties") {
    remove <- c("point-elliott-treaty", "cession-642", "cession-532-2", "cession-373",
                "cession-565", "cession-654", "cession-706", "cession-357", "cession-482",
                "cession-332", "cession-205", "cession-66", "cession-53", "cession-695",
                "cession-446")

    native_lands_canada <- native_lands_canada  %>%
      filter( !(native_lands_canada$Slug %in% remove))
  }

  # Calculate area
  native_lands_canada$area <- st_area(native_lands_canada)
  native_lands_canada <- arrange(native_lands_canada, -area)

  # Write to disk
  write_sf(native_lands_canada, paste0("inst/extdata/native_lands/native_lands_", request, ".geojson"))

}
