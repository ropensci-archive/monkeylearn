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

## ------------------------------------------------------------------------
library("monkeylearn")
library("gutenbergr")
library("dplyr")

little_women <- gutenberg_download(c(514),
                                 meta_fields = "title")



## ------------------------------------------------------------------------

library("tidytext")
little_women <- little_women %>%
  unnest_tokens(paragraph, text, token = "paragraphs") %>%
  summarize(whole_text = paste(paragraph, collapse = " "))

chapters <- strsplit( little_women$whole_text, "[Cc]hapter")[[1]]

little_women_chapters <- tibble::tibble(
  chapter = 1:length(chapters),
  text = chapters
)

all(nchar(little_women_chapters$text, type = "bytes") < 50000)


## ------------------------------------------------------------------------

entities <- monkeylearn_extract(request = little_women_chapters$text,
                              extractor_id = "ex_isnnZRbS",
                              verbose = TRUE)
entities %>%
 group_by(entity, tag) %>%
 summarize(n_occurences = n()) %>%
  arrange(desc(n_occurences)) %>%
  filter(n_occurences > 5) %>%
  knitr::kable()

## ------------------------------------------------------------------------

keywords <- monkeylearn_extract(request = little_women_chapters$text,
                                extractor_id = "ex_y7BPYzNG",
                                params = list(max_keywords = 3))
keywords %>%
  group_by(keyword) %>%
  summarize(n_occurences = sum(count)) %>%
  arrange(desc(n_occurences)) %>%
  filter(n_occurences > 10) %>%
  knitr::kable()

## ---- message = FALSE----------------------------------------------------

topics <- monkeylearn_classify(little_women_chapters$text,
                     classifier_id = "cl_5icAVzKR")
topics %>%
  group_by(label) %>%
  summarize(n_occurences = n()) %>%
  filter(n_occurences > 1) %>%
  arrange(desc(n_occurences)) %>%
  knitr::kable()


