#' Monkeylearn extract from a dataframe column or vector of texts
#'
#' Independent extractions for each row of a dataframe using the Monkeylearn extractor modules
#'
#' @param input A dataframe or vector of texts (each text smaller than 50kB)
#'
#' @param col If input is a dataframe, the unquoted name of the character column containing text to extract from
#' @param key The API key
#' @param extractor_id The ID of the extractor
#' @param params Parameters for the module as a named list.
#' @param texts_per_req Number of texts to be processed per requests. Minimum value is the number of texts in input; max is 200, as per
#' [Monkeylearn documentation](docs.monkeylearn.com/article/api-reference/). If NULL, we default to 200, or, if there are fewer than 200 texts, the length of the input.
#' @param unnest Should the output column be unnested?
#' @param verbose Whether to output messages about batch requests and progress of processing.
#'
#' @details Find IDs of extractors using \url{https://app.monkeylearn.com/main/explore}.
#'
#' This function relates the rows in your original dataframe or elements in your vector to an extraction particular to that row.
#' This allows you to know which row of your original dataframe is associated with which extraction.
#' Each row of the dataframe is extracted separately from all of the others, but the number of extractions a particular input row
#' is assigned may vary (unless you specify a fixed number of outputs in \code{params}).
#'
#' The \code{texts_per_req} parameter simply specifies the number of rows to feed the API at a time; it does not lump these together
#' for extraction as a group. Varying this parameter does not affect the final output, but does affect speed: one batched request of
#' x texts is faster than x single-text requests:
#' \url{http://help.monkeylearn.com/frequently-asked-questions/queries/can-i-classify-or-extract-more-than-one-text-with-one-api-request}.
#' Even if batched, each text still counts as one query, so batching does not save you on hits to the API.
#' See the [Monkeylearn API docs](docs.monkeylearn.com/article/api-reference/) for more details.
#'
#' You can check the number of calls you can still make in the API using \code{attr(output, "headers")$x.query.limit.remaining}
#' and \code{attr(output, "headers")$x.query.limit.limit}.
#'
#' @importFrom magrittr %>%
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
#'  fighting against perceptions of Wall Street as boring and regulation-bound and
#'  Silicon Valley as the promised land of flip-flops, beanbag chairs and million-dollar
#'   stock options.\n\n Their argument to the room of technologically inclined students
#'   was that Wall Street was where they could find far more challenging, diverse and,
#'    yes, lucrative jobs working on some of the worlds most difficult technical problems.\n\n
#'    Whereas in other opportunities you might be considering, it is working one type of data
#'    or one type of application, we deal in hundreds of products in hundreds of markets, with
#'     thousands or tens of thousands of clients, every day, millions of times of day worldwide,
#'      Afsheen Afshar, a managing director at Goldman Sachs, told the students."
#' output <- monkey_extract(text,
#'                             extractor_id = "ex_y7BPYzNG",
#'                             params = list(max_keywords = 3,
#'                             use_company_names = 1))
#' attr(output, "headers")}
#'
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
#' @return A data.frame (tibble) with the cleaned input (empty strings removed) and a new column, nested by default, containing the extraction for that particular row.
#' Attribute is a data.frame (tibble) "headers" including the number of remaining queries as "x.query.limit.remaining".
#'
#' @export
#'

