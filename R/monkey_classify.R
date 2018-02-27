#' Monkeylearn classify from a dataframe column or vector of texts
#'
#' Independent classifications for each row of a dataframe using the Monkeylearn classifiers modules
#'
#' @param input A dataframe or vector of texts (each text smaller than 50kB)
#'
#' @param col If input is a dataframe, the unquoted name of the character column containing text to classify
#' @param key The API key
#' @param classifier_id The ID of the classifier
#' @param params Parameters for the module as a named list.
#' @param texts_per_req Number of texts to be processed per requests. Minimum value is the number of texts in input; max is 200, as per
#' [Monkeylearn documentation](docs.monkeylearn.com/article/api-reference/). If NULL, we default to 200, or, if there are fewer than 200 texts, the length of the input.
#' @param unnest Should the output column be unnested?
#' @param verbose Whether to output messages about batch requests and progress of processing.
#'
#' @details Find IDs of classifiers using \url{https://app.monkeylearn.com/main/explore}.
#'
#' This function relates the rows in your original dataframe or elements in your vector to a classification particular to that row.
#' This allows you to know which row of your original dataframe is associated with which classification.
#' Each row of the dataframe is classified separately from all of the others, but the number of classifications a particular input row
#' is assigned may vary (unless you specify a fixed number of outputs in \code{params}).
#'
#' The \code{texts_per_req} parameter simply specifies the number of rows to feed the API at a time; it does not lump these together
#' for classification as a group. Varying this parameter does not affect the final output, but does affect speed: one batched request of
#' x texts is faster than x single-text requests:
#' \url{http://help.monkeylearn.com/frequently-asked-questions/queries/can-i-classify-or-extract-more-than-one-text-with-one-api-request}.
#' Even if batched, each text still counts as one query, so batching does not save you on hits to the API.
#' See the [Monkeylearn API docs](docs.monkeylearn.com/article/api-reference/) for more details.
#'
#' You can check the number of calls you can still make in the API using \code{attr(output, "headers")$x.query.limit.remaining}
#' and \code{attr(output, "headers")$x.query.limit.limit}.
#'
#'
#' @examples \dontrun{
#' text1 <- "Hauràs de dirigir-te al punt de trobada del grup al que et vulguis unir."
#' text2 <- "i want to buy an iphone"
#' text3 <- "Je déteste ne plus avoir de dentifrice."
#' text_4 <- "I hate not having any toothpaste."
#' request_df <- tibble::as_tibble(list(txt = c(text1, text2, text3, text_4)))
#' monkeylearn_classify_df(request_df, txt, texts_per_req = 2, unnest = TRUE
#' attr(output, "headers")}
#'
#' @return A data.frame (tibble) with the cleaned input (empty strings removed) and a new column, nested by default, containing the classification for that particular row.
#' Attribute is a data.frame (tibble) "headers" including the number of remaining queries as "x.query.limit.remaining".
#'
#' @export

