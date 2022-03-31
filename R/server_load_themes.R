
server_load_themes <- quote({

# Read-in themes ---------------------------------------------------------------
# Forest
frst <- rast(system.file(
  "extdata", "02_intermediate", "HABITAT",
  "CA_forest_VLCE_2015_forest_only_ha_proj_scale.tif", package = "impact"))

# Grassland
gras <- rast(system.file(
  "extdata", "02_intermediate", "HABITAT",
  "AAFC_LU2015_comb_masked_by_Prairie_grassland_comb.tif", package = "impact"))

# Wetlands
wetl <- rast(system.file(
  "extdata", "02_intermediate", "HABITAT",
  "Wetland_comb_proj_diss_90m_Arc.tif", package = "impact"))

# Rivers
rivr <- rast(system.file(
  "extdata", "02_intermediate", "HABITAT",
  "grid_1km_water_linear_flow_length_1km.tif", package = "impact"))

# Lakes
laks <- rast(system.file(
  "extdata", "02_intermediate", "HABITAT",
  "Lakes_CanVec_50k_ha.tif", package = "impact"))

# Shoreline
shrl <- rast(system.file(
  "extdata", "02_intermediate", "HABITAT",
  "Shoreline.tif", package = "impact"))

# Climate
cfor <- rast(system.file(
  "extdata", "02_intermediate", "CLIMATE",
  "fwdshortestpath.tif", package = "impact"))

cref <- rast(system.file(
  "extdata", "02_intermediate", "CLIMATE",
  "NA_combo_refugia_sum45.tif", package = "impact"))

# Carbon
csta <- rast(system.file(
  "extdata", "02_intermediate", "CARBON",
  "Carbon_Mitchell_2021_t.tif", package = "impact")) %>%
  terra::crop(cfor)

cseq <- rast(system.file(
  "extdata", "02_intermediate", "CARBON",
  "Carbon_Potential_NFI_2011_CO2e_t_year.tif", package = "impact")) %>%
  terra::crop(cfor)

# Freshwater
fwat <- rast(system.file("extdata", "02_intermediate", "ES",
  "water_provision_2a_norm.tif", package = "impact"))

# Recreation
recr <- rast(system.file("extdata", "02_intermediate", "ES",
  "rec_pro_1a_norm.tif", package = "impact"))

# Species at risk - ECCC
SAR <- rast(system.file("extdata", "02_intermediate",
  "SAR_sum.tif", package = "impact"))

# Amphibian - IUCN
amph <- rast(system.file("extdata", "02_intermediate",
  "amph_sum.tif", package = "impact"))

# Bird - IUCN
bird <- rast(system.file("extdata", "02_intermediate",
  "bird_sum.tif", package = "impact"))

# Mammal - IUCN
mamm <- rast(system.file("extdata", "02_intermediate",
  "bird_sum.tif", package = "impact"))

# Reptile - ICUN
rept <- rast(system.file("extdata", "02_intermediate",
  "rept_sum.tif", package = "impact"))

# Species at risk - NatureServe Canada
SAR_NSC <- rast(system.file("extdata", "02_intermediate",
  "NSC_SARsum.tif", package = "impact"))

# Endemic species - NatureServe Canada
END_NSC <- rast(system.file("extdata", "02_intermediate",
  "NSC_ENDsum.tif", package = "impact"))

# Several species - NatureServe Canada
SPP_NSC <- rast(system.file("extdata", "02_intermediate",
  "NSC_SPPsum.tif", package = "impact"))

# Stack feature rasters --------------------------------------------------------

feat_stack <- c(frst, gras, wetl, rivr, laks, shrl, cfor, cref, csta, cseq, fwat, recr)
feat_stack <- terra::setMinMax(feat_stack)

names(feat_stack) <- c(
  "Forest", "Grassland", "Wetland", "River", "Lakes", "Shoreline",
  "Climate_velocity", "Climate_refugia", "Carbon_current", "Carbon_potential",
  "Freshwater", "Recreation"
)


# Stack species rasters --------------------------------------------------------

spp_stack <- c(SAR, amph, bird, mamm, rept, SAR_NSC, END_NSC, SPP_NSC)
spp_stack <- terra::setMinMax(spp_stack)
names(spp_stack) <- c(
  "Species_at_Risk_ECCC", "Amphibians_IUCN", "Birds_IUCN", "Mammals_IUCN",
  "Reptiles_IUCN", "Species_at_Risk_NSC", "Endemics_NSC", "Biodiversity_NSC"
)

# Close quote
})
