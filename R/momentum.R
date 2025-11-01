#' Add Relative Strength Index (RSI)
#'
#' Add RSI indicator to market data. RSI measures the magnitude of recent price
#' changes to evaluate overbought or oversold conditions. Values range from 0-100,
#' with >70 typically considered overbought and <30 oversold.
#'
#' @param data A data frame or market_tbl with price data
#' @param n Integer: number of periods for RSI calculation (default: 14)
#' @param price Character: column name to use (default: "close")
#' @param name Character: name for new column (default: "rsi")
#'
#' @return Data with new RSI column added
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add 14-period RSI
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_rsi(14)
#'
#' # Identify oversold/overbought
#' library(dplyr)
#' prices |>
#'   add_rsi(14) |>
#'   mutate(
#'     oversold = rsi < 30,
#'     overbought = rsi > 70
#'   )
#' }
add_rsi <- function(data, n = 14, price = "close", name = "rsi") {
        if (!price %in% names(data)) {
                stop("Column '", price, "' not found in data")
        }
        
        # Calculate RSI grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(symbol) |>
                        dplyr::mutate(!!name := calc_rsi(.data[[price]], n)) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(!!name := calc_rsi(.data[[price]], n))
        }
        
        return(data)
}


# Helper function to calculate RSI
calc_rsi <- function(prices, n = 14) {
        # Calculate price changes
        price_diff <- diff(c(NA, prices))
        
        # Separate gains and losses
        gains <- ifelse(price_diff > 0, price_diff, 0)
        losses <- ifelse(price_diff < 0, abs(price_diff), 0)
        
        # Calculate average gains and losses using EMA
        avg_gains <- ema(gains, n)
        avg_losses <- ema(losses, n)
        
        # Calculate RS and RSI
        rs <- avg_gains / avg_losses
        rsi <- 100 - (100 / (1 + rs))
        
        # Handle edge cases
        rsi[is.nan(rsi)] <- 50  # When both avg_gains and avg_losses are 0
        rsi[is.infinite(rsi)] <- 100  # When avg_losses is 0
        
        return(rsi)
}


#' Add MACD (Moving Average Convergence Divergence)
#'
#' Add MACD indicator with signal line and histogram. MACD is calculated as
#' the difference between two EMAs, and the signal line is an EMA of the MACD.
#'
#' @param data A data frame or market_tbl with price data
#' @param fast Integer: fast EMA period (default: 12)
#' @param slow Integer: slow EMA period (default: 26)
#' @param signal Integer: signal line EMA period (default: 9)
#' @param price Character: column name to use (default: "close")
#'
#' @return Data with new MACD columns: macd, macd_signal, macd_histogram
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add MACD with default parameters
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_macd()
#'
#' # Use MACD crossover as signal
#' library(dplyr)
#' prices |>
#'   add_macd() |>
#'   mutate(
#'     macd_cross_up = (macd > macd_signal) & (lag(macd) <= lag(macd_signal)),
#'     macd_cross_down = (macd < macd_signal) & (lag(macd) >= lag(macd_signal))
#'   )
#' }
add_macd <- function(data, fast = 12, slow = 26, signal = 9, price = "close") {
        if (!price %in% names(data)) {
                stop("Column '", price, "' not found in data")
        }
        
        # Calculate MACD grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(.data$symbol) |>
                        dplyr::mutate(
                                ema_fast = ema(.data[[price]], fast),
                                ema_slow = ema(.data[[price]], slow),
                                macd = .data$ema_fast - .data$ema_slow,
                                macd_signal = ema(.data$macd, signal),
                                macd_histogram = .data$macd - .data$macd_signal
                        ) |>
                        dplyr::select(-.data$ema_fast, -.data$ema_slow) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(
                                ema_fast = ema(.data[[price]], fast),
                                ema_slow = ema(.data[[price]], slow),
                                macd = .data$ema_fast - .data$ema_slow,
                                macd_signal = ema(.data$macd, signal),
                                macd_histogram = .data$macd - .data$macd_signal
                        ) |>
                        dplyr::select(-.data$ema_fast, -.data$ema_slow)
        }
        
        return(data)
}


#' Add Stochastic Oscillator
#'
#' Add Stochastic Oscillator (%K and %D lines). The stochastic oscillator
#' compares a closing price to its price range over a period of time.
#'
#' @param data A data frame or market_tbl with OHLC data
#' @param n Integer: lookback period (default: 14)
#' @param smooth Integer: smoothing period for %D line (default: 3)
#'
#' @return Data with new columns: stoch_k and stoch_d
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add Stochastic
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_stochastic(14, smooth = 3)
#'
#' # Identify oversold/overbought
#' library(dplyr)
#' prices |>
#'   add_stochastic() |>
#'   mutate(
#'     oversold = stoch_k < 20,
#'     overbought = stoch_k > 80
#'   )
#' }
add_stochastic <- function(data, n = 14, smooth = 3) {
        required_cols <- c("high", "low", "close")
        missing_cols <- setdiff(required_cols, names(data))
        
        if (length(missing_cols) > 0) {
                stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
        }
        
        # Calculate Stochastic grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(.data$symbol) |>
                        dplyr::mutate(
                                lowest_low = zoo::rollapply(.data$low, width = n, FUN = min, fill = NA, align = "right"),
                                highest_high = zoo::rollapply(.data$high, width = n, FUN = max, fill = NA, align = "right"),
                                stoch_k = 100 * (.data$close - .data$lowest_low) / (.data$highest_high - .data$lowest_low),
                                stoch_d = sma(.data$stoch_k, smooth)
                        ) |>
                        dplyr::select(-.data$lowest_low, -.data$highest_high) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(
                                lowest_low = zoo::rollapply(.data$low, width = n, FUN = min, fill = NA, align = "right"),
                                highest_high = zoo::rollapply(.data$high, width = n, FUN = max, fill = NA, align = "right"),
                                stoch_k = 100 * (.data$close - .data$lowest_low) / (.data$highest_high - .data$lowest_low),
                                stoch_d = sma(.data$stoch_k, smooth)
                        ) |>
                        dplyr::select(-.data$lowest_low, -.data$highest_high)
        }
        
        return(data)
}


