test_that("RandomBot works on task 11", {
  set.seed(444L)
  bot = OMLRandomBot$new(11)
  res = bot$run()
  expect_class(res, "OMLMlrRun")
})

test_that("RandomBot works on task 12", {
  set.seed(111L)
  bot = OMLRandomBot$new(12)
  res = bot$run()
  expect_class(res, "OMLMlrRun")
})

test_that("RandomBot timeout works", {
  set.seed(1234L)
  bot = OMLRandomBot$new(12)
  expect_error(bot$run(0.1))
})
