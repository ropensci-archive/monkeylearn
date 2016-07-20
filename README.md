monkeylearn
===========

[![Build Status](https://travis-ci.org/masalmon/monkeylearn.svg?branch=master)](https://travis-ci.org/masalmon/monkeylearn) [![Build status](https://ci.appveyor.com/api/projects/status/a7bjnb5dpr8qrx58?svg=true)](https://ci.appveyor.com/project/masalmon/monkeylearn) [![codecov](https://codecov.io/gh/masalmon/monkeylearn/branch/master/graph/badge.svg)](https://codecov.io/gh/masalmon/monkeylearn)

UNDER DEVELOPMENT!! Feedback and suggestions and pull request welcome. This project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

This package is an interface to the [MonkeyLearn API](http://docs.monkeylearn.com/article/api-reference/). MonkeyLearn is a Machine Learning platform on the cloud that allows software companies and developers to easily extract actionable data from text.

The goal of the package is not to support machine learning algorithms development with R or the API, but only to *reap the benefits of the existing modules on Monkeylearn*. Therefore, there are only two functions, one for using *extractors*, and one for using *classifiers*. The difference between extractors and classifiers is that extractors output information about words, whereas classifiers output information about each text as a whole. Named entity recognition is an extraction task, whereas assigning a topic to a text is a classification task.

To get an API key for MonkeyLearn, register at <http://monkeylearn.com/>. Note that MonkeyLearn supports registration through GitHub, which makes the registration process really easy. The free API key provides up to 100,000 requests a month For ease of use, save your API key as an environment variable as described at <http://stat545.com/bit003_api-key-env-var.html>.

Both functions of the package will conveniently look for your API key using `Sys.getenv("MONKEYLEARN_KEY")` so if your API key is an environment variable called "MONKEYLEARN\_KEY" you don't need to input it manually.

Installation
============

To install the package, you will need the `devtools` package.

``` r
devtools::install_github("masalmon/monkeylearn")
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

    ## $results
    ## # A tibble: 7 x 4
    ##   count      tag            entity  text
    ## * <int>    <chr>             <chr> <dbl>
    ## 1     1 LOCATION            Europe     1
    ## 2     1 LOCATION           Prussia     1
    ## 3     1 LOCATION   Austria-Hungary     1
    ## 4     1 LOCATION           Austria     1
    ## 5     1 LOCATION           Germany     1
    ## 6     1   PERSON Otto von Bismarck     1
    ## 7     2 LOCATION            Russia     1
    ## 
    ## $headers
    ## # A tibble: 1 x 10
    ##           allow     content.type                          date      server
    ## *        <fctr>           <fctr>                        <fctr>      <fctr>
    ## 1 POST, OPTIONS application/json Wed, 20 Jul 2016 10:28:35 GMT nginx/1.8.0
    ## # ... with 6 more variables: vary <fctr>, x.query.limit.limit <fctr>,
    ## #   x.query.limit.remaining <fctr>, x.query.limit.request.queries <fctr>,
    ## #   content.length <fctr>, connection <fctr>

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

    ## $results
    ## # A tibble: 3 x 5
    ##   relevance count positions_in_text                      keyword  text
    ## *     <chr> <int>            <list>                        <chr> <dbl>
    ## 1     0.978     3         <int [3]>                  Wall Street     1
    ## 2     0.652     2         <int [2]>               Silicon Valley     1
    ## 3     0.543     0         <int [0]> million-dollar stock options     1
    ## 
    ## $headers
    ## # A tibble: 1 x 10
    ##           allow     content.type                          date      server
    ## *        <fctr>           <fctr>                        <fctr>      <fctr>
    ## 1 POST, OPTIONS application/json Wed, 20 Jul 2016 10:37:46 GMT nginx/1.8.0
    ## # ... with 6 more variables: vary <fctr>, x.query.limit.limit <fctr>,
    ## #   x.query.limit.remaining <fctr>, x.query.limit.request.queries <fctr>,
    ## #   content.length <fctr>, connection <fctr>

``` r
output2 <- monkeylearn_extract(text,
                              extractor_id = "ex_y7BPYzNG",
                              params = list(max_keywords = 1))
output2
```

    ## $results
    ## # A tibble: 1 x 5
    ##   relevance count positions_in_text     keyword  text
    ## *     <chr> <int>            <list>       <chr> <dbl>
    ## 1     0.978     3         <int [3]> Wall Street     1
    ## 
    ## $headers
    ## # A tibble: 1 x 10
    ##           allow     content.type                          date      server
    ## *        <fctr>           <fctr>                        <fctr>      <fctr>
    ## 1 POST, OPTIONS application/json Wed, 20 Jul 2016 10:28:36 GMT nginx/1.8.0
    ## # ... with 6 more variables: vary <fctr>, x.query.limit.limit <fctr>,
    ## #   x.query.limit.remaining <fctr>, x.query.limit.request.queries <fctr>,
    ## #   content.length <fctr>, connection <fctr>

How to find extractors?
-----------------------

You can find extractors and their IDs, including extractors for text in Spanish, at <https://app.monkeylearn.com/main/explore> Here are a few ones for text in English:

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

    ## $results
    ## # A tibble: 10 x 5
    ##    relevance count positions_in_text                      keyword  text
    ## *      <chr> <int>            <list>                        <chr> <dbl>
    ## 1      0.978     3         <int [3]>                  Wall Street     1
    ## 2      0.652     2         <int [2]>               Silicon Valley     1
    ## 3      0.543     1         <int [1]> million-dollar stock options     1
    ## 4      0.543     1         <int [1]>      Goldman Sachs employees     1
    ## 5      0.543     1         <int [1]>      University faculty club     1
    ## 6      0.543     1         <int [1]>         recent Tuesday night     1
    ## 7      0.543     1         <int [1]> difficult technical problems     1
    ## 8      0.435     2         <int [2]>                    thousands     1
    ## 9      0.435     2         <int [2]>                         type     1
    ## 10     0.435     2         <int [2]>                     hundreds     1
    ## 
    ## $headers
    ## # A tibble: 1 x 10
    ##           allow     content.type                          date      server
    ## *        <fctr>           <fctr>                        <fctr>      <fctr>
    ## 1 POST, OPTIONS application/json Wed, 20 Jul 2016 10:37:47 GMT nginx/1.8.0
    ## # ... with 6 more variables: vary <fctr>, x.query.limit.limit <fctr>,
    ## #   x.query.limit.remaining <fctr>, x.query.limit.request.queries <fctr>,
    ## #   content.length <fctr>, connection <fctr>

-   [Useful data extractor](https://app.monkeylearn.com/extraction/extractors/ex_dqRio5sG/tab/description-tab), `extractor_id = "ex_dqRio5sG"`. Extract useful data from text. This algorithm can be used to detect many different useful data: links, phones, ips, prices, times, emails, bitcoin addresses, dates, ipv6s, hex colors and credit cards.

When using this extractor, the format of the API output is a bit different than for other extractors, see below how the output looks like.

``` r
text <- "Hi, my email is john@example.com and my credit card is 4242-4242-4242-4242 so you can charge me with $10. My phone number is 15555 9876. We can get in touch on April 16, at 10:00am"
text2 <- "Hi, my email is mary@example.com and my credit card is 4242-4232-4242-4242. My phone number is 16655 9876. We can get in touch on April 16, at 10:00am"
output <- monkeylearn_extract(request = c(text, text2),
                              extractor_id = "ex_dqRio5sG")
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
    ## # A tibble: 1 x 10
    ##           allow     content.type                          date      server
    ## *        <fctr>           <fctr>                        <fctr>      <fctr>
    ## 1 POST, OPTIONS application/json Wed, 20 Jul 2016 10:28:36 GMT nginx/1.8.0
    ## # ... with 6 more variables: vary <fctr>, x.query.limit.limit <fctr>,
    ## #   x.query.limit.remaining <fctr>, x.query.limit.request.queries <fctr>,
    ## #   content.length <fctr>, connection <fctr>

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

    ## $results
    ## # A tibble: 6 x 4
    ##   category_id probability                      label  text
    ## *       <int>       <dbl>                      <chr> <dbl>
    ## 1       65976       0.851                       Pets     1
    ## 2       66008       0.239                       Fish     1
    ## 3       66013       0.792                  Fish Food     1
    ## 4       67618       0.702                Cell Phones     2
    ## 5       67639       0.484              Family Mobile     2
    ## 6       67641       0.547 Family Mobile Starter Kits     2
    ## 
    ## $headers
    ## # A tibble: 1 x 10
    ##           allow     content.type                          date      server
    ## *        <fctr>           <fctr>                        <fctr>      <fctr>
    ## 1 POST, OPTIONS application/json Wed, 20 Jul 2016 10:37:48 GMT nginx/1.8.0
    ## # ... with 6 more variables: vary <fctr>, x.query.limit.limit <fctr>,
    ## #   x.query.limit.remaining <fctr>, x.query.limit.request.queries <fctr>,
    ## #   content.length <fctr>, connection <fctr>

You can find classifiers and their IDs at <https://app.monkeylearn.com/main/explore> Here are a few examples:

-   [Language detection](https://app.monkeylearn.com/categorizer/projects/cl_oJNMkt2V/tab/main-tab), `classifier_id = "cl_oJNMkt2V"`. Detect language in text. New languages were added for a total of 48 different languages arranged in language families.

``` r
text1 <- "Hauràs de dirigir-te al punt de trobada del grup al que et vulguis unir."
text2 <- "i want to buy an iphone"
text3 <- "Je déteste ne plus avoir de dentifrice."
request <- c(text1, text2, text3)
monkeylearn_classify(request,
                     classifier_id = "cl_oJNMkt2V")
```

    ## $results
    ## # A tibble: 6 x 4
    ##   category_id probability      label  text
    ## *       <int>       <dbl>      <chr> <dbl>
    ## 1       64494       0.994     Italic     1
    ## 2       64495       0.993 Catalan-ca     1
    ## 3       64483       0.360   Germanic     2
    ## 4       64486       0.759 English-en     2
    ## 5       64494       0.562     Italic     3
    ## 6       64496       0.994  French-fr     3
    ## 
    ## $headers
    ## # A tibble: 1 x 10
    ##           allow     content.type                          date      server
    ## *        <fctr>           <fctr>                        <fctr>      <fctr>
    ## 1 POST, OPTIONS application/json Wed, 20 Jul 2016 10:28:38 GMT nginx/1.8.0
    ## # ... with 6 more variables: vary <fctr>, x.query.limit.limit <fctr>,
    ## #   x.query.limit.remaining <fctr>, x.query.limit.request.queries <fctr>,
    ## #   content.length <fctr>, connection <fctr>

-   [Profanity and abuse detection](https://app.monkeylearn.com/categorizer/projects/cl_KFXhoTdt/tab/main-tab), `classifier_id = "cl_KFXhoTdt"`.

``` r
text1 <- "I think this is awesome."
text2 <- "Holy shit! You did great!"
request <- c(text1, text2)
monkeylearn_classify(request,
                     classifier_id = "cl_KFXhoTdt")
```

    ## $results
    ## # A tibble: 2 x 4
    ##   category_id probability     label  text
    ## *       <int>       <dbl>     <chr> <dbl>
    ## 1      103768       0.827     clean     1
    ## 2      103767       1.000 profanity     2
    ## 
    ## $headers
    ## # A tibble: 1 x 10
    ##           allow     content.type                          date      server
    ## *        <fctr>           <fctr>                        <fctr>      <fctr>
    ## 1 POST, OPTIONS application/json Wed, 20 Jul 2016 10:37:49 GMT nginx/1.8.0
    ## # ... with 6 more variables: vary <fctr>, x.query.limit.limit <fctr>,
    ## #   x.query.limit.remaining <fctr>, x.query.limit.request.queries <fctr>,
    ## #   content.length <fctr>, connection <fctr>

-   [General topic classifier](https://app.monkeylearn.com/categorizer/projects/cl_5icAVzKR/tab/), `classifier_id = "cl_5icAVzKR"`.

``` r
text1 <- "Let me tell you about my dog and my cat. They are really friendly and like going on walks. They both like chasing mice."
text2 <- "My first R package was probably a disaster but I keep learning how to program."
request <- c(text1, text2)
monkeylearn_classify(request,
                     classifier_id = "cl_5icAVzKR")
```

    ## $results
    ## # A tibble: 5 x 4
    ##   category_id probability                label  text
    ## *       <int>       <dbl>                <chr> <dbl>
    ## 1       64600       0.894              Animals     1
    ## 2       64608       0.649              Mammals     1
    ## 3       64611       0.869         Land Mammals     1
    ## 4       64638       0.240 Computers & Internet     2
    ## 5       64640       0.252             Internet     2
    ## 
    ## $headers
    ## # A tibble: 1 x 10
    ##           allow     content.type                          date      server
    ## *        <fctr>           <fctr>                        <fctr>      <fctr>
    ## 1 POST, OPTIONS application/json Wed, 20 Jul 2016 10:28:39 GMT nginx/1.8.0
    ## # ... with 6 more variables: vary <fctr>, x.query.limit.limit <fctr>,
    ## #   x.query.limit.remaining <fctr>, x.query.limit.request.queries <fctr>,
    ## #   content.length <fctr>, connection <fctr>
