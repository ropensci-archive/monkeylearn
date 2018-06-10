
# status check
monkeylearn_check <- function(req, try_number = 1, verbose = FALSE) {
  if (req$status_code < 400) return(TRUE)
  if (req$status_code >= 400) {
    if (verbose) {
      message(paste("Pause for http error, wait & try number", try_number + 2)) # nolint
    }
    Sys.sleep(2^try_number)
    return(FALSE)
  }
  if (identical(req, "")) {
    stop("No output to parse",
      call. = FALSE
    )
    Sys.sleep(10)
    return(FALSE)
  }

  stop("HTTP failure: ", req$status_code, "\n", httr::content(req)$detail, call. = FALSE)
}


# format request
monkeylearn_prep <- function(text, params) {
  jsonlite::toJSON(c(
    list(text_list = I(text)),
    params
  ),
  auto_unbox = TRUE
  )
}


# base URL
monkeylearn_url <- function() {
  "https://api.monkeylearn.com/v2/"
}

monkeylearn_url_v3 <- function() {
  "https://api.monkeylearn.com/v3/"
}


# URL for classify
monkeylearn_url_classify <- function(classifier_id) {
  paste0(
    monkeylearn_url(),
    "classifiers/",
    classifier_id,
    "/classify/"
  )
}


# URL for extractor
monkeylearn_url_extractor <- function(extractor_id) {
  paste0(
    monkeylearn_url(),
    "extractors/",
    extractor_id,
    "/extract/"
  )
}


# no blank request
monkeylearn_filter_blank <- function(request) {
  # Turn NULLs to NA
  request <- request %>% purrr::map_chr(replace_null)
  # Remove NAs and emtpy strings
  request <- request[!gsub(" ", "", request) %in% c("", NA)]

  request
}


# check text size
monkeylearn_text_size <- function(request) {
  if (any(unlist(vapply(request, nchar,
    type = "bytes",
    FUN.VALUE = 0
  )) > 500000)) {
    stop("Each text in the request should be smaller than 500 kb.",
      call. = FALSE
    )
  }
}


# get results classify or extract
monkeylearn_get_extractor <- function(request, key, extractor_id) {
  monkey_post(monkeylearn_url_extractor(extractor_id),
    httr::add_headers(
      "Accept" = "application/json",
      "Authorization" = paste("Token ", key),
      "Content-Type" =
        "application/json"
    ),
    body = request
  )
}


monkeylearn_get_classify <- function(request, key, classifier_id) {
  monkey_post(monkeylearn_url_classify(classifier_id),
    httr::add_headers(
      "Accept" = "application/json",
      "Authorization" = paste("Token ", key),
      "Content-Type" =
        "application/json"
    ),
    body = request
  )
}


# -- Not currently used, but may be worth condensing monkeylearn_get_classify and monkeylearn_get_extractor into this
monkeylearn_post <- function(request, key, classifier_id) {
  monkey_post(monkeylearn_url_classify(classifier_id),
    httr::add_headers(
      "Accept" = "application/json",
      "Authorization" = paste("Token ", key),
      "Content-Type" =
        "application/json"
    ),
    body = request
  )
}


# parse results
monkeylearn_parse <- function(output, request_text) {
  text <- httr::content(output,
    as = "text",
    encoding = "UTF-8"
  )
  temp <- jsonlite::fromJSON(text)

  if (methods::is(temp$result, "list")) {
    if (length(temp$result[[1]]) != 0) {
      results <- do.call("rbind", temp$result)
      results$text_md5 <- unlist(mapply(rep, vapply(
        X = request_text,
        FUN = digest::digest,
        FUN.VALUE = character(1),
        USE.NAMES = FALSE,
        algo = "md5"
      ),
      unlist(vapply(temp$result, nrow,
        FUN.VALUE = 0
      )),
      SIMPLIFY = FALSE
      ))
    } else {
      message("No results for this call")
      return(NULL)
    }
  } else {
    results <- as.data.frame(temp$result)
    results$text_md5 <- vapply(
      X = request_text,
      FUN = digest::digest,
      FUN.VALUE = character(1),
      USE.NAMES = FALSE,
      algo = "md5"
    )
  }

  headers <- as.data.frame(httr::headers(output))
  headers$text_md5 <- list(vapply(
    X = request_text,
    FUN = digest::digest,
    FUN.VALUE = character(1),
    USE.NAMES = FALSE,
    algo = "md5"
  ))

  list(
    results = results,
    headers = headers
  )
}


monkeylearn_parse_each <- function(output, request_text, verbose = TRUE) {
  text <- httr::content(output,
    as = "text",
    encoding = "UTF-8"
  )
  temp <- jsonlite::fromJSON(text)
  results <- NULL

  if (methods::is(temp$result, "list")) {
    if (length(temp$result[[1]]) == 0) {
      results$result[[1]] <- NA_character_

      if (verbose) {
        message("No results for this call; returning NA.")
      }
    } else {
      results <- temp
    }
  } else { # Not sure what other type of output we'd get
    results <- temp
    # results$text_md5 <- map(temp$result, digest::digest)
  }

  headers <- as.data.frame(httr::headers(output))
  headers$text_md5 <- list(vapply(
    X = request_text,
    FUN = digest::digest,
    FUN.VALUE = character(1),
    USE.NAMES = FALSE,
    algo = "md5"
  ))

  headers <- list(headers = headers)
  out <- append(results, headers)
  return(out)
}

