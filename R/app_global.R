app_global <- quote({

  # Get system environmental variables ----
  env_data <- Sys.getenv("DATA_DIRECTORY")
  env_tiles <- Sys.getenv("TILE_DIRECTORY")

  ## Assign data directory: basedata ----
  if (nchar(env_data) > 0) {
    data_path <- "/appdata"
  } else {
    data_path <- normalizePath(file.path("..", "impactextractions", "appdata"))
  }

  ## Assign data directory: tiles ----
  if (nchar(env_tiles) > 0) {
    tile_path <- "/appdata/tiles"
  } else {
    tile_path <- normalizePath(file.path("..", "impactextractions", "appdata", "tiles"))
  }

  ## Check paths
  assertthat::assert_that(file.exists(data_path), msg = paste0("Can't find basedata.R in: ", data_path))
  assertthat::assert_that(file.exists(tile_path), msg = paste0("Can't find tiles in: ", tile_path))

  # Read-in basedata -----------------------------------------------------------
  load(file.path(data_path, "basedata.RData"))

  # Read-in regional goals -------------------------------------------------------
  goals_csv <- readr::read_csv(file.path(data_path, "goals.csv"))

  # Species table inputs ---------------------------------------------------------
  pmp_attributes <- c("Property", "Name", "Region", "Area (ha)", "Species at Risk (ECCC)",
                      "Amphibians (IUCN)", "Birds (IUCN)", "Mammals (IUCN)",
                      "Reptiles (IUCN)","Species at Risk (NSC)", "Endemics (NSC)",
                      "Biodiversity (NSC)", "Forest (ha)", "Grassland (ha)", "Wetland (ha)",
                      "River (km)", "Lakes (ha)", "Shoreline (km)", "Climate Velocity", "Climate Refugia",
                      "Carbon Current", "Carbon Potential", "Freshwater (ha)", "Recreation (ha)")

  pmp_values <- c("PROPERTY_N", "NAME", "REGION","Area_ha","Species_at_Risk_ECCC",
                  "Amphibians_IUCN","Birds_IUCN","Mammals_IUCN",
                  "Reptiles_IUCN","Species_at_Risk_NSC",
                  "Endemics_NSC", "Biodiversity_NSC", "Forest", "Grassland",
                  "Wetland", "River", "Lakes", "Shoreline", "Climate_velocity",
                  "Climate_refugia", "Carbon_current", "Carbon_potential", "Freshwater",
                  "Recreation")

})
