#' monkeylearn_classify
#'
#' monkeylearn_classify
#'
#' @param request
#'
#' @param key
#'
#' @importFrom jsonlite toJSON
#' @examples text1 <- "lions are very big animals"
#' text2 <- "i want to buy an iphone"
#' request <- toJSON(list(text_list = c(text1, text2)))
#' result <- monkeylearn_classify(request)
#' httr::content(result)
#' @export
monkeylearn_classify <- function(request, key = monkeylearn_key(quiet = TRUE)){
  monkeylearn_get(request, key)
}