# See whether we have a situation like what is returned in output$result when extractor ex_dqRio5sG is used
detect_nulls <- function(tbl) {
  if (inherits(tbl, "data.frame")) {
    for (i in seq_along(tbl)) {
      for (j in seq_along(tbl[, i])) {
        if (length(tbl[, i][[j]]) == 0) { # If any of the cells are of length 0, we have a NULL
          contains_nulls <- TRUE
        } else {
          contains_nulls <- FALSE
        }
      }
    }
  } else {
    contains_nulls <- FALSE
  }
  return(contains_nulls)
}


replace_null <- function(x, replacement = NA_character_) {
  if (length(x) == 0 || length(x[[1]]) == 0) {
    replacement
  } else {
    x
  }
}

replace_x <- function(x, replacement = NA_character_) {
  if (length(x) == 0 || is.null(x) || is.na(x) || nrow(x) == 0 || length(x[[1]]) == 0) {
    replacement
  } else {
    x
  }
}

replace_nulls_vec <- function(v) {
  v <- lapply(v, replace_x)

  if (all(is.na(v))) {
    warning("No responses for any inputs.")
    return(v)
  }

  replacement <- v[which(!is.na(v))][[1]][1, ]

  for (i in seq_along(replacement)) {
    replacement[, i] <- NA
  }

  v <- lapply(v, replace_x,
    replacement = replacement
  )

  return(v)
}


determine_texts_per_req <- function(length1, texts_per_req) {
  if (is.null(texts_per_req)) {
    if (length1 < 200) {
      texts_per_req <- length1
    } else {
      texts_per_req <- 200
    }
  } else if (!is.numeric(texts_per_req) || texts_per_req <= 0 || texts_per_req > length1) {
    stop("texts_per_req must be a whole positive number less than or equal to the number of texts.")
  } else if (texts_per_req > 200) {
    warning("Maximum 200 texts recommended per requests.")
    texts_per_req <- texts_per_req # Go ahead with the attempt to send more than 200 texts
  }
  return(texts_per_req)
}


get_request_orig <- function(input) {
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
}


test_texts <- function(input, action = "classify",
                       do_test_headers = TRUE, classifier_id = "cl_oFKL5wft",
                       extractor_id = "ex_isnnZRbS", ...) {
  stopifnot(action %in% c("classify", "extract"))

  if (action == "classify") {
    output <- monkey_classify(input, classifier_id = "cl_oFKL5wft", ...)
  } else if (action == "extract") {
    output <- monkey_extract(input, extractor_id = "ex_isnnZRbS", ...)
  }

  testthat::expect_is(output, "data.frame")

  if (do_test_headers == TRUE) {
    test_headers(output)
  }
  return(output)
}


test_headers <- function(df) {
  testthat::test_that("headers are a dataframe of > 0 rows", {
    testthat::expect_is(attr(df, "headers"), "data.frame")
    testthat::expect_gte(nrow(attr(df, "headers")), 1)
  })
}


# Current rates
# There is a maximum amount of requests per minute that you
# can make to the API depending on your plan: 20 for the Free plan,
# 60 for the Team plan and 120 for the Business plan.
# The API is limited to 5 concurrent requests per second.
monkeylearn_rates <- data.frame(
  plan = c("free", "team", "business", "custom"),
  req_min = c(20, 60, 120, 999)
)

monkeylearn_plan <- Sys.getenv("MONKEYLEARN_PLAN")
if (identical(monkeylearn_plan, "")) {
  message("Please indicate your Monkeylearn plan in the MONKEYLEARN_PLAN environment variable\n
          Now using 'free' by default") # nolint
  monkeylearn_plan <- "free"
}


if (!monkeylearn_plan %in% monkeylearn_rates$plan) {
  stop('Your MONKEYLEARN_PLAN should be either "free", "team", "business" or  "custom"')
}

if (monkeylearn_plan != "custom") {
  monkeylearn_rate <- monkeylearn_rates$req_min[monkeylearn_rates$plan == monkeylearn_plan]
} else {
  monkeylearn_rate <- Sys.getenv("MONKEYLEARN_RATE")
  if (identical(monkeylearn_rate, "")) {
    message("Please indicate your Monkeylearn rate in the MONKEYLEARN_RATE environment variable\n
            Now using 120 by default") # nolint
    monkeylearn_plan <- 120
  }
}


# rate limiting
monkey_post <- ratelimitr::limit_rate(
  httr::POST,
  ratelimitr::rate(n = 5, period = 1),
  ratelimitr::rate(n = monkeylearn_rate, period = 60)
)

#' Retrieve Monkeylearn API key
#'
#' @return An Monkeylearn API Key
#'
#' @details Looks in env var \code{MONKEYLEARN_KEY}
#'
#' @keywords internal
#' @export
monkeylearn_key <- function(quiet = TRUE) {
  pat <- Sys.getenv("MONKEYLEARN_KEY")
  if (identical(pat, "")) {
    return(NULL)
  }
  if (!quiet) {
    message("Using Monkeylearn API Key from envvar MONKEYLEARN_KEY")
  }
  return(pat)
}


#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
