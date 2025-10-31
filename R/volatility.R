#' Add Bollinger Bands
#'
#' Add Bollinger Bands to market data. Bollinger Bands consist of a middle band
#' (SMA) and two outer bands at standard deviations away from the middle.
#'
#' @param data A data frame or market_tbl with price data
#' @param n Integer: period for moving average (default: 20)
#' @param sd Numeric: number of standard deviations for bands (default: 2)
#' @param price Character: column name to use (default: "close")
#'
#' @return Data with new columns: bb_upper, bb_middle, bb_lower
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add Bollinger Bands
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_bbands(20, sd = 2)
#'
#' # Identify when price touches bands
#' library(dplyr)
#' prices |>
#'   add_bbands() |>
#'   mutate(
#'     at_lower_band = close <= bb_lower,
#'     at_upper_band = close >= bb_upper,
#'     squeeze = (bb_upper - bb_lower) / bb_middle < 0.05
#'   )
#' }
add_bbands <- function(data, n = 20, sd = 2, price = "close") {
        if (!price %in% names(data)) {
                stop("Column '", price, "' not found in data")
        }
        
        # Calculate Bollinger Bands grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(symbol) |>
                        dplyr::mutate(
                                bb_middle = sma(.data[[price]], n),
                                rolling_sd = zoo::rollapply(.data[[price]], width = n, FUN = sd, fill = NA, align = "right"),
                                bb_upper = bb_middle + (sd * rolling_sd),
                                bb_lower = bb_middle - (sd * rolling_sd)
                        ) |>
                        dplyr::select(-rolling_sd) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(
                                bb_middle = sma(.data[[price]], n),
                                rolling_sd = zoo::rollapply(.data[[price]], width = n, FUN = sd, fill = NA, align = "right"),
                                bb_upper = bb_middle + (sd * rolling_sd),
                                bb_lower = bb_middle - (sd * rolling_sd)
                        ) |>
                        dplyr::select(-rolling_sd)
        }
        
        return(data)
}


#' Add Average True Range (ATR)
#'
#' Add ATR indicator. ATR measures market volatility by calculating the
#' average of true ranges over a period.
#'
#' @param data A data frame or market_tbl with OHLC data
#' @param n Integer: period for ATR (default: 14)
#' @param name Character: name for new column (default: "atr")
#'
#' @return Data with new ATR column
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add ATR
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_atr(14)
#'
#' # Use ATR for position sizing
#' library(dplyr)
#' prices |>
#'   add_atr() |>
#'   mutate(
#'     position_size = 1000 / (2 * atr)  # Risk 2 ATRs
#'   )
#' }
add_atr <- function(data, n = 14, name = "atr") {
        required_cols <- c("high", "low", "close")
        missing_cols <- setdiff(required_cols, names(data))
        
        if (length(missing_cols) > 0) {
                stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
        }
        
        # Calculate ATR grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(symbol) |>
                        dplyr::mutate(
                                prev_close = dplyr::lag(close),
                                tr1 = high - low,
                                tr2 = abs(high - prev_close),
                                tr3 = abs(low - prev_close),
                                true_range = pmax(tr1, tr2, tr3, na.rm = TRUE),
                                !!name := ema(true_range, n)
                        ) |>
                        dplyr::select(-prev_close, -tr1, -tr2, -tr3, -true_range) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(
                                prev_close = dplyr::lag(close),
                                tr1 = high - low,
                                tr2 = abs(high - prev_close),
                                tr3 = abs(low - prev_close),
                                true_range = pmax(tr1, tr2, tr3, na.rm = TRUE),
                                !!name := ema(true_range, n)
                        ) |>
                        dplyr::select(-prev_close, -tr1, -tr2, -tr3, -true_range)
        }
        
        return(data)
}
