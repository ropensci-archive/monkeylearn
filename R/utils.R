#' @importFrom jsonlite toJSON fromJSON
#' @importFrom httr content POST add_headers headers

# format request
monkeylearn_prep <- function(text){
  toJSON(list(text_list = text))
}

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

# parse results
monkeylearn_parse <- function(output){


  text <- content(output, as = "text",
                        encoding = "UTF-8")
  if (identical(text, "")) stop("No output to parse",
                                call. = FALSE)
  temp <- fromJSON(text)
  temp <-  do.call("rbind", temp$result)
  headers <- as.data.frame(headers(output))

  list(results = temp,
       headers = headers)

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
