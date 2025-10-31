# 🚀 Quick Start: tradefeatures

Get started with technical indicators in 5 minutes!

## Installation

```r
devtools::install_github("tradingverse/tradefeatures")
library(tradefeatures)
```

## 30-Second Example

```r
library(tradeio)
library(tradefeatures)
library(dplyr)

# Fetch data and add indicators
aapl <- fetch_prices("AAPL", from = "2024-01-01") |>
  add_sma(20) |>
  add_rsi(14) |>
  add_macd()

# View enriched data
head(aapl)
```

## Common Patterns

### Pattern 1: RSI Oversold

```r
fetch_prices("AAPL", from = "2024-01-01") |>
  add_rsi(14) |>
  filter(rsi < 30)  # Find oversold conditions
```

### Pattern 2: SMA Crossover

```r
fetch_prices("AAPL", from = "2024-01-01") |>
  add_sma(50) |>
  add_sma(200) |>
  mutate(golden_cross = detect_golden_cross(sma_50, sma_200))
```

### Pattern 3: Bollinger Band Squeeze

```r
fetch_prices("AAPL", from = "2024-01-01") |>
  add_bbands(20) |>
  mutate(squeeze = (bb_upper - bb_lower) / bb_middle < 0.1)
```

## Complete Strategy Example

```r
library(tradeengine)

results <- fetch_prices("AAPL", from = "2023-01-01") |>
  add_sma(20) |>
  add_rsi(14) |>
  add_strategy(
    entry = (close > sma_20) & (rsi < 30),
    exit = (close < sma_20) | (rsi > 70)
  ) |>
  backtest(initial_capital = 10000)

print(results$summary)
```

## Available Indicators

### Trend (6)
- `add_sma()` - Simple Moving Average
- `add_ema()` - Exponential Moving Average
- `add_vwap()` - Volume Weighted Average Price
- `sma()`, `ema()` - Standalone functions
- `detect_golden_cross()`, `detect_death_cross()`

### Momentum (5)
- `add_rsi()` - Relative Strength Index
- `add_macd()` - MACD with signal
- `add_stochastic()` - Stochastic Oscillator
- `add_cci()` - Commodity Channel Index
- `add_williams_r()` - Williams %R

### Volatility (2)
- `add_bbands()` - Bollinger Bands
- `add_atr()` - Average True Range

### Volume (1)
- `add_obv()` - On-Balance Volume

### Utils
- `calc_returns()` - Price returns
- `calc_momentum()` - Price momentum

## Learning Resources

```r
# Vignettes
vignette("getting-started")
vignette("case-study-sma-crossover")
vignette("case-study-rsi-mean-reversion")

# Examples
source(system.file("examples/basic_indicators.R", package = "tradefeatures"))

# Help
?add_rsi
?add_macd
?add_bbands
```

## Common Use Cases

### 1. Find Oversold Stocks

```r
fetch_prices(c("AAPL", "MSFT", "GOOGL"), from = "2024-01-01") |>
  add_rsi(14) |>
  group_by(symbol) |>
  filter(datetime == max(datetime)) |>
  filter(rsi < 30) |>
  arrange(rsi)
```

### 2. Identify Trend Direction

```r
fetch_prices("AAPL", from = "2024-01-01") |>
  add_sma(20) |>
  add_sma(50) |>
  add_sma(200) |>
  mutate(trend = case_when(
    close > sma_20 & sma_20 > sma_50 & sma_50 > sma_200 ~ "STRONG BULL",
    close > sma_20 & sma_20 > sma_50 ~ "BULL",
    close < sma_20 & sma_20 < sma_50 ~ "BEAR",
    TRUE ~ "NEUTRAL"
  ))
```

### 3. Measure Volatility

```r
fetch_prices("AAPL", from = "2024-01-01") |>
  add_atr(14) |>
  add_bbands(20) |>
  mutate(
    volatility_level = case_when(
      atr > lag(atr, 20) * 1.5 ~ "HIGH",
      atr < lag(atr, 20) * 0.7 ~ "LOW",
      TRUE ~ "NORMAL"
    )
  )
```

## Tips

✅ **Start simple** - Master 2-3 indicators first  
✅ **Combine categories** - Use trend + momentum + volatility  
✅ **Always backtest** - Test before trading real money  
✅ **Watch for overfitting** - Don't use too many indicators  
✅ **Understand the math** - Know how indicators work  

## Next Steps

1. Run `source(system.file("examples/basic_indicators.R", package = "tradefeatures"))`
2. Read `vignette("getting-started")`
3. Try a case study: `vignette("case-study-sma-crossover")`
4. Build your own strategy!

---

**Need help?** Check the documentation: `?tradefeatures`

Happy trading! 📈
