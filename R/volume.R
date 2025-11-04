#' Add On-Balance Volume (OBV)
#'
#' Add OBV indicator. OBV uses volume flow to predict changes in stock price.
#' When the security closes higher than the previous close, all of the day's
#' volume is considered up-volume. When the security closes lower, all of the
#' day's volume is considered down-volume.
#'
#' @param data A data frame or market_tbl with price and volume data
#' @param name Character: name for new column (default: "obv")
#'
#' @return Data with new OBV column
#' @export
#'
#' @examples
#' \dontrun{
#' library(tradeio)
#'
#' # Add OBV
#' prices <- fetch_prices("AAPL", from = "2024-01-01") |>
#'   add_obv()
#'
#' # Check for divergence
#' library(dplyr)
#' prices |>
#'   add_obv() |>
#'   mutate(
#'     price_trend = close > lag(close, 10),
#'     obv_trend = obv > lag(obv, 10),
#'     bullish_divergence = !price_trend & obv_trend,
#'     bearish_divergence = price_trend & !obv_trend
#'   )
#' }
add_obv <- function(data, name = "obv") {
        required_cols <- c("close", "volume")
        missing_cols <- setdiff(required_cols, names(data))
        
        if (length(missing_cols) > 0) {
                stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
        }
        
        # Calculate OBV grouped by symbol if present
        if ("symbol" %in% names(data)) {
                data <- data |>
                        dplyr::group_by(.data$symbol) |>
                        dplyr::mutate(
                                price_change = .data$close - dplyr::lag(.data$close),
                                volume_direction = dplyr::case_when(
                                        .data$price_change > 0 ~ .data$volume,
                                        .data$price_change < 0 ~ -.data$volume,
                                        TRUE ~ 0
                                ),
                                !!name := cumsum(tidyr::replace_na(.data$volume_direction, 0))
                        ) |>
                        dplyr::select(-.data$price_change, -.data$volume_direction) |>
                        dplyr::ungroup()
        } else {
                data <- data |>
                        dplyr::mutate(
                                price_change = .data$close - dplyr::lag(.data$close),
                                volume_direction = dplyr::case_when(
                                        .data$price_change > 0 ~ .data$volume,
                                        .data$price_change < 0 ~ -.data$volume,
                                        TRUE ~ 0
                                ),
                                !!name := cumsum(tidyr::replace_na(.data$volume_direction, 0))
                        ) |>
                        dplyr::select(-.data$price_change, -.data$volume_direction)
        }
        
        data <- preserve_market_tbl(data)
        return(data)
}
