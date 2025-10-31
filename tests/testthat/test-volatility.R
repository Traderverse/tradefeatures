library(testthat)
library(tradefeatures)

test_that("add_bbands adds columns correctly", {
        data <- tibble::tibble(
                symbol = "TEST",
                datetime = as.POSIXct(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30)),
                close = rnorm(30, 100, 2)
        )
        
        result <- add_bbands(data, n = 20, sd = 2)
        
        expect_true("bb_upper" %in% names(result))
        expect_true("bb_middle" %in% names(result))
        expect_true("bb_lower" %in% names(result))
        expect_equal(nrow(result), nrow(data))
        
        # Upper should be > middle > lower
        valid_rows <- !is.na(result$bb_upper)
        if (any(valid_rows)) {
                expect_true(all(result$bb_upper[valid_rows] > result$bb_middle[valid_rows]))
                expect_true(all(result$bb_middle[valid_rows] > result$bb_lower[valid_rows]))
        }
})

test_that("add_atr adds column correctly", {
        data <- tibble::tibble(
                symbol = "TEST",
                datetime = as.POSIXct(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30)),
                open = rnorm(30, 100, 2),
                high = rnorm(30, 102, 2),
                low = rnorm(30, 98, 2),
                close = rnorm(30, 100, 2)
        )
        
        result <- add_atr(data, n = 14)
        
        expect_true("atr" %in% names(result))
        expect_equal(nrow(result), nrow(data))
        
        # ATR should be positive
        valid_atr <- result$atr[!is.na(result$atr)]
        expect_true(all(valid_atr > 0))
})
