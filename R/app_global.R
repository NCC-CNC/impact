app_global <- quote({


  # Read-in basedata -------------------------------------------------------------
  load(system.file("extdata", "03_clean", "basedata.RData", package = "impact"))

  # Read-in regional goals -------------------------------------------------------
  goals_csv <- read_csv(system.file("extdata", "sheets", "Regional_goals.csv", package = "impact"))


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
