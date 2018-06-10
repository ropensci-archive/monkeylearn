#' monkeylearn_extractors
#'
#' List of Monkeylearn extractor modules
#'
#' @param key The API key
#' @param private default is FALSE, whether to show private modules only instead of private and public modules
#' @return A data.frame (tibble) with details about the
#' extractors including their extractor_id which should be used in
#' \code{monkey_extract}.
#' @details If you don't have any private modules,
#' \code{monkeylearn_extractors(private = TRUE)} returns an empty data.frame.
#'
#' @examples \dontrun{
#' monkeylearn_extractors(private = FALSE)
#' monkeylearn_extractors(private = TRUE)
#' }
#'
#' @export
monkeylearn_extractors <- function(private = FALSE,
                                   key = monkeylearn_key(quiet = TRUE)) {
  results <- NULL
  page <- 1

  address <- ifelse(!private,
    paste0(
      monkeylearn_url_v3(), "extractors",
      "/?all=1&page=",
      page
    ),
    paste0(
      monkeylearn_url(), "extractors",
      "/?page=",
      page
    )
  )

  output <- httr::GET(
    address,
    httr::add_headers(
      "Authorization" = paste("Token ", monkeylearn_key()),
      "Content-Type" =
        "application/json"
    )
  )

  text <- httr::content(output,
    as = "text",
    encoding = "UTF-8"
  )
  results <- jsonlite::fromJSON(text)

  if (class(results) == "data.frame") {
    names(results)[1] <- "extractor_id"

    results <- results %>% tibble::as_tibble()
  } else {
    message("Error retrieving extractors.")
  }

  return(results)
}
