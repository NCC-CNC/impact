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
                "path" = file.path(data_path, "native_lands", "reserves_YK.shp"),
                "sf" = NULL),
    "NWT" = list("group" = "NWT Reserves",
                 "path" = file.path(data_path, "native_lands", "reserves_NWT.shp"),
                 "sf" = NULL),
    "NU" = list("group" = "NU Reserves",
                "path" = file.path(data_path, "native_lands", "reserves_NU.shp"),
                "sf" = NULL))

  reserve_names <- unname(unlist(purrr::map_depth(reserve_groups, 1, "group")))

})