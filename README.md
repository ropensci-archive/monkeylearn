monkeylearn
===========

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

    ## $results
    ## Source: local data frame [6 x 3]
    ## 
    ##   category_id probability                      label
    ##         (int)       (dbl)                      (chr)
    ## 1       65976       0.851                       Pets
    ## 2       66008       0.239                       Fish
    ## 3       66013       0.792                  Fish Food
    ## 4       67618       0.702                Cell Phones
    ## 5       67639       0.484              Family Mobile
    ## 6       67641       0.547 Family Mobile Starter Kits
    ## 
    ## $headers
    ## Source: local data frame [1 x 10]
    ## 
    ##           allow     content.type                          date      server
    ##          (fctr)           (fctr)                        (fctr)      (fctr)
    ## 1 POST, OPTIONS application/json Fri, 13 May 2016 11:39:25 GMT nginx/1.8.0
    ## Variables not shown: vary (fctr), x.query.limit.limit (fctr),
    ##   x.query.limit.remaining (fctr), x.query.limit.request.queries (fctr),
    ##   content.length (fctr), connection (fctr)

Extract
=======

You can find extractors and their IDs at <https://app.monkeylearn.com/main/explore>

``` r
text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
output <- monkeylearn_extract(request = text,
                              extractor_id = "ex_isnnZRbS")
output
```

    ## $results
    ## Source: local data frame [7 x 3]
    ## 
    ##   count      tag            entity
    ##   (int)    (chr)             (chr)
    ## 1     1 LOCATION            Europe
    ## 2     1 LOCATION           Prussia
    ## 3     1 LOCATION   Austria-Hungary
    ## 4     1 LOCATION           Austria
    ## 5     1 LOCATION           Germany
    ## 6     1   PERSON Otto von Bismarck
    ## 7     2 LOCATION            Russia
    ## 
    ## $headers
    ## Source: local data frame [1 x 10]
    ## 
    ##           allow     content.type                          date      server
    ##          (fctr)           (fctr)                        (fctr)      (fctr)
    ## 1 POST, OPTIONS application/json Fri, 13 May 2016 11:39:25 GMT nginx/1.8.0
    ## Variables not shown: vary (fctr), x.query.limit.limit (fctr),
    ##   x.query.limit.remaining (fctr), x.query.limit.request.queries (fctr),
    ##   content.length (fctr), connection (fctr)
