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
