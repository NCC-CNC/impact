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

# Leaflet On Render NCC properties
addPolygon_spinner_ugly_js <- "

  function(el, x, data) {

    // select map, loader, button
    var m = this;
    const elem = document.getElementById('leafletBusy');
    const reserves = document.querySelectorAll('#reserves input');
    const ncc_parcels = document.querySelectorAll('#ncc_regions input');

    // when map is rendered, display loading
    // adjust delay as needed
    m.whenReady(function() {
      elem.classList.remove('visually-hidden');
      setTimeout(function() {
       elem.classList.add('visually-hidden');
        }, 0)
    });

    // click event on radio button node list
    for (var i = 0; i < reserves.length; i++) {
      reserves[i].addEventListener('change', function(event) {
        // show loading element
        elem.classList.remove('visually-hidden');
        (new Promise(function(resolve, reject) {
          // leaflet event: layeradd
          m.addEventListener('layeradd', function(event) {
            console.log(event.type)
            // resolve after a few seconds to ensure all
            // elements rendered (adjust as needed)
            // time is in milliseconds
            setTimeout(function() {
              resolve('done');
              }, 0)
            })
        })).then(function(response) {
        // resolve: hide loading screen
        console.log('done');
        elem.classList.add('visually-hidden');
        }).catch(function(error) {
        // throw errors
        console.error(error);
        });
      });
    };

    // click event on ncc parcel button node list
    for (var i = 0; i < ncc_parcels.length; i++) {
      ncc_parcels[i].addEventListener('change', function(event) {
        // show loading element
        elem.classList.remove('visually-hidden');
        (new Promise(function(resolve, reject) {
          // leaflet event: layeradd
          m.addEventListener('layeradd', function(event) {
            console.log(event.type)
            // resolve after a few seconds to ensure all
            // elements rendered (adjust as needed)
            // time is in milliseconds
            setTimeout(function() {
              resolve('done');
              }, 0)
            })
          })).then(function(response) {
          // resolve: hide loading screen
          console.log('done');
          elem.classList.add('visually-hidden');
          }).catch(function(error) {
          // throw errors
          console.error(error);
          });
      });
    };
  }

"


