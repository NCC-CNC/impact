# PMP plot and table titles
download_UI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(column(8, offset = 2, align = "center",
      downloadButton(outputId = ns("download"),
                   label = "Download Extractions",
                   icon = icon("download"),
                   width = "100%")))
  )
}

download_SERVER <- function(id, user_pmp_mean) {
  moduleServer(id, function(input, output, session) {

    # Time stamp for output folder
    datetime <- format(Sys.time(),"%Y%m%d%H%M%S")

    # Create temporary directory to save data
    td <- tempfile()
    dir.create(td, recursive = FALSE, showWarnings = FALSE)

    # Save shapefile to tmp director
    sf::write_sf(user_pmp_mean(), paste0(td, "/pmp_extractions.shp"))

    # Zip
    files2zip <- list.files(td, full.names = TRUE, recursive = FALSE)
    utils::zip(zipfile = file.path(td, paste0("pmp_extractions_", datetime, ".zip")),
               files = files2zip,
               flags = '-r9Xj') # flag so it does not take parent folders

    # set download button behavior
    output$download <- shiny::downloadHandler(
      filename <- function() {
        paste0("pmp_extractions_", datetime, ".zip", sep="")
      },
      content <- function(file) {
        file.copy(file.path(td, paste0("pmp_extractions_", datetime, ".zip")), file)
      },
      contentType = "application/zip"
    )
  })
}
