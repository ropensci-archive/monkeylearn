#' Defunct functions in monkeylearn
#'
#' These functions are gone, no longer available.
#'
#' \itemize{
#'  \item \code{\link{monkeylearn_extract}}: Use monkey_extract() instead.
#'  \item \code{\link{monkeylearn_classify}}: Use monkey_classify() instead.
#' }
#'
#' @name monkeylearn-defunct

monkeylearn_extract <- function(...) {
  .Defunct("monkey_extract")
}

monkeylearn_classify <- function(...) {
  .Defunct("monkey_classify")
}
