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

## ---- eval = FALSE-------------------------------------------------------
#  devtools::install_github("ropenscilabs/monkeylearn")
#  

## ---- message = FALSE----------------------------------------------------
library("monkeylearn")
text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
output <- monkeylearn_extract(request = text,
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
   yes, lucrative jobs working on some of the worlds most difficult technical problems.\n\n
   Whereas in other opportunities you might be considering, it is working one type of data
   or one type of application, we deal in hundreds of products in hundreds of markets, with
    thousands or tens of thousands of clients, every day, millions of times of day worldwide,
     Afsheen Afshar, a managing director at Goldman Sachs, told the students."
output <- monkeylearn_extract(text,
                              extractor_id = "ex_y7BPYzNG",
                              params = list(max_keywords = 3))
output
output2 <- monkeylearn_extract(text,
                              extractor_id = "ex_y7BPYzNG",
                              params = list(max_keywords = 1))
output2
attr(output2, "headers")

## ---- message = FALSE----------------------------------------------------
text <- "A panel of Goldman Sachs employees spent a recent Tuesday night at the Columbia University faculty club trying to convince a packed room of potential recruits that Wall Street, not Silicon Valley, was the place to be for computer scientists.

The Goldman employees knew they had an uphill battle. They were fighting against perceptions of Wall Street as boring and regulation-bound and Silicon Valley as the promised land of flip-flops, beanbag chairs and million-dollar stock options.

Their argument to the room of technologically inclined students was that Wall Street was where they could find far more challenging, diverse and, yes, lucrative jobs working on some of the world’s most difficult technical problems.

“Whereas in other opportunities you might be considering, it is working one type of data or one type of application, we deal in hundreds of products in hundreds of markets, with thousands or tens of thousands of clients, every day, millions of times of day worldwide,” Afsheen Afshar, a managing director at Goldman Sachs, told the students."
output <- monkeylearn_extract(request = text,
                              extractor_id = "ex_y7BPYzNG")
output


## ---- message = FALSE----------------------------------------------------
text <- "Hi, my email is john@example.com and my credit card is 4242-4242-4242-4242 so you can charge me with $10. My phone number is 15555 9876. We can get in touch on April 16, at 10:00am"
text2 <- "Hi, my email is mary@example.com and my credit card is 4242-4232-4242-4242. My phone number is 16655 9876. We can get in touch on April 16, at 10:00am"
output <- monkeylearn_extract(request = c(text, text2),
                              extractor_id = "ex_dqRio5sG")
output


## ---- message = FALSE----------------------------------------------------
text1 <- "my dog is an avid rice eater"
text2 <- "i want to buy an iphone"
request <- c(text1, text2)
monkeylearn_classify(request,
                     classifier_id = "cl_oFKL5wft")


## ------------------------------------------------------------------------

monkeylearn_classifiers(private = FALSE)


## ------------------------------------------------------------------------

classifiers <- monkeylearn_classifiers(private = FALSE)
classifiers_sentiment_french <- dplyr::filter(classifiers,
                                              grepl("[Ss]entiment", name), language == "fr")


## ------------------------------------------------------------------------
classifier_id <- classifiers_sentiment_french$classifier_id
classifier_id

text1 <- "Nous avons fait un magnifique voyage et parlé avec des personnes adorables."
text2 <- "Je déteste ne plus avoir de dentifrice."
text3 <- "Je pense que cette personne est exécrable et mesquine, je suis en colère."
request <- c(text1, text2, text3)
monkeylearn_classify(request,
                     classifier_id = classifier_id)

## ---- message = FALSE----------------------------------------------------
text1 <- "Hauràs de dirigir-te al punt de trobada del grup al que et vulguis unir."
text2 <- "i want to buy an iphone"
text3 <- "Je déteste ne plus avoir de dentifrice."
request <- c(text1, text2, text3)
monkeylearn_classify(request,
                     classifier_id = "cl_oJNMkt2V")


## ---- message = FALSE----------------------------------------------------
text1 <- "I think this is awesome."
text2 <- "Holy shit! You did great!"
request <- c(text1, text2)
monkeylearn_classify(request,
                     classifier_id = "cl_KFXhoTdt")


## ---- message = FALSE----------------------------------------------------
text1 <- "Let me tell you about my dog and my cat. They are really friendly and like going on walks. They both like chasing mice."
text2 <- "My first R package was probably a disaster but I keep learning how to program."
request <- c(text1, text2)
monkeylearn_classify(request,
                     classifier_id = "cl_5icAVzKR")


