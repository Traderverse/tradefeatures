library(testthat)
library(tradefeatures)

test_that("add_rsi adds column correctly", {
        data <- tibble::tibble(
                symbol = "TEST",
                datetime = as.POSIXct(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30)),
                close = rnorm(30, 100, 2)
        )
        
        result <- add_rsi(data, n = 14)
        
        expect_true("rsi" %in% names(result))
        expect_equal(nrow(result), nrow(data))
        
        # RSI should be between 0 and 100
        valid_rsi <- result$rsi[!is.na(result$rsi)]
        expect_true(all(valid_rsi >= 0 & valid_rsi <= 100))
})

test_that("add_macd adds columns correctly", {
        data <- tibble::tibble(
                symbol = "TEST",
                datetime = as.POSIXct(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 60)),
                close = rnorm(60, 100, 2)
        )
        
        result <- add_macd(data)
        
        expect_true("macd" %in% names(result))
        expect_true("macd_signal" %in% names(result))
        expect_true("macd_histogram" %in% names(result))
        expect_equal(nrow(result), nrow(data))
})

test_that("add_stochastic adds columns correctly", {
        data <- tibble::tibble(
                symbol = "TEST",
                datetime = as.POSIXct(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30)),
                open = rnorm(30, 100, 2),
                high = rnorm(30, 102, 2),
                low = rnorm(30, 98, 2),
                close = rnorm(30, 100, 2),
                volume = rpois(30, 1000000)
        )
        
        result <- add_stochastic(data, n = 14)
        
        expect_true("stoch_k" %in% names(result))
        expect_true("stoch_d" %in% names(result))
        expect_equal(nrow(result), nrow(data))
})

test_that("calc_momentum works correctly", {
        prices <- c(100, 102, 104, 106, 108, 110)
        result <- calc_momentum(prices, n = 3)
        
        # Should return percentage change over 3 periods
        expect_equal(length(result), length(prices))
        expect_true(is.na(result[1]))
        expect_true(is.na(result[2]))
        expect_true(is.na(result[3]))
        
        # Fourth value should be % change from first
        expect_equal(result[4], ((106 / 100) - 1) * 100)
})
