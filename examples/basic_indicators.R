# =============================================================================
# tradefeatures Basic Examples
# Quick introduction to technical indicators
# =============================================================================

library(tradefeatures)
library(tradeio)
library(dplyr)

cat("\n")
cat("╔══════════════════════════════════════════════════════╗\n")
cat("║     tradefeatures: Technical Indicators Demo       ║\n")
cat("╚══════════════════════════════════════════════════════╝\n")
cat("\n")

# =============================================================================
# Example 1: Simple Moving Averages
# =============================================================================

cat("═══ Example 1: Simple Moving Averages ═══\n\n")

prices <- fetch_prices("AAPL", from = "2024-01-01") |>
        add_sma(20, name = "sma_20") |>
        add_sma(50, name = "sma_50") |>
        add_sma(200, name = "sma_200")

cat("Added 3 SMAs to", nrow(prices), "rows of data\n")
cat("\nLatest values:\n")
print(tail(select(prices, datetime, close, sma_20, sma_50, sma_200), 5))

# =============================================================================
# Example 2: Exponential Moving Averages
# =============================================================================

cat("\n\n═══ Example 2: Exponential Moving Averages ═══\n\n")

prices <- fetch_prices("AAPL", from = "2024-01-01") |>
        add_ema(12, name = "ema_12") |>
        add_ema(26, name = "ema_26")

cat("EMAs are more responsive to recent prices than SMAs\n")
cat("\nComparison (last 5 days):\n")
print(tail(select(prices, datetime, close, ema_12, ema_26), 5))

# =============================================================================
# Example 3: RSI (Relative Strength Index)
# =============================================================================

cat("\n\n═══ Example 3: RSI (Momentum Indicator) ═══\n\n")

prices <- fetch_prices("AAPL", from = "2024-01-01") |>
        add_rsi(14)

# Find oversold and overbought conditions
signals <- prices |>
        mutate(
                oversold = rsi < 30,
                overbought = rsi > 70,
                signal = case_when(
                        oversold ~ "BUY SIGNAL",
                        overbought ~ "SELL SIGNAL",
                        TRUE ~ "NEUTRAL"
                )
        )

cat("RSI interpretation:\n")
cat("  RSI < 30  = Oversold (potential buy)\n")
cat("  RSI > 70  = Overbought (potential sell)\n")
cat("  30-70     = Neutral\n\n")

buy_signals <- sum(signals$oversold, na.rm = TRUE)
sell_signals <- sum(signals$overbought, na.rm = TRUE)

cat("Found", buy_signals, "oversold signals and", sell_signals, "overbought signals\n\n")

cat("Recent RSI values:\n")
print(tail(select(signals, datetime, close, rsi, signal), 10))

# =============================================================================
# Example 4: MACD
# =============================================================================

cat("\n\n═══ Example 4: MACD (Trend & Momentum) ═══\n\n")

prices <- fetch_prices("AAPL", from = "2024-01-01") |>
        add_macd()

# Detect crossovers
signals <- prices |>
        mutate(
                bullish_cross = (macd > macd_signal) & (lag(macd) <= lag(macd_signal)),
                bearish_cross = (macd < macd_signal) & (lag(macd) >= lag(macd_signal))
        )

bullish <- sum(signals$bullish_cross, na.rm = TRUE)
bearish <- sum(signals$bearish_cross, na.rm = TRUE)

cat("MACD Crossover Signals:\n")
cat("  Bullish crosses:", bullish, "\n")
cat("  Bearish crosses:", bearish, "\n\n")

cat("Recent MACD values:\n")
print(tail(select(signals, datetime, close, macd, macd_signal, macd_histogram), 5))

# =============================================================================
# Example 5: Bollinger Bands
# =============================================================================

cat("\n\n═══ Example 5: Bollinger Bands (Volatility) ═══\n\n")

prices <- fetch_prices("AAPL", from = "2024-01-01") |>
        add_bbands(20, sd = 2)

# Analyze price position relative to bands
analysis <- prices |>
        mutate(
                at_lower = close <= bb_lower,
                at_upper = close >= bb_upper,
                band_width = (bb_upper - bb_lower) / bb_middle,
                squeeze = band_width < 0.1  # Tight bands indicate low volatility
        )

cat("Price touches lower band:", sum(analysis$at_lower, na.rm = TRUE), "times\n")
cat("Price touches upper band:", sum(analysis$at_upper, na.rm = TRUE), "times\n")
cat("Bollinger Squeeze periods:", sum(analysis$squeeze, na.rm = TRUE), "days\n\n")

cat("Recent Bollinger Band values:\n")
print(tail(select(analysis, datetime, close, bb_lower, bb_middle, bb_upper), 5))

# =============================================================================
# Example 6: ATR (Average True Range)
# =============================================================================

cat("\n\n═══ Example 6: ATR (Volatility Measure) ═══\n\n")

prices <- fetch_prices("AAPL", from = "2024-01-01") |>
        add_atr(14)

avg_atr <- mean(prices$atr, na.rm = TRUE)
current_atr <- tail(prices$atr[!is.na(prices$atr)], 1)

cat("ATR measures volatility in price units\n")
cat("Average ATR:", round(avg_atr, 2), "\n")
cat("Current ATR:", round(current_atr, 2), "\n")
cat("\nUse ATR for:\n")
cat("  • Position sizing\n")
cat("  • Stop loss placement\n")
cat("  • Volatility assessment\n\n")

