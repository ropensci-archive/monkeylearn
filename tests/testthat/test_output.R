context("test output")

test_that("monkeylearn_parse returns a list of two data.frames",{
  text1 <- "my dog is an avid rice eater"
  text2 <- "i want to buy an iphone"
  request <- c(text1, text2)
  output <- monkeylearn_classify(request)
  expect_is(output, "list")
  expect_is(output$results, "tbl_df")
  expect_is(output$headers, "tbl_df")

  text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
  output <- monkeylearn_extract(request = text)
  expect_is(output, "list")
  expect_is(output$results, "tbl_df")
  expect_is(output$headers, "tbl_df")
})
