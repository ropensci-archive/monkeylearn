## Test environments
* local x86_64-w64-mingw32/x64 install, R 3.3.1
* Ubuntu 12.04 (on Travis CI), R devel, release and oldrel
* Windows on Appveyor CI (stable, patched and oldrel)

## R CMD check results

0 errors | 0 warnings | 0 note

## Release summary


* New functions `monkey_classify()` and `monkey_extract()` that:
    * Accept as input both a vector and a dataframe and named column
    * Always return a tibble explicitly relating each input to its classification, allowing for the removal of the MD5 hash
    * Have an `unnest` flag to unnest the output (turn 1 row per input into 1 row per output)
    * Have a `.keep_all` flag to retain other columns if input is a dataframe
    * Coerce `NULL` values and empty vectors returned from MonkeyLearn to `NA`s
    * Include inputs that could not be processed as `NA`s in the output
    * Message the first 20 indices of inputs that are not sent to the API (these now include `NA` and `NULL` values as well as empty strings)
    * Message the currently processing batch

* Bug fixes and improvements to `monkeylearn_classify()` and `monkeylearn_extract()`
    * `monkeylearn_classify()` can now accept `params`
    * Fix to messaging when unable to connect to MonkeyLearn API
    * Default texts per request is set to 200 now (the recommended number), rather than 20
    * Addition of message suggesting that users switch to newer functions

* Implementation of `ratelimitr`. Creation and documentation of two environment variables allowing smarter rate handling when querying the MonkeyLearn API.

* Creation of `pkgdown` website

* Programmatic test coverage to re-use common tests for multiple circumstances.

* Use of a `cowsay` monkey when verbose=TRUE.


---