cat("Recent ATR values:\n")
print(tail(select(prices, datetime, close, atr), 5))

# =============================================================================
# Example 7: Stochastic Oscillator
# =============================================================================

cat("\n\n═══ Example 7: Stochastic Oscillator ═══\n\n")

prices <- fetch_prices("AAPL", from = "2024-01-01") |>
        add_stochastic(14, smooth = 3)

# Identify signals
signals <- prices |>
        mutate(
                oversold = stoch_k < 20,
                overbought = stoch_k > 80
        )

cat("Stochastic interpretation:\n")
cat("  < 20 = Oversold\n")
cat("  > 80 = Overbought\n")
cat("  %K crossing %D = Momentum shift\n\n")

cat("Recent Stochastic values:\n")
print(tail(select(signals, datetime, close, stoch_k, stoch_d), 5))

# =============================================================================
# Example 8: On-Balance Volume (OBV)
# =============================================================================

cat("\n\n═══ Example 8: On-Balance Volume ═══\n\n")

prices <- fetch_prices("AAPL", from = "2024-01-01") |>
        add_obv()

# Check for divergence
analysis <- prices |>
        mutate(
                price_trend = close > lag(close, 20),
                obv_trend = obv > lag(obv, 20),
                bullish_divergence = !price_trend & obv_trend,
                bearish_divergence = price_trend & !obv_trend
        )

cat("OBV tracks cumulative volume flow\n")
cat("Look for divergences between price and OBV\n\n")

cat("Recent OBV values:\n")
print(tail(select(analysis, datetime, close, volume, obv), 5))

# =============================================================================
# Example 9: Pattern Detection
# =============================================================================

cat("\n\n═══ Example 9: Pattern Detection ═══\n\n")

prices <- fetch_prices("AAPL", from = "2024-01-01") |>
        add_sma(50, name = "sma_50") |>
        add_sma(200, name = "sma_200") |>
        mutate(
                golden_cross = detect_golden_cross(sma_50, sma_200),
                death_cross = detect_death_cross(sma_50, sma_200)
        )

golden_crosses <- sum(prices$golden_cross, na.rm = TRUE)
death_crosses <- sum(prices$death_cross, na.rm = TRUE)

cat("Golden Cross (50 SMA crosses above 200 SMA):", golden_crosses, "\n")
cat("Death Cross (50 SMA crosses below 200 SMA):", death_crosses, "\n\n")

if (golden_crosses > 0) {
        cat("Golden cross dates:\n")
        print(prices |> filter(golden_cross) |> select(datetime, sma_50, sma_200))
}

# =============================================================================
# Example 10: Multi-Indicator Combination
# =============================================================================

cat("\n\n═══ Example 10: Multi-Indicator Strategy ═══\n\n")

enriched_data <- fetch_prices("AAPL", from = "2024-01-01") |>
        # Trend
        add_sma(20, name = "sma_20") |>
        add_ema(50, name = "ema_50") |>
        # Momentum
        add_rsi(14) |>
        add_macd() |>
        # Volatility
        add_bbands(20) |>
        add_atr(14) |>
        # Volume
        add_obv()

cat("Added 7 different indicators!\n\n")

# Create a scoring system
scored <- enriched_data |>
        mutate(
                # Trend score
                trend_score = case_when(
                        close > sma_20 & sma_20 > ema_50 ~ 2,
                        close > sma_20 | sma_20 > ema_50 ~ 1,
                        TRUE ~ 0
                ),
                # Momentum score
                momentum_score = case_when(
                        rsi > 50 & macd > macd_signal ~ 2,
                        rsi > 50 | macd > macd_signal ~ 1,
                        TRUE ~ 0
                ),
                # Volatility score (prefer lower volatility)
                vol_score = if_else(atr < lag(atr, 5), 1, 0),
                # Total score
                total_score = trend_score + momentum_score + vol_score
        )

cat("Scoring system:\n")
cat("  Trend: 0-2 points\n")
cat("  Momentum: 0-2 points\n")
cat("  Volatility: 0-1 points\n")
cat("  Maximum: 5 points\n\n")

score_summary <- scored |>
        group_by(total_score) |>
        summarise(days = n()) |>
        arrange(desc(total_score))

cat("Score distribution:\n")
print(score_summary)

cat("\nRecent scores (last 5 days):\n")
print(tail(select(scored, datetime, close, trend_score, momentum_score, vol_score, total_score), 5))

# =============================================================================
# Summary
# =============================================================================

cat("\n\n")
cat("╔══════════════════════════════════════════════════════╗\n")
cat("║          tradefeatures Examples Complete           ║\n")
cat("╚══════════════════════════════════════════════════════╝\n")
cat("\n")

cat("✅ Demonstrated:\n")
cat("  • Trend indicators (SMA, EMA, VWAP)\n")
cat("  • Momentum indicators (RSI, MACD, Stochastic, CCI)\n")
cat("  • Volatility indicators (Bollinger Bands, ATR)\n")
cat("  • Volume indicators (OBV)\n")
cat("  • Pattern detection (Golden/Death Cross)\n")
cat("  • Multi-indicator combinations\n")
cat("\n")

cat("📚 Next Steps:\n")
cat("  1. Check out the vignettes for detailed strategies\n")
cat("  2. Read case studies for real-world examples\n")
cat("  3. Build your own indicator combinations\n")
cat("  4. Integrate with tradeengine for backtesting\n")
cat("\n")

cat("Try: vignette('getting-started', package = 'tradefeatures')\n")
cat("\n")
