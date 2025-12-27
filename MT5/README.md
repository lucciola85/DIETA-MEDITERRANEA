# MT5 Expert Advisors Portfolio

## Overview

This directory contains a professional portfolio of MetaTrader 5 Expert Advisors designed for diversified automated trading. The portfolio includes three specialized EAs with different strategies, plus a Portfolio Manager for centralized risk control.

---

# EA Portfolio System

## Portfolio Composition

| EA Name | Strategy | Symbol | Timeframe | Capital Allocation |
|---------|----------|--------|-----------|-------------------|
| **TREND_TURTLE** | Trend-Following | US30 (Dow Jones) | D1 | 40% |
| **RANGE_PANTHER** | Mean-Reversion | EURGBP | H4 | 30% |
| **MOMENTUM_SCALPER** | Breakout | XAUUSD (Gold) | H1 | 30% |
| **PORTFOLIO_MANAGER** | Risk Control | All | - | Oversight |

## Correlation Analysis

The portfolio is designed with low correlation between assets:
- **US30 & XAUUSD**: Variable correlation, often decorrelated
- **US30 & EURGBP**: No direct correlation (US index vs EU cross)
- **EURGBP & XAUUSD**: No significant correlation

---

# EA 1: TREND_TURTLE

## Strategy Overview
Trend-following system for capturing macro trends on the Dow Jones Industrial Average (US30).

### Entry Conditions (LONG)
1. EMA(50) above EMA(200) on D1
2. Candle closes above EMA(50)
3. ADX(14) > 25 (trend quality filter)
4. Weekly EMA filter (optional higher timeframe confirmation)

### Entry Conditions (SHORT)
- Inverse of LONG conditions

### Exit Strategy
- **Initial Stop Loss**: 2.5 × ATR(14) from entry
- **Take Profit**: None (exit via trailing stop)
- **Trailing Stop**: Moves to EMA(50) after 1 ATR profit

### Special Features
- ATR volatility filter (avoids dead and hysteric markets)
- Dynamic money management (reduces risk during drawdown)
- Optional pyramiding (add to winning positions)
- CSV logging for all trades

---

# EA 2: RANGE_PANTHER

## Strategy Overview
Mean-reversion system for trading ranges on EURGBP, a historically ranging forex pair.

### Entry Conditions (LONG)
1. Price within Support/Resistance range
2. Price near support (within 0.5 ATR)
3. RSI(14) < 30 (oversold)
4. Linear regression channel is flat (optional)

### Entry Conditions (SHORT)
1. Price near resistance (within 0.5 ATR)
2. RSI(14) > 70 (overbought)

### Exit Strategy
- **Take Profit**: Opposite range level
- **Stop Loss**: Beyond S/R level by 1 ATR
- **Partial Close**: 50% at mid-range, move SL to breakeven
- **Early Exit**: If RSI returns to 50 without hitting TP

### Special Features
- Dynamic S/R via linear regression channel
- Auto-disables when range breaks (1.5 ATR beyond levels)
- Scale-out management for locked profits
- Session filter for London trading hours

---

# EA 3: MOMENTUM_SCALPER

## Strategy Overview
Breakout system for capturing momentum moves on Gold (XAUUSD).

### Entry Conditions (LONG BREAKOUT)
1. **Consolidation Phase**: ATR(14) of last 10 periods < 50-period average
2. **Breakout**: Price closes above 20-period high
3. **Volume Confirmation**: Breakout candle volume > 1.5× average
4. **MACD Confirmation**: Bullish crossover

### Entry Conditions (SHORT BREAKOUT)
- Inverse conditions

### Exit Strategy
- **Stop Loss**: Below consolidation low
- **Take Profit**: 1:2 or 1:3 risk/reward ratio
- **Partial Close**: 50% at 1:1, move to breakeven
- **Extended TP**: Remaining position targets 1:3

### Special Features
- Pullback entry option (wait for retest of breakout level)
- Candlestick pattern recognition (hammer, engulfing)
- Breakeven management
- Multi-timeframe pullback detection

---

# EA 4: PORTFOLIO_MANAGER

## Overview
Master controller that oversees all portfolio EAs with centralized risk management.

