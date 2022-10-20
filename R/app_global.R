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
  assertthat::assert_that(file.exists(data_path),
    msg = paste0("Can't find basedata.R in: ", data_path))
  assertthat::assert_that(file.exists(tile_path),
    msg = paste0("Can't find tiles in: ", tile_path))

  # Read-in basedata -----------------------------------------------------------
  load(file.path(data_path, "basedata.RData"))

  # Read-in regional goals -------------------------------------------------------
  goals_csv <- readr::read_csv(file.path(data_path, "goals.csv"),
    locale = readr::locale(encoding = "latin1"))

  # Data structure for NCC accomplishments with extracted national metrics
  ncc_parcels <<- list(
    "BC" = list("group" = "BC",
                "region" = "British Columbia",
                "sf" = NULL),
    "AB" = list("group" = "AB",
                "region" = "Alberta",
                "sf" = NULL),
    "SK" = list("group" = "SK",
                "region" = "Saskatchewan",
                "sf" = NULL),
    "MB" = list("group" = "MB",
                "region" = "Manitoba",
                "sf" = NULL),
    "ON" = list("group" = "ON",
                "region" = "Ontario",
                "sf" = NULL),
    "QC" = list("group" = "QC",
                "region" = "Quebec",
                "sf" = NULL),
    "AT" = list("group" = "AT",
                "region" = "Atlantic",
                "sf" = NULL),
    "YK" = list("group" = "YK",
                "region" = "Yukon",
                "sf" = NULL))

  # Species table inputs ---------------------------------------------------------
  pmp_attributes <- c("Area (ha)", "Species at Risk (ECCC)",
    "Amphibians (IUCN)", "Birds (IUCN)", "Mammals (IUCN)","Reptiles (IUCN)",
    "Species at Risk (NSC)", "Endemics (NSC)", "Biodiversity (NSC)",
    "Forest (ha)", "Grassland (ha)", "Wetland (ha)", "River (km)", "Lakes (ha)",
    "Shoreline (km)", "Climate Velocity (km/year)", "Climate Refugia (index)",
    "Carbon Current (tonnes)", "Carbon Potential (tonnes per year)",
    "Freshwater (ha)", "Recreation (ha)")

  pmp_values <- c("Area_ha","Species_at_Risk_ECCC","Amphibians_IUCN",
    "Birds_IUCN","Mammals_IUCN","Reptiles_IUCN","Species_at_Risk_NSC",
    "Endemics_NSC", "Biodiversity_NSC", "Forest", "Grassland", "Wetland",
    "River", "Lakes", "Shoreline", "Climate_velocity", "Climate_refugia",
    "Carbon_current", "Carbon_potential", "Freshwater", "Recreation")

  # Read-in First Nation layers ------------------------------------------------

  nl_ncc <- data.table::fread(file.path(data_path, "native_lands", "native_lands_ncc.csv"), encoding = "UTF-8")

  fn_points <- sf::read_sf(file.path(data_path, "native_lands", "Premiere_Nation_First_Nation.shp"))

  tc_points <- sf::read_sf(file.path(data_path, "native_lands", "Conseil_Tribal_Tribal_Council.shp"))

  ic_points <- sf::read_sf(file.path(data_path, "native_lands", "Communaute_Inuite_Inuit_Community.shp"))

  # Data structure fore First Nation reserves
  reserve_groups <<- list(
    "BC" = list("group" = "BC Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_bc.shp"),
                "sf" = NULL),
    "AB" = list("group" = "AB Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_ab.shp"),
                "sf" = NULL),
    "SK" = list("group" = "SK Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_sk.shp"),
                "sf" = NULL),
    "MB" = list("group" = "MB Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_mb.shp"),
                "sf" = NULL),
    "ON" = list("group" = "ON Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_on.shp"),
                "sf" = NULL),
    "QC" = list("group" = "QC Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_qc.shp"),
                "sf" = NULL),
    "AT" = list("group" = "AT Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_at.shp"),
                "sf" = NULL),
    "YK" = list("group" = "YK Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_YK.shp"),
                "sf" = NULL),
    "NWT" = list("group" = "NWT Reserves",
                 "path" = file.path(data_path, "native_lands", "reserves_NWT.shp"),
                 "sf" = NULL),
    "NU" = list("group" = "NU Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_NU.shp"),
                "sf" = NULL))

  reserve_names <<- unname(unlist(purrr::map_depth(reserve_groups, 1, "group")))

})
