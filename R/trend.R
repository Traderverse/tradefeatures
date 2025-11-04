#' Simple Moving Average (Standalone)
#'
#' Calculate simple moving average of a price series. This is a standalone
#' function that returns just the SMA values.
#'
#' @param x Numeric vector: price series
#' @param n Integer: number of periods for moving average (default: 20)
#'
#' @return Numeric vector of SMA values (same length as input)
#' @export
#'
#' @examples
#' prices <- c(100, 102, 101, 103, 105, 104, 106)
#' sma(prices, n = 3)
#'
#' # Use in dplyr
#' \dontrun{
#' library(dplyr)
#' prices_df |> mutate(sma_20 = sma(close, 20))
#' }
sma <- function(x, n = 20) {
        if (length(x) == 0) return(numeric(0))
        if (n < 1) stop("n must be >= 1")
        if (n > length(x)) {
                warning("n is greater than length of x, returning all NA")
                return(rep(NA_real_, length(x)))
        }
        
        # Use zoo::rollmean for efficiency
        if (requireNamespace("zoo", quietly = TRUE)) {
                return(zoo::rollmean(x, k = n, fill = NA, align = "right"))
        } else {
                # Fallback implementation
                result <- rep(NA_real_, length(x))
                for (i in n:length(x)) {
                        result[i] <- mean(x[(i - n + 1):i], na.rm = TRUE)
                }
                return(result)
        }
}


#' Exponential Moving Average (Standalone)
#'
#' Calculate exponential moving average of a price series. EMA gives more
#' weight to recent prices.
#'
#' @param x Numeric vector: price series
#' @param n Integer: number of periods for EMA (default: 20)
#'
#' @return Numeric vector of EMA values (same length as input)
#' @export
#'
#' @examples
#' prices <- c(100, 102, 101, 103, 105, 104, 106)
#' ema(prices, n = 3)
#'
#' # Use in dplyr
#' \dontrun{
#' library(dplyr)
#' prices_df |> mutate(ema_12 = ema(close, 12))
#' }
ema <- function(x, n = 20) {
        if (length(x) == 0) return(numeric(0))
        if (n < 1) stop("n must be >= 1")
        
        # Calculate smoothing factor
        alpha <- 2 / (n + 1)
        
        # Initialize result
        result <- rep(NA_real_, length(x))
        
        # First EMA value is SMA
        if (length(x) >= n) {
                result[n] <- mean(x[1:n], na.rm = TRUE)
                
                # Calculate EMA for remaining values
                for (i in (n + 1):length(x)) {
                        if (!is.na(x[i]) && !is.na(result[i - 1])) {
                                result[i] <- alpha * x[i] + (1 - alpha) * result[i - 1]
                        }
                }
        }
        
        return(result)
}


#' Add Simple Moving Average
#'
#' Add simple moving average as a new column to market data.
#'
#' @param data A data frame or market_tbl with price data
#' @param n Integer: number of periods for moving average (default: 20)
#' @param price Character: column name to use for calculation (default: "close")
#' @param name Character: name for new column (default: "sma_\{n\}")
#'
#' @return Data with new SMA column added
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add 20-day SMA
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_sma(20)
#'
#' # Add multiple SMAs with custom names
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_sma(20, name = "sma_short") |>
#'   add_sma(50, name = "sma_medium") |>
#'   add_sma(200, name = "sma_long")
#' }
add_sma <- function(data, n = 20, price = "close", name = NULL) {
        if (!price %in% names(data)) {
                stop("Column '", price, "' not found in data")
        }
        
        # Generate column name
        if (is.null(name)) {
                name <- paste0("sma_", n)
        }
        
        # Calculate SMA grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(symbol) |>
                        dplyr::mutate(!!name := sma(.data[[price]], n)) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(!!name := sma(.data[[price]], n))
        }
        
        data <- preserve_market_tbl(data)
        return(data)
}


