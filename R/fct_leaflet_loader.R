# loading screen functional component: child element
loading_elem <- function(id, text = NULL) {
  stopifnot(!is.null(id))

  # generate element with dots
  el <- tags$div(
    id = id,
    class = "visually-hidden loading-ui spinner",
    `aria-hidden` = "true")

  # if a message is specified, then replace dots
  # and adjust classes
  if (length(text) > 0) {
    el$attribs$class <- "loading-ui loading-text"
    el$children <- tags$p(
      class = "loading-message",
      as.character(text)
    )
  }

  # return
  return(el)
}

#' loader
loading_message <- function(..., id, text = NULL) {
  tags$div(
    class = "loading-container",
    tags$span(
      class = "visually-hidden",
      "loading"
    ),
    loading_elem(id = id, text = text),
    ...
  )
}
