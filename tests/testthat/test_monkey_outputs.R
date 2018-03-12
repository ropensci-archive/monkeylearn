context("test monkey_ outputs")

test_that("monkeylearn_parse returns a data.frame with a data.frame as attribute",{
  text1 <- "my dog is an avid rice eater"
  text2 <- "i want to buy an iphone"
  request <- c(text1, text2)
  output <- monkey_classify(request,
                            classifier_id = "cl_oFKL5wft")

  expect_is(output, "data.frame")
  test_headers(output)
  expect_error(monkey_classify(request, foo,   # This is a vector, so we shouldn't supply a column
                               classifier_id = "cl_oFKL5wft"))

  text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
  output <- monkey_extract(request,
                           extractor_id = "ex_isnnZRbS")

  expect_is(output, "data.frame")
  test_headers(output)

  text <- "Hi, my email is john@example.com and my credit card is 4242-4242-4242-4242 so you can charge me with $10. My phone number is 15555 9876. We can get in touch on April 16, at 10:00am"
  text2 <- "Hi, my email is mary@example.com and my credit card is 4242-4232-4242-4242. My phone number is 16655 9876. We can get in touch on April 16, at 10:00am"
  # output <- monkey_extract(input = c(text, text2),
  #                               extractor_id = "ex_dqRio5sG")     # ----- See issue #39: trouble creating `output_nested`  from `output$result` in `monkey_extract()` with this particular extractor
  # output <- monkey_extract(input = c(text, text2),
  #                                 extractor_id = "ex_dqRio5sG")


  expect_is(output, "data.frame")
  test_headers(output)

  text1 <- "Hauràs de dirigir-te al punt de trobada del grup al que et vulguis unir."
  text2 <- "i want to buy an iphone"
  text3 <- "Je déteste ne plus avoir de dentifrice."
  request <- c(text1, text2, text3)
  output <- monkey_classify(request,
                                 classifier_id = "cl_oJNMkt2V")

  expect_is(output, "data.frame")
  test_headers(output)


  text <- "A panel of Goldman Sachs employees spent a recent Tuesday night at the Columbia University faculty club trying to convince a packed room of potential recruits that Wall Street, not Silicon Valley, was the place to be for computer scientists.\n\n The Goldman employees knew they had an uphill battle. They were fighting against perceptions of Wall Street as boring and regulation-bound and Silicon Valley as the promised land of flip-flops, beanbag chairs and million-dollar stock options.\n\n Their argument to the room of technologically inclined students was that Wall Street was where they could find far more challenging, diverse and, yes, lucrative jobs working on some of the worlds most difficult technical problems.\n\n Whereas in other opportunities you might be considering, it is working one type of data or one type of application, we deal in hundreds of products in hundreds of markets, with thousands or tens of thousands of clients, every day, millions of times of day worldwide, Afsheen Afshar, a managing director at Goldman Sachs, told the students."
  output <- monkey_extract(text,
                          extractor_id = "ex_y7BPYzNG",
                          params = list(max_keywords = 3,
                                        use_company_names = 1))

  expect_is(output, "data.frame")
  test_headers(output)

})

test_that("No error if no results from the extractor call",{
  expect_is(monkey_extract(input = "hello", extractor_id = "ex_y7BPYzNG"), "tbl_df")
  expect_message(monkey_extract(input = "hello", extractor_id = "ex_y7BPYzNG", verbose = TRUE),
                 "No results for this call")
})

test_that("We can use different texts_per_req in classify_df and get the same output and unnesting works", {
  text1 <- "Hauràs de dirigir-te al punt de trobada del grup al que et vulguis unir."
  text2 <- "i want to buy an iphone"
  text3 <- "Je déteste ne plus avoir de dentifrice."
  text_4 <- "I hate not having any toothpaste."
  request_df <- tibble::as_tibble(list(txt = c(text1, text2, text3, text_4)))

  output_unnested <- monkey_classify(request_df, txt, texts_per_req = 2, unnest = TRUE)
  output_nested <- monkey_classify(request_df, txt, texts_per_req = 2, unnest = FALSE)
  output_2_texts <- tidyr::unnest(monkey_classify(request_df, txt, texts_per_req = 2))
  output_3_texts <- tidyr::unnest(monkey_classify(request_df, txt, texts_per_req = 3))

  # Different numbers of texts_per_req give same output
  expect_equal(output_2_texts, output_3_texts)

  # Unnesting parameter unnests
  expect_equal(tidyr::unnest(output_nested),
                             output_unnested)
  test_headers(output_nested)
  test_headers(output_unnested)

  # Dataframe or vector as input produce same result
  vec_output <- monkey_classify(request_df$txt, texts_per_req = 2, unnest = TRUE)
  df_output <- monkey_classify(request_df, txt, texts_per_req = 1, unnest = TRUE)

  expect_equal(vec_output, df_output)
  test_headers(vec_output)
  test_headers(df_output)
})


test_that("We can reconstruct the same length vector as we had in our input, retaining empty strings", {
  text_w_empties <- c(
    "In a hole in the ground there lived a hobbit.",
    "It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife.",
    "",
    "When Mr. Bilbo Baggins of Bag End announced that he would shortly be celebrating his eleventy-first birthday with a party of special magnificence, there was much talk and excitement in Hobbiton.",
    " ")

  empties_result_unnested <- monkey_classify(text_w_empties, texts_per_req = 2, unnest = TRUE)
  empties_result_nested <- monkey_classify(text_w_empties, texts_per_req = 2, unnest = FALSE)

  # We should have the same empty strings in outputs as we had in inputs
  expect_equal(length(which(empties_result_unnested$req %in% c("", " "))),
              length(which(text_w_empties %in% c("", " "))))
  expect_equal(empties_result_nested$req[4], text_w_empties[4])

  expect_is(empties_result_unnested, "data.frame")
  expect_is(attr(empties_result_unnested, "headers"), "data.frame")
  expect_gte(nrow(attr(empties_result_unnested, "headers")), 1)

  # We should be able to post hoc unnest a nested dataframe with empties
  empties_result_nested_posthoc <- tidyr::unnest(empties_result_nested)
  expect_equal(empties_result_nested_posthoc, empties_result_unnested)

  # Same behavior with extractors
  empties_extracted_nested <- monkey_extract(text_w_empties, extractor_id = "ex_y7BPYzNG")
  empties_extracted_unnested <- monkey_extract(text_w_empties, extractor_id = "ex_y7BPYzNG", unnest = TRUE)
  testthat::expect_equal(dim(tidyr::unnest(empties_extracted_nested)), dim(empties_extracted_unnested))
})





