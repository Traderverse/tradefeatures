library(testthat)
library(tradefeatures)

test_that("add_obv adds column correctly", {
        data <- tibble::tibble(
                symbol = "TEST",
                datetime = as.POSIXct(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30)),
                close = rnorm(30, 100, 2),
                volume = rpois(30, 1000000)
        )
        
        result <- add_obv(data)
        
        expect_true("obv" %in% names(result))
        expect_equal(nrow(result), nrow(data))
        
        # First OBV should be 0 (no previous price to compare)
        expect_equal(result$obv[1], 0)
})
