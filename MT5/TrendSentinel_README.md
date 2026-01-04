# TrendSentinel EA for MetaTrader 5

## Overview

**TrendSentinel** is an advanced Expert Advisor for MetaTrader 5 that automatically scans multiple markets to identify high-probability trend starts using multi-timeframe analysis and triple confirmation.

## Philosophy

The EA is designed to catch the beginning of genuine trends with high probability by:
- **Triple Confirmation**: Using multiple timeframes to confirm trend direction
- **Quality Filtering**: Only trading signals with quality score ≥ 7/10
- **Smart Entry**: Using stop entry orders to confirm momentum before entering

## Key Features

### Multi-Symbol Scanner
- Automatically scans all symbols in Market Watch
- Customizable symbol list support
- Scheduled scanning every 5 minutes (configurable)
- Analyzes up to 28 major pairs simultaneously

### Multi-Timeframe Analysis
- **Signal Timeframe**: M15 (primary signal generation)
- **Confirmation Timeframe 1**: H1 (trend confirmation)
- **Confirmation Timeframe 2**: H4 (trend confirmation)
- **Filter Timeframe**: D1 (overall trend filter)

### Advanced Trend Detection
The EA uses multiple technical indicators:
- **Triple EMA System**: 8, 21, and 50-period EMAs
- **Donchian Channel**: 20-period for breakout detection
- **ADX**: Measures trend strength (threshold: 25)
- **RSI**: 14-period for momentum confirmation
- **Volume Analysis**: Confirms strength of moves

### Trend Quality Scoring (0-10 Points)

Each signal is scored based on:
1. **Multi-timeframe alignment** (max 4 points)
   - All timeframes aligned: 4 points
   - Partial alignment: 2 points

2. **Trend strength via ADX** (max 2 points)
   - ADX > 35: 2 points
   - ADX > 25: 1 point

3. **Momentum confirmation** (max 2 points)
   - RSI in optimal range: 2 points
   - RSI trending correctly: 1 point

4. **Volume surge** (max 1 point)
   - Volume > 120% of average: 1 point

5. **Structure breakout** (max 1 point)
   - Price breaks Donchian channel: 1 point

### Entry Conditions

#### Bullish Signal
- EMA Fast (8) > EMA Slow (21)
- EMA Fast (8) > EMA Trend (50) on H4
- Close > Donchian High
- ADX +DI > -DI
- Quality Score ≥ 7/10

#### Bearish Signal
- EMA Fast (8) < EMA Slow (21)
- EMA Fast (8) < EMA Trend (50) on H4
- Close < Donchian Low
- ADX -DI > +DI
- Quality Score ≥ 7/10

### Risk Management

#### Position Sizing
- **Risk per trade**: 0.5% of balance (configurable)
- Automatic lot calculation based on SL distance
- Respects broker's min/max lot size limits

#### Risk Limits
- **Max daily risk**: 2.0% of balance
- **Max trades per symbol**: 3
- **Max total trades**: 10
- **Correlation filter**: Avoids highly correlated positions (>0.7)

#### Stop Loss & Take Profit
- **Stop Loss**: 1.8 × ATR
- **Take Profit**: 2.5 × Risk (R:R = 1:2.5)
- **Partial Close**: 50% at 1:1 R:R (breakeven)
- **Trailing Stop**: ATR-based dynamic trailing

### Order Management

#### Stop Entry Orders
- Entry placed at: Current Price + 0.5 × ATR (Bullish)
- Entry placed at: Current Price - 0.5 × ATR (Bearish)
- Confirms momentum before entry

#### Position Management
- Automatic trailing stop based on ATR
- Partial close at breakeven point
- Stop loss moved to breakeven after partial close
- Continuous monitoring of all positions

## Installation

1. Copy `TrendSentinel_MT5.mq5` to your MetaTrader 5 folder:
   ```
   [MT5 Data Folder]/MQL5/Experts/TrendSentinel_MT5.mq5
   ```

2. Compile the EA in MetaEditor (press F7)

