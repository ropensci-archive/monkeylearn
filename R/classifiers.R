#' monkeylearn_classifiers
#'
#' List of Monkeylearn classifiers modules
#'
#' @param private default is FALSE, whether to show private modules instead of public modules
#' @return A data.frame, but nothing now, in dev.
#' @export
monkeylearn_classifiers <- function(private = FALSE) {
  output <- httr::POST(paste0(monkeylearn_url(), "classifiers",
                              ifelse(!private, "/?all=1", "")),
       httr::add_headers(
         "Authorization" = paste("Token ", monkeylearn_key()),
         "Content-Type" =
           "application/json"
       )
  )


  text <- httr::content(output, as = "text",
                  encoding = "UTF-8")
  temp <- jsonlite::fromJSON(text)
}
