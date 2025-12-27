//+------------------------------------------------------------------+
//|                                                  RANGE_PANTHER.mq5 |
//|                                    Copyright 2024, Trading Portfolio |
//|                      EA 2: Mean-Reversion Strategy for EURGBP (H4) |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trading Portfolio"
#property link      "https://github.com/lucciola85"
#property version   "1.00"
#property description "RANGE_PANTHER - Mean-Reversion Expert Advisor"
#property description "Designed for EURGBP on H4 timeframe"
#property description "Uses Support/Resistance levels with RSI and regression channel"
#property strict

//--- Include standard library files
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Input Parameters - General Settings                               |
//+------------------------------------------------------------------+
input group "═══════════ GENERAL SETTINGS ═══════════"
input string            InpEAName           = "RANGE_PANTHER";     // EA Name
input int               InpMagicNumber      = 111002;              // Magic Number
input string            InpTradeComment     = "RP_H4";             // Trade Comment
input ENUM_TIMEFRAMES   InpTimeframe        = PERIOD_H4;           // Main Timeframe (H4 recommended)

//+------------------------------------------------------------------+
//| Input Parameters - Capital Allocation                             |
//+------------------------------------------------------------------+
input group "═══════════ CAPITAL & RISK MANAGEMENT ═══════════"
input double            InpAllocatedCapital = 10000.0;             // Capital Allocated to this EA
input double            InpRiskPercent      = 1.0;                 // Risk per Trade (%)
input double            InpRiskBase         = 1.0;                 // Base Risk % (for dynamic adjustment)
input double            InpMaxDrawdownPct   = 20.0;                // Max Acceptable Drawdown (%)
input double            InpMinLotSize       = 0.01;                // Minimum Lot Size
input double            InpMaxLotSize       = 5.0;                 // Maximum Lot Size
input int               InpMaxPositions     = 1;                   // Max Open Positions

//+------------------------------------------------------------------+
//| Input Parameters - Range Detection                                |
//+------------------------------------------------------------------+
input group "═══════════ RANGE DETECTION ═══════════"
input int               InpRangePeriod      = 50;                  // Range Lookback Period
input double            InpProximityATR     = 0.5;                 // Proximity to S/R (ATR multiplier)
input double            InpBreakoutATR      = 1.5;                 // Breakout Threshold (ATR multiplier)

//+------------------------------------------------------------------+
//| Input Parameters - Linear Regression Channel                      |
//+------------------------------------------------------------------+
input group "═══════════ REGRESSION CHANNEL ═══════════"
input bool              InpUseRegChannel    = true;                // Use Linear Regression Channel
input int               InpRegPeriod        = 50;                  // Regression Period
input double            InpRegDeviation     = 2.0;                 // Standard Deviations
input double            InpMaxChannelSlope  = 0.0001;              // Max Channel Slope (flat range)

//+------------------------------------------------------------------+
//| Input Parameters - RSI Settings                                   |
//+------------------------------------------------------------------+
input group "═══════════ RSI OSCILLATOR ═══════════"
input int               InpRSIPeriod        = 14;                  // RSI Period
input int               InpRSIOversold      = 30;                  // RSI Oversold Level
input int               InpRSIOverbought    = 70;                  // RSI Overbought Level
input int               InpRSIMidLevel      = 50;                  // RSI Middle Level (for early exit)

//+------------------------------------------------------------------+
//| Input Parameters - ATR Settings                                   |
//+------------------------------------------------------------------+
input group "═══════════ ATR SETTINGS ═══════════"
input int               InpATRPeriod        = 14;                  // ATR Period
input double            InpSLATRMultiplier  = 1.0;                 // SL beyond S/R (ATR mult)

//+------------------------------------------------------------------+
//| Input Parameters - Volatility Filter                              |
//+------------------------------------------------------------------+
input group "═══════════ VOLATILITY FILTER ═══════════"
input bool              InpUseATRFilter     = true;                // Enable ATR Volatility Filter
input double            InpATRMinPercent    = 0.1;                 // Min ATR as % of Price
input double            InpATRMaxPercent    = 1.0;                 // Max ATR as % of Price