monkey_extract <- function(input, col = NULL,
                            key = monkeylearn_key(quiet = TRUE),
                            extractor_id = "ex_isnnZRbS",
                            params = NULL,
                            texts_per_req = NULL,
                            unnest = TRUE,
                            verbose = TRUE) {

  if (verbose && extractor_id == "ex_isnnZRbS") {
    message(paste0("Using extractor ID ", extractor_id, "; to find other extractors, visit https://app.monkeylearn.com/main/explore/"))
  }

  if (!is.logical(unnest)) { stop("Error: unnest must be boolean.") }
  if (is.null(input)) { stop("input must be non-NULL") }

  # We're either taking a dataframe or a vector; not both, not neither
  if (inherits(input, "data.frame")) {
    if (is.null(deparse(substitute(col)))) {
      stop("If input is a dataframe, col must be non-null")
    }
    request_orig <- input[[deparse(substitute(col))]]
  } else if (is.vector(input)) {
    if (!is.null(col)) {
      warning("Input is a vector but col was supplied; it will be ignored.")
    }
    request_orig <- input
  } else {
    stop("input must be a dataframe or a vector")
  }

  # Add names to vector
  names(request_orig) <- 1:length(request_orig)

  length1 <- length(request_orig)

  # Filter the blank requests
  request_pre_chunking <- monkeylearn_filter_blank(request_orig)

  filtered_len <- length(request_pre_chunking)

  # Default texts_per_req to 200, or to the length of the input if fewer than 200 texts
  # If more than 200 texts sent, proceed with a warning
  texts_per_req <- determine_texts_per_req(filtered_len, texts_per_req)

  if (filtered_len == 0) {
    warning("You only entered blank text in the request.", call. = FALSE)
    return(tibble::tibble())
  } else {
    if (length1 != filtered_len) {
      if(verbose) {
        # Indices in request_orig that are not in request
        emtpy_str_indices <- setdiff(seq_along(request_orig), which(request_orig %in% request_pre_chunking))

        if (length(emtpy_str_indices) <= 20) {
          message(paste0("The following indices were empty strings and could not be sent to the API: ",
                         paste0(emtpy_str_indices, collapse = ", "),
                         "
                         They will still be included in the output. \n"))

        } else {
          emtpy_str_indices_trunc <- emtpy_str_indices[1:20]
          message(paste0("The following indices were empty strings and could not be sent to the API. (Displaying first 20): ",
                         paste0(paste0(emtpy_str_indices_trunc, collapse = ", "), "..."),
                         "
                         They will still be included in the output. \n"))
        }
      }
    }

    # Split request into texts_per_req texts per request
    request <- split(request_pre_chunking, ceiling(seq_along(request_pre_chunking)/texts_per_req))

    results <- NULL
    headers <- NULL

    for (i in seq_along(request)) {
      min_text <- ifelse((i - 1)*texts_per_req == 0, 1, (i - 1)*texts_per_req)
      max_text <- ifelse(i == length(request), filtered_len, i*texts_per_req)

      if (verbose) {
        message(paste0("Processing batch ", i, " of ", length(request), " batches: texts ", min_text, " to ", max_text))

        if (i %% 10 == 0) {
          message("
                  /~\\
                  C oo
                  _( ^)
                  /  ~  \\
                  Still working!
                  ")
        }
        }


      monkeylearn_text_size(request[[i]])
      request_part <- monkeylearn_prep(request[[i]],
                                       params)

      output <- tryCatch(monkeylearn_get_extractor(request_part, key, extractor_id))

      # ---- Try send to API ----
      # For the case when the server returns nothing try 5 times, not more
      try_number <- 1
      while (class(output) == "try-error" && try_number < 6) {
        message(paste0("Server returned nothing, trying again, try number", try_number))
        Sys.sleep(2^try_number)
        output <- tryCatch(monkeylearn_get_extractor(request_part, key, extractor_id))
        try_number <- try_number + 1
      }

      # Check the output -- if it is 429 (throttle limit) try again. Try 5 times, not more
      try_number <- 1
      while(!monkeylearn_check(output) && try_number < 6) {
        if (verbose) { message(paste0("Received 429, trying again, try number", try_number)) }
        output <- monkeylearn_get_extractor(request_part, key, extractor_id)
        try_number <- try_number + 1
      }
      # --------------------------

      # Parse output
      output <- monkeylearn_parse_each(output, request_text = request[[i]], verbose = verbose)

      # Set up the two columns
      request_reconstructed <- tibble::tibble(req = request[[i]],
                                              row_name = as.numeric(names(request[[i]])))

      res <- output$result
      if (length(res) == 1 && is.na(res)) {
        res <- rep(res, nrow(request_reconstructed))
      }
      output_nested <- tibble::tibble(resp = res)


      # Get our result and headers for this batch
      this_result <- dplyr::bind_cols(request_reconstructed, output_nested)
      this_headers <- tibble::as_tibble(output$headers) %>% purrr::map_df(.p = is.factor, .f = as.character)

      results <- dplyr::bind_rows(results, this_result)
      headers <- dplyr::bind_rows(headers, this_headers)
        }

    # If we had empty strings in the input, get them back into the result in the right spots
    if (length(request_orig) > nrow(results)) {
      request_orig_df <- tibble::tibble(req_orig = request_orig,
                                        row_name = as.numeric(names(request_orig)))

      results <- dplyr::left_join(request_orig_df, results,
                                  by = "row_name")

      results$resp <- replace_nulls_vec(results$resp)

      results <- results[ , -which(names(results) == "req")]
      names(results)[which(names(results) == "req_orig")] <- "req"
    }

    if (unnest == TRUE) {
      results <- tidyr::unnest(results)
    }

    results <- results[ , -which(names(results) == "row_name")]

    # Done!
    attr(results, "headers") <- tibble::as_tibble(headers)
    return(results)
      }
  }
