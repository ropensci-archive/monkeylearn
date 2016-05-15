context("check text size")
test_that("A too long text creates an error",{
  expect_error(monkeylearn_classify(request = toString(rep("lala", 400000))),
               "Each text in the request should be smaller than 500 kb")
})

