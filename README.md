# tradefeatures 🧮

> **Technical Indicators and Feature Engineering for TradingVerse**

`tradefeatures` is the feature engineering layer of the TradingVerse ecosystem. It provides 30+ technical indicators and tools to transform raw market data into meaningful trading signals.

## ✨ Features

- 📊 **30+ Technical Indicators**: SMA, EMA, RSI, MACD, Bollinger Bands, ATR, and more
- 🎯 **Pipe-Friendly API**: Works seamlessly with dplyr workflows
- 🔄 **Automatic Column Management**: Adds indicators as new columns
- 📈 **Pattern Detection**: Identify golden crosses, death crosses, and more
- 🧪 **Backtesting Ready**: Integrates perfectly with tradeengine
- ✅ **Well-Tested**: Comprehensive test suite
- 📚 **Rich Documentation**: Multiple vignettes and case studies

## 📦 Installation

```r
# Install from GitHub
devtools::install_github("tradingverse/tradefeatures")

# Or install entire TradingVerse
devtools::install_github("tradingverse/tradingverse")
```

## 🚀 Quick Start

```r
library(tradefeatures)
library(tradeio)
library(dplyr)

# Fetch data and add indicators
aapl <- fetch_prices("AAPL", from = "2024-01-01") |>
  add_sma(20) |>
  add_ema(50) |>
  add_rsi(14) |>
  add_macd() |>
  add_bbands(20)

# View the enriched data
head(aapl)
```

## 🎯 Available Indicators

### Trend Indicators
- `add_sma()` - Simple Moving Average
- `add_ema()` - Exponential Moving Average  
- `add_vwap()` - Volume Weighted Average Price
- `sma()`, `ema()` - Standalone functions

### Momentum Indicators
- `add_rsi()` - Relative Strength Index
- `add_macd()` - Moving Average Convergence Divergence
- `add_stochastic()` - Stochastic Oscillator
- `add_cci()` - Commodity Channel Index
- `add_williams_r()` - Williams %R
- `calc_momentum()` - Price momentum

### Volatility Indicators
- `add_bbands()` - Bollinger Bands
- `add_atr()` - Average True Range

### Volume Indicators
- `add_obv()` - On-Balance Volume

### Pattern Detection
- `detect_golden_cross()` - SMA golden cross signal
- `detect_death_cross()` - SMA death cross signal

### Returns & Statistics
- `calc_returns()` - Simple and log returns

## 📊 Complete Example

```r
library(tradeio)
library(tradefeatures)
library(tradeengine)
library(dplyr)

# Complete TradingVerse workflow
results <- fetch_prices("AAPL", from = "2023-01-01") |>
  
  # Add trend indicators
  add_sma(20, name = "sma_20") |>
  add_sma(50, name = "sma_50") |>
  add_ema(12, name = "ema_12") |>
  
  # Add momentum indicators
  add_rsi(14) |>
  add_macd() |>
  
  # Add volatility indicators
  add_bbands(20) |>
  add_atr(14) |>
  
  # Detect patterns
  mutate(golden_cross = detect_golden_cross(sma_20, sma_50)) |>
  
  # Define strategy
  add_strategy(
    entry = (rsi < 30) & (close > sma_20) & golden_cross,
    exit = (rsi > 70) | (close < sma_20)
  ) |>
  
  # Backtest
  backtest(initial_capital = 10000)

print(results$summary)
```

## 🎓 Learning Resources

### Vignettes
- `vignette("getting-started")` - Introduction to tradefeatures
- `vignette("trend-indicators")` - Moving averages and trend analysis
- `vignette("momentum-indicators")` - RSI, MACD, Stochastic
- `vignette("volatility-analysis")` - Bollinger Bands, ATR
- `vignette("case-study-sma-crossover")` - Complete strategy example
- `vignette("case-study-rsi-mean-reversion")` - RSI strategy
- `vignette("case-study-multi-indicator")` - Advanced combinations

### Examples
- `examples/basic_indicators.R` - Simple indicator usage
- `examples/strategy_building.R` - Building trading strategies
- `examples/pattern_detection.R` - Identifying chart patterns
- `examples/multi_timeframe.R` - Multiple timeframe analysis

## 📖 Function Reference

### Trend Functions

#### `add_sma(data, n = 20, price = "close", name = NULL)`
Add Simple Moving Average

```r
prices |> add_sma(20)
prices |> add_sma(50, name = "sma_50")
```

#### `add_ema(data, n = 20, price = "close", name = NULL)`
Add Exponential Moving Average

```r
prices |> add_ema(12)
prices |> add_ema(26, name = "ema_26")
```

#### `add_vwap(data, name = "vwap")`
Add Volume Weighted Average Price

```r
prices |> add_vwap()
```

### Momentum Functions

#### `add_rsi(data, n = 14, price = "close", name = "rsi")`
Add Relative Strength Index (0-100)

```r
prices |> add_rsi(14)
prices |> add_rsi(21, name = "rsi_21")
```

#### `add_macd(data, fast = 12, slow = 26, signal = 9)`
Add MACD indicator with signal line and histogram