### Key Functions

#### Circuit Breaker
- **Trigger**: Portfolio drawdown exceeds 12%
- **Action**: Halts all trading, optionally closes all positions
- **Cooldown**: Resumes after configurable pause period

#### Correlation Monitoring
- Calculates real-time correlation between portfolio symbols
- Alerts when correlation exceeds threshold (0.7)
- Can block correlated trades (optional)

#### Capital Rebalancing
- **Monthly**: Rebalances on specified day
- **Weekly**: Rebalances every Monday
- **On Drift**: Rebalances when allocation drifts > 10%

#### Dashboard
Visual display showing:
- Portfolio equity and drawdown
- Individual EA performance
- Current allocation vs. target
- Correlation matrix
- Circuit breaker status

---

# Common Features (All EAs)

## Money Management

### Position Sizing Formula
```
Lot Size = (Allocated_Capital × Risk%) / (SL_Distance × Value_Per_Pip)
```

### Dynamic Risk Adjustment
```
Current_Risk = Base_Risk × (1 - Current_DD / Max_DD)
```
Reduces risk proportionally during drawdowns.

## Volatility Filter
All EAs filter trades based on ATR:
- **Min ATR**: Avoids low-volatility (holiday) markets
- **Max ATR**: Avoids extreme volatility events

## Logging
- CSV file logging for all trades
- Timestamps, prices, SL/TP, reasons
- Critical event alerts

---

# Installation

1. Copy all `.mq5` files to your MT5 `Experts` folder:
   ```
   [MT5 Data Folder]/MQL5/Experts/
   ```

2. Compile each EA in MetaEditor (F7)

3. Attach EAs to appropriate charts:
   - TREND_TURTLE → US30, D1
   - RANGE_PANTHER → EURGBP, H4
   - MOMENTUM_SCALPER → XAUUSD, H1
   - PORTFOLIO_MANAGER → Any chart

4. Configure capital allocation in each EA to match portfolio targets

---

# Configuration Guide

## Capital Allocation Example
With €100,000 total capital:

| EA | Allocation | Capital |
|----|------------|---------|
| TREND_TURTLE | 40% | €40,000 |
| RANGE_PANTHER | 30% | €30,000 |
| MOMENTUM_SCALPER | 30% | €30,000 |

## Risk Parameters
- **Risk per Trade**: 1% recommended
- **Max Drawdown per EA**: 20%
- **Portfolio Circuit Breaker**: 12%

---

# Backtesting Recommendations

1. Use "Every tick based on real ticks" for accuracy
2. Test minimum 2-3 years of data
3. Include spreads and commissions
4. Test each EA individually first
5. Then test portfolio correlation

---

# Risk Warning

⚠️ **DISCLAIMER**: Trading financial instruments involves substantial risk. Past performance is not indicative of future results. These EAs are provided "as is" without warranty. Only trade with capital you can afford to lose.

---

# GAMORAFX - MT5 Expert Advisor

## Overview

GAMORAFX is a professional MetaTrader 5 Expert Advisor designed for automated forex trading. It implements a multi-strategy approach with advanced risk management features to maximize profitability while minimizing risk.

## Features

### Multi-Strategy Trading System
- **Moving Average Crossover**: Uses fast and slow EMA/SMA crossovers for trend identification
- **RSI (Relative Strength Index)**: Identifies overbought/oversold conditions
- **MACD (Moving Average Convergence Divergence)**: Confirms momentum and trend direction

### Advanced Risk Management
- **Position Sizing**: Automatic lot calculation based on account balance and risk percentage
- **Maximum Drawdown Protection**: Stops trading when maximum drawdown threshold is reached
- **Position Limits**: Configurable maximum number of open positions
- **Trailing Stop**: Dynamic stop loss that follows profitable trades

### Trading Controls
- **Trading Hours Filter**: Optionally restrict trading to specific hours
- **Multiple Timeframe Support**: Works on any timeframe from M1 to MN1
- **Magic Number**: Unique identifier to manage only positions opened by this EA

## Installation

