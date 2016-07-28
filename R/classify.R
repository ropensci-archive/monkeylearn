#' monkeylearn_classify
#'
#' Access to Monkeylearn classifiers modules
#'
#' @param request A vector of characters (each text smaller than 50kB)
#'
#' @param key The API key
#' @param classifier_id The ID of the classifier
#' @param verbose whether to output messages about batch requests
#'
#' @details Find IDs of classifiers using \url{https://app.monkeylearn.com/main/explore}.
#'
#'  You can use batch to send up to 200 texts to be analyzed within the API
#'  (classification or extraction) with each request.
#' So for example, if you need to analyze 6000 tweets,
#' instead of doing 6000 requests to the API, you can use batch to send 30 requests,
#' each request with 200 tweets.
#' The function automatically makes these batch calls and waits if there is a throttle limit error,
#' but you might want to control the process yourself using several calls to the function.
#'
#' You can check the number of calls you can still make in the API using \code{attr(output, "headers")$x.query.limit.remaining}
#' and \code{attr(output, "headers")$x.query.limit.limit}.
#'
#' @importFrom jsonlite toJSON
#' @examples \dontrun{
#' text1 <- "my dog is an avid rice eater"
#' text2 <- "i want to buy an iphone"
#' request <- c(text1, text2)
#' output <- monkeylearn_classify(request)
#' output
#' attr(output, "headers")}
#' @return A data.frames with the results whose attribute is a data.frame "headers" including the number of remaining queries as "x.query.limit.remaining".
#' Both data.frames include a column with the (list of) md5 checksum(s) of the corresponding text(s) computed using the \code{digest digest} function.
#' @export
monkeylearn_classify <- function(request, key = monkeylearn_key(quiet = TRUE),
                                 classifier_id = "cl_oFKL5wft",
                                 verbose = FALSE) {

  # 20 texts per request
  request <- split(request, ceiling(seq_along(request)/20))

  results <- NULL
  headers <- NULL

  for(i in 1:length(request)) {

    if(verbose) {
      message(paste0("Processing request number ", i, " out of ", length(request)))
    }

    monkeylearn_text_size(request[[i]])
    request_part <- monkeylearn_prep(request[[i]],
                                     params = NULL)
    output <- tryCatch(monkeylearn_get_classify(request_part, key, classifier_id))
    # for the case when the server returns nothing
    # try 5 times, not more
    try_number <- 1
    while(class(output) == "try-error" && try_number < 6) {
      message(paste0("Server returned nothing, trying again, try number", i))
      Sys.sleep(2^try_number)
      output <- tryCatch(monkeylearn_get_classify(request_part, key, classifier_id))
      try_number <- try_number + 1
    }

    # check the output -- if it is 429 try again (throttle limit)
    # try 5 times, not more
    try_number <- 1
    while(!monkeylearn_check(output) && try_number < 6) {
      output <- monkeylearn_get_classify(request_part, key, classifier_id)
      try_number <- try_number + 1
    }
    # parse output
    output <- monkeylearn_parse(output, request_text = request[[i]])

    results <- rbind(results, output$results)
    headers <- rbind(headers, output$headers)
  }

  # done!
  attr(results, "headers") <- headers
  results
}
