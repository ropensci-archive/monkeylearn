monkeylearn
===========

UNDER DEVELOPMENT!!

This package is an interface to the [MonkeyLearn API](http://docs.monkeylearn.com/article/api-reference/). MonkeyLearn is a Machine Learning platform on the cloud that allows software companies and developers to easily extract actionable data from text.

What it does for now
====================

Nearly nothing, but here is an example.

``` r
library("monkeylearn")
text1 <- "lions are very big animals"
text2 <- "i want to buy an iphone"
request <- c(text1, text2)
output <- monkeylearn_classify(request)
output
```

    ## $results
    ##   category_id probability                label
    ## 1       64600       0.742              Animals
    ## 2       64608       0.259              Mammals
    ## 3       64611       0.551         Land Mammals
    ## 4       64644       0.661 Consumer Electronics
    ## 5       64646       0.794       Mobile Devices
    ## 
    ## $headers
    ##           allow     content.type                          date      server
    ## 1 POST, OPTIONS application/json Thu, 12 May 2016 16:03:08 GMT nginx/1.8.0
    ##             vary x.query.limit.limit x.query.limit.remaining
    ## 1 Accept, Cookie              100000                   99986
    ##   x.query.limit.request.queries content.length connection
    ## 1                             2            371 keep-alive
