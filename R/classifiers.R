#' monkeylearn_classifiers
#'
#' List of Monkeylearn classifiers modules
#'
#' @param key The API key
#' @param private default is FALSE, whether to show private modules only instead of private and public modules
#' @return A data.frame (tibble) with details about the
#' classifiers including their classifier_id which should be used in
#' \code{monkeylearn_classify}.
#' @details If you don't have any private modules,
#' \code{monkeylearn_classifiers(private = TRUE)} returns an empty data.frame.
#'
#' @examples \dontrun{
#' monkeylearn_classifiers(private = FALSE)
#' monkeylearn_classifiers(private = TRUE)
#' }
#'
#' @export
monkeylearn_classifiers <- function(private = FALSE,
                                    key = monkeylearn_key(quiet = TRUE)) {

  page <- 1
  has_next <- TRUE
  results <- NULL

  while(has_next == TRUE){
    address <- ifelse(!private,
                      paste0(monkeylearn_url(), "classifiers",
                             "/?all=1&page=",
                             page),
                      paste0(monkeylearn_url(), "classifiers",
                             "/?page=",
                             page))

    output <- httr::GET(address,
                        httr::add_headers(
                          "Authorization" = paste("Token ", monkeylearn_key()),
                          "Content-Type" =
                            "application/json"
                        )
    )


    text <- httr::content(output, as = "text",
                          encoding = "UTF-8")
    temp <- jsonlite::fromJSON(text)

    if(class(temp$results) == "data.frame"){
      has_next <- temp$has_next[1]

      names(temp$results)[1] <- "classifier_id"
      results <- dplyr::bind_rows(results, temp$results)

      page <- page + 1
    }
  else{
    has_next <- FALSE
  }

  }
  tibble::as_tibble(results)
}
