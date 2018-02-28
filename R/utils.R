

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

  stop("HTTP failure: ", req$status_code, "\n", httr::content(req)$detail, call. = FALSE)
}

# format request
monkeylearn_prep <- function(text, params) {
  jsonlite::toJSON(c(list(text_list = I(text)),
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

# # find which indices in original vector are blank
# monkeylearn_find_blanks <- function(request){
#   inds <- which(request %in% c("", " "))
#
#   return(inds)
# }

# no blank request
monkeylearn_filter_blank <- function(request){
  request <- request[gsub(" ", "", request) != ""]

  request
}

# check text size
monkeylearn_text_size <- function(request) {

  if(any(unlist(vapply(request, nchar, type = "bytes",
                       FUN.VALUE = 0)) > 500000)) {
    stop("Each text in the request should be smaller than 500 kb.",
         call. = FALSE)
  }
}

# get results classify
monkeylearn_get_classify <- function(request, key, classifier_id) {
  httr::POST(monkeylearn_url_classify(classifier_id),
       httr::add_headers(
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
  httr::POST(monkeylearn_url_extractor(extractor_id),
       httr::add_headers(
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

  text <- httr::content(output, as = "text",
                        encoding = "UTF-8")
  temp <- jsonlite::fromJSON(text)

  if(methods::is(temp$result, "list")) {
    if(length(temp$result[[1]]) != 0){
      results <-  do.call("rbind", temp$result)
      results$text_md5 <- unlist(mapply(rep, vapply(X=request_text,
                                                    FUN=digest::digest,
                                                    FUN.VALUE=character(1),
                                                    USE.NAMES=FALSE,
                                                    algo = "md5"),
                                        unlist(vapply(temp$result, nrow,
                                                      FUN.VALUE = 0)),
                                        SIMPLIFY = FALSE))

    } else{
      message("No results for this call")
      return(NULL)
    }
  } else {
    results <- as.data.frame(temp$result)
    results$text_md5 <- vapply(X=request_text,
                               FUN=digest::digest,
                               FUN.VALUE=character(1),
                               USE.NAMES=FALSE,
                               algo = "md5")
  }

  headers <- as.data.frame(httr::headers(output))
  headers$text_md5 <- list(vapply(X=request_text,
                                  FUN=digest::digest,
                                  FUN.VALUE=character(1),
                                  USE.NAMES=FALSE,
                                  algo = "md5"))

  list(results = results,
       headers = headers)
}


monkeylearn_parse_each <- function(output, request_text, verbose = TRUE) {

  text <- httr::content(output, as = "text",
                  encoding = "UTF-8")
  temp <- jsonlite::fromJSON(text)
  results <- NULL

  if(methods::is(temp$result, "list")) {
    if(length(temp$result[[1]]) == 0){
      results$result[[1]] <- NA_character_

      if (verbose) { message("No results for this call; returning NA.") }

    } else {
      results <- temp
    }
  } else {   # Not sure what other type of output we'd get
    results <- temp
    # results$text_md5 <- map(temp$result, digest::digest)
  }

  headers <- as.data.frame(httr::headers(output))
  headers$text_md5 <- list(vapply(X=request_text,
                                  FUN=digest::digest,
                                  FUN.VALUE=character(1),
                                  USE.NAMES=FALSE,
                                  algo = "md5"))

  headers <- list(headers = headers)
  out <- append(results, headers)
  return(out)

}


replace_x <- function(x, replacement = NA_character_) {
  if(is.null(x) || is.na(x)) {
    replacement
  } else {
    x
  }
}


replace_nulls_vec <- function(v) {
  v <- lapply(v, replace_x)

  if (all(is.na(v))) {
    warning("No responses for any inputs.")
    return(v)
  }

  replacement <- v[which(!is.na(v))][[1]][1, ]

  for (i in seq_along(replacement)) {
    replacement[, i] <- NA
  }

  v <- lapply(v, replace_x,
              replacement = replacement)

  return(v)
}


test_headers <- function(df) {
  testthat::test_that("headers are a dataframe of > 0 rows", {
    testthat::expect_is(attr(df, "headers"), "data.frame")
    testthat::expect_gte(nrow(attr(df, "headers")), 1)
  })
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
