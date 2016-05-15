#' monkeylearn_extract
#'
#' Access to Monkeylearn extractors modules
#'
#' @param request A vector of characters (each text smaller than 50kB)
#'
#' @param key The API key
#' @param extractor_id The ID of the extractor
#'
#' @importFrom jsonlite toJSON
#' @examples text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
#' output <- monkeylearn_extract(request = text)
#' output
#' @details Find IDs of extractors using \url{https://app.monkeylearn.com/main/explore}.
#' Within the free plan, you can make up to 20 requests per minute.
#'  You can use batch to send up to 200 texts to be analyzed within the API
#'  (classification or extraction) with each request.
#' So for example, if you need to analyze 6000 tweets,
#' instead of doing 6000 requests to the API, you can use batch to send 30 requests,
#' each request with 200 tweets.
#' The function automatically makes these batch calls and waits if there is a throttle limit error,
#' but you might want to control the process yourself using several calls to the function.
#' @return A list of two data.frames (dplyr tbl_df), one with the results, the other with headers including the number of remaining queries as "x.query.limit.remaining".
#' @export
monkeylearn_extract <- function(request, key = monkeylearn_key(quiet = TRUE),
                                extractor_id = "ex_isnnZRbS"){

  # 20 texts per request
  request <- split(request, ceiling(seq_along(request)/20))

  results <- NULL
  headers <- NULL

  for(i in 1:length(request)){

    print(paste0("Processing request number ", i, " out of ", length(request)))
    monkeylearn_text_size(request[[i]])
    request_part <- monkeylearn_prep(request[[i]])
    output <- tryCatch(monkeylearn_get_extractor(request_part, key, extractor_id))
    # for the case when the server returns nothing
    while(class(output) == "try-error"){
      print("Server returned nothing, trying again in 10 seconds")
      Sys.sleep(10)
      output <- tryCatch(monkeylearn_get_extractor(request_part, key, extractor_id))
    }
    # check the output -- if it is 429 try again (throttle limit)
    while(!monkeylearn_check(output)){
      output <- monkeylearn_get_extractor(request_part, key, extractor_id)
    }
    # parse output
    output <- monkeylearn_parse(output)
    # text index
    output$results$text <- output$results$text + (i-1)*20
    results <- rbind(results, output$results)
    headers <- rbind(headers, output$headers)
  }

  # done!
  list(results = results,
       headers = headers)

}

