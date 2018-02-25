context("test output")

test_that("monkeylearn_parse returns a data.frame with a data.frame as attribute",{
  text1 <- "my dog is an avid rice eater"
  text2 <- "i want to buy an iphone"
  request <- c(text1, text2)
  output <- monkeylearn_classify(request,
                                 classifier_id = "cl_oFKL5wft")

  expect_is(output, "data.frame")
  expect_is(attr(output, "headers"), "data.frame")
  expect_gte(nrow(attr(output, "headers")), 1)

  text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
  output <- monkeylearn_extract(request = text,
                                extractor_id = "ex_isnnZRbS")

  expect_is(output, "data.frame")
  expect_is(attr(output, "headers"), "data.frame")
  expect_gte(nrow(attr(output, "headers")), 1)

  text <- "Hi, my email is john@example.com and my credit card is 4242-4242-4242-4242 so you can charge me with $10. My phone number is 15555 9876. We can get in touch on April 16, at 10:00am"
  text2 <- "Hi, my email is mary@example.com and my credit card is 4242-4232-4242-4242. My phone number is 16655 9876. We can get in touch on April 16, at 10:00am"
  output <- monkeylearn_extract(request = c(text, text2),
                                extractor_id = "ex_dqRio5sG")

  expect_is(output, "data.frame")
  expect_is(attr(output, "headers"), "data.frame")
  expect_gte(nrow(attr(output, "headers")), 1)

  text1 <- "Hauràs de dirigir-te al punt de trobada del grup al que et vulguis unir."
  text2 <- "i want to buy an iphone"
  text3 <- "Je déteste ne plus avoir de dentifrice."
  request <- c(text1, text2, text3)
  output <- monkeylearn_classify(request,
                       classifier_id = "cl_oJNMkt2V")

  expect_is(output, "data.frame")
  expect_is(attr(output, "headers"), "data.frame")
  expect_gte(nrow(attr(output, "headers")), 1)


  text <- "A panel of Goldman Sachs employees spent a recent Tuesday night at the Columbia University faculty club trying to convince a packed room of potential recruits that Wall Street, not Silicon Valley, was the place to be for computer scientists.\n\n The Goldman employees knew they had an uphill battle. They were fighting against perceptions of Wall Street as boring and regulation-bound and Silicon Valley as the promised land of flip-flops, beanbag chairs and million-dollar stock options.\n\n Their argument to the room of technologically inclined students was that Wall Street was where they could find far more challenging, diverse and, yes, lucrative jobs working on some of the worlds most difficult technical problems.\n\n Whereas in other opportunities you might be considering, it is working one type of data or one type of application, we deal in hundreds of products in hundreds of markets, with thousands or tens of thousands of clients, every day, millions of times of day worldwide, Afsheen Afshar, a managing director at Goldman Sachs, told the students."
  output <- monkeylearn_extract(text,
                                 extractor_id = "ex_y7BPYzNG",
                                params = list(max_keywords = 3,
                                              use_company_names = 1))

  expect_is(output, "data.frame")
  expect_is(attr(output, "headers"), "data.frame")
  expect_gte(nrow(attr(output, "headers")), 1)

  })

test_that("monkeylearn_classifiers returns a data frame",{
  expect_is(monkeylearn_classifiers(), "tbl_df")
  expect_is(monkeylearn_classifiers(private = TRUE), "tbl_df")
})

test_that("No error if no results from the extractor call",{
  expect_is(monkeylearn_extract(request = "hello", extractor_id = "ex_y7BPYzNG"), "tbl_df")
  expect_message(monkeylearn_extract(request = "hello", extractor_id = "ex_y7BPYzNG"),
                  "No results for this call")
})

test_that("We can use different texts_per_req in classify_df and get the same output and unnesting works", {
  text1 <- "Hauràs de dirigir-te al punt de trobada del grup al que et vulguis unir."
  text2 <- "i want to buy an iphone"
  text3 <- "Je déteste ne plus avoir de dentifrice."
  text_4 <- "I hate not having any toothpaste."
  request_df <- tibble::as_tibble(list(txt = c(text1, text2, text3, text_4)))

  expect_equal(tidyr::unnest(monkey_classify(request_df, txt, texts_per_req = 2)),
               tidyr::unnest(monkey_classify(request_df, txt, texts_per_req = 3)))

  expect_equal(tidyr::unnest(monkey_classify(request_df, txt, texts_per_req = 2)),
               (monkey_classify(request_df, txt, texts_per_req = 2, unnest = TRUE)))
})

