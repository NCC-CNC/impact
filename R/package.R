
#' @import shiny
#' @import shinydashboard
#' @import leaflet
#' @import leaflet.extras
#' @import leaflet.extras2
#' @import shinyWidgets
#' @import shinyFeedback
#' @import htmltools
#' @import htmlwidgets
#' @import shinycssloaders
#' @import readr
#' @import shinyjs
#' @import sf
#' @import plotly
#' @import shinipsum
#' @import exactextractr
#' @import terra
#' @import dplyr
#' @import tidyr
#' @import purrr
#' @import shinyBS
#' @import DT
#' @import ggplot2
NULL

#' impact:
#'
#' The application is a decision support tool to help prioritize conservation
#' efforts for the Nature Conservancy of Canada. It provides an interactive
#' interface for conducting systematic conservation planning exercises, and
#' uses mathematical optimization algorithms to generate solutions.
#'
#' @name impact
#'
#' @docType package
#'
#' @examples
#' \donttest{
#  # launch application
#' if (interactive()) {
#' run_app()
#' }
#' }
NULL

# define global variables to pass package checks
## these variables are used in lazy evaluation or the shiny application
utils::globalVariables(
  c(
    "pmp_attributes",
    "pmp_values",
    "id_",
    "Regions",
    "Category"
  )
)


# define functions for internally used packages to pass checks
tmp1 <- rgdal::readOGR
tmp1 <- R.utils::gzip
