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

## ---- message = FALSE----------------------------------------------------
library(monkeylearn)
library(magrittr)

text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
output <- monkey_extract(input = text,
                         extractor_id = "ex_isnnZRbS")
output
attr(output, "headers")

## ------------------------------------------------------------------------
text <- "A panel of Goldman Sachs employees spent a recent Tuesday night at the
Columbia University faculty club trying to convince a packed room of potential
recruits that Wall Street, not Silicon Valley, was the place to be for computer
scientists.\n\n The Goldman employees knew they had an uphill battle. They were
fighting against perceptions of Wall Street as boring and regulation-bound and
Silicon Valley as the promised land of flip-flops, beanbag chairs and million-dollar
stock options.\n\n Their argument to the room of technologically inclined students
was that Wall Street was where they could find far more challenging, diverse and,
yes, lucrative jobs working on some of the worlds most difficult technical problems."

output <- monkey_extract(text,
                        extractor_id = "ex_YCya9nrn",
                        params = list(max_keywords = 3))
output
output2 <- monkey_extract(text,
                          extractor_id = "ex_YCya9nrn",
                          params = list(max_keywords = 1))
output2
attr(output2, "headers")

## ---- message = FALSE----------------------------------------------------
text <- "A panel of Goldman Sachs employees spent a recent Tuesday night at the Columbia University faculty club trying to convince a packed room of potential recruits that Wall Street, not Silicon Valley, was the place to be for computer scientists.

The Goldman employees knew they had an uphill battle. They were fighting against perceptions of Wall Street as boring and regulation-bound and Silicon Valley as the promised land of flip-flops, beanbag chairs and million-dollar stock options.

Their argument to the room of technologically inclined students was that Wall Street was where they could find far more challenging, diverse and, yes, lucrative jobs working on some of the world?s most difficult technical problems.

?Whereas in other opportunities you might be considering, it is working one type of data or one type of application, we deal in hundreds of products in hundreds of markets, with thousands or tens of thousands of clients, every day, millions of times of day worldwide,? Afsheen Afshar, a managing director at Goldman Sachs, told the students."

monkey_extract(text, extractor_id = "ex_YCya9nrn")

## ---- message = FALSE----------------------------------------------------
text <- "Hi, my email is john@example.com and my credit card is 4242-4242-4242-4242 so you can charge me with $10. My phone number is 15555 9876. We can get in touch on April 16, at 10:00am"
text2 <- "Hi, my email is mary@example.com and my credit card is 4242-4232-4242-4242. My phone number is 16655 9876. We can get in touch on April 16, at 10:00am"

monkey_extract(c(text, text2), extractor_id = "ex_dqRio5sG", unnest = TRUE)

## ---- message = FALSE----------------------------------------------------
text1 <- "my dog is an avid rice eater"
text2 <- "i want to buy an iphone"
request <- c(text1, text2)

monkey_classify(request, classifier_id = "cl_sGdE8hD9")

## ------------------------------------------------------------------------
monkeylearn_classifiers(private = FALSE)

## ---- message = FALSE----------------------------------------------------
text1 <- "Haur?s de dirigir-te al punt de trobada del grup al que et vulguis unir."
text2 <- "i want to buy an iphone"
text3 <- "Je d?teste ne plus avoir de dentifrice."
request <- c(text1, text2, text3)

monkey_classify(request, classifier_id = "cl_oJNMkt2V")

## ---- message = FALSE----------------------------------------------------
text1 <- "I think this is awesome."
text2 <- "Holy shit! You did great!"
request <- c(text1, text2)

monkey_classify(request, classifier_id = "cl_KFXhoTdt")

## ---- message = FALSE----------------------------------------------------
text1 <- "Let me tell you about my dog and my cat. They are really friendly and like going on walks. They both like chasing mice."
text2 <- "My first R package was probably a disaster but I keep learning how to program."
request <- c(text1, text2)
monkey_classify(request, classifier_id = "cl_5icAVzKR")


## ----monkey_input--------------------------------------------------------
input <- c("Emma Woodhouse, handsome, clever, and rich, with a comfortable home",
 "and happy disposition, seemed to unite some of the best blessings of",
 "existence; and had lived nearly twenty-one years in the world with very",
 "little to distress or vex her.",
 "",                   # <--- note the empty string!
 "She was the youngest of the two daughters of a most affectionate,",
 "indulgent father; and had, in consequence of her sister's marriage, been",
 "mistress of his house from a very early period. Her mother had died",
 "too long ago for her to have more than an indistinct remembrance of",
 "her caresses; and her place had been supplied by an excellent woman as",
 "governess, who had fallen little short of a mother in affection.")

## ----monkey_output-------------------------------------------------------
(output <- monkey_classify(input, unnest = FALSE))

## ----very_empty_input----------------------------------------------------
(very_empty_input <- rep("", 25) %>% c(input) %>% sample())

## ------------------------------------------------------------------------
monkey_classify(very_empty_input, unnest = FALSE)

## ------------------------------------------------------------------------
output$res

## ----unnest_true---------------------------------------------------------
(output_unnested <- monkey_classify(input, verbose = FALSE, unnest = TRUE))

## ----compare_df----------------------------------------------------------
input_df <- tibble::tibble(text = input)
output_df_unnested <- monkey_classify(input_df, text, unnest = TRUE, verbose = FALSE) %>%
    dplyr::rename(req = text)

testthat::expect_equal(output_unnested, output_df_unnested)

## ----keep_all------------------------------------------------------------
sw <- dplyr::starwars %>%
  dplyr::select(name, height) %>%
  dplyr::sample_n(nrow(input_df))

sw_input_df <- input_df %>%
  dplyr::bind_cols(sw)

sw_input_df %>% monkey_classify(text, unnest = FALSE, verbose = FALSE)

## ----one_by_one, warning=FALSE-------------------------------------------
one_by_one <- system.time(output <- monkey_classify(input, texts_per_req = 1))

## ----batch_of_five, warning=FALSE----------------------------------------
batch_of_five <- system.time(output <- monkey_classify(input, texts_per_req = 5))

## ----speedup-------------------------------------------------------------
(speedup <- one_by_one[1] / batch_of_five[1])

