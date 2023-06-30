app_global <- quote({

  # File upload limit (1GB)
  options(shiny.maxRequestSize = 1000*1024^2) # 1GB

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
  assertthat::assert_that(file.exists(data_path),
    msg = paste0("Can't find basedata.R in: ", data_path))
  assertthat::assert_that(file.exists(tile_path),
    msg = paste0("Can't find tiles in: ", tile_path))

  # Read-in basedata -----------------------------------------------------------
  load(file.path(data_path, "basedata.RData"))

  # Read-in regional goals -------------------------------------------------------
  goals_csv <- readr::read_csv(file.path(data_path, "goals.csv"),
    locale = readr::locale(encoding = "latin1"))

  # Species table inputs ---------------------------------------------------------
  pmp_attributes <- c(
    "Area (ha)",
    "Species at Risk (ECCC)", "Amphibians (IUCN)", "Birds (IUCN)",
    "Mammals (IUCN)", "Reptiles (IUCN)",
    "Species at Risk (NSC)", "Endemic Species (NSC)", "Common Species (NSC)",
    "Forest LC (ha)", "Forest LU (ha)", "Grassland (ha)", "Wetland (ha)",
    "River (km)", "Lakes (ha)", "Shoreline (km)",
    "Climate Velocity (km/year)", "Climate Refugia (index)", "Climate Extremes (index)",
    "Carbon Current (tonnes)", "Carbon Potential (tonnes per year)",
    "Freshwater (ha)", "Human Footprint (index)",  "Recreation (ha)")

  pmp_values <- c(
    "Area_ha",
    "ECCC_SAR", "IUCN_AMPH", "IUCN_BIRD",
    "IUCN_MAMM", "IUCN_REPT",
    "NSC_SAR", "NSC_END", "NSC_SPP",
    "Forest_LC", "Forest_LU", "Grassland", "Wetland",
    "River", "Lakes", "Shore",
    "Climate_V", "Climate_R", "Climate_E",
    "Carbon_C", "Carbon_P",
    "Freshwater", "HF_IDX", "Rec")

  # Read-in First Nation layers ------------------------------------------------

  nl_ncc <- data.table::fread(file.path(data_path, "native_lands", "native_lands_ncc_20221122.csv"), encoding = "UTF-8")

  fn_points <- sf::read_sf(file.path(data_path, "native_lands", "Premiere_Nation_First_Nation.shp"))

  tc_points <- sf::read_sf(file.path(data_path, "native_lands", "Conseil_Tribal_Tribal_Council.shp"))

  ic_points <- sf::read_sf(file.path(data_path, "native_lands", "Communaute_Inuite_Inuit_Community.shp"))

})
