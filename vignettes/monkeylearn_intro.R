## ---- echo = FALSE, warning=FALSE, message=FALSE-------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

## ---- eval = FALSE-------------------------------------------------------
#  devtools::install_github("masalmon/monkeylearn")
#  

