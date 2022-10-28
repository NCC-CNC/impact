server_data_structure <- quote ({

  # Data structure for NCC accomplishments with extracted national metrics
  ncc_parcels <- list(
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

  # Data structure fore First Nation reserves
  reserve_groups <- list(
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
                "path" = file.path(data_path, "native_lands", "reserves_yk.shp"),
                "sf" = NULL),
    "NWT" = list("group" = "NWT Reserves",
                 "path" = file.path(data_path, "native_lands", "reserves_nwt.shp"),
                 "sf" = NULL),
    "NU" = list("group" = "NU Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_nu.shp"),
                "sf" = NULL))

  reserve_names <- unname(unlist(purrr::map_depth(reserve_groups, 1, "group")))

  # Data structure fore Native-Land.ca
  native_land_groups <- list(
    "Territories" = list("group" = "Territories",
                "path" = file.path(data_path, "native_lands", "native_lands_territories.geojson"),
                "sf" = NULL),
    "Languages" = list("group" = "Languages",
                "path" = file.path(data_path, "native_lands", "native_lands_languages.geojson"),
                "sf" = NULL),
    "Treaties" = list("group" = "Treaties",
                "path" = file.path(data_path, "native_lands", "native_lands_treaties.geojson"),
                "sf" = NULL))

  native_land_names <- unname(unlist(purrr::map_depth(native_land_groups, 1, "group")))
})
