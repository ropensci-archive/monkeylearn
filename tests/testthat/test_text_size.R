context("check text size")
test_that("More than 20 texts creates an error",{
  expect_error(monkeylearn_classify(request = rep("lala", 40)),
               "The request should not contain more than 20 texts.")
})


test_that("A too long text creates an error",{
  expect_error(monkeylearn_classify(request = toString(rep("lala", 400000))),
               "Each text in the request should be smaller than 500 kb")
})

