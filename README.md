monkeylearn
===========

[![Build Status](https://travis-ci.org/masalmon/monkeylearn.svg?branch=master)](https://travis-ci.org/masalmon/monkeylearn) [![Build status](https://ci.appveyor.com/api/projects/status/a7bjnb5dpr8qrx58?svg=true)](https://ci.appveyor.com/project/masalmon/monkeylearn) [![codecov](https://codecov.io/gh/masalmon/monkeylearn/branch/master/graph/badge.svg)](https://codecov.io/gh/masalmon/monkeylearn)

UNDER DEVELOPMENT!!

This package is an interface to the [MonkeyLearn API](http://docs.monkeylearn.com/article/api-reference/). MonkeyLearn is a Machine Learning platform on the cloud that allows software companies and developers to easily extract actionable data from text.

The goal of the package is not to support machine learning algorithms development with R or the API, but only to reap the benefits of the existing modules on Monkeylearn. Therefore, there are only two functions, one for using extractors, and one for using classifiers.

To get an API key for MonkeyLearn, register at <http://monkeylearn.com/>. The free API key provides up to 100,000 requests a month For ease of use, save your API key as an environment variable as described at <http://stat545.com/bit003_api-key-env-var.html>.

Both functions of the package will conveniently look for your API key using `Sys.getenv("MONKEYLEARN_KEY")` so if your API key is an environment variable called "MONKEYLEARN\_KEY" you don't need to input it manually.

Installation
============

To install the package, you will need the `devtools` package.

``` r
devtools::install_github("masalmon/monkeylearn")
```

Classify
========

You can find classifiers and their IDs at <https://app.monkeylearn.com/main/explore>

``` r
library("monkeylearn")
text1 <- "my dog is an avid rice eater"
text2 <- "i want to buy an iphone"
request <- c(text1, text2)
monkeylearn_classify(request,
                     classifier_id = "cl_oFKL5wft")
```

    ## [1] "Processing request number 1 out of 1"

    ## $results
    ## Source: local data frame [6 x 4]
    ## 
    ##   category_id probability                      label  text
    ##         (int)       (dbl)                      (chr) (dbl)
    ## 1       65976       0.851                       Pets     1
    ## 2       66008       0.239                       Fish     1
    ## 3       66013       0.792                  Fish Food     1
    ## 4       67618       0.702                Cell Phones     2
    ## 5       67639       0.484              Family Mobile     2
    ## 6       67641       0.547 Family Mobile Starter Kits     2
    ## 
    ## $headers
    ## Source: local data frame [1 x 10]
    ## 
    ##           allow     content.type                          date      server
    ##          (fctr)           (fctr)                        (fctr)      (fctr)
    ## 1 POST, OPTIONS application/json Tue, 17 May 2016 12:58:56 GMT nginx/1.8.0
    ## Variables not shown: vary (fctr), x.query.limit.limit (fctr),
    ##   x.query.limit.remaining (fctr), x.query.limit.request.queries (fctr),
    ##   content.length (fctr), connection (fctr)

Extract
=======

A first example
---------------

``` r
text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
output <- monkeylearn_extract(request = text,
                              extractor_id = "ex_isnnZRbS")
```

    ## [1] "Processing request number 1 out of 1"

``` r
output
```

    ## $results
    ## Source: local data frame [7 x 4]
    ## 
    ##   count      tag            entity  text
    ##   (int)    (chr)             (chr) (dbl)
    ## 1     1 LOCATION            Europe     1
    ## 2     1 LOCATION           Prussia     1
    ## 3     1 LOCATION   Austria-Hungary     1
    ## 4     1 LOCATION           Austria     1
    ## 5     1 LOCATION           Germany     1
    ## 6     1   PERSON Otto von Bismarck     1
    ## 7     2 LOCATION            Russia     1
    ## 
    ## $headers
    ## Source: local data frame [1 x 10]
    ## 
    ##           allow     content.type                          date      server
    ##          (fctr)           (fctr)                        (fctr)      (fctr)
    ## 1 POST, OPTIONS application/json Tue, 17 May 2016 12:52:55 GMT nginx/1.8.0
    ## Variables not shown: vary (fctr), x.query.limit.limit (fctr),
    ##   x.query.limit.remaining (fctr), x.query.limit.request.queries (fctr),
    ##   content.length (fctr), connection (fctr)

How to find extractors?
-----------------------

You can find extractors and their IDs, including extractors for text in Spanish, at <https://app.monkeylearn.com/main/explore> Here are a few ones for text in English:

-   [Entity extractor](https://app.monkeylearn.com/extraction/extractors/ex_isnnZRbS/tab/description-tab), `extractor_id = "ex_isnnZRbS"` (used in the first example). Extract Entities from text using Named Entity Recognition (NER). NER labels sequences of words in a text which are the names of things, such as person and company names. This implementation labels 3 classes: PERSON, ORGANIZATION and LOCATION. This NER tagger is implemented using Conditional Random Field (CRF) sequence models and is trained over a huge amount of data.

-   [Keyword extractor](https://app.monkeylearn.com/extraction/extractors/ex_y7BPYzNG/tab/description-tab), `extractor_id = "ex_y7BPYzNG"`. Extract keywords from text in English. Keywords can be compounded by one or more words and are defined as the important topics in your content and can be used to index data, generate tag clouds or for searching. This keyword extraction algorithm employs statistical algorithms and natural language processing technology to analyze your content and identify the relevant keywords.

``` r
text <- "A panel of Goldman Sachs employees spent a recent Tuesday night at the Columbia University faculty club trying to convince a packed room of potential recruits that Wall Street, not Silicon Valley, was the place to be for computer scientists.

The Goldman employees knew they had an uphill battle. They were fighting against perceptions of Wall Street as boring and regulation-bound and Silicon Valley as the promised land of flip-flops, beanbag chairs and million-dollar stock options.

Their argument to the room of technologically inclined students was that Wall Street was where they could find far more challenging, diverse and, yes, lucrative jobs working on some of the world’s most difficult technical problems.

“Whereas in other opportunities you might be considering, it is working one type of data or one type of application, we deal in hundreds of products in hundreds of markets, with thousands or tens of thousands of clients, every day, millions of times of day worldwide,” Afsheen Afshar, a managing director at Goldman Sachs, told the students."
output <- monkeylearn_extract(request = text,
                              extractor_id = "ex_y7BPYzNG")
```

    ## [1] "Processing request number 1 out of 1"

``` r
output
```

    ## $results
    ## Source: local data frame [10 x 5]
    ## 
    ##    relevance count positions_in_text                      keyword  text
    ##        (chr) (int)             (chr)                        (chr) (dbl)
    ## 1      0.978     3          <int[3]>                  Wall Street     1
    ## 2      0.652     2          <int[2]>               Silicon Valley     1
    ## 3      0.543     1          <int[1]> million-dollar stock options     1
    ## 4      0.543     1          <int[1]>      Goldman Sachs employees     1
    ## 5      0.543     1          <int[1]>      University faculty club     1
    ## 6      0.543     1          <int[1]>         recent Tuesday night     1
    ## 7      0.543     1          <int[1]> difficult technical problems     1
    ## 8      0.435     2          <int[2]>                    thousands     1
    ## 9      0.435     2          <int[2]>                         type     1
    ## 10     0.435     2          <int[2]>                     hundreds     1
    ## 
    ## $headers
    ## Source: local data frame [1 x 10]
    ## 
    ##           allow     content.type                          date      server
    ##          (fctr)           (fctr)                        (fctr)      (fctr)
    ## 1 POST, OPTIONS application/json Tue, 17 May 2016 12:58:56 GMT nginx/1.8.0
    ## Variables not shown: vary (fctr), x.query.limit.limit (fctr),
    ##   x.query.limit.remaining (fctr), x.query.limit.request.queries (fctr),
    ##   content.length (fctr), connection (fctr)

-   [Useful data extractor](https://app.monkeylearn.com/extraction/extractors/ex_dqRio5sG/tab/description-tab), `extractor_id = "ex_dqRio5sG"`. Extract useful data from text. This algorithm can be used to detect many different useful data: links, phones, ips, prices, times, emails, bitcoin addresses, dates, ipv6s, hex colors and credit cards.

When using this extractor, the format of the API output is a bit different than for other extractors, see below how the output looks like.

``` r
text <- "Hi, my email is john@example.com and my credit card is 4242-4242-4242-4242 so you can charge me with $10. My phone number is 15555 9876. We can get in touch on April 16, at 10:00am"
text2 <- "Hi, my email is mary@example.com and my credit card is 4242-4232-4242-4242. My phone number is 16655 9876. We can get in touch on April 16, at 10:00am"
output <- monkeylearn_extract(request = c(text, text2),
                              extractor_id = "ex_dqRio5sG")
```

    ## [1] "Processing request number 1 out of 1"

``` r
output
```

    ## $results
    ##         links     phones  ips prices   times           emails
    ## 1 example.com 15555 9876 NULL    $10 10:00am john@example.com
    ## 2 example.com 16655 9876 NULL        10:00am mary@example.com
    ##   bitcoin_addresses     dates ipv6s hex_colors        credit_cards text
    ## 1              NULL April 16,  NULL       NULL 4242-4242-4242-4242    1
    ## 2              NULL April 16,  NULL       NULL 4242-4232-4242-4242    2
    ## 
    ## $headers
    ## Source: local data frame [1 x 10]
    ## 
    ##           allow     content.type                          date      server
    ##          (fctr)           (fctr)                        (fctr)      (fctr)
    ## 1 POST, OPTIONS application/json Tue, 17 May 2016 12:52:55 GMT nginx/1.8.0
    ## Variables not shown: vary (fctr), x.query.limit.limit (fctr),
    ##   x.query.limit.remaining (fctr), x.query.limit.request.queries (fctr),
    ##   content.length (fctr), connection (fctr)
