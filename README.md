-   [monkeylearn](#monkeylearn)
-   [Installation](#installation)
-   [Extract](#extract)
    -   [A first example](#a-first-example)
    -   [Parameters](#parameters)
    -   [How to find extractors?](#how-to-find-extractors)
-   [Classify](#classify)
    -   [A first example](#a-first-example-1)
    -   [How to find classifiers?](#how-to-find-classifiers)
-   [Check the number of remaining calls](#check-the-number-of-remaining-calls)
-   [Meta](#meta)

monkeylearn
===========

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/monkeylearn)](http://cran.r-project.org/package=monkeylearn) [![Build Status](https://travis-ci.org/ropenscilabs/monkeylearn.svg?branch=master)](https://travis-ci.org/ropenscilabs/monkeylearn) [![Build status](https://ci.appveyor.com/api/projects/status/m4to8epnyd8y34rq?svg=true)](https://ci.appveyor.com/project/ropenscilabs/monkeylearn) [![codecov](https://codecov.io/gh/ropenscilabs/monkeylearn/branch/master/graph/badge.svg)](https://codecov.io/gh/ropenscilabs/monkeylearn)

This package is an interface to the [MonkeyLearn API](http://docs.monkeylearn.com/article/api-reference/). MonkeyLearn is a Machine Learning platform on the cloud that allows software companies and developers to easily extract actionable data from text.

The goal of the package is not to support machine learning algorithms development with R or the API, but only to *reap the benefits of the existing modules on Monkeylearn*. Therefore, there are only two functions, one for using *extractors*, and one for using *classifiers*. The difference between extractors and classifiers is that extractors output information about words, whereas classifiers output information about each text as a whole. Named entity recognition is an extraction task, whereas assigning a topic to a text is a classification task.

To get an API key for MonkeyLearn, register at <http://monkeylearn.com/>. Note that MonkeyLearn supports registration through GitHub, which makes the registration process really easy. The free API key provides up to 100,000 requests a month For ease of use, save your API key as an environment variable as described at <http://stat545.com/bit003_api-key-env-var.html>.

Both functions of the package will conveniently look for your API key using `Sys.getenv("MONKEYLEARN_KEY")` so if your API key is an environment variable called "MONKEYLEARN\_KEY" you don't need to input it manually.

You can see an example of the package in action in this blog post ["Analyzing \#first7jobs tweets with MonkeyLearn and R"](https://blog.monkeylearn.com/analyzing-first7jobs-tweets-monkeylearn-r/).

Installation
============

Install the package with this command:

``` r
install.packages("monkeylearn")
```

Or install the development version using [devtools](https://github.com/hadley/devtools):

``` r
devtools::install_github("ropenscilabs/monkeylearn")
```

Extract
=======

A first example
---------------

``` r
library("monkeylearn")
text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
output <- monkeylearn_extract(request = text,
                              extractor_id = "ex_isnnZRbS")
output
```

    ##   count      tag            entity                         text_md5
    ## 1     1 LOCATION            Europe 95132b831aa7a4ba1a666b93490b3c9c
    ## 2     1 LOCATION           Prussia 95132b831aa7a4ba1a666b93490b3c9c
    ## 3     1 LOCATION   Austria-Hungary 95132b831aa7a4ba1a666b93490b3c9c
    ## 4     1 LOCATION           Austria 95132b831aa7a4ba1a666b93490b3c9c
    ## 5     1 LOCATION           Germany 95132b831aa7a4ba1a666b93490b3c9c
    ## 6     1   PERSON Otto von Bismarck 95132b831aa7a4ba1a666b93490b3c9c
    ## 7     2 LOCATION            Russia 95132b831aa7a4ba1a666b93490b3c9c

``` r
attr(output, "headers")
```

    ## # A tibble: 1 x 11
    ##           allow     content.type                          date
    ##          <fctr>           <fctr>                        <fctr>
    ## 1 POST, OPTIONS application/json Sun, 11 Sep 2016 07:31:23 GMT
    ## # ... with 8 more variables: server <fctr>, vary <fctr>,
    ## #   x.query.limit.limit <fctr>, x.query.limit.remaining <fctr>,
    ## #   x.query.limit.request.queries <fctr>, content.length <fctr>,
    ## #   connection <fctr>, text_md5 <list>

Parameters
----------

If the documentation of the extractor you use states it has parameters, you can pass them as a named list, see below.

``` r
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
```

    ##   relevance count positions_in_text                      keyword
    ## 1     0.978     3     164, 341, 568                  Wall Street
    ## 2     0.652     2          181, 389               Silicon Valley
    ## 3     0.543     0                   million-dollar stock options
    ##                           text_md5
    ## 1 c52e4d898bf4009ba347820c86275973
    ## 2 c52e4d898bf4009ba347820c86275973
    ## 3 c52e4d898bf4009ba347820c86275973

``` r
output2 <- monkeylearn_extract(text,
                              extractor_id = "ex_y7BPYzNG",
                              params = list(max_keywords = 1))
output2
```

    ##   relevance count positions_in_text     keyword
    ## 1     0.978     3     164, 341, 568 Wall Street
    ##                           text_md5
    ## 1 c52e4d898bf4009ba347820c86275973

``` r
attr(output2, "headers")
```

    ## # A tibble: 1 x 11
    ##           allow     content.type                          date
    ##          <fctr>           <fctr>                        <fctr>
    ## 1 POST, OPTIONS application/json Sun, 11 Sep 2016 07:31:26 GMT
    ## # ... with 8 more variables: server <fctr>, vary <fctr>,
    ## #   x.query.limit.limit <fctr>, x.query.limit.remaining <fctr>,
    ## #   x.query.limit.request.queries <fctr>, content.length <fctr>,
    ## #   connection <fctr>, text_md5 <list>

How to find extractors?
-----------------------

You can find extractors and their IDs, including extractors for text in Spanish, at <https://app.monkeylearn.com/main/explore>

There is no endpoint for automatically finding all extractors, but if you find one in the website you particularly like and use a lot in your language and application, you could choose to save its id as an environment variable as explained [here](http://stat545.com/bit003_api-key-env-var.html). Reading about extractors on the website will give you a good overview of their characteristics and original application.

Here are a few ones for text in English:

-   [Entity extractor](https://app.monkeylearn.com/extraction/extractors/ex_isnnZRbS/tab/description-tab), `extractor_id = "ex_isnnZRbS"` (used in the first example). Extract Entities from text using Named Entity Recognition (NER). NER labels sequences of words in a text which are the names of things, such as person and company names. This implementation labels 3 classes: PERSON, ORGANIZATION and LOCATION. This NER tagger is implemented using Conditional Random Field (CRF) sequence models.

-   [Keyword extractor](https://app.monkeylearn.com/extraction/extractors/ex_y7BPYzNG/tab/description-tab), `extractor_id = "ex_y7BPYzNG"`. Extract keywords from text in English. Keywords can be compounded by one or more words and are defined as the important topics in your content and can be used to index data, generate tag clouds or for searching. This keyword extraction algorithm employs statistical algorithms and natural language processing technology to analyze your content and identify the relevant keywords.

``` r
text <- "A panel of Goldman Sachs employees spent a recent Tuesday night at the Columbia University faculty club trying to convince a packed room of potential recruits that Wall Street, not Silicon Valley, was the place to be for computer scientists.

The Goldman employees knew they had an uphill battle. They were fighting against perceptions of Wall Street as boring and regulation-bound and Silicon Valley as the promised land of flip-flops, beanbag chairs and million-dollar stock options.

Their argument to the room of technologically inclined students was that Wall Street was where they could find far more challenging, diverse and, yes, lucrative jobs working on some of the world’s most difficult technical problems.

“Whereas in other opportunities you might be considering, it is working one type of data or one type of application, we deal in hundreds of products in hundreds of markets, with thousands or tens of thousands of clients, every day, millions of times of day worldwide,” Afsheen Afshar, a managing director at Goldman Sachs, told the students."
output <- monkeylearn_extract(request = text,
                              extractor_id = "ex_y7BPYzNG")
output
```

    ##    relevance count positions_in_text                      keyword
    ## 1      0.978     3     164, 339, 560                  Wall Street
    ## 2      0.652     2          181, 386               Silicon Valley
    ## 3      0.543     1               456 million-dollar stock options
    ## 4      0.543     1                11      Goldman Sachs employees
    ## 5      0.543     1                80      University faculty club
    ## 6      0.543     1                43         recent Tuesday night
    ## 7      0.543     1               689 difficult technical problems
    ## 8      0.435     2          898, 919                    thousands
    ## 9      0.435     2          796, 816                         type
    ## 10     0.435     2          848, 872                     hundreds
    ##                            text_md5
    ## 1  92e785ec2d96e130be99085a3de2025d
    ## 2  92e785ec2d96e130be99085a3de2025d
    ## 3  92e785ec2d96e130be99085a3de2025d
    ## 4  92e785ec2d96e130be99085a3de2025d
    ## 5  92e785ec2d96e130be99085a3de2025d
    ## 6  92e785ec2d96e130be99085a3de2025d
    ## 7  92e785ec2d96e130be99085a3de2025d
    ## 8  92e785ec2d96e130be99085a3de2025d
    ## 9  92e785ec2d96e130be99085a3de2025d
    ## 10 92e785ec2d96e130be99085a3de2025d

-   [Useful data extractor](https://app.monkeylearn.com/extraction/extractors/ex_dqRio5sG/tab/description-tab), `extractor_id = "ex_dqRio5sG"`. Extract useful data from text. This algorithm can be used to detect many different useful data: links, phones, ips, prices, times, emails, bitcoin addresses, dates, ipv6s, hex colors and credit cards.

When using this extractor, the format of the API output is a bit different than for other extractors, see below how the output looks like.

``` r
text <- "Hi, my email is john@example.com and my credit card is 4242-4242-4242-4242 so you can charge me with $10. My phone number is 15555 9876. We can get in touch on April 16, at 10:00am"
text2 <- "Hi, my email is mary@example.com and my credit card is 4242-4232-4242-4242. My phone number is 16655 9876. We can get in touch on April 16, at 10:00am"
output <- monkeylearn_extract(request = c(text, text2),
                              extractor_id = "ex_dqRio5sG")
output
```

    ##         links     phones  ips prices   times           emails
    ## 1 example.com 15555 9876 NULL    $10 10:00am john@example.com
    ## 2 example.com 16655 9876 NULL        10:00am mary@example.com
    ##   bitcoin_addresses     dates ipv6s hex_colors        credit_cards
    ## 1              NULL April 16,  NULL       NULL 4242-4242-4242-4242
    ## 2              NULL April 16,  NULL       NULL 4242-4232-4242-4242
    ##                           text_md5
    ## 1 8c2b65bfca064616356c6a2cae2f5519
    ## 2 c97eba30f94868ba6b7c3d250f59133a

Classify
========

A first example
---------------

``` r
text1 <- "my dog is an avid rice eater"
text2 <- "i want to buy an iphone"
request <- c(text1, text2)
monkeylearn_classify(request,
                     classifier_id = "cl_oFKL5wft")
```

    ## # A tibble: 6 x 4
    ##   category_id probability                      label
    ## *       <int>       <dbl>                      <chr>
    ## 1       65976       0.851                       Pets
    ## 2       66008       0.239                       Fish
    ## 3       66013       0.792                  Fish Food
    ## 4       67618       0.702                Cell Phones
    ## 5       67639       0.484              Family Mobile
    ## 6       67641       0.547 Family Mobile Starter Kits
    ## # ... with 1 more variables: text_md5 <chr>

How to find classifiers?
------------------------

You can find classifiers and their IDs at <https://app.monkeylearn.com/main/explore> or you can use the `monkeylearn_classifiers` function, choosing to show all classifiers or only the private ones with `private = TRUE`. The first column of the resulting data.frame is the `classifier_id` to be used in `monkeylearn_classify`.

``` r
monkeylearn_classifiers(private = FALSE)
```

    ## # A tibble: 152 x 19
    ##    classifier_id                                                   name
    ##            <chr>                                                  <chr>
    ## 1    cl_cq6e5oEq Tweets - Offensive and hate speech detection - English
    ## 2    cl_YygsUUkN                                        Founder Names 2
    ## 3    cl_UXdsVBzj           Smart Restaurant Reviews Sentiments Analysis
    ## 4    cl_bwxdJMHE                                               Spam Ham
    ## 5    cl_xG46wHyZ                                     Good News (German)
    ## 6    cl_2MXugh99                             GMS-Hotel-Reviews-Analysis
    ## 7    cl_mEcCuEcG                                     Emotions in Tweets
    ## 8    cl_MUsRyHwV        Bownty - EN NATIONAL category classifier (v2.1)
    ## 9    cl_5pzHfLSv           Bownty - EN LOCAL category classifier (v2.1)
    ## 10   cl_ZRfE9AUu                               Settore comunale dal PEG
    ## # ... with 142 more rows, and 17 more variables: description <chr>,
    ## #   train_state <chr>, train_job_id <lgl>, language <chr>,
    ## #   ngram_range <chr>, use_stemmer <lgl>, stop_words <chr>,
    ## #   max_features <int>, strip_stopwords <lgl>, is_multilabel <lgl>,
    ## #   is_twitter_data <lgl>, normalize_weights <lgl>, classifier <chr>,
    ## #   industry <chr>, classifier_type <chr>, text_type <chr>,
    ## #   permissions <chr>

For instance, for doing sentiment analysis in French, one could extract all classifiers and then look at classifiers containing the word "sentiment" in their name and "fr" as language.

``` r
classifiers <- monkeylearn_classifiers(private = FALSE)

classifiers_sentiment_french <- classifiers[!is.na(classifiers$name),]

classifiers_sentiment_french <- classifiers_sentiment_french[!is.na(classifiers_sentiment_french$language),]

classifiers_sentiment_french <- classifiers_sentiment_french[grepl("[Ss]entiment", classifiers_sentiment_french$name)& classifiers_sentiment_french$language == "fr",]

classifiers_sentiment_french
```

    ## # A tibble: 2 x 19
    ##   classifier_id                                         name
    ##           <chr>                                        <chr>
    ## 1   cl_UXdsVBzj Smart Restaurant Reviews Sentiments Analysis
    ## 2   cl_36FHzFrP                          Sentiment - general
    ## # ... with 17 more variables: description <chr>, train_state <chr>,
    ## #   train_job_id <lgl>, language <chr>, ngram_range <chr>,
    ## #   use_stemmer <lgl>, stop_words <chr>, max_features <int>,
    ## #   strip_stopwords <lgl>, is_multilabel <lgl>, is_twitter_data <lgl>,
    ## #   normalize_weights <lgl>, classifier <chr>, industry <chr>,
    ## #   classifier_type <chr>, text_type <chr>, permissions <chr>

Let's use the general one to perform sentiment analysis.

``` r
classifier_id <- classifiers_sentiment_french$classifier_id[classifiers_sentiment_french$name == "Sentiment - general"]
classifier_id
```

    ## [1] "cl_36FHzFrP"

``` r
text1 <- "Nous avons fait un magnifique voyage et parlé avec des personnes adorables."
text2 <- "Je déteste ne plus avoir de dentifrice."
text3 <- "Je pense que cette personne est exécrable et mesquine, je suis en colère."
request <- c(text1, text2, text3)
monkeylearn_classify(request,
                     classifier_id = classifier_id)
```

    ## # A tibble: 3 x 4
    ##   category_id probability label                         text_md5
    ## *       <int>       <dbl> <chr>                            <chr>
    ## 1      399772       0.898   pos 4be183aca0c66a62dcb5ee245c2d1597
    ## 2      399771       0.685   neg 7543a88ecc9cc8d4dd8d515cc25f196c
    ## 3      399771       0.572   neg aa9fde0e6eafcc5c5745611d1f19deb5

Here are a few other examples:

-   [Language detection](https://app.monkeylearn.com/categorizer/projects/cl_oJNMkt2V/tab/main-tab), `classifier_id = "cl_oJNMkt2V"`. Detect language in text. New languages were added for a total of 48 different languages arranged in language families.

``` r
text1 <- "Hauràs de dirigir-te al punt de trobada del grup al que et vulguis unir."
text2 <- "i want to buy an iphone"
text3 <- "Je déteste ne plus avoir de dentifrice."
request <- c(text1, text2, text3)
monkeylearn_classify(request,
                     classifier_id = "cl_oJNMkt2V")
```

    ## # A tibble: 6 x 4
    ##   category_id probability      label                         text_md5
    ## *       <int>       <dbl>      <chr>                            <chr>
    ## 1       64494       0.994     Italic ec3fd6de86b1f2044c7bf7fb47831197
    ## 2       64495       0.993 Catalan-ca ec3fd6de86b1f2044c7bf7fb47831197
    ## 3       64483       0.360   Germanic af5c621a49a008f6e6a0d5ad47f2e1f4
    ## 4       64486       0.759 English-en af5c621a49a008f6e6a0d5ad47f2e1f4
    ## 5       64494       0.562     Italic 7543a88ecc9cc8d4dd8d515cc25f196c
    ## 6       64496       0.994  French-fr 7543a88ecc9cc8d4dd8d515cc25f196c

-   [Profanity and abuse detection](https://app.monkeylearn.com/categorizer/projects/cl_KFXhoTdt/tab/main-tab), `classifier_id = "cl_KFXhoTdt"`.

``` r
text1 <- "I think this is awesome."
text2 <- "Holy shit! You did great!"
request <- c(text1, text2)
monkeylearn_classify(request,
                     classifier_id = "cl_KFXhoTdt")
```

    ## # A tibble: 2 x 4
    ##   category_id probability     label                         text_md5
    ## *       <int>       <dbl>     <chr>                            <chr>
    ## 1      103768       0.827     clean 641e443d9485034d30fec6c36d67d4cd
    ## 2      103767       1.000 profanity 2b9e3eb08b256277e4c2b3dfcc8d5c75

-   [General topic classifier](https://app.monkeylearn.com/categorizer/projects/cl_5icAVzKR/tab/), `classifier_id = "cl_5icAVzKR"`.

``` r
text1 <- "Let me tell you about my dog and my cat. They are really friendly and like going on walks. They both like chasing mice."
text2 <- "My first R package was probably a disaster but I keep learning how to program."
request <- c(text1, text2)
monkeylearn_classify(request,
                     classifier_id = "cl_5icAVzKR")
```

    ## # A tibble: 5 x 4
    ##   category_id probability                label
    ## *       <int>       <dbl>                <chr>
    ## 1       64600       0.894              Animals
    ## 2       64608       0.649              Mammals
    ## 3       64611       0.869         Land Mammals
    ## 4       64638       0.240 Computers & Internet
    ## 5       64640       0.252             Internet
    ## # ... with 1 more variables: text_md5 <chr>

Check the number of remaining calls
===================================

After each call to a function you can check how many calls to the API you can still make using `attr(output, "headers")$x.query.limit.remaining` and `attr(output, "headers")$x.query.limit.limit`. The period after which `attr(output, "headers")$x.query.limit.remaining` depends on your subscription and is not included in the output.

Meta
====

-   Please [report any issues or bugs](https://github.com/ropenscilabs/monkeylearn/issues).
-   License: GPL
-   Get citation information for `opencage` in R doing `citation(package = 'monkeylearn')`
-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci\_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