#' Add Commodity Channel Index (CCI)
#'
#' Add CCI indicator. CCI measures the current price level relative to an
#' average price level over a period of time.
#'
#' @param data A data frame or market_tbl with OHLC data
#' @param n Integer: lookback period (default: 20)
#' @param name Character: name for new column (default: "cci")
#'
#' @return Data with new CCI column
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add CCI
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_cci(20)
#' }
add_cci <- function(data, n = 20, name = "cci") {
        required_cols <- c("high", "low", "close")
        missing_cols <- setdiff(required_cols, names(data))
        
        if (length(missing_cols) > 0) {
                stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
        }
        
        # CCI constant
        constant <- 0.015
        
        # Calculate CCI grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(.data$symbol) |>
                        dplyr::mutate(
                                typical_price = (.data$high + .data$low + .data$close) / 3,
                                sma_tp = sma(.data$typical_price, n),
                                mean_deviation = zoo::rollapply(
                                        .data$typical_price,
                                        width = n,
                                        FUN = function(x) mean(abs(x - mean(x))),
                                        fill = NA,
                                        align = "right"
                                ),
                                !!name := (.data$typical_price - .data$sma_tp) / (constant * .data$mean_deviation)
                        ) |>
                        dplyr::select(-.data$typical_price, -.data$sma_tp, -.data$mean_deviation) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(
                                typical_price = (.data$high + .data$low + .data$close) / 3,
                                sma_tp = sma(.data$typical_price, n),
                                mean_deviation = zoo::rollapply(
                                        .data$typical_price,
                                        width = n,
                                        FUN = function(x) mean(abs(x - mean(x))),
                                        fill = NA,
                                        align = "right"
                                ),
                                !!name := (.data$typical_price - .data$sma_tp) / (constant * .data$mean_deviation)
                        ) |>
                        dplyr::select(-.data$typical_price, -.data$sma_tp, -.data$mean_deviation)
        }
        
        return(data)
}


#' Add Williams %R
#'
#' Add Williams %R indicator. Similar to Stochastic but inverted and
#' typically more sensitive to price movements.
#'
#' @param data A data frame or market_tbl with OHLC data
#' @param n Integer: lookback period (default: 14)
#' @param name Character: name for new column (default: "williams_r")
#'
#' @return Data with new Williams %R column
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add Williams %R
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_williams_r(14)
#' }
add_williams_r <- function(data, n = 14, name = "williams_r") {
        required_cols <- c("high", "low", "close")
        missing_cols <- setdiff(required_cols, names(data))
        
        if (length(missing_cols) > 0) {
                stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
        }
        
        # Calculate Williams %R grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(.data$symbol) |>
                        dplyr::mutate(
                                highest_high = zoo::rollapply(.data$high, width = n, FUN = max, fill = NA, align = "right"),
                                lowest_low = zoo::rollapply(.data$low, width = n, FUN = min, fill = NA, align = "right"),
                                !!name := -100 * (.data$highest_high - .data$close) / (.data$highest_high - .data$lowest_low)
                        ) |>
                        dplyr::select(-.data$highest_high, -.data$lowest_low) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(
                                highest_high = zoo::rollapply(.data$high, width = n, FUN = max, fill = NA, align = "right"),
                                lowest_low = zoo::rollapply(.data$low, width = n, FUN = min, fill = NA, align = "right"),
                                !!name := -100 * (.data$highest_high - .data$close) / (.data$highest_high - .data$lowest_low)
                        ) |>
                        dplyr::select(-.data$highest_high, -.data$lowest_low)
        }
        
        return(data)
}


#' Calculate Price Momentum
#'
#' Calculate price momentum as the rate of change over n periods.
#'
#' @param prices Numeric vector: price series
#' @param n Integer: lookback period (default: 10)
#'
#' @return Numeric vector of momentum values
#' @export
#'
#' @examples
#' prices <- c(100, 102, 101, 103, 105, 104, 106, 108, 107, 109, 111)
#' calc_momentum(prices, n = 5)
calc_momentum <- function(prices, n = 10) {
        if (length(prices) < n) {
                return(rep(NA_real_, length(prices)))
        }
        
        # Momentum = (Current Price / Price n periods ago) - 1
        lagged_prices <- dplyr::lag(prices, n)
        momentum <- (prices / lagged_prices) - 1
        
        return(momentum * 100)  # Return as percentage
}
