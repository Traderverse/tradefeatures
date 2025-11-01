library(testthat)
library(tradefeatures)

test_that("calc_returns with simple returns", {
        prices <- c(100, 105, 102, 108)
        result <- calc_returns(prices, type = "simple")
        
        expect_equal(length(result), length(prices))
        expect_true(is.na(result[1]))
        
        # Second value should be 5% return
        expect_equal(result[2], 0.05)
})

test_that("calc_returns with log returns", {
        prices <- c(100, 105, 102, 108)
        result <- calc_returns(prices, type = "log")
        
        expect_equal(length(result), length(prices))
        expect_true(is.na(result[1]))
        
        # Log returns should be approximately simple returns for small changes
        simple <- calc_returns(prices, type = "simple")
        expect_true(abs(result[2] - simple[2]) < 0.01)
})

test_that("validate_indicator_params catches errors", {
        data <- tibble::tibble(
                close = rnorm(10, 100, 2)
        )
        
        # Should warn when n is too large
        expect_warning(
                validate_indicator_params(15, data, min_n = 1),
                "Data has fewer rows"
        )
        
        # Should error when n is too small
        expect_error(
                validate_indicator_params(3, data, min_n = 5),
                "Parameter 'n' must be >= 5"
        )
})

test_that("check_required_columns detects missing columns", {
        data <- tibble::tibble(
                close = rnorm(10, 100, 2)
        )
        
        # Should error when column is missing
        expect_error(
                check_required_columns(data, c("high", "low")),
                "Missing required columns"
        )
        
        # Should pass when columns exist
        data_complete <- tibble::tibble(
                high = rnorm(10, 102, 2),
                low = rnorm(10, 98, 2),
                close = rnorm(10, 100, 2)
        )
        
        expect_silent(check_required_columns(data_complete, c("high", "low", "close")))
})
