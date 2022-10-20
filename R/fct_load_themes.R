
load_themes <- function() {

# Read-in themes ---------------------------------------------------------------
# Forest
frst <- rast(file.path(data_path, "themes", "albers",
  "CA_forest_VLCE_2015_forest_only_ha_proj_scale.tif"))

# Grassland
gras <- rast(file.path(data_path, "themes", "albers",
  "AAFC_LU2015_comb_masked_by_Prairie_grassland_comb.tif"))

# Wetlands
wetl <- rast(file.path(data_path, "themes", "albers",
  "Wetland_comb_proj_diss_90m_Arc.tif"))

# Rivers
rivr <- rast(file.path( data_path, "themes", "albers",
  "grid_1km_water_linear_flow_length_1km.tif"))

# Lakes
laks <- rast(file.path(data_path, "themes", "albers",
  "Lakes_CanVec_50k_ha.tif"))

# Shoreline
shrl <- rast(file.path(data_path, "themes", "albers",
  "Shoreline.tif"))

# Climate
cfor <- rast(file.path(data_path, "themes", "albers",
  "fwdshortestpath.tif"))

cref <- rast(file.path(data_path, "themes", "albers",
  "NA_combo_refugia_sum45.tif"))

# Carbon
csta <- rast(file.path(data_path, "themes", "albers",
  "Carbon_Mitchell_2021_t.tif")) %>% terra::crop(cfor)

cseq <- rast(file.path(data_path, "themes", "albers",
  "Carbon_Potential_NFI_2011_CO2e_t_year.tif")) %>% terra::crop(cfor)

# Freshwater
fwat <- rast(file.path(data_path, "themes", "albers",
  "water_provision_2a_norm.tif"))

# Recreation
recr <- rast(file.path(data_path, "themes", "albers",
  "rec_pro_1a_norm.tif"))

# Species at risk - ECCC
SAR <- rast(file.path(data_path, "themes", "albers",
  "SAR_sum.tif"))

# Amphibian - IUCN
amph <- rast(file.path(data_path, "themes", "albers",
  "amph_sum.tif"))

# Bird - IUCN
bird <- rast(file.path(data_path, "themes", "albers",
  "bird_sum.tif"))

# Mammal - IUCN
mamm <- rast(file.path(data_path, "themes", "albers",
  "bird_sum.tif"))

# Reptile - ICUN
rept <- rast(file.path(data_path, "themes", "albers",
  "rept_sum.tif"))

# Species at risk - NatureServe Canada
SAR_NSC <- rast(file.path(data_path, "themes", "albers",
  "NSC_SARsum.tif"))

# Endemic species - NatureServe Canada
END_NSC <- rast(file.path(data_path, "themes", "albers",
  "NSC_ENDsum.tif"))

# Several species - NatureServe Canada
SPP_NSC <- rast(file.path(data_path, "themes", "albers",
  "NSC_SPPsum.tif"))

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

return(list("features" = feat_stack, "species" = spp_stack))

# Close function
}