//+------------------------------------------------------------------+
//| Input Parameters - Session Filter                                 |
//+------------------------------------------------------------------+
input group "═══════════ SESSION FILTER ═══════════"
input bool              InpUseSessionFilter = true;                // Enable Session Filter
input int               InpSessionStart     = 8;                   // Session Start Hour (London)
input int               InpSessionEnd       = 17;                  // Session End Hour

//+------------------------------------------------------------------+
//| Input Parameters - Partial Close (Scale-Out)                      |
//+------------------------------------------------------------------+
input group "═══════════ PARTIAL CLOSE ═══════════"
input bool              InpUsePartialClose  = true;                // Enable Partial Close
input double            InpPartialPercent   = 50.0;                // % to close at TP1
input double            InpTP1Ratio         = 0.5;                 // TP1 at % of full range

//+------------------------------------------------------------------+
//| Input Parameters - Range Disabling                                |
//+------------------------------------------------------------------+
input group "═══════════ RANGE BREAK MANAGEMENT ═══════════"
input bool              InpDisableOnBreak   = true;                // Disable if range breaks
input int               InpCooldownBars     = 10;                  // Bars to wait after break

//+------------------------------------------------------------------+
//| Input Parameters - Logging                                        |
//+------------------------------------------------------------------+
input group "═══════════ LOGGING ═══════════"
input bool              InpEnableLogging    = true;                // Enable CSV Logging
input bool              InpEnableAlerts     = true;                // Enable Alerts

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
CTrade          g_trade;
CSymbolInfo     g_symbolInfo;
CPositionInfo   g_positionInfo;
CAccountInfo    g_accountInfo;

// Indicator handles
int g_handleRSI, g_handleATR;

// Indicator buffers
double g_bufRSI[], g_bufATR[];

// State variables
double g_initialCapital;
double g_highestEquity;
double g_currentDrawdown;
datetime g_lastBarTime;
double g_supportLevel;
double g_resistanceLevel;
double g_rangeSize;
bool g_rangeDisabled;
int g_cooldownCounter;
bool g_partialCloseDone;
double g_regSlope;
double g_regIntercept;
double g_regUpper;
double g_regLower;
int g_fileHandle;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- Initialize symbol info
    if(!g_symbolInfo.Name(_Symbol))
    {
        Print("Error: Failed to initialize symbol info for ", _Symbol);
        return(INIT_FAILED);
    }
    
    //--- Validate trading environment
    if(!ValidateTradingEnvironment())
        return(INIT_FAILED);
    
    //--- Set up trade object
    g_trade.SetExpertMagicNumber(InpMagicNumber);
    g_trade.SetDeviationInPoints(15);
    g_trade.SetAsyncMode(false);
    SetOptimalFillingType();
    
    //--- Create indicator handles
    if(!CreateIndicatorHandles())
        return(INIT_FAILED);
    
    //--- Initialize buffers
    InitializeBuffers();
    
    //--- Initialize state
    //--- Use actual account equity for drawdown tracking (important for backtesting!)
    g_initialCapital = g_accountInfo.Equity();
    g_highestEquity = g_initialCapital;
    g_currentDrawdown = 0;
    g_lastBarTime = 0;
    g_supportLevel = 0;
    g_resistanceLevel = 0;
    g_rangeSize = 0;
    g_rangeDisabled = false;
    g_cooldownCounter = 0;
    g_partialCloseDone = false;
    g_regSlope = 0;
    g_regIntercept = 0;
    g_regUpper = 0;
    g_regLower = 0;
    
    //--- Open log file
    if(InpEnableLogging)
    {
        string filename = InpEAName + "_" + _Symbol + "_Log.csv";
        g_fileHandle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_COMMON, ',');
        if(g_fileHandle != INVALID_HANDLE)
        {
            FileWrite(g_fileHandle, "Timestamp", "Action", "Price", "SL", "TP", "Lots", "Reason");
        }
    }
    
    //--- Calculate initial range
    CalculateRange();
    
    Print("═══════════════════════════════════════════════════");
    Print("  ", InpEAName, " initialized successfully");
    Print("  Symbol: ", _Symbol);
    Print("  Timeframe: ", EnumToString(InpTimeframe));
    Print("  Allocated Capital: ", InpAllocatedCapital);
    Print("  Risk per Trade: ", InpRiskPercent, "%");
    Print("  Range Period: ", InpRangePeriod);
    Print("  RSI: ", InpRSIPeriod, " (", InpRSIOversold, "/", InpRSIOverbought, ")");
    Print("═══════════════════════════════════════════════════");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- Release indicator handles
    if(g_handleRSI != INVALID_HANDLE) IndicatorRelease(g_handleRSI);
    if(g_handleATR != INVALID_HANDLE) IndicatorRelease(g_handleATR);
    
    //--- Close log file
    if(g_fileHandle != INVALID_HANDLE)
        FileClose(g_fileHandle);
    
    Print(InpEAName, " deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    //--- Update symbol info
    if(!g_symbolInfo.RefreshRates())
        return;
    
    //--- Manage partial close (on every tick for immediate execution)
    if(InpUsePartialClose && !g_partialCloseDone)
        ManagePartialClose();
    
    //--- Check for new bar
    datetime currentBarTime = iTime(_Symbol, InpTimeframe, 0);
    if(currentBarTime == g_lastBarTime)
        return;
    g_lastBarTime = currentBarTime;
    
    //--- Update drawdown
    UpdateDrawdown();
    
    //--- Check if trading is allowed
    if(!IsTradingAllowed())
        return;
    
    //--- Copy indicator buffers
    if(!CopyIndicatorBuffers())
        return;
    
    //--- Check session filter
    if(InpUseSessionFilter && !IsValidSession())
        return;
    
    //--- Check volatility filter
    if(InpUseATRFilter && !PassVolatilityFilter())
        return;
    
    //--- Handle cooldown
    if(g_cooldownCounter > 0)
    {
        g_cooldownCounter--;
        return;
    }
    
    //--- Recalculate range levels
    CalculateRange();
    
    //--- Check if range has been broken
    if(InpDisableOnBreak && CheckRangeBreak())
    {
        g_rangeDisabled = true;
        g_cooldownCounter = InpCooldownBars;
        Print("Range broken! Trading disabled for ", InpCooldownBars, " bars");
        return;
    }
    else
    {
        g_rangeDisabled = false;
    }
    
    //--- Check for exit conditions (RSI returning to middle)
    CheckEarlyExit();
    
    //--- Check for new entry signals
    if(CountPositions() < InpMaxPositions && !g_rangeDisabled)
    {
        int signal = GetTradeSignal();
        if(signal != 0)
        {
            ExecuteTrade(signal);
        }
    }
}

