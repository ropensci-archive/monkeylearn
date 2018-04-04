# monkeylearn 0.2.0

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


# monkeylearn 0.1.3

* Better states the dependency on tibble, it is tibble >= 1.2.

* Better handles blank text in input, outputs an empty tibble and a warning if the request is only blank, and a message if only parts of the request are blank.


# monkeylearn 0.1.2

* Disables HTTP2 for now because of a bug for Windows users. Fix by Jeroen Ooms.

# monkeylearn 0.1.1

* Added a `NEWS.md` file to track changes to the package.



