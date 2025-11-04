#' Calculate Returns
#'
#' Calculate simple or logarithmic returns from a price series.
#'
#' @param prices Numeric vector: price series
#' @param type Character: "simple" or "log" (default: "simple")
#' @param lag Integer: number of periods for return calculation (default: 1)
#'
#' @return Numeric vector of returns
#' @export
#'
#' @examples
#' prices <- c(100, 102, 101, 103, 105, 104, 106)
#'
#' # Simple returns
#' calc_returns(prices, type = "simple")
#'
#' # Log returns
#' calc_returns(prices, type = "log")
#'
#' # Multi-period returns
#' calc_returns(prices, type = "simple", lag = 5)
calc_returns <- function(prices, type = c("simple", "log"), lag = 1) {
        type <- match.arg(type)
        
        if (length(prices) < lag + 1) {
                return(rep(NA_real_, length(prices)))
        }
        
        lagged_prices <- dplyr::lag(prices, lag)
        
        returns <- switch(
                type,
                simple = (prices / lagged_prices) - 1,
                log = log(prices / lagged_prices)
        )
        
        return(returns)
}


#' Validate Indicator Parameters
#'
#' Helper function to validate common indicator parameters.
#'
#' @param n Integer: period parameter
#' @param data Data frame
#' @param min_n Integer: minimum allowed value for n
#'
#' @keywords internal
validate_indicator_params <- function(n, data, min_n = 1) {
        if (!is.numeric(n) || n < min_n) {
                stop("Parameter 'n' must be >= ", min_n)
        }
        
        if (nrow(data) < n) {
                warning("Data has fewer rows (", nrow(data), ") than indicator period (", n, ")")
        }
}


#' Check Required Columns
#'
#' Helper function to check if required columns exist in data.
#'
#' @param data Data frame
#' @param required Character vector: required column names
#'
#' @keywords internal
check_required_columns <- function(data, required) {
        missing <- setdiff(required, names(data))
        if (length(missing) > 0) {
                stop("Missing required columns: ", paste(missing, collapse = ", "))
        }
}


#' Preserve Market Table Class
#'
#' Helper function to ensure market_tbl class is preserved after operations.
#' Use this at the end of any function that uses dplyr operations on market_tbl objects.
#'
#' @param data Data frame that should be a market_tbl
#'
#' @return Data frame with market_tbl class
#' @export
preserve_market_tbl <- function(data) {
        if (!"market_tbl" %in% class(data)) {
                class(data) <- c("market_tbl", class(data))
        }
        return(data)
}
