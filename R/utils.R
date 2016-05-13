#' @importFrom jsonlite toJSON fromJSON
#' @importFrom dplyr tbl_df
#' @importFrom httr content POST add_headers headers

# status check
monkeylearn_check <- function(req) {
  if (req$status_code < 400) return(invisible())
  stop("HTTP failure: ", req$status_code, "\n", content(req)$detail, call. = FALSE)
}

# format request
monkeylearn_prep <- function(text){
  toJSON(list(text_list = text))
}

# base URL
monkeylearn_url <- function(){
  "https://api.monkeylearn.com/v2/"
}

# URL for classify
monkeylearn_url_classify <- function(classifier_id) {
  paste0(monkeylearn_url(),
         "classifiers/",
         classifier_id,
         "/classify/")
}

# URL for extractor
monkeylearn_url_extractor <- function(extractor_id) {
  paste0(monkeylearn_url(),
         "extractors/",
         extractor_id,
         "/extract/")
}

# get results classify
monkeylearn_get_classify <- function(request, key, classifier_id){
  POST(monkeylearn_url_classify(classifier_id),
       add_headers(
         "Accept" = "application/json",
         "Authorization" = paste("Token ", key),
         "Content-Type" =
           "application/json"
       ),
       body = request
  )
}


# get results extract
monkeylearn_get_extractor <- function(request, key, extractor_id){
  POST(monkeylearn_url_extractor(extractor_id),
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
  results <-  do.call("rbind", temp$result)
  results$text <- unlist(mapply(rep, 1:length(temp$result),
                                unlist(lapply(temp$result, nrow)),
                                SIMPLIFY = FALSE))
  headers <- as.data.frame(headers(output))

  list(results = tbl_df(results),
       headers = tbl_df(headers))

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
