#' tradefeatures: Technical Indicators for TradingVerse
#'
#' @description
#' `tradefeatures` provides comprehensive technical analysis indicators and
#' feature engineering tools for financial market data. Transform raw OHLCV
#' data into meaningful trading signals with 30+ indicators.
#'
#' @section Main Functions:
#' **Trend Indicators:**
#' * [add_sma()] - Simple Moving Average
#' * [add_ema()] - Exponential Moving Average
#' * [add_vwap()] - Volume Weighted Average Price
#'
#' **Momentum Indicators:**
#' * [add_rsi()] - Relative Strength Index
#' * [add_macd()] - MACD with signal line
#' * [add_stochastic()] - Stochastic Oscillator
#' * [add_cci()] - Commodity Channel Index
#' * [add_williams_r()] - Williams %R
#'
#' **Volatility Indicators:**
#' * [add_bbands()] - Bollinger Bands
#' * [add_atr()] - Average True Range
#'
#' **Volume Indicators:**
#' * [add_obv()] - On-Balance Volume
#'
#' **Pattern Detection:**
#' * [detect_golden_cross()] - MA golden cross
#' * [detect_death_cross()] - MA death cross
#'
#' **Returns & Statistics:**
#' * [calc_returns()] - Price returns
#' * [calc_momentum()] - Price momentum
#'
#' @section Philosophy:
#' All `add_*()` functions:
#' * Work with pipes (`|>` and `%>%`)
#' * Add columns to existing data
#' * Accept customizable parameters
#' * Use sensible defaults
#' * Handle missing values gracefully
#'
#' @section Integration:
#' Works seamlessly with:
#' * **tradeio** - Fetch market data
#' * **tradeengine** - Backtest strategies
#' * **dplyr** - Data manipulation
#'
#' @examples
#' \dontrun{
#' library(tradefeatures)
#' library(tradeio)
#' library(dplyr)
#'
#' # Add multiple indicators
#' enriched_data <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_sma(20) |>
#'   add_rsi(14) |>
#'   add_macd() |>
#'   add_bbands(20)
#'
#' # Use in strategy
#' results <- enriched_data |>
#'   add_strategy(
#'     entry = (rsi < 30) & (close > sma_20),
#'     exit = (rsi > 70) | (close < sma_20)
#'   ) |>
#'   backtest(initial_capital = 10000)
#' }
#'
#' @docType package
#' @name tradefeatures-package
#' @aliases tradefeatures
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

# Global variable bindings for R CMD check
utils::globalVariables(c(
        "close", "open", "high", "low", "volume",
        "symbol", "datetime",
        "sma_20", "sma_50", "sma_200",
        "ema_12", "ema_26",
        "rsi", "macd", "macd_signal", "macd_histogram",
        "bb_upper", "bb_middle", "bb_lower",
        "atr", "obv",
        "stoch_k", "stoch_d",
        "cci", "williams_r"
))
