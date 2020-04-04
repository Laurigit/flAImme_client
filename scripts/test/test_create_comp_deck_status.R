#test_create_comp_deck_status

deck_status_test <- data.table(CYCLER_ID = 1, CARD_ID = c(2,3,3,4,5), Zone = "Recycle")

test_that("cols are shown even when no cards are left", {
  rs <- data.table("1" = 0)
  expect_equal(create_comp_deck_status(deck_status_test, 3, ADM_CYCLER_INFO)[, "1", with = FALSE], rs )

})