monkey_classify <- function(input, col = NULL,
                           key = monkeylearn_key(quiet = TRUE),
                           classifier_id = "cl_oFKL5wft",
                           params = NULL,
                           texts_per_req = NULL,
                           unnest = FALSE,
                           verbose = TRUE) {


  if (!is.logical(unnest)) { stop("Error: unnest must be boolean.") }

  if (is.null(input)) { stop("input must be non-NULL") }

  # We're either taking a dataframe or a vector; not both, not neither
  if (inherits(input, "data.frame")) {
    if (is.null(deparse(substitute(col)))) {
      stop("If input is a dataframe, col must be non-null")
    }
    request_orig <- input[[deparse(substitute(col))]]
  } else if (is.vector(input)) {
    request_orig <- input
  } else {
    stop("input must be a dataframe or a vector")
  }

  # Add names to vector
  names(request_orig) <- 1:length(request_orig)

  length1 <- length(request_orig)

  # Default texts_per_req to 200, or to the length of the input if fewer than 200 texts
  if (is.null(texts_per_req)) {
    if (length1 < 200) {
      texts_per_req <- length1
    } else {
      texts_per_req <- 200
    }
  } else if (!is.numeric(texts_per_req) || texts_per_req <= 0 || texts_per_req > length1) {
    stop("Error: texts_per_req must be a whole positive number less than or equal to the number of texts.")
  } else if (texts_per_req > 200) {
    warning("Maximum 200 texts recommended per rquests.")
  }

  # filter the blank requests
  request <- monkeylearn_filter_blank(request_orig)

  if (length(request) == 0) {
    warning("You only entered blank text in the request.", call. = FALSE)
    return(tibble::tibble())
  } else {
    if (length1 != length(request)) {
      message("The parts of your request that are only blank are not sent to the API.")
    }
    # Split request into texts_per_req texts per request
    request <- split(request, ceiling(seq_along(request)/texts_per_req))

    results <- NULL
    headers <- NULL

    for(i in seq_along(request)) {
      min_text <- ifelse((i - 1)*texts_per_req == 0, 1, (i - 1)*texts_per_req)
      max_text <- i*texts_per_req

      if (verbose) {
        message(paste0("Processing batch ", i, " of ", length(request), " batches; texts ", min_text, " to ", max_text))
      }

      monkeylearn_text_size(request[[i]])
      request_part <- monkeylearn_prep(request[[i]],
                                       params)

      output <- tryCatch(monkeylearn_get_classify(request_part, key, classifier_id))

      # ---- Checks ----
      # for the case when the server returns nothing try 5 times, not more
      try_number <- 1
      while (class(output) == "try-error" && try_number < 6) {
        message(paste0("Server returned nothing, trying again, try number", try_number))
        Sys.sleep(2^try_number)
        output <- tryCatch(monkeylearn_get_classify(request_part, key, classifier_id))
        try_number <- try_number + 1
      }

      # check the output -- if it is 429 try again (throttle limit) try 5 times, not more
      try_number <- 1
      while(!monkeylearn_check(output) && try_number < 6) {
        if (verbose) { message(paste0("Received 429, trying again, try number", try_number)) }
        output <- monkeylearn_get_classify(request_part, key, classifier_id)
        try_number <- try_number + 1
      }
      # ----------------

      # parse output
      output <- monkeylearn_parse_each(output, request_text = request[[i]], verbose = verbose)

      # Set up the two columns
      request_reconstructed <- tibble::as_tibble(list(req = request[[i]]))

      res <- output$result
      if (length(res) == 1 && is.na(res)) {
        res <- rep(res, nrow(request_reconstructed))
      }
      output_nested <- tibble::tibble(resp = res)


      # Get our result and headers for this batch
      this_result <- dplyr::bind_cols(request_reconstructed, output_nested)
      this_headers <- tibble::as_tibble(output$headers)

      results <- dplyr::bind_rows(results, this_result)
      header <- dplyr::bind_rows(headers, this_headers)
    }

    attr(results, "headers") <- tibble::as_tibble(headers)

      # If we had blanks in the input, get them back into the result
    if (length(request_orig) > nrow(results)) {
      request_orig_df <- tibble::tibble(req_orig = request_orig)
      # request_orig_df$row_name <- as.numeric(names(request_orig))
      # results$row_name <- as.numeric(rownames(results))

      # Unnest what we can now
      if (unnest == TRUE) {
        results <- tidyr::unnest(results)
      } else {
        results$resp <- lapply(results$resp, replace_nulls)
      }

      results <- dplyr::left_join(request_orig_df, results,
                                  by = c("req_orig" = "req"))  # by = "row_name"


      results <-
        results[!(names(results) %in% c("req_orig"))]  #  "row_name"


    } else {
      if (unnest == TRUE) {
        results <- tidyr::unnest(results)
      }
    }

    return(results)
  }
}


