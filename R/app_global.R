app_global <- quote({

  library(shiny)
  library(shinydashboard)
  library(leaflet)
  library(leaflet.extras)
  library(leaflet.extras2)
  library(shinyWidgets)
  library(shinyFeedback)
  library(htmltools)
  library(htmlwidgets)
  library(shinycssloaders)
  library(readr)
  library(shinyjs)
  library(tidyverse)
  library(sf)
  library(plotly)
  library(shinipsum)
  library(kableExtra)
  library(exactextractr)
  library(terra)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(shinyBS)
  library(DT)

  # Read-in basedata -------------------------------------------------------------
  load(file.path("data", "03_clean", "basedata.RData"))

  # Read-in regional goals -------------------------------------------------------
  goals_csv <- read_csv(file.path("data", "sheets", "Regional_goals.csv"))

  # source shiny mods ------------------------------------------------------------
  source(file.path("scripts", "mod_tables.R"))
  source(file.path("scripts", "mod_extractions.R"))
  source(file.path("scripts", "mod_report.R"))
  source(file.path("scripts", "mod_comparison.R"))

  # Source functions -------------------------------------------------------------
  source(file.path("scripts", "fct_popup.R"))
  source(file.path("scripts", "fct_plots.R"))
  source(file.path("scripts", "fct_shpupload.R"))

  # Source conservation themes ---------------------------------------------------
  source(file.path("scripts", "server_load_themes.R"))

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