1. Copy `GAMORAFX.mq5` to your MetaTrader 5 `Experts` folder:
   ```
   [MT5 Data Folder]/MQL5/Experts/GAMORAFX.mq5
   ```

2. Compile the EA in MetaEditor (press F7)

3. Attach the EA to your desired chart

4. Configure the input parameters according to your trading preferences

## Input Parameters

### General Settings
| Parameter | Default | Description |
|-----------|---------|-------------|
| Timeframe | H1 | Trading timeframe |
| Magic Number | 123456 | Unique identifier for EA's trades |
| Trade Comment | GAMORAFX | Comment for trade orders |

### Risk Management
| Parameter | Default | Description |
|-----------|---------|-------------|
| Risk per Trade | 2.0% | Percentage of balance to risk per trade |
| Max Drawdown | 20.0% | Maximum allowed drawdown before stopping |
| Max Positions | 3 | Maximum simultaneous open positions |
| Min Lot Size | 0.01 | Minimum lot size |
| Max Lot Size | 10.0 | Maximum lot size |

### Moving Average Strategy
| Parameter | Default | Description |
|-----------|---------|-------------|
| Enable MA Strategy | true | Toggle MA strategy |
| Fast MA Period | 12 | Fast moving average period |
| Slow MA Period | 26 | Slow moving average period |
| MA Method | EMA | Moving average calculation method |

### RSI Strategy
| Parameter | Default | Description |
|-----------|---------|-------------|
| Enable RSI Strategy | true | Toggle RSI strategy |
| RSI Period | 14 | RSI calculation period |
| Overbought Level | 70 | RSI overbought threshold |
| Oversold Level | 30 | RSI oversold threshold |

### MACD Strategy
| Parameter | Default | Description |
|-----------|---------|-------------|
| Enable MACD Strategy | true | Toggle MACD strategy |
| MACD Fast | 12 | Fast EMA period |
| MACD Slow | 26 | Slow EMA period |
| MACD Signal | 9 | Signal line period |

### Stop Loss & Take Profit
| Parameter | Default | Description |
|-----------|---------|-------------|
| Stop Loss | 50 | Stop loss in points |
| Take Profit | 100 | Take profit in points |
| Use Trailing Stop | true | Enable trailing stop |
| Trailing Start | 30 | Points profit before trailing activates |
| Trailing Step | 10 | Trailing stop distance in points |

### Trading Hours
| Parameter | Default | Description |
|-----------|---------|-------------|
| Use Trading Hours | false | Enable time filter |
| Start Hour | 8 | Trading start hour (server time) |
| End Hour | 20 | Trading end hour (server time) |

## Trading Logic

### Signal Generation
The EA requires a majority of enabled strategies to agree before opening a trade:
- If 2-3 strategies are enabled, at least 2 must signal in the same direction
- If only 1 strategy is enabled, its signal is used directly

### Entry Conditions
**Buy Signal:**
- MA: Fast MA crosses above Slow MA
- RSI: RSI crosses above oversold level
- MACD: MACD line crosses above Signal line

**Sell Signal:**
- MA: Fast MA crosses below Slow MA
- RSI: RSI crosses below overbought level
- MACD: MACD line crosses below Signal line

## Risk Disclaimer

⚠️ **WARNING**: Trading foreign exchange on margin carries a high level of risk and may not be suitable for all investors. Before deciding to trade foreign exchange, you should carefully consider your investment objectives, level of experience, and risk appetite.

The possibility exists that you could sustain a loss of some or all of your initial investment and therefore you should not invest money that you cannot afford to lose. You should be aware of all the risks associated with foreign exchange trading and seek advice from an independent financial advisor if you have any doubts.

Past performance is not indicative of future results. This EA is provided "as is" without warranty of any kind.

## Backtesting

Before using GAMORAFX on a live account:
1. Test thoroughly in the Strategy Tester
2. Use "Every tick based on real ticks" for accurate results
3. Test across different market conditions
4. Start with a demo account
5. Only use real money once you understand the EA's behavior

## Support

For support, feature requests, or bug reports, please contact the GAMORAFX team.

## License

Copyright 2024, GAMORAFX Team. All rights reserved.

---

**Happy Trading! 📈**
