//+------------------------------------------------------------------+
//|                                             MOMENTUM_SCALPER.mq5 |
//|                                    Copyright 2024, Trading Portfolio |
//|                      EA 3: Breakout Strategy for XAUUSD (H1)      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trading Portfolio"
#property link      "https://github.com/lucciola85"
#property version   "1.00"
#property description "MOMENTUM_SCALPER - Breakout Expert Advisor"
#property description "Designed for XAUUSD (Gold) on H1 timeframe"
#property description "Uses consolidation detection with volume and MACD confirmation"
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
input string            InpEAName           = "MOMENTUM_SCALPER";  // EA Name
input int               InpMagicNumber      = 111003;              // Magic Number
input string            InpTradeComment     = "MS_H1";             // Trade Comment
input ENUM_TIMEFRAMES   InpTimeframe        = PERIOD_H1;           // Main Timeframe (H1 recommended)

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
//| Input Parameters - Consolidation Detection                        |
//+------------------------------------------------------------------+
input group "═══════════ CONSOLIDATION DETECTION ═══════════"
input int               InpATRPeriod        = 14;                  // ATR Period
input int               InpATRShortPeriod   = 10;                  // Short ATR Lookback
input int               InpATRLongPeriod    = 50;                  // Long ATR Lookback for Average
input int               InpBreakoutPeriod   = 20;                  // Breakout Lookback (High/Low)

//+------------------------------------------------------------------+
//| Input Parameters - Volume Confirmation                            |
//+------------------------------------------------------------------+
input group "═══════════ VOLUME CONFIRMATION ═══════════"
input bool              InpUseVolumeFilter  = true;                // Use Volume Confirmation
input int               InpVolumePeriod     = 5;                   // Volume Average Period
input double            InpVolumeMult       = 1.5;                 // Min Volume Multiplier

//+------------------------------------------------------------------+
//| Input Parameters - MACD Confirmation                              |
//+------------------------------------------------------------------+
input group "═══════════ MACD CONFIRMATION ═══════════"
input bool              InpUseMACDFilter    = true;                // Use MACD Confirmation
input int               InpMACDFast         = 12;                  // MACD Fast EMA
input int               InpMACDSlow         = 26;                  // MACD Slow EMA
input int               InpMACDSignal       = 9;                   // MACD Signal Period

//+------------------------------------------------------------------+
//| Input Parameters - Risk/Reward Ratio                              |
//+------------------------------------------------------------------+
input group "═══════════ RISK/REWARD ═══════════"
input double            InpRRRatio          = 2.0;                 // Risk/Reward Ratio (1:X)
input double            InpRRRatio2         = 3.0;                 // Extended R/R for remaining position

//+------------------------------------------------------------------+
//| Input Parameters - Partial Close                                  |
//+------------------------------------------------------------------+
input group "═══════════ PARTIAL CLOSE ═══════════"
input bool              InpUsePartialClose  = true;                // Enable Partial Close
input double            InpPartialPercent   = 50.0;                // % to close at TP1
input double            InpTP1RR            = 1.0;                 // TP1 at Risk/Reward 1:X

//+------------------------------------------------------------------+
//| Input Parameters - Pullback Entry                                 |
//+------------------------------------------------------------------+
input group "═══════════ PULLBACK ENTRY ═══════════"
input bool              InpUsePullback      = false;               // Wait for Pullback Entry
input ENUM_TIMEFRAMES   InpPullbackTF       = PERIOD_M15;          // Pullback Detection Timeframe
input int               InpPullbackBars     = 5;                   // Max Bars to Wait for Pullback

//+------------------------------------------------------------------+
//| Input Parameters - Volatility Filter                              |
//+------------------------------------------------------------------+
input group "═══════════ VOLATILITY FILTER ═══════════"
input bool              InpUseATRFilter     = true;                // Enable ATR Volatility Filter
input double            InpATRMinPercent    = 0.2;                 // Min ATR as % of Price
input double            InpATRMaxPercent    = 2.0;                 // Max ATR as % of Price

//+------------------------------------------------------------------+
//| Input Parameters - Session Filter                                 |
//+------------------------------------------------------------------+
input group "═══════════ SESSION FILTER ═══════════"
input bool              InpUseSessionFilter = true;                // Enable Session Filter
input int               InpSessionStart     = 8;                   // Session Start Hour
input int               InpSessionEnd       = 20;                  // Session End Hour
input bool              InpAvoidNews        = true;                // Avoid News Time
input int               InpNewsBefore       = 5;                   // Minutes Before News
input int               InpNewsAfter        = 15;                  // Minutes After News

