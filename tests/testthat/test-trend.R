library(testthat)
library(tradefeatures)

test_that("sma calculates correctly", {
        prices <- c(100, 102, 101, 103, 105, 104, 106)
        result <- sma(prices, n = 3)
        
        # First two values should be NA
        expect_true(is.na(result[1]))
        expect_true(is.na(result[2]))
        
        # Third value should be average of first 3
        expect_equal(result[3], mean(c(100, 102, 101)))
})

test_that("ema calculates correctly", {
        prices <- c(100, 102, 101, 103, 105, 104, 106)
        result <- ema(prices, n = 3)
        
        # First two values should be NA
        expect_true(is.na(result[1]))
        expect_true(is.na(result[2]))
        
        # Third value should be SMA of first 3
        expect_equal(result[3], mean(c(100, 102, 101)))
})

test_that("add_sma adds column correctly", {
        data <- tibble::tibble(
                symbol = "TEST",
                datetime = as.POSIXct(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30)),
                close = rnorm(30, 100, 2)
        )
        
        result <- add_sma(data, n = 10)
        
        expect_true("sma_10" %in% names(result))
        expect_equal(nrow(result), nrow(data))
})

test_that("add_ema adds column correctly", {
        data <- tibble::tibble(
                symbol = "TEST",
                datetime = as.POSIXct(seq.Date(as.Date("2024-01-01"), by = "day", length.out = 30)),
                close = rnorm(30, 100, 2)
        )
        
        result <- add_ema(data, n = 10)
        
        expect_true("ema_10" %in% names(result))
        expect_equal(nrow(result), nrow(data))
})

test_that("detect_golden_cross works", {
        short_ma <- c(90, 95, 100, 105, 110)
        long_ma <- c(100, 100, 100, 100, 100)
        
        result <- detect_golden_cross(short_ma, long_ma)
        
        # Should detect cross around index 3-4
        expect_true(any(result))
})

test_that("detect_death_cross works", {
        short_ma <- c(110, 105, 100, 95, 90)
        long_ma <- c(100, 100, 100, 100, 100)
        
        result <- detect_death_cross(short_ma, long_ma)
        
        # Should detect cross around index 3-4
        expect_true(any(result))
})
