#' monkeylearn_classify
#'
#' monkeylearn_classify
#'
#' @param request A vector of characters
#'
#' @param key The API key
#'
#' @importFrom jsonlite toJSON
#' @examples text1 <- "lions are very big animals"
#' text2 <- "i want to buy an iphone"
#' request <- c(text1, text2)
#' output <- monkeylearn_classify(request)
#' output
#' @export
monkeylearn_classify <- function(request, key = monkeylearn_key(quiet = TRUE)){
  request <- monkeylearn_prep(request)
  output <- monkeylearn_get(request, key)
  monkeylearn_parse(output)
}