3. Attach to any chart (the chart symbol doesn't matter as EA scans all symbols)

4. Configure parameters in the EA settings

## Input Parameters

### SCANNER SETTINGS
| Parameter | Default | Description |
|-----------|---------|-------------|
| ScanInterval | 300 | Seconds between scans (5 minutes) |
| ScanAllSymbols | true | Scan all Market Watch symbols |
| CustomSymbols | "" | Custom symbol list (comma-separated) |

### TREND DETECTION
| Parameter | Default | Description |
|-----------|---------|-------------|
| SignalTF | M15 | Primary signal timeframe |
| ConfirmTF1 | H1 | First confirmation timeframe |
| ConfirmTF2 | H4 | Second confirmation timeframe |
| FilterTF | D1 | Overall trend filter |
| MA_Fast_Period | 8 | Fast EMA period |
| MA_Slow_Period | 21 | Slow EMA period |
| MA_Trend_Period | 50 | Trend EMA period |
| Donchian_Period | 20 | Donchian Channel period |
| ADX_Threshold | 25.0 | Minimum ADX for trend |
| RSI_Period | 14 | RSI period |
| Volume_Lookback | 5 | Volume comparison period |

### ENTRY & EXIT
| Parameter | Default | Description |
|-----------|---------|-------------|
| UseStopEntry | true | Use stop entry orders |
| EntryDistance_ATR | 0.5 | Entry distance (ATR multiplier) |
| SL_ATR_Multiplier | 1.8 | Stop loss (ATR multiplier) |
| TP_RiskReward | 2.5 | Take profit risk:reward ratio |
| UsePartialClose | true | Enable partial position close |
| PartialClose_At | 1.0 | Partial close at R:R ratio |

### RISK MANAGEMENT
| Parameter | Default | Description |
|-----------|---------|-------------|
| RiskPerTrade | 0.5 | Risk per trade (% of balance) |
| MaxDailyRisk | 2.0 | Maximum daily risk (%) |
| MaxOpenTrades | 3 | Max trades per symbol |
| MaxTotalTrades | 10 | Max total open trades |
| UseCorrelationFilter | true | Filter correlated symbols |
| MaxCorrelation | 0.7 | Maximum correlation allowed |

### ADVANCED FILTERS
| Parameter | Default | Description |
|-----------|---------|-------------|
| MinTrendQuality | 7 | Minimum quality score (0-10) |
| FilterNews | true | Avoid trading during news |
| NewsMinutesBefore | 60 | Minutes before news to avoid |
| NewsMinutesAfter | 30 | Minutes after news to avoid |
| OnlyTradingHours | false | Trade only during hours |
| TradingHoursStart | "08:00" | Trading start time |
| TradingHoursEnd | "20:00" | Trading end time |

### GENERAL SETTINGS
| Parameter | Default | Description |
|-----------|---------|-------------|
| MagicNumber | 123456 | Unique EA identifier |
| TradeComment | "TrendSentinel" | Comment for trades |

## Usage Recommendations

### Getting Started
1. **Start on Demo**: Always test on demo account first
2. **Monitor Initial Trades**: Watch the first 10-20 trades to understand behavior
3. **Adjust Parameters**: Tune settings based on your risk tolerance
4. **Check Logs**: Review signal logs regularly

### Optimal Settings for Different Risk Profiles

#### Conservative (Low Risk)
- RiskPerTrade: 0.3%
- MaxDailyRisk: 1.0%
- MaxTotalTrades: 5
- MinTrendQuality: 8

#### Moderate (Medium Risk)
- RiskPerTrade: 0.5%
- MaxDailyRisk: 2.0%
- MaxTotalTrades: 10
- MinTrendQuality: 7

#### Aggressive (High Risk)
- RiskPerTrade: 1.0%
- MaxDailyRisk: 3.0%
- MaxTotalTrades: 15
- MinTrendQuality: 6

### Best Practices

1. **Market Watch Setup**
   - Add major pairs: EURUSD, GBPUSD, USDJPY, etc.
   - Ensure symbols have good liquidity
   - Avoid exotic pairs with wide spreads

2. **VPS Recommended**
   - Run EA on VPS for 24/7 operation
   - Ensures all scans execute on time
   - Prevents missed opportunities

3. **Monitor Daily Risk**
   - Check daily risk usage regularly
   - Adjust if hitting limits too often
   - Review trades that trigger stops

4. **Backtesting**
   - Backtest on "Every tick" mode
   - Test multiple market conditions
   - Verify on different time periods

## Performance Metrics

### Target Performance
- **Profit Factor**: > 1.5
- **Maximum Drawdown**: < 15%
- **Recovery Factor**: > 2.0
- **Sharpe Ratio**: > 1.0
- **Win Rate**: 40-60%
- **Avg Win / Avg Loss**: > 2.0

### Trade Logging
The EA automatically logs all signals to CSV file:
- Filename: `TrendSentinel_Signals_[AccountNumber].csv`
- Location: `MQL5/Files/`
- Contains: Timestamp, Symbol, Direction, Entry, SL, TP, Quality

## Architecture

### Class Structure

#### CSymbolScanner
- Manages symbol list from Market Watch
- Supports custom symbol lists
- Validates symbol availability

#### CTrendDetector
- Multi-timeframe trend analysis
- Quality scoring system
- Signal generation with complete trade parameters

#### CRiskManager
- Position sizing calculations
- Daily risk tracking
- Risk limit enforcement

#### COrderManager
- Order placement (market/stop)
- Position management
- Trailing stop implementation
- Partial close execution

## Event Handlers

### OnInit()
- Initializes all components
- Sets up timer for scanning
- Validates parameters

### OnDeinit()
- Cleanup and resource release
- Final logging

### OnTick()
- Manages open positions
- Applies trailing stops
- Executes partial closes

### OnTimer()
- Scheduled market scanning
- Signal analysis
- Order placement

### OnTrade()
- Trade event logging
- Performance tracking

## Technical Notes

### MT5 Specifics
- Uses `#include <Trade/Trade.mqh>` for trade operations
- Indicator handles managed properly with CopyBuffer()
- ADX uses MAIN_LINE, PLUSDI_LINE, MINUSDI_LINE
- Donchian Channel implemented internally (no external dependency)
- Proper handle release on deinitialization

### Resource Management
- Indicator handles created and released per analysis
- Efficient buffer management
- Timer-based scanning reduces CPU usage

### Error Handling
- Validates all indicator handle creation
- Checks buffer copy operations
- Logs all errors with context

## Troubleshooting

### Common Issues

**EA doesn't open trades**
- Check if symbols are in Market Watch
- Verify minimum quality score isn't too high
- Ensure daily risk limit not reached
- Check if within trading hours (if enabled)

**Too many trades opening**
- Increase MinTrendQuality parameter
- Reduce MaxTotalTrades
- Enable correlation filter
- Reduce RiskPerTrade

**Trailing stop not working**
- Verify positions have correct magic number
- Check ATR values are reasonable
- Ensure positions have initial SL set

**Compilation errors**
- Verify MT5 build is up to date
- Check Trade library is available
- Ensure no syntax errors

## Risk Disclaimer

⚠️ **WARNING**: Trading foreign exchange and CFDs carries a high level of risk and may not be suitable for all investors. Before trading, you should carefully consider your investment objectives, level of experience, and risk appetite.

The possibility exists that you could sustain a loss of some or all of your initial investment. Past performance is not indicative of future results. This EA is provided "as is" without warranty of any kind.

**Always test thoroughly on a demo account before using real money.**

## Support and Development

### Version History
- **v1.00** - Initial release with full feature set

### Future Enhancements
- Integration with economic calendar API
- Machine learning trend quality optimization
- Multi-strategy support
- Advanced correlation matrix
- Performance analytics dashboard

## License

Copyright 2024, Trend Sentinel Team. All rights reserved.

---

**Trade Smart, Catch Trends Early! 📈**
