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
#' @param .keep_all If \code{input} is a dataframe, should non-\code{col} columns be retained in the output?
#' @param verbose Whether to output messages about batch requests and progress of processing.
#' @param ... Other arguments
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
#' @importFrom magrittr %>%
#'
#' @examples \dontrun{
#' text1 <- "Hauràs de dirigir-te al punt de trobada del grup al que et vulguis unir."
#' text2 <- "i want to buy an iphone"
#' text3 <- "Je déteste ne plus avoir de dentifrice."
#' text_4 <- "I hate not having any toothpaste."
#' request_df <- tibble::as_tibble(list(txt = c(text1, text2, text3, text_4)))
#' monkey_classify(request_df, txt, texts_per_req = 2, unnest = TRUE)
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
                            unnest = TRUE,
                            .keep_all = TRUE,
                            verbose = TRUE,
                            ...) {
  if (verbose && classifier_id == "cl_oFKL5wft") {
    message(paste0("Using classifier ID ", classifier_id, "; to find other classifiers, run monkeylearn_classifiers() or visit https://app.monkeylearn.com/main/explore/"))
  }

  if (!is.logical(unnest)) {
    stop("Error: unnest must be boolean.")
  }
  if (is.null(input)) {
    stop("input must be non-null.")
  }

  # We're either taking a dataframe or a vector; not both, not neither
  if (inherits(input, "data.frame")) {
    if (is.null(substitute(col))) {
      stop("If input is a dataframe, col must be non-null.")
    } else if (!deparse(substitute(col)) %in% names(input)) {
      stop("Column supplied does not appear in dataframe.")
    }
    request_orig <- input[[deparse(substitute(col))]]
  } else if (is.vector(input)) {
    if (!is.null(substitute(col))) {
      warning("Input is a vector but col was supplied; it will be ignored.")
    }
    if (.keep_all == FALSE) {
      warning("Input is a vector but .keep_all was set to FALSE; it will be ignored.")
    }
    request_orig <- input
  } else {
    stop("input must be a dataframe or a vector")
  }

  # Add names to vector
  names(request_orig) <- 1:length(request_orig)

  length_orig <- length(request_orig)

  # Filter the blank requests
  request_pre_chunking <- monkeylearn_filter_blank(request_orig)

  length_filtered <- length(request_pre_chunking)

  # Default texts_per_req to 200, or to the length of the input if fewer than 200 texts
  # If more than 200 texts sent, proceed with a warning
  texts_per_req <- determine_texts_per_req(length_filtered, texts_per_req)

  if (length_filtered == 0) {
    warning("You only entered blank text or NAs in the request.", call. = FALSE)
    return(tibble::tibble())
  } else {
    if (length_orig != length_filtered) {
      if (verbose) {
        # Indices in request_orig that are not in request
        emtpy_str_indices <- setdiff(seq_along(request_orig), which(request_orig %in% request_pre_chunking))

        if (length(emtpy_str_indices) <= 20) {
          message(paste0(
            "The following indices were empty strings and could not be sent to the API: ",
            paste0(emtpy_str_indices, collapse = ", "),
            "
            They will still be included in the output. \n"
          ))
        } else {
          emtpy_str_indices_trunc <- emtpy_str_indices[1:20]
          message(paste0(
            "The following indices were empty strings and could not be sent to the API. (Displaying first 20): ",
            paste0(paste0(emtpy_str_indices_trunc, collapse = ", "), "..."),
            "
            They will still be included in the output. \n"
          ))
        }
      }
    }

    # Split request into texts_per_req texts per request
    request <- split(request_pre_chunking, ceiling(seq_along(request_pre_chunking) / texts_per_req))

    results <- NULL
    headers <- NULL

    for (i in seq_along(request)) {
      min_text <- ifelse((i - 1) * texts_per_req == 0, 1, (i - 1) * texts_per_req)
      max_text <- ifelse(i == length(request), length_filtered, i * texts_per_req)

      if (verbose) {
        message(paste0("Processing batch ", i, " of ", length(request), " batches: texts ", min_text, " to ", max_text))

        if (i %% 10 == 0) {
          # Insert possible ASCII art or message here
          message("Still working!")
        }
      }

      monkeylearn_text_size(request[[i]])
      request_part <- monkeylearn_prep(
        request[[i]],
        params
      )

      output <- tryCatch(monkeylearn_get_classify(request_part, key, classifier_id))

      # ---- Try send to API ----
      # For the case when the server returns nothing try 5 times, not more
      try_number <- 1
      while (class(output) == "try-error" && try_number < 6) {
        message(paste0("Server returned nothing, trying again, try number", try_number))
        Sys.sleep(2^try_number)
        output <- tryCatch(monkeylearn_get_classify(request_part, key, classifier_id))
        try_number <- try_number + 1
      }

      # Check the output -- if it is 429 (throttle limit) try again. Try 5 times, not more
      try_number <- 1
      while (!monkeylearn_check(output) && try_number < 6) {
        if (verbose) {
          message(paste0("Received 429, trying again, try number", try_number))
        }
        output <- monkeylearn_get_classify(request_part, key, classifier_id)
        try_number <- try_number + 1
      }
      # --------------------------

      # Parse output
      output <- monkeylearn_parse_each(output, request_text = request[[i]], verbose = verbose)
      res <- output$result

      # Some acrobatics to replace NULLs with NAs
      if (detect_nulls(res) == TRUE) {
        res_orig <- res %>% purrr::modify_depth(2, replace_null) %>%
          tidyr::unnest()

        res <- NULL
        for (j in 1:nrow(res_orig)) {
          res <- append(res, res_orig[j, ] %>% list())
        }
      }

      # If the entire output is NULL or NA, give ourselves a vector of NAs of the original length of the input
      if ((length(res) == 1 && is.na(res)) |
        res %>% unlist() %>% is.null()) {
        res <- rep(NA_character_, length_orig)
      }

      res_nested <- tibble::tibble(res = res)

      # Set up the two columns
      request_reconstructed <- tibble::tibble(
        req = request[[i]],
        row_name = as.numeric(names(request[[i]]))
      )

      # Get our result and headers for this batch
      this_result <- dplyr::bind_cols(request_reconstructed, res_nested)
      this_headers <- tibble::as_tibble(output$headers) %>% purrr::map_df(.p = is.factor, .f = as.character)

      results <- dplyr::bind_rows(results, this_result)
      headers <- dplyr::bind_rows(headers, this_headers)
    }

    # If we had empty strings in the input, get them back into the result in the right spots
    if (length(request_orig) > nrow(results)) {
      request_orig_df <- tibble::tibble(
        req = request_orig,
        row_name = as.numeric(names(request_orig))
      )

      results <- dplyr::left_join(request_orig_df, results,
        by = c("row_name", "req")
      )

      # Replace NULLs with NAs
      results$res <- replace_nulls_vec(results$res)
    }

    # Remove joiner column
    results <- results[, -which(names(results) == "row_name")]

    # Retain the original column name if input is a dataframe, rather than renaming it to req
    if (inherits(input, "data.frame")) {
      names(results)[which(names(results) == "req")] <- deparse(substitute(col))
    }

    if (.keep_all == TRUE && inherits(input, "data.frame")) {
      results <- dplyr::bind_cols(
        input[, -(which(names(input) == deparse(substitute(col))))],
        results
      )
    }

    if (unnest == TRUE & !(all(is.na(results$res)))) {
      results <- tidyr::unnest(results)
    }

    # Done!
    attr(results, "headers") <- tibble::as_tibble(headers)
    return(results)
  }
}
