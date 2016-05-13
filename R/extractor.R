#' monkeylearn_extract
#'
#' Access to Monkeylearn extractors modules
#'
#' @param request A vector of characters
#'
#' @param key The API key
#' @param extractor_id The ID of the extractor
#'
#' @importFrom jsonlite toJSON
#' @examples text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
#' output <- monkeylearn_extract(request = text)
#' output
#' @details Find IDs of extractors using \url{https://app.monkeylearn.com/main/explore}.
#' @return A list of two data.frames (dplyr tbl_df), one with the results, the other with headers including the number of remaining queries as "x.query.limit.remaining".
#' @export
monkeylearn_extract <- function(request, key = monkeylearn_key(quiet = TRUE),
                                extractor_id = "ex_isnnZRbS"){
  request <- monkeylearn_prep(request)
  output <- monkeylearn_get_extractor(request, key, extractor_id)
  monkeylearn_parse(output)
}

