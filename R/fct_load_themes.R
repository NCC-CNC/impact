
load_themes <- function() {

# Read-in themes ---------------------------------------------------------------
# Forest
frst_lc <- rast(file.path(data_path, "themes", "albers",
  "FOREST_LC_COMPOSITE_1KM.tif"))

frst_lu <- rast(file.path(data_path, "themes", "albers",
  "FOREST_LU_COMPOSITE_1KM.tif"))

# Grassland
gras <- rast(file.path(data_path, "themes", "albers",
  "Grassland_AAFC_LUTS_Total_Percent.tif"))

# Wetlands
wetl <- rast(file.path(data_path, "themes", "albers",
  "Wetland_comb_proj_diss_90m_Arc.tif"))

# Rivers
rivr <- rast(file.path(data_path, "themes", "albers",
  "grid_1km_water_linear_flow_length_1km.tif"))

# Lakes
laks <- rast(file.path(data_path, "themes", "albers",
  "Lakes_CanVec_50k_ha.tif"))

# Shoreline
shrl <- rast(file.path(data_path, "themes", "albers",
  "Shoreline.tif"))

# Climate Forward Velocity
cvel <- rast(file.path(data_path, "themes", "albers",
  "Climate_FwdShortestPath_2080_RCP85.tif"))

# Climate Refugia
cref <- rast(file.path(data_path, "themes", "albers",
  "Climate_Refugia_2080_RCP85.tif"))

## Climate Extremes
cext <- rast(file.path(data_path, "themes", "albers",
  "Climate_LaSorte_ExtremeHeatEvents.tif"))

# Carbon Current
csta <- rast(file.path(data_path, "themes", "albers",
  "Carbon_Mitchell_2021_t.tif")) %>% terra::crop(cvel)

# Carbon Potential
cseq <- rast(file.path(data_path, "themes", "albers",
  "Carbon_Potential_NFI_2011_CO2e_t_year.tif")) %>% terra::crop(cvel)

# Freshwater
fwat <- rast(file.path(data_path, "themes", "albers",
  "water_provision_2a_norm.tif"))

# Human Footprint Index
hfi <- rast(file.path(data_path, "themes", "albers",
  "CDN_HF_cum_threat_20221031_NoData.tif"))

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
  "mamm_sum.tif"))

# Reptile - ICUN
rept <- rast(file.path(data_path, "themes", "albers",
  "rept_sum.tif"))

# Species at risk - NatureServe Canada
SAR_NSC <- rast(file.path(data_path, "themes", "albers",
  "NSC_SARsum.tif"))

# Endemic species - NatureServe Canada
END_NSC <- rast(file.path(data_path, "themes", "albers",
  "NSC_ENDsum.tif"))

# Common species - NatureServe Canada
SPP_NSC <- rast(file.path(data_path, "themes", "albers",
  "NSC_SPPsum.tif"))

# Stack feature rasters --------------------------------------------------------

feat_stack <- c(frst_lc, frst_lu, gras,
                wetl, rivr, laks, shrl,
                cvel, cref, cext,
                csta, cseq,
                fwat, hfi, recr)

feat_stack <- terra::setMinMax(feat_stack)

names(feat_stack) <- c("Forest_LC", "Forest_LU", "Grassland",
                       "Wetland", "River", "Lakes","Shore",
                       "Climate_V", "Climate_R", "Climate_E",
                       "Carbon_C", "Carbon_P",
                       "Freshwater", "HF_IDX", "Rec")

# Stack species rasters --------------------------------------------------------

spp_stack <- c(SAR, amph, bird, mamm, rept, SAR_NSC, END_NSC, SPP_NSC)
spp_stack <- terra::setMinMax(spp_stack)
names(spp_stack) <- c("ECCC_SAR", "IUCN_AMPH", "IUCN_BIRD",
                      "IUCN_MAMM","IUCN_REPT", "NSC_SAR",
                      "NSC_END", "NSC_SPP")

return(list("features" = feat_stack, "species" = spp_stack))

# Close function
}
