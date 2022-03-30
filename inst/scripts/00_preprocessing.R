library(sf)
library(terra)
library(exactextractr)
library(dplyr)
library(tidyr)
library(purrr)

# Read-in NCC project mgmt. plan boundaries ------------------------------------

PMP <- read_sf(file.path("data", "01_raw", "NCC", "Parcels_20210531_Achievements_prjEA_RRupdate.shp")) %>%
  filter(!is.na(NAME)) %>%
  # Set to rater projection (not sure about this coordinate system...)
  st_transform(crs = st_crs("+proj=aea +lat_0=40 +lon_0=-96 +lat_1=50 +lat_2=70 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs "))

# Read-in feature themes: ------------------------------------------------------

# Forest
frst <- rast(file.path(
  "data", "02_intermediate", "HABITAT","CA_forest_VLCE_2015_forest_only_ha_proj_scale.tif"))

# Grassland
gras <- rast(file.path(
  "data", "02_intermediate", "HABITAT","AAFC_LU2015_comb_masked_by_Prairie_grassland_comb.tif"))

# Wetlands
wetl <- rast(file.path(
  "data", "02_intermediate", "HABITAT","Wetland_comb_proj_diss_90m_Arc.tif"))

# Rivers
rivr <- rast(file.path(
  "data", "02_intermediate", "HABITAT","grid_1km_water_linear_flow_length_1km.tif"))

# Lakes
laks <- rast(file.path(
  "data", "02_intermediate", "HABITAT","Lakes_CanVec_50k_ha.tif"))

# Shoreline
shrl <- rast(file.path(
  "data", "02_intermediate", "HABITAT","Shoreline.tif"))

# Climate
cfor <- rast(file.path(
  "data", "02_intermediate", "CLIMATE","fwdshortestpath.tif"))

cref <- rast(file.path(
  "data", "02_intermediate", "CLIMATE", "NA_combo_refugia_sum45.tif"))

# Carbon
csta <- rast(file.path(
  "data", "02_intermediate", "CARBON","Carbon_Mitchell_2021_t.tif")) %>% 
  terra::crop(cfor)

cseq <- rast(file.path(
  "data", "02_intermediate", "CARBON", "Carbon_Potential_NFI_2011_CO2e_t_year.tif")) %>% 
  terra::crop(cfor)

# Freshwater
fwat <- rast(file.path("data", "02_intermediate", "ES","water_provision_2a_norm.tif"))

# Recreation
recr <- rast(file.path("data", "02_intermediate", "ES", "rec_pro_1a_norm.tif"))

# Stack feature rasters --------------------------------------------------------

feat_stack <- c(frst, gras, wetl, rivr, laks, shrl, cfor, cref, csta, cseq, fwat, recr)
feat_stack <- terra::setMinMax(feat_stack)

names(feat_stack) <- c(
  "Forest", "Grassland", "Wetland", "River", "Lakes", "Shoreline",
  "Climate_velocity", "Climate_refugia", "Carbon_current", "Carbon_potential",
  "Freshwater", "Recreation"
)

# Read-in species themes: ------------------------------------------------------

# Species at risk - ECCC
SAR <- rast(file.path("data", "02_intermediate", "SAR_sum.tif"))

# Amphibian - IUCN
amph <- rast(file.path("data", "02_intermediate", "amph_sum.tif"))

# Bird - IUCN
bird <- rast(file.path("data", "02_intermediate", "bird_sum.tif"))

# Mammal - IUCN
mamm <- rast(file.path("data", "02_intermediate", "bird_sum.tif"))

# Reptile - ICUN
rept <- rast(file.path("data", "02_intermediate", "rept_sum.tif"))

# Species at risk - NatureServe Canada
SAR_NSC <- rast(file.path("data", "02_intermediate", "NSC_SARsum.tif"))

# Endemic species - NatureServe Canada
END_NSC <- rast(file.path("data", "02_intermediate", "NSC_ENDsum.tif"))

# Several species - NatureServe Canada
SPP_NSC <- rast(file.path("data", "02_intermediate", "NSC_SPPsum.tif"))

# Stack species rasters --------------------------------------------------------

spp_stack <- c(SAR, amph, bird, mamm, rept, SAR_NSC, END_NSC, SPP_NSC)
spp_stack <- terra::setMinMax(spp_stack)
names(spp_stack) <- c(
  "Species_at_Risk_ECCC", "Amphibians_IUCN", "Birds_IUCN", "Mammals_IUCN",
  "Reptiles_IUCN", "Species_at_Risk_NSC", "Endemics_NSC", "Biodiversity_NSC"
)

# Extract raster variables to PMP ----------------------------------------------

# Environmental variables
PMP_feat_stack_mean <- exact_extract(feat_stack, PMP, fun = "sum", force_df = TRUE) %>%
  round(1)
names(PMP_feat_stack_mean) <- gsub("sum.", "", names(PMP_feat_stack_mean))
PMP_feat_stack_mean <- PMP_feat_stack_mean %>%
  mutate(
    across(everything(), ~ replace_na(.x, 0))
  )

# Species variables
PMP_spp_stack_mean <- exact_extract(spp_stack, PMP, fun = "max", force_df = TRUE) %>%
  round(1)
names(PMP_spp_stack_mean) <- gsub("max.", "", names(PMP_spp_stack_mean))
PMP_spp_stack_mean <- PMP_spp_stack_mean %>%
  mutate(
    across(everything(), ~ replace_na(.x, 0))
  )

# Combine all extractions into one sf object -----------------------------------
PMP_tmp <- cbind(PMP, PMP_feat_stack_mean, PMP_spp_stack_mean) %>%
  st_transform(crs = st_crs(4326)) %>% # WGS 84
  st_make_valid()

# Assign unique-ID
PMP_tmp$id <- 1:nrow(PMP_tmp)

# Project PMP to WGS 84
PMP <- PMP %>% st_transform(crs = st_crs(4326))

# # Save clean data --------------------------------------------------------------

# Subset PMP for dev purposes
PMP_sub <- PMP_tmp %>% filter(REGION == "Alberta Region")

# Save data for shiny app
save(PMP, PMP_tmp, PMP_sub, PMP_feat_stack_mean, PMP_spp_stack_mean,
     file = file.path("data", "03_clean", "basedata.RData"))
