#' monkeylearn_classify
#'
#' Access to Monkeylearn classifiers modules
#'
#' @param request A vector of characters
#'
#' @param key The API key
#' @param classifier_id The ID of the classifier
#'
#' @details Find IDs of classifiers using \url{https://app.monkeylearn.com/main/explore}.
#'
#' @importFrom jsonlite toJSON
#' @examples text1 <- "my dog is an avid rice eater"
#' text2 <- "i want to buy an iphone"
#' request <- c(text1, text2)
#' output <- monkeylearn_classify(request)
#' output
#' @return A list of two data.frames (dplyr tbl_df), one with the results, the other with headers including the number of remaining queries as "x.query.limit.remaining".
#' @export
monkeylearn_classify <- function(request, key = monkeylearn_key(quiet = TRUE),
                                 classifier_id = "cl_oFKL5wft"){
  monkeylearn_text_size(request)
  request <- monkeylearn_prep(request)
  output <- monkeylearn_get_classify(request, key, classifier_id)
  monkeylearn_check(output)
  monkeylearn_parse(output)
}