#' Add Exponential Moving Average
#'
#' Add exponential moving average as a new column to market data.
#'
#' @param data A data frame or market_tbl with price data
#' @param n Integer: number of periods for EMA (default: 20)
#' @param price Character: column name to use for calculation (default: "close")
#' @param name Character: name for new column (default: "ema_\{n\}")
#'
#' @return Data with new EMA column added
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add 12-day EMA
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_ema(12)
#'
#' # Add multiple EMAs
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_ema(12, name = "ema_fast") |>
#'   add_ema(26, name = "ema_slow")
#' }
add_ema <- function(data, n = 20, price = "close", name = NULL) {
        if (!price %in% names(data)) {
                stop("Column '", price, "' not found in data")
        }
        
        # Generate column name
        if (is.null(name)) {
                name <- paste0("ema_", n)
        }
        
        # Calculate EMA grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(symbol) |>
                        dplyr::mutate(!!name := ema(.data[[price]], n)) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(!!name := ema(.data[[price]], n))
        }
        
        data <- preserve_market_tbl(data)
        return(data)
}


#' Add Volume Weighted Average Price (VWAP)
#'
#' Add VWAP as a new column. VWAP is the average price weighted by volume,
#' often used for intraday trading.
#'
#' @param data A data frame or market_tbl with OHLCV data
#' @param name Character: name for new column (default: "vwap")
#'
#' @return Data with new VWAP column added
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add VWAP
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_vwap()
#' }
add_vwap <- function(data, name = "vwap") {
        required_cols <- c("high", "low", "close", "volume")
        missing_cols <- setdiff(required_cols, names(data))
        
        if (length(missing_cols) > 0) {
                stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
        }
        
        # Calculate typical price
        data <- data |>
                dplyr::mutate(
                        typical_price = (.data$high + .data$low + .data$close) / 3,
                        pv = .data$typical_price * .data$volume
                )
        
        # Calculate VWAP grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(.data$symbol) |>
                        dplyr::mutate(
                                !!name := cumsum(.data$pv) / cumsum(.data$volume)
                        ) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(
                                !!name := cumsum(.data$pv) / cumsum(.data$volume)
                        )
        }
        
        # Remove temporary columns
        data <- data |>
                dplyr::select(-typical_price, -pv)
        
        data <- preserve_market_tbl(data)
        return(data)
}


#' Detect Golden Cross
#'
#' Detect when a shorter moving average crosses above a longer moving average,
#' which is a bullish signal.
#'
#' @param short_ma Numeric vector: shorter moving average
#' @param long_ma Numeric vector: longer moving average
#'
#' @return Logical vector: TRUE where golden cross occurs
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#' library(dplyr)
#'
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_sma(50, name = "sma_50") |>
#'   add_sma(200, name = "sma_200") |>
#'   mutate(golden_cross = detect_golden_cross(sma_50, sma_200))
#' }
detect_golden_cross <- function(short_ma, long_ma) {
        # Golden cross: short MA crosses above long MA
        # Previous period: short <= long
        # Current period: short > long
        
        prev_short <- dplyr::lag(short_ma)
        prev_long <- dplyr::lag(long_ma)
        
        golden_cross <- (prev_short <= prev_long) & (short_ma > long_ma)
        golden_cross[is.na(golden_cross)] <- FALSE
        
        return(golden_cross)
}


#' Detect Death Cross
#'
#' Detect when a shorter moving average crosses below a longer moving average,
#' which is a bearish signal.
#'
#' @param short_ma Numeric vector: shorter moving average
#' @param long_ma Numeric vector: longer moving average
#'
#' @return Logical vector: TRUE where death cross occurs
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#' library(dplyr)
#'
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_sma(50, name = "sma_50") |>
#'   add_sma(200, name = "sma_200") |>
#'   mutate(death_cross = detect_death_cross(sma_50, sma_200))
#' }
detect_death_cross <- function(short_ma, long_ma) {
        # Death cross: short MA crosses below long MA
        # Previous period: short >= long
        # Current period: short < long
        
        prev_short <- dplyr::lag(short_ma)
        prev_long <- dplyr::lag(long_ma)
        
        death_cross <- (prev_short >= prev_long) & (short_ma < long_ma)
        death_cross[is.na(death_cross)] <- FALSE
        
        return(death_cross)
}