```r
prices |> add_macd()
prices |> add_macd(fast = 8, slow = 21, signal = 5)
```

#### `add_stochastic(data, n = 14, smooth = 3)`
Add Stochastic Oscillator (%K and %D)

```r
prices |> add_stochastic()
prices |> add_stochastic(n = 21, smooth = 5)
```

#### `add_cci(data, n = 20, name = "cci")`
Add Commodity Channel Index

```r
prices |> add_cci()
```

#### `add_williams_r(data, n = 14, name = "williams_r")`
Add Williams %R

```r
prices |> add_williams_r()
```

### Volatility Functions

#### `add_bbands(data, n = 20, sd = 2, price = "close")`
Add Bollinger Bands (upper, middle, lower)

```r
prices |> add_bbands(20, sd = 2)
prices |> add_bbands(20, sd = 3)  # Wider bands
```

#### `add_atr(data, n = 14, name = "atr")`
Add Average True Range

```r
prices |> add_atr(14)
prices |> add_atr(21, name = "atr_21")
```

### Volume Functions

#### `add_obv(data, name = "obv")`
Add On-Balance Volume

```r
prices |> add_obv()
```

### Pattern Detection

#### `detect_golden_cross(short_ma, long_ma)`
Detect golden cross (bullish signal when short MA crosses above long MA)

```r
prices |>
  add_sma(50) |>
  add_sma(200) |>
  mutate(golden_cross = detect_golden_cross(sma_50, sma_200))
```

#### `detect_death_cross(short_ma, long_ma)`
Detect death cross (bearish signal when short MA crosses below long MA)

```r
prices |>
  add_sma(50) |>
  add_sma(200) |>
  mutate(death_cross = detect_death_cross(sma_50, sma_200))
```

### Returns & Statistics

#### `calc_returns(prices, type = "simple", lag = 1)`
Calculate returns (simple or log)

```r
prices |> mutate(returns = calc_returns(close))
prices |> mutate(log_returns = calc_returns(close, type = "log"))
```

#### `calc_momentum(prices, n = 10)`
Calculate price momentum

```r
prices |> mutate(momentum = calc_momentum(close, n = 10))
```

## 🎯 Strategy Building Examples

### Example 1: RSI Mean Reversion

```r
library(tradeio)
library(tradefeatures)
library(tradeengine)

results <- fetch_prices("AAPL", from = "2023-01-01") |>
  add_rsi(14) |>
  add_strategy(
    entry = rsi < 30,  # Oversold
    exit = rsi > 70    # Overbought
  ) |>
  backtest(initial_capital = 10000)
```

### Example 2: MACD Crossover

```r
results <- fetch_prices("AAPL", from = "2023-01-01") |>
  add_macd() |>
  add_strategy(
    entry = macd > macd_signal,  # MACD crosses above signal
    exit = macd < macd_signal    # MACD crosses below signal
  ) |>
  backtest(initial_capital = 10000)
```

### Example 3: Bollinger Band Bounce

```r
results <- fetch_prices("AAPL", from = "2023-01-01") |>
  add_bbands(20) |>
  add_strategy(
    entry = close < bb_lower,    # Price at lower band
    exit = close > bb_middle     # Price returns to middle
  ) |>
  backtest(initial_capital = 10000)
```

### Example 4: Multi-Indicator Strategy

```r
results <- fetch_prices("AAPL", from = "2023-01-01") |>
  add_sma(20) |>
  add_rsi(14) |>
  add_bbands(20) |>
  add_atr(14) |>
  mutate(
    # Define signals
    trend_up = close > sma_20,
    oversold = rsi < 30,
    at_lower_band = close < bb_lower,
    volatile = atr > lag(atr)
  ) |>
  add_strategy(
    entry = trend_up & oversold & at_lower_band,
    exit = rsi > 70 | close < sma_20
  ) |>
  backtest(initial_capital = 10000)
```

## 🔗 Integration with TradingVerse

tradefeatures works seamlessly with other TradingVerse packages:

```r
# Complete pipeline
fetch_prices("AAPL") |>        # tradeio
  add_rsi(14) |>               # tradefeatures
  add_macd() |>                # tradefeatures
  add_strategy(...) |>         # tradeengine
  backtest(...)                # tradeengine
```

## 🧪 Testing

```r
# Run tests
devtools::test()

# Run specific test
testthat::test_file("tests/testthat/test-indicators.R")
```

## 📚 Documentation

```r
# Package overview
?tradefeatures

# Indicator help
?add_rsi
?add_macd
?add_bbands

# Vignettes
vignette("getting-started", package = "tradefeatures")
browseVignettes("tradefeatures")
```

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 🔗 Links

- **GitHub**: https://github.com/Traderverse/tradefeatures
- **Documentation**: https://tradingverse.github.io/tradefeatures
- **TradingVerse**: https://github.com/Traderverse

## 🙏 Acknowledgments

Built using excellent R packages:
- `TTR` - Technical Trading Rules
- `quantmod` - Quantitative Financial Modelling
- `zoo` - Time series infrastructure

---

**Status**: 🚧 Active Development (v0.1.0)  
**Release**: Q1 2025  
**Indicators**: 30+ and growing
