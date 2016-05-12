
#' @importFrom httr content POST add_headers
# base URL for classify
monkeylearn_url_classify <- function() {
  "https://api.monkeylearn.com/v2/classifiers/cl_5icAVzKR/classify/"
}
# get results
monkeylearn_get <- function(request, key){
  POST(monkeylearn_url_classify(),
       add_headers(
         "Accept" = "application/json",
         "Authorization" = paste("Token ", key),
         "Content-Type" =
           "application/json"
       ),
       body = request
  )
}



#' Retrieve Monkeylearn API key
#'
#' @return An Monkeylearn API Key
#'
#' @details Looks in env var \code{MONKEYLEARN_KEY}
#'
#' @keywords internal
#' @export
monkeylearn_key <- function(quiet = TRUE) {
  pat <- Sys.getenv("MONKEYLEARN_KEY")
  if (identical(pat, ""))  {
    return(NULL)
  }
  if (!quiet) {
    message("Using Monkeylearn API Key from envvar MONKEYLEARN_KEY")
  }
  return(pat)
}
