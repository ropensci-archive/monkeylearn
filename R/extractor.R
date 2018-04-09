#' monkeylearn_extract
#'
#' Access to Monkeylearn extractors modules
#'
#' @param request A vector of characters (each text smaller than 50kB)
#'
#' @param key The API key
#' @param extractor_id The ID of the extractor
#' @param texts_per_req Number of texts to be fed through per request (max 200). Does not affect output, but may affect speed of processing.
#' @param verbose Whether to output messages about batch requests
#' @param params Parameters for the module as a named list. See the second example.
#'
#' @examples \dontrun{
#' text <- "In the 19th century, the major European powers had gone to great lengths
#' to maintain a balance of power throughout Europe, resulting in the existence of
#'  a complex network of political and military alliances throughout the continent by 1900.[7]
#'   These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria.
#'   Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of
#'    the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary,
#'     Russia and Germany."
#' output <- monkeylearn_extract(request = text)
#' output
#' # example with parameters
#' text <- "A panel of Goldman Sachs employees spent a recent Tuesday night at the
#' Columbia University faculty club trying to convince a packed room of potential
#' recruits that Wall Street, not Silicon Valley, was the place to be for computer
#' scientists.\n\n The Goldman employees knew they had an uphill battle. They were
#' fighting against perceptions of Wall Street as boring and regulation-bound and
#' Silicon Valley as the promised land of flip-flops, beanbag chairs and million-dollar
#' stock options.\n\n Their argument to the room of technologically inclined students
#' was that Wall Street was where they could find far more challenging, diverse and,
#' yes, lucrative jobs working on some of the worlds most difficult technical problems."
#'
#' output <- monkeylearn_extract(text,
#'                               extractor_id = "ex_y7BPYzNG",
#'                               params = list(max_keywords = 3,
#'                                             use_company_names = 1))
#' attr(output, "headers")}
#' @details Find IDs of extractors using \url{https://app.monkeylearn.com/main/explore}.
#' Within the free plan, you can make up to 20 requests per minute.
#'
#' You can use batch to send up to 200 texts to be analyzed within the API
#' (classification or extraction) with each request.
#' So for example, if you need to analyze 6000 tweets,
#' instead of doing 6000 requests to the API, you can use batch to send 30 requests,
#' each request with 200 tweets.
#' The function automatically makes these batch calls and waits if there is a throttle limit error,
#' but you might want to control the process yourself using several calls to the function.
#'
#' You can check the number of calls you can still make in the API using \code{attr(output, "headers")$x.query.limit.remaining}
#' and \code{attr(output, "headers")$x.query.limit.limit}.
#'
#' @return A data.frame with the results whose attribute is a data.frame (tibble) "headers" including the number of remaining queries as "x.query.limit.remaining".
#' Both data.frames include a column with the (list of) md5 checksum(s) of the corresponding text(s) computed using the \code{digest digest} function.
#' @export

monkeylearn_extract <- function(request, key = monkeylearn_key(quiet = TRUE),
                                extractor_id = "ex_isnnZRbS",
                                texts_per_req = 200,
                                verbose = TRUE,
                                params = NULL) {
  if (verbose) {
    message("This function is in the process of being deprecated. We suggest you switch to monkey_extract.
More information available here: https://ropensci.github.io/monkeylearn/")
  }

  # filter the blank requests
  length1 <- length(request)
  request <- monkeylearn_filter_blank(request)
  if (length(request) == 0) {
    warning("You only entered blank text in the request.", call. = FALSE)
    return(tibble::tibble())
  } else {
    if (length1 != length(request)) {
      message("The parts of your request that are only blank are not sent to the API.")
    }

    # 20 texts per request
    request <- split(request, ceiling(seq_along(request) / texts_per_req))

    results <- NULL
    headers <- NULL

    for (i in seq_along(request)) {
      if (verbose) {
        message(paste0("Processing request number ", i, " out of ", length(request)))
      }

      monkeylearn_text_size(request[[i]])
      request_part <- monkeylearn_prep(
        request[[i]],
        params
      )
      output <- tryCatch(monkeylearn_get_extractor(request_part, key, extractor_id))
      # for the case when the server returns nothing
      # try 5 times, not more
      try_number <- 1
      while (class(output) == "try-error" && try_number < 6) {
        message(paste0("Server returned nothing, trying again, try number", try_number))
        Sys.sleep(2^try_number)
        output <- tryCatch(monkeylearn_get_extractor(request_part, key, extractor_id))
        try_number <- try_number + 1
      }

      # check the output
      try_number <- 1
      while (!monkeylearn_check(output, try_number, verbose) &&
             try_number < 6){
        output <- monkeylearn_get_extractor(request_part, key, extractor_id)
        try_number <- try_number + 1
      }
      # parse output
      output <- monkeylearn_parse(output, request_text = request[[i]])

      results <- suppressWarnings(dplyr::bind_rows(results, output$results))
      headers <- suppressWarnings(dplyr::bind_rows(headers, output$headers))
    }

    # done!
    attr(results, "headers") <- tibble::as_tibble(headers)
    results
  }
}
