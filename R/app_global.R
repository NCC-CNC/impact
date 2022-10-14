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

  # Subset achievements by region
  bc <- dplyr::filter(PMP_tmp, REGION == "British Columbia")
  ab <- dplyr::filter(PMP_tmp, REGION == "Alberta")
  sk <- dplyr::filter(PMP_tmp, REGION == "Saskatchewan")
  mb <- dplyr::filter(PMP_tmp, REGION == "Manitoba")
  on <- dplyr::filter(PMP_tmp, REGION == "Ontario")
  qc <- dplyr::filter(PMP_tmp, REGION == "Quebec")
  at <- dplyr::filter(PMP_tmp, REGION == "Atlantic")
  yk <- dplyr::filter(PMP_tmp, REGION == "Yukon")

  # create named list of achievements
  achievements <- list("British Columbia" = bc, "Alberta" = ab,
    "Saskatchewan" = sk, "Manitoba" = mb, "Ontario" = on, "Quebec" = qc,
    "Atlantic" = at, "Yukon" = yk)

  # Create a manual cache list that flags if data has been loaded
  cached <- list("British Columbia" = 0, "Alberta" = 0,
    "Saskatchewan" = 0, "Manitoba" = 0, "Ontario" = 0, "Quebec" = 0,
     "Atlantic" = 0, "Yukon" = 0)

  # Read-in regional goals -------------------------------------------------------
  goals_csv <- readr::read_csv(file.path(data_path, "goals.csv"),
    locale = readr::locale(encoding = "latin1"))

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
  nl_ncc <- geojsonsf::geojson_sf(file.path(data_path, "native_lands", "native_lands_ncc.geojson"))

  fn_points <- read_sf(file.path(data_path, "native_lands", "Premiere_Nation_First_Nation.shp")) %>%
    st_transform(crs = 4326)

  tc_points <- read_sf(file.path(data_path, "native_lands", "Conseil_Tribal_Tribal_Council.shp")) %>%
    st_transform(crs = 4326)

  ic_points <- read_sf(file.path(data_path, "native_lands", "Communaute_Inuite_Inuit_Community.shp")) %>%
    st_transform(crs = 4326)

  reserves_bc <- read_sf(file.path(data_path, "native_lands", "reserves_bc.shp"))
  reserves_ab <- read_sf(file.path(data_path, "native_lands", "reserves_ab.shp"))
  reserves_sk <- read_sf(file.path(data_path, "native_lands", "reserves_sk.shp"))
  reserves_mb <- read_sf(file.path(data_path, "native_lands", "reserves_mb.shp"))
  reserves_on <- read_sf(file.path(data_path, "native_lands", "reserves_on.shp"))
  reserves_qc <- read_sf(file.path(data_path, "native_lands", "reserves_qc.shp"))
  reserves_at <- read_sf(file.path(data_path, "native_lands", "reserves_at.shp"))
  reserves_yk <- read_sf(file.path(data_path, "native_lands", "reserves_yk.shp"))
  reserves_nwt <- read_sf(file.path(data_path, "native_lands", "reserves_nwt.shp"))
  reserves_nu <- read_sf(file.path(data_path, "native_lands", "reserves_nu.shp"))

})
