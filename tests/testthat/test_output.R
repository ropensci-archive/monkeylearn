context("test output")

test_that("monkeylearn_parse returns a list of two data.frames",{
  text1 <- "my dog is an avid rice eater"
  text2 <- "i want to buy an iphone"
  request <- c(text1, text2)
  output <- monkeylearn_classify(request,
                                 classifier_id = "cl_oFKL5wft")
  expect_is(output, "list")
  expect_is(output$results, "tbl_df")
  expect_is(output$headers, "tbl_df")

  text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
  output <- monkeylearn_extract(request = text,
                                extractor_id = "ex_isnnZRbS")
  expect_is(output, "list")
  expect_is(output$results, "tbl_df")
  expect_is(output$headers, "tbl_df")

  text <- "Hi, my email is john@example.com and my credit card is 4242-4242-4242-4242 so you can charge me with $10. My phone number is 15555 9876. We can get in touch on April 16, at 10:00am"
  text2 <- "Hi, my email is mary@example.com and my credit card is 4242-4232-4242-4242. My phone number is 16655 9876. We can get in touch on April 16, at 10:00am"
  output <- monkeylearn_extract(request = c(text, text2),
                                extractor_id = "ex_dqRio5sG")
  expect_is(output, "list")
  expect_is(output$results, "data.frame")
  expect_is(output$headers, "tbl_df")

  text1 <- "Hauràs de dirigir-te al punt de trobada del grup al que et vulguis unir."
  text2 <- "i want to buy an iphone"
  text3 <- "Je déteste ne plus avoir de dentifrice."
  request <- c(text1, text2, text3)
  output <- monkeylearn_classify(request,
                       classifier_id = "cl_oJNMkt2V")
  expect_is(output, "list")
  expect_is(output$results, "tbl_df")
  expect_is(output$headers, "tbl_df")
})