//+------------------------------------------------------------------+
//| Validate trading environment                                      |
//+------------------------------------------------------------------+
bool ValidateTradingEnvironment()
{
    if(!g_symbolInfo.IsSynchronized())
    {
        Print("Error: Symbol not synchronized");
        return false;
    }
    
    if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
    {
        Print("Error: Algorithmic trading not allowed");
        return false;
    }
    
    if(!TerminalInfoInteger(TERMINAL_CONNECTED))
    {
        Print("Error: Terminal not connected to server");
        return false;
    }
    
    int barsAvailable = Bars(_Symbol, InpTimeframe);
    int barsNeeded = InpRangePeriod + 50;
    if(barsAvailable < barsNeeded)
    {
        Print("Error: Insufficient historical data");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Create indicator handles                                         |
//+------------------------------------------------------------------+
bool CreateIndicatorHandles()
{
    //--- RSI
    g_handleRSI = iRSI(_Symbol, InpTimeframe, InpRSIPeriod, PRICE_CLOSE);
    if(g_handleRSI == INVALID_HANDLE)
    {
        Print("Error: Failed to create RSI handle");
        return false;
    }
    
    //--- ATR
    g_handleATR = iATR(_Symbol, InpTimeframe, InpATRPeriod);
    if(g_handleATR == INVALID_HANDLE)
    {
        Print("Error: Failed to create ATR handle");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Initialize buffers                                               |
//+------------------------------------------------------------------+
void InitializeBuffers()
{
    ArraySetAsSeries(g_bufRSI, true);
    ArraySetAsSeries(g_bufATR, true);
}

//+------------------------------------------------------------------+
//| Copy indicator buffers                                           |
//+------------------------------------------------------------------+
bool CopyIndicatorBuffers()
{
    int bars = 10;
    
    if(CopyBuffer(g_handleRSI, 0, 0, bars, g_bufRSI) < bars) return false;
    if(CopyBuffer(g_handleATR, 0, 0, bars, g_bufATR) < bars) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Calculate Support/Resistance range                                |
//+------------------------------------------------------------------+
void CalculateRange()
{
    //--- Use linear regression channel if enabled
    if(InpUseRegChannel)
    {
        CalculateRegressionChannel();
        
        //--- Check if channel is flat enough
        if(MathAbs(g_regSlope) <= InpMaxChannelSlope)
        {
            g_resistanceLevel = g_regUpper;
            g_supportLevel = g_regLower;
            g_rangeSize = g_resistanceLevel - g_supportLevel;
            return;
        }
    }
    
    //--- Fallback: Use simple High/Low
    double highestHigh = 0;
    double lowestLow = DBL_MAX;
    
    for(int i = 1; i <= InpRangePeriod; i++)
    {
        double high = iHigh(_Symbol, InpTimeframe, i);
        double low = iLow(_Symbol, InpTimeframe, i);
        
        if(high > highestHigh) highestHigh = high;
        if(low < lowestLow) lowestLow = low;
    }
    
    g_resistanceLevel = highestHigh;
    g_supportLevel = lowestLow;
    g_rangeSize = g_resistanceLevel - g_supportLevel;
}

//+------------------------------------------------------------------+
//| Calculate Linear Regression Channel                               |
//+------------------------------------------------------------------+
void CalculateRegressionChannel()
{
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    int n = InpRegPeriod;
    
    double closes[];
    ArrayResize(closes, n);
    
    for(int i = 0; i < n; i++)
    {
        double close = iClose(_Symbol, InpTimeframe, i + 1);
        closes[i] = close;
        
        double x = i;
        sumX += x;
        sumY += close;
        sumXY += x * close;
        sumX2 += x * x;
    }
    
    //--- Calculate slope and intercept
    double denominator = (n * sumX2 - sumX * sumX);
    if(denominator == 0)
    {
        g_regSlope = 0;
        g_regIntercept = sumY / n;
    }
    else
    {
        g_regSlope = (n * sumXY - sumX * sumY) / denominator;
        g_regIntercept = (sumY - g_regSlope * sumX) / n;
    }
    
    //--- Calculate standard deviation
    double sumSqDev = 0;
    for(int i = 0; i < n; i++)
    {
        double expected = g_regIntercept + g_regSlope * i;
        double deviation = closes[i] - expected;
        sumSqDev += deviation * deviation;
    }
    double stdDev = MathSqrt(sumSqDev / n);
    
    //--- Calculate channel bounds at current bar
    double currentReg = g_regIntercept; // At bar 0
    g_regUpper = currentReg + stdDev * InpRegDeviation;
    g_regLower = currentReg - stdDev * InpRegDeviation;
}

//+------------------------------------------------------------------+
//| Check if range has been broken                                    |
//+------------------------------------------------------------------+
bool CheckRangeBreak()
{
    if(g_supportLevel == 0 || g_resistanceLevel == 0)
        return false;
    
    double atr = g_bufATR[1];
    double close = iClose(_Symbol, InpTimeframe, 1);
    
    //--- Check breakout above resistance
    if(close > g_resistanceLevel + atr * InpBreakoutATR)
        return true;
    
    //--- Check breakout below support
    if(close < g_supportLevel - atr * InpBreakoutATR)
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Get trade signal                                                  |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
    if(g_supportLevel == 0 || g_resistanceLevel == 0)
    {
        Print("No S/R levels yet - Support:", g_supportLevel, " Resistance:", g_resistanceLevel);
        return 0;
    }
    
    double close = iClose(_Symbol, InpTimeframe, 1);
    double rsi = g_bufRSI[1];
    double atr = g_bufATR[1];
    double proximity = atr * InpProximityATR;
    
    //--- Debug print (once per day)
    static datetime lastPrintTime = 0;
    datetime currentTime = TimeCurrent();
    if(currentTime - lastPrintTime > 86400)
    {
        Print("Range Check: S=", g_supportLevel, " R=", g_resistanceLevel, " Close=", close, " RSI=", rsi, " Prox=", proximity);
        lastPrintTime = currentTime;
    }
    
    //--- LONG conditions (at support):
    // 1. Price near support level (within proximity ATR)
    // 2. RSI is oversold
    // 3. No existing position
    if(close <= g_supportLevel + proximity && close >= g_supportLevel - proximity)
    {
        if(rsi < InpRSIOversold)
        {
            if(!HasPositionType(POSITION_TYPE_BUY))
            {
                Print("LONG signal: Price near support (", close, "), RSI oversold (", rsi, ")");
                return 1;
            }
        }
    }
    
    //--- SHORT conditions (at resistance):
    // 1. Price near resistance level (within proximity ATR)
    // 2. RSI is overbought
    // 3. No existing position
    if(close >= g_resistanceLevel - proximity && close <= g_resistanceLevel + proximity)
    {
        if(rsi > InpRSIOverbought)
        {
            if(!HasPositionType(POSITION_TYPE_SELL))
            {
                Print("SHORT signal: Price near resistance (", close, "), RSI overbought (", rsi, ")");
                return -1;
            }
        }
    }
    
    return 0;
}

//+------------------------------------------------------------------+
//| Execute trade                                                     |
//+------------------------------------------------------------------+
void ExecuteTrade(int signal)
{
    double atr = g_bufATR[1];
    double ask = g_symbolInfo.Ask();
    double bid = g_symbolInfo.Bid();
    int digits = (int)g_symbolInfo.Digits();
    
    double sl, tp;
    double slDistance;
    
    if(signal > 0) // BUY at support
    {
        //--- SL below support
        slDistance = MathAbs(ask - g_supportLevel) + atr * InpSLATRMultiplier;
        sl = NormalizeDouble(ask - slDistance, digits);
        
        //--- TP at resistance
        tp = NormalizeDouble(g_resistanceLevel, digits);
        
        double lotSize = CalculateLotSize(slDistance);
        
        if(g_trade.Buy(lotSize, _Symbol, ask, sl, tp, InpTradeComment))
        {
            g_partialCloseDone = false;
            LogTrade("BUY", ask, sl, tp, lotSize, "Mean reversion LONG at support");
            
            if(InpEnableAlerts)
                Alert(InpEAName, ": BUY opened at support on ", _Symbol);
        }
        else
        {
            Print("Error opening BUY: ", g_trade.ResultRetcode(), " - ", g_trade.ResultRetcodeDescription());
        }
    }
    else if(signal < 0) // SELL at resistance
    {
        //--- SL above resistance
        slDistance = MathAbs(g_resistanceLevel - bid) + atr * InpSLATRMultiplier;
        sl = NormalizeDouble(bid + slDistance, digits);
        
        //--- TP at support
        tp = NormalizeDouble(g_supportLevel, digits);
        
        double lotSize = CalculateLotSize(slDistance);
        
        if(g_trade.Sell(lotSize, _Symbol, bid, sl, tp, InpTradeComment))
        {
            g_partialCloseDone = false;
            LogTrade("SELL", bid, sl, tp, lotSize, "Mean reversion SHORT at resistance");
            
            if(InpEnableAlerts)
                Alert(InpEAName, ": SELL opened at resistance on ", _Symbol);
        }
        else
        {
            Print("Error opening SELL: ", g_trade.ResultRetcode(), " - ", g_trade.ResultRetcodeDescription());
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate lot size                                                |
//+------------------------------------------------------------------+
double CalculateLotSize(double slDistance)
{
    //--- Dynamic risk adjustment
    double riskPercent = InpRiskBase;
    if(g_currentDrawdown > 0)
    {
        riskPercent = InpRiskBase * (1.0 - (g_currentDrawdown / InpMaxDrawdownPct));
        riskPercent = MathMax(riskPercent, InpRiskBase * 0.25);
    }
    
    double riskAmount = InpAllocatedCapital * (riskPercent / 100.0);
    
    double tickValue = g_symbolInfo.TickValue();
    double tickSize = g_symbolInfo.TickSize();
    
    if(tickValue <= 0 || tickSize <= 0)
        return InpMinLotSize;
    
    double slTicks = slDistance / tickSize;
    double lotSize = riskAmount / (slTicks * tickValue);
    
    //--- Normalize
    double lotStep = g_symbolInfo.LotsStep();
    double minLot = g_symbolInfo.LotsMin();
    double maxLot = g_symbolInfo.LotsMax();
    
    lotSize = MathFloor(lotSize / lotStep) * lotStep;
    lotSize = MathMax(lotSize, InpMinLotSize);
    lotSize = MathMin(lotSize, InpMaxLotSize);
    lotSize = MathMax(lotSize, minLot);
    lotSize = MathMin(lotSize, maxLot);
    
    return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Manage partial close (scale-out)                                  |
//+------------------------------------------------------------------+
void ManagePartialClose()
{
    int total = PositionsTotal();
    
    for(int i = total - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) continue;
        
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
        
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double tp = PositionGetDouble(POSITION_TP);
        double sl = PositionGetDouble(POSITION_SL);
        double volume = PositionGetDouble(POSITION_VOLUME);
        ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        
        double currentPrice = (posType == POSITION_TYPE_BUY) ? g_symbolInfo.Bid() : g_symbolInfo.Ask();
        
        //--- Calculate TP1 (midpoint)
        double fullDistance = MathAbs(tp - openPrice);
        double tp1Distance = fullDistance * InpTP1Ratio;
        double tp1Level;
        
        if(posType == POSITION_TYPE_BUY)
            tp1Level = openPrice + tp1Distance;
        else
            tp1Level = openPrice - tp1Distance;
        
        //--- Check if TP1 reached
        bool tp1Reached = (posType == POSITION_TYPE_BUY) ? 
                          (currentPrice >= tp1Level) : (currentPrice <= tp1Level);
        
        if(tp1Reached)
        {
            //--- Close partial position
            double closeVolume = NormalizeDouble(volume * (InpPartialPercent / 100.0), 2);
            closeVolume = MathMax(closeVolume, g_symbolInfo.LotsMin());
            
            if(closeVolume < volume)
            {
                if(g_trade.PositionClosePartial(ticket, closeVolume))
                {
                    g_partialCloseDone = true;
                    
                    //--- Move SL to breakeven
                    int digits = (int)g_symbolInfo.Digits();
                    double newSL = NormalizeDouble(openPrice, digits);
                    g_trade.PositionModify(ticket, newSL, tp);
                    
                    LogTrade("PARTIAL_CLOSE", currentPrice, newSL, tp, closeVolume, "TP1 reached, moved SL to breakeven");
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check for early exit (RSI returning to middle)                    |
//+------------------------------------------------------------------+
void CheckEarlyExit()
{
    int total = PositionsTotal();
    double rsi = g_bufRSI[1];
    
    for(int i = total - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) continue;
        
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
        
        ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        
        //--- For LONG: exit if RSI rises above 50 without hitting TP
        if(posType == POSITION_TYPE_BUY && rsi > InpRSIMidLevel)
        {
            double profit = PositionGetDouble(POSITION_PROFIT);
            if(profit > 0) // Only if in profit
            {
                if(g_trade.PositionClose(ticket))
                {
                    LogTrade("EARLY_EXIT", g_symbolInfo.Bid(), 0, 0, 0, "RSI returned to middle (LONG)");
                }
            }
        }
        
        //--- For SHORT: exit if RSI falls below 50 without hitting TP
        if(posType == POSITION_TYPE_SELL && rsi < InpRSIMidLevel)
        {
            double profit = PositionGetDouble(POSITION_PROFIT);
            if(profit > 0)
            {
                if(g_trade.PositionClose(ticket))
                {
                    LogTrade("EARLY_EXIT", g_symbolInfo.Ask(), 0, 0, 0, "RSI returned to middle (SHORT)");
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                       |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
{
    if(g_currentDrawdown >= InpMaxDrawdownPct)
    {
        Print("Trading suspended: Drawdown limit reached");
        return false;
    }
    
    double marginLevel = g_accountInfo.MarginLevel();
    if(marginLevel > 0 && marginLevel < 200)
    {
        Print("Trading suspended: Low margin level");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Update drawdown calculation                                       |
//+------------------------------------------------------------------+
void UpdateDrawdown()
{
    double currentEquity = g_accountInfo.Equity();
    
    if(currentEquity > g_highestEquity)
        g_highestEquity = currentEquity;
    
    g_currentDrawdown = ((g_highestEquity - currentEquity) / g_highestEquity) * 100;
}

//+------------------------------------------------------------------+
//| Pass volatility filter                                            |
//+------------------------------------------------------------------+
bool PassVolatilityFilter()
{
    double atr = g_bufATR[1];
    double price = g_symbolInfo.Bid();
    double atrPercent = (atr / price) * 100;
    
    if(atrPercent < InpATRMinPercent || atrPercent > InpATRMaxPercent)
    {
        Print("Volatility filter failed: ATR% = ", atrPercent);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if valid trading session                                    |
//+------------------------------------------------------------------+
bool IsValidSession()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    if(dt.hour >= InpSessionStart && dt.hour < InpSessionEnd)
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Count open positions                                              |
//+------------------------------------------------------------------+
int CountPositions()
{
    int count = 0;
    int total = PositionsTotal();
    
    for(int i = 0; i < total; i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0)
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
               PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
            {
                count++;
            }
        }
    }
    
    return count;
}

//+------------------------------------------------------------------+
//| Check if has specific position type                               |
//+------------------------------------------------------------------+
bool HasPositionType(ENUM_POSITION_TYPE type)
{
    int total = PositionsTotal();
    
    for(int i = 0; i < total; i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0)
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
               PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
            {
                return true;
            }
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Log trade to CSV file                                             |
//+------------------------------------------------------------------+
void LogTrade(string action, double price, double sl, double tp, double lots, string reason)
{
    if(!InpEnableLogging || g_fileHandle == INVALID_HANDLE)
        return;
    
    string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
    FileWrite(g_fileHandle, timestamp, action, price, sl, tp, lots, reason);
    FileFlush(g_fileHandle);
    
    Print(InpEAName, " | ", action, " | Price: ", price, " | SL: ", sl, " | TP: ", tp, " | ", reason);
}

//+------------------------------------------------------------------+
//| Set optimal filling type                                          |
//+------------------------------------------------------------------+
void SetOptimalFillingType()
{
    uint filling = (uint)g_symbolInfo.TradeFillFlags();
    
    if((filling & SYMBOL_FILLING_FOK) != 0)
        g_trade.SetTypeFilling(ORDER_FILLING_FOK);
    else if((filling & SYMBOL_FILLING_IOC) != 0)
        g_trade.SetTypeFilling(ORDER_FILLING_IOC);
    else
        g_trade.SetTypeFilling(ORDER_FILLING_RETURN);
}

//+------------------------------------------------------------------+
//| OnTrade - Track trade results                                     |
//+------------------------------------------------------------------+
void OnTrade()
{
    static int lastDealsCount = 0;
    static datetime lastHistoryTime = 0;
    
    datetime startTime = (lastHistoryTime > 0) ? lastHistoryTime : TimeCurrent() - 86400;
    if(!HistorySelect(startTime, TimeCurrent()))
        return;
    
    int total = HistoryDealsTotal();
    if(total <= lastDealsCount)
        return;
    
    for(int i = lastDealsCount; i < total; i++)
    {
        ulong ticket = HistoryDealGetTicket(i);
        if(ticket <= 0) continue;
        
        if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != InpMagicNumber) continue;
        if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
        
        ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
        if(entry != DEAL_ENTRY_OUT) continue;
        
        double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
        double commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
        double swap = HistoryDealGetDouble(ticket, DEAL_SWAP);
        double netProfit = profit + commission + swap;
        
        LogTrade("CLOSE", HistoryDealGetDouble(ticket, DEAL_PRICE), 0, 0, 
                 HistoryDealGetDouble(ticket, DEAL_VOLUME), 
                 "P/L: " + DoubleToString(netProfit, 2));
        
        if(InpEnableAlerts)
            Alert(InpEAName, ": Position closed. P/L: ", netProfit);
        
        //--- Reset partial close flag on full close
        if(CountPositions() == 0)
            g_partialCloseDone = false;
    }
    
    lastDealsCount = total;
    lastHistoryTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| OnTester - Optimization criterion                                 |
//+------------------------------------------------------------------+
double OnTester()
{
    double profit = TesterStatistics(STAT_PROFIT);
    double drawdown = TesterStatistics(STAT_EQUITY_DD_RELATIVE);
    int trades = (int)TesterStatistics(STAT_TRADES);
    double profitFactor = TesterStatistics(STAT_PROFIT_FACTOR);
    
    if(drawdown > 0 && trades >= 30)
        return (profit / drawdown) * profitFactor;
    
    return 0;
}
//+------------------------------------------------------------------+
