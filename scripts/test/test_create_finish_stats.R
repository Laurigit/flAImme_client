
example_data <- data.table(SLOTS_OVER_FINISH = c(5, 4, 1, 2, 2), FINISH_TURN = c(12, 12, 12, 13, 13), LANE = c(1, 1, 1, 1, 2), GAME_ID = 1,
                           CYCLER_ID = c(5, 4, 3, 2, 1))
double_data <- data.table(SLOTS_OVER_FINISH = c(5, 4, 1, 2, 2), FINISH_TURN = c(12, 12, 12, 13, 13), LANE = c(1, 1, 1, 1, 2), GAME_ID = 2,
                          CYCLER_ID = c(5, 4, 3, 2, 1))

append <- rbind(example_data, double_data)

test_that("finish calculation works", {
  res <- create_finish_stats(append)
  expect_equal(res[2, TIME], 0)
  expect_equal(res[8, POINTS], 1)
})