//+------------------------------------------------------------------+
//| Input Parameters - Breakeven                                      |
//+------------------------------------------------------------------+
input group "═══════════ BREAKEVEN ═══════════"
input bool              InpUseBreakeven     = true;                // Enable Breakeven
input double            InpBEActivation     = 1.0;                 // BE Activation (R multiple)
input int               InpBEOffset         = 5;                   // BE Offset (Points)

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
int g_handleATR, g_handleMACD;

// Indicator buffers
double g_bufATR[], g_bufMACDMain[], g_bufMACDSignal[];

// State variables
double g_initialCapital;
double g_highestEquity;
double g_currentDrawdown;
datetime g_lastBarTime;
double g_consolidationHigh;
double g_consolidationLow;
bool g_inConsolidation;
bool g_breakoutSignalPending;
int g_breakoutDirection;
datetime g_breakoutTime;
int g_pullbackWaitCounter;
bool g_partialCloseDone;
double g_entryPrice;
double g_initialSLDistance;
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
    g_trade.SetDeviationInPoints(50); // Higher for Gold
    g_trade.SetAsyncMode(false);
    SetOptimalFillingType();
    
    //--- Create indicator handles
    if(!CreateIndicatorHandles())
        return(INIT_FAILED);
    
    //--- Initialize buffers
    InitializeBuffers();
    
    //--- Initialize state
    g_initialCapital = InpAllocatedCapital;
    g_highestEquity = g_initialCapital;
    g_currentDrawdown = 0;
    g_lastBarTime = 0;
    g_consolidationHigh = 0;
    g_consolidationLow = 0;
    g_inConsolidation = false;
    g_breakoutSignalPending = false;
    g_breakoutDirection = 0;
    g_breakoutTime = 0;
    g_pullbackWaitCounter = 0;
    g_partialCloseDone = false;
    g_entryPrice = 0;
    g_initialSLDistance = 0;
    
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
    
    Print("═══════════════════════════════════════════════════");
    Print("  ", InpEAName, " initialized successfully");
    Print("  Symbol: ", _Symbol);
    Print("  Timeframe: ", EnumToString(InpTimeframe));
    Print("  Allocated Capital: ", InpAllocatedCapital);
    Print("  Risk per Trade: ", InpRiskPercent, "%");
    Print("  Breakout Period: ", InpBreakoutPeriod);
    Print("  R/R Ratio: 1:", InpRRRatio);
    Print("═══════════════════════════════════════════════════");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- Release indicator handles
    if(g_handleATR != INVALID_HANDLE) IndicatorRelease(g_handleATR);
    if(g_handleMACD != INVALID_HANDLE) IndicatorRelease(g_handleMACD);
    
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
    
    //--- Manage positions (every tick)
    ManageBreakeven();
    if(InpUsePartialClose && !g_partialCloseDone)
        ManagePartialClose();
    
    //--- Handle pending pullback entry
    if(InpUsePullback && g_breakoutSignalPending)
    {
        CheckPullbackEntry();
    }
    
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
    
    //--- Detect consolidation
    DetectConsolidation();
    
    //--- Check for breakout signals
    if(CountPositions() < InpMaxPositions && g_inConsolidation)
    {
        int signal = GetBreakoutSignal();
        if(signal != 0)
        {
            if(InpUsePullback)
            {
                //--- Wait for pullback
                g_breakoutSignalPending = true;
                g_breakoutDirection = signal;
                g_breakoutTime = TimeCurrent();
                g_pullbackWaitCounter = InpPullbackBars;
                Print("Breakout detected. Waiting for pullback...");
            }
            else
            {
                //--- Execute immediately
                ExecuteTrade(signal);
            }
        }
    }
    
    //--- Check if pullback wait expired
    if(g_breakoutSignalPending)
    {
        g_pullbackWaitCounter--;
        if(g_pullbackWaitCounter <= 0)
        {
            g_breakoutSignalPending = false;
            g_breakoutDirection = 0;
            Print("Pullback wait expired. Breakout signal cancelled.");
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
    int barsNeeded = MathMax(InpATRLongPeriod, InpBreakoutPeriod) + 50;
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
    //--- ATR
    g_handleATR = iATR(_Symbol, InpTimeframe, InpATRPeriod);
    if(g_handleATR == INVALID_HANDLE)
    {
        Print("Error: Failed to create ATR handle");
        return false;
    }
    
    //--- MACD
    if(InpUseMACDFilter)
    {
        g_handleMACD = iMACD(_Symbol, InpTimeframe, InpMACDFast, InpMACDSlow, InpMACDSignal, PRICE_CLOSE);
        if(g_handleMACD == INVALID_HANDLE)
        {
            Print("Error: Failed to create MACD handle");
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Initialize buffers                                               |
//+------------------------------------------------------------------+
void InitializeBuffers()
{
    ArraySetAsSeries(g_bufATR, true);
    ArraySetAsSeries(g_bufMACDMain, true);
    ArraySetAsSeries(g_bufMACDSignal, true);
}

//+------------------------------------------------------------------+
//| Copy indicator buffers                                           |
//+------------------------------------------------------------------+
bool CopyIndicatorBuffers()
{
    int bars = InpATRLongPeriod + 5;
    
    if(CopyBuffer(g_handleATR, 0, 0, bars, g_bufATR) < bars) return false;
    
    if(InpUseMACDFilter && g_handleMACD != INVALID_HANDLE)
    {
        if(CopyBuffer(g_handleMACD, 0, 0, 10, g_bufMACDMain) < 10) return false;
        if(CopyBuffer(g_handleMACD, 1, 0, 10, g_bufMACDSignal) < 10) return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Detect consolidation phase                                        |
//+------------------------------------------------------------------+
void DetectConsolidation()
{
    //--- Calculate short-term ATR average
    double atrShort = 0;
    for(int i = 1; i <= InpATRShortPeriod; i++)
    {
        atrShort += g_bufATR[i];
    }
    atrShort /= InpATRShortPeriod;
    
    //--- Calculate long-term ATR average
    double atrLong = 0;
    for(int i = 1; i <= InpATRLongPeriod; i++)
    {
        atrLong += g_bufATR[i];
    }
    atrLong /= InpATRLongPeriod;
    
    //--- Consolidation: Short-term ATR < Long-term ATR (market is "flat")
    g_inConsolidation = (atrShort < atrLong);
    
    //--- Calculate consolidation range (high/low of breakout period)
    g_consolidationHigh = 0;
    g_consolidationLow = DBL_MAX;
    
    for(int i = 1; i <= InpBreakoutPeriod; i++)
    {
        double high = iHigh(_Symbol, InpTimeframe, i);
        double low = iLow(_Symbol, InpTimeframe, i);
        
        if(high > g_consolidationHigh) g_consolidationHigh = high;
        if(low < g_consolidationLow) g_consolidationLow = low;
    }
}

//+------------------------------------------------------------------+
//| Get breakout signal                                               |
//+------------------------------------------------------------------+
int GetBreakoutSignal()
{
    double close = iClose(_Symbol, InpTimeframe, 1);
    
    //--- Volume confirmation
    if(InpUseVolumeFilter)
    {
        double currentVolume = (double)iTickVolume(_Symbol, InpTimeframe, 1);
        double avgVolume = 0;
        
        for(int i = 2; i <= InpVolumePeriod + 1; i++)
        {
            avgVolume += (double)iTickVolume(_Symbol, InpTimeframe, i);
        }
        avgVolume /= InpVolumePeriod;
        
        if(currentVolume < avgVolume * InpVolumeMult)
            return 0; // Not enough volume
    }
    
    //--- MACD confirmation
    bool macdBullish = true;
    bool macdBearish = true;
    
    if(InpUseMACDFilter && ArraySize(g_bufMACDMain) >= 2)
    {
        //--- MACD bullish crossover
        macdBullish = (g_bufMACDMain[2] <= g_bufMACDSignal[2] && g_bufMACDMain[1] > g_bufMACDSignal[1]);
        //--- MACD bearish crossover
        macdBearish = (g_bufMACDMain[2] >= g_bufMACDSignal[2] && g_bufMACDMain[1] < g_bufMACDSignal[1]);
    }
    
    //--- LONG breakout
    if(close > g_consolidationHigh)
    {
        if(!InpUseMACDFilter || macdBullish)
        {
            if(!HasPositionType(POSITION_TYPE_BUY))
            {
                Print("LONG breakout: Close=", close, " > High=", g_consolidationHigh);
                return 1;
            }
        }
    }
    
    //--- SHORT breakout
    if(close < g_consolidationLow)
    {
        if(!InpUseMACDFilter || macdBearish)
        {
            if(!HasPositionType(POSITION_TYPE_SELL))
            {
                Print("SHORT breakout: Close=", close, " < Low=", g_consolidationLow);
                return -1;
            }
        }
    }
    
    return 0;
}

//+------------------------------------------------------------------+
//| Check for pullback entry                                          |
//+------------------------------------------------------------------+
void CheckPullbackEntry()
{
    if(!g_breakoutSignalPending)
        return;
    
    double currentPrice = g_symbolInfo.Bid();
    
    if(g_breakoutDirection > 0) // Bullish breakout
    {
        //--- Wait for pullback to breakout level
        if(currentPrice <= g_consolidationHigh)
        {
            //--- Check for bullish candle pattern on pullback TF
            if(IsBullishReversal())
            {
                ExecuteTrade(1);
                g_breakoutSignalPending = false;
            }
        }
    }
    else if(g_breakoutDirection < 0) // Bearish breakout
    {
        //--- Wait for pullback to breakout level
        if(currentPrice >= g_consolidationLow)
        {
            //--- Check for bearish candle pattern on pullback TF
            if(IsBearishReversal())
            {
                ExecuteTrade(-1);
                g_breakoutSignalPending = false;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check for bullish reversal pattern                                |
//+------------------------------------------------------------------+
bool IsBullishReversal()
{
    double open = iOpen(_Symbol, InpPullbackTF, 1);
    double close = iClose(_Symbol, InpPullbackTF, 1);
    double high = iHigh(_Symbol, InpPullbackTF, 1);
    double low = iLow(_Symbol, InpPullbackTF, 1);
    double body = MathAbs(close - open);
    double range = high - low;
    
    //--- Hammer pattern: small body, long lower wick
    if(close > open && body < range * 0.4)
    {
        double lowerWick = MathMin(open, close) - low;
        if(lowerWick > body * 2)
            return true;
    }
    
    //--- Bullish engulfing
    double prevOpen = iOpen(_Symbol, InpPullbackTF, 2);
    double prevClose = iClose(_Symbol, InpPullbackTF, 2);
    
    if(prevClose < prevOpen && close > open)
    {
        if(close > prevOpen && open < prevClose)
            return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check for bearish reversal pattern                                |
//+------------------------------------------------------------------+
bool IsBearishReversal()
{
    double open = iOpen(_Symbol, InpPullbackTF, 1);
    double close = iClose(_Symbol, InpPullbackTF, 1);
    double high = iHigh(_Symbol, InpPullbackTF, 1);
    double low = iLow(_Symbol, InpPullbackTF, 1);
    double body = MathAbs(close - open);
    double range = high - low;
    
    //--- Shooting star pattern: small body, long upper wick
    if(close < open && body < range * 0.4)
    {
        double upperWick = high - MathMax(open, close);
        if(upperWick > body * 2)
            return true;
    }
    
    //--- Bearish engulfing
    double prevOpen = iOpen(_Symbol, InpPullbackTF, 2);
    double prevClose = iClose(_Symbol, InpPullbackTF, 2);
    
    if(prevClose > prevOpen && close < open)
    {
        if(close < prevOpen && open > prevClose)
            return true;
    }
    
    return false;
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
    double point = g_symbolInfo.Point();
    
    double sl, tp;
    double slDistance;
    
    if(signal > 0) // BUY breakout
    {
        //--- SL below consolidation low
        slDistance = ask - g_consolidationLow;
        sl = NormalizeDouble(g_consolidationLow, digits);
        
        //--- TP based on R/R ratio
        tp = NormalizeDouble(ask + slDistance * InpRRRatio, digits);
        
        double lotSize = CalculateLotSize(slDistance);
        
        if(g_trade.Buy(lotSize, _Symbol, ask, sl, tp, InpTradeComment))
        {
            g_entryPrice = ask;
            g_initialSLDistance = slDistance;
            g_partialCloseDone = false;
            
            LogTrade("BUY", ask, sl, tp, lotSize, "Breakout LONG above consolidation");
            
            if(InpEnableAlerts)
                Alert(InpEAName, ": BUY breakout on ", _Symbol);
        }
        else
        {
            Print("Error opening BUY: ", g_trade.ResultRetcode(), " - ", g_trade.ResultRetcodeDescription());
        }
    }
    else if(signal < 0) // SELL breakout
    {
        //--- SL above consolidation high
        slDistance = g_consolidationHigh - bid;
        sl = NormalizeDouble(g_consolidationHigh, digits);
        
        //--- TP based on R/R ratio
        tp = NormalizeDouble(bid - slDistance * InpRRRatio, digits);
        
        double lotSize = CalculateLotSize(slDistance);
        
        if(g_trade.Sell(lotSize, _Symbol, bid, sl, tp, InpTradeComment))
        {
            g_entryPrice = bid;
            g_initialSLDistance = slDistance;
            g_partialCloseDone = false;
            
            LogTrade("SELL", bid, sl, tp, lotSize, "Breakout SHORT below consolidation");
            
            if(InpEnableAlerts)
                Alert(InpEAName, ": SELL breakout on ", _Symbol);
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
//| Manage breakeven                                                  |
//+------------------------------------------------------------------+
void ManageBreakeven()
{
    if(!InpUseBreakeven)
        return;
    
    int total = PositionsTotal();
    int digits = (int)g_symbolInfo.Digits();
    double point = g_symbolInfo.Point();
    
    for(int i = total - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) continue;
        
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
        
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double currentSL = PositionGetDouble(POSITION_SL);
        double currentTP = PositionGetDouble(POSITION_TP);
        ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        
        double currentPrice = (posType == POSITION_TYPE_BUY) ? g_symbolInfo.Bid() : g_symbolInfo.Ask();
        double profitDistance = (posType == POSITION_TYPE_BUY) ? 
                               (currentPrice - openPrice) : (openPrice - currentPrice);
        
        //--- Check if BE activation reached
        double beActivationDistance = g_initialSLDistance * InpBEActivation;
        
        if(profitDistance >= beActivationDistance)
        {
            double newSL;
            
            if(posType == POSITION_TYPE_BUY)
            {
                newSL = NormalizeDouble(openPrice + InpBEOffset * point, digits);
                if(currentSL < newSL)
                {
                    if(g_trade.PositionModify(ticket, newSL, currentTP))
                    {
                        LogTrade("BREAKEVEN", currentPrice, newSL, currentTP, 0, "Moved SL to breakeven");
                    }
                }
            }
            else // SELL
            {
                newSL = NormalizeDouble(openPrice - InpBEOffset * point, digits);
                if(currentSL > newSL || currentSL == 0)
                {
                    if(g_trade.PositionModify(ticket, newSL, currentTP))
                    {
                        LogTrade("BREAKEVEN", currentPrice, newSL, currentTP, 0, "Moved SL to breakeven");
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Manage partial close                                              |
//+------------------------------------------------------------------+
void ManagePartialClose()
{
    int total = PositionsTotal();
    int digits = (int)g_symbolInfo.Digits();
    double point = g_symbolInfo.Point();
    
    for(int i = total - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) continue;
        
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
        
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double currentTP = PositionGetDouble(POSITION_TP);
        double currentSL = PositionGetDouble(POSITION_SL);
        double volume = PositionGetDouble(POSITION_VOLUME);
        ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        
        double currentPrice = (posType == POSITION_TYPE_BUY) ? g_symbolInfo.Bid() : g_symbolInfo.Ask();
        double profitDistance = (posType == POSITION_TYPE_BUY) ? 
                               (currentPrice - openPrice) : (openPrice - currentPrice);
        
        //--- TP1 level based on R/R
        double tp1Distance = g_initialSLDistance * InpTP1RR;
        
        if(profitDistance >= tp1Distance)
        {
            //--- Close partial position
            double closeVolume = NormalizeDouble(volume * (InpPartialPercent / 100.0), 2);
            closeVolume = MathMax(closeVolume, g_symbolInfo.LotsMin());
            
            if(closeVolume < volume)
            {
                if(g_trade.PositionClosePartial(ticket, closeVolume))
                {
                    g_partialCloseDone = true;
                    
                    //--- Move SL to breakeven and extend TP
                    double newSL = NormalizeDouble(openPrice + InpBEOffset * point, digits);
                    if(posType == POSITION_TYPE_SELL)
                        newSL = NormalizeDouble(openPrice - InpBEOffset * point, digits);
                    
                    //--- Extended TP for remaining position
                    double newTP;
                    if(posType == POSITION_TYPE_BUY)
                        newTP = NormalizeDouble(openPrice + g_initialSLDistance * InpRRRatio2, digits);
                    else
                        newTP = NormalizeDouble(openPrice - g_initialSLDistance * InpRRRatio2, digits);
                    
                    g_trade.PositionModify(ticket, newSL, newTP);
                    
                    LogTrade("PARTIAL_CLOSE", currentPrice, newSL, newTP, closeVolume, 
                             "TP1 reached at 1:" + DoubleToString(InpTP1RR, 1));
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
    
    //--- Basic session check
    if(dt.hour < InpSessionStart || dt.hour >= InpSessionEnd)
        return false;
    
    return true;
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
        
        //--- Reset on full close
        if(CountPositions() == 0)
        {
            g_partialCloseDone = false;
            g_breakoutSignalPending = false;
        }
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
    double trades = TesterStatistics(STAT_TRADES);
    double profitFactor = TesterStatistics(STAT_PROFIT_FACTOR);
    
    if(drawdown > 0 && trades >= 30)
        return (profit / drawdown) * profitFactor;
    
    return 0;
}
//+------------------------------------------------------------------+
