#' @importFrom jsonlite toJSON fromJSON
#' @importFrom dplyr tbl_df
#' @importFrom methods is
#' @importFrom httr content POST add_headers headers

# status check
monkeylearn_check <- function(req) {
  if (req$status_code < 400) return(TRUE)
  if (req$status_code == 429) {
    "Pause for throttle limit, 60 seconds"
    Sys.sleep(60)
    return(FALSE)
  }
  if (identical(req, "")) {
    stop("No output to parse",
         call. = FALSE)
    Sys.sleep(10)
    return(FALSE)
  }

  stop("HTTP failure: ", req$status_code, "\n", content(req)$detail, call. = FALSE)
}

# format request
monkeylearn_prep <- function(text, params) {
  toJSON(c(list(text_list = I(text)),
           params),
         auto_unbox = TRUE)
}

# base URL
monkeylearn_url <- function() {
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

# check text size
monkeylearn_text_size <- function(request) {

  if(any(unlist(lapply(request, nchar, type = "bytes")) > 500000)) {
    stop("Each text in the request should be smaller than 500 kb.",
         call. = FALSE)
  }
}

# get results classify
monkeylearn_get_classify <- function(request, key, classifier_id) {
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
monkeylearn_get_extractor <- function(request, key, extractor_id) {
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
monkeylearn_parse <- function(output, request_text) {


  text <- content(output, as = "text",
                        encoding = "UTF-8")
  temp <- fromJSON(text)
  if(is(temp$result, "list")) {
    results <-  do.call("rbind", temp$result)
    results$text_md5 <- unlist(mapply(rep, sapply(request_text,
                                              digest::digest, algo = "md5",
                                              simplify = TRUE,
                                              USE.NAMES = FALSE),
                                  unlist(lapply(temp$result, nrow)),
                                  SIMPLIFY = FALSE))
  } else{
    results <- as.data.frame(temp$result)
    results$text_md5 <- sapply(request_text,
                               digest::digest, algo = "md5",
                               simplify = TRUE,
                               USE.NAMES = FALSE)
  }

  headers <- as.data.frame(headers(output))
  headers$text_md5 <- list(sapply(request_text,
                             digest::digest, algo = "md5",
                             simplify = TRUE,
                             USE.NAMES = FALSE))

  list(results = results,
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
