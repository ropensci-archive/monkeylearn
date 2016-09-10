## ---- echo = FALSE, warning=FALSE, message=FALSE-------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
pat <- Sys.getenv("MONKEYLEARN_KEY")
IS_THERE_KEY <- (pat != "")
NOT_CRAN <- ifelse(IS_THERE_KEY, NOT_CRAN, FALSE)
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

