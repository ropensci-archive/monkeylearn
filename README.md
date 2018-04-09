monkeylearn
===========

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/monkeylearn)](http://cran.r-project.org/package=monkeylearn) [![Build Status](https://travis-ci.org/ropensci/monkeylearn.svg?branch=master)](https://travis-ci.org/ropensci/monkeylearn) [![Build status](https://ci.appveyor.com/api/projects/status/m4to8epnyd8y34rq?svg=true)](https://ci.appveyor.com/project/ropensci/monkeylearn) [![codecov](https://codecov.io/gh/ropensci/monkeylearn/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/monkeylearn)
[![](https://badges.ropensci.org/45_status.svg)](https://github.com/ropensci/onboarding/issues/45)

This R package is an interface to the [MonkeyLearn API](http://docs.monkeylearn.com/article/api-reference/). MonkeyLearn is a Machine Learning platform on the cloud that allows software companies and developers to easily extract actionable data from text. :monkey:

The current goal of the package is not to support machine learning algorithms development with R or the API, but only to *reap the benefits of the existing modules on Monkeylearn*. Therefore, there are only two types of functions, one for using *extractors* (`monkey_extract` and the old less user-friendly `monkeylearn_extract`), and one for using *classifiers* (`monkey_classify` and the old less user-friendly `monkeylearn_classify`). The difference between extractors and classifiers is that extractors output information about words, whereas classifiers output information about each text as a whole. Named entity recognition is an extraction task, whereas assigning a topic to a text is a classification task.

# Installation and setup

To install the package, you will need the `devtools` package.

``` r
devtools::install_github("ropensci/monkeylearn")
```

To get an API key for MonkeyLearn, register at <http://monkeylearn.com/>. Note that MonkeyLearn supports registration through GitHub, which makes the registration process really easy. For ease of use, save your API key as an environment variable as described at <http://stat545.com/bit003_api-key-env-var.html>.

All functions of the package will conveniently look for your API key using `Sys.getenv("MONKEYLEARN_KEY")` so if your API key is an environment variable called "MONKEYLEARN\_KEY" you don't need to input it manually.

Please also create a "MONKEYLEARN\_PLAN" environment variable indicating whether your [Monkeylearn plan](https://app.monkeylearn.com/main/my-account/tab/change-plan/) is "free", "team" or "business".

# Documentation

Please refer to the [`pkgdown` website](http://ropensci.github.io/monkeylearn/) to read docs, in particular the [reference](http://ropensci.github.io/monkeylearn/reference/index.html) and the [vignettes](http://ropensci.github.io/monkeylearn/articles/index.html).

# External use cases

Submit your use cases by opening [a new issue](https://github.com/ropensci/monkeylearn/issues/new)!

## Using the newer set of functions `monkey_extract` and `monkey_classify`

* [@aedobbyn's](https://github.com/aedobbyn/) [Monkeys are like Onions](https://dobb.ae/2018/03/25/monkeys-are-like-onions/)

## Using the older set of functions `monkeylearn_extract` and `monkeylearn_classify`

* [@maelle's](https://github.com/maelle/) [Analyzing #first7jobs tweets with Monkeylearn and R](http://www.masalmon.eu/2016/10/02/first7jobs-repost/)

* [@maelle's](https://github.com/maelle/) [Which science is all around? #BillMeetScienceTwitter](http://www.masalmon.eu/2017/05/20/billnye/)

* [@maelle's](https://github.com/maelle/) [The Guardian Experience: heavy or light topics?](http://www.masalmon.eu/2017/10/02/guardian-experience/)

* [@maelle's](https://github.com/maelle/) [Names of b.....s badder than Taylor Swift, a class in women's studies?](http://www.masalmon.eu/2017/12/05/badderb/)

Meta
----

-   Please [report any issues or bugs](https://github.com/ropensci/monkeylearn/issues).
-   License: GPL
-   Get citation information for `opencage` in R doing `citation(package = 'monkeylearn')`
-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci\_footer](https://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
