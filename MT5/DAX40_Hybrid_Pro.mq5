//+------------------------------------------------------------------+
//|                                              DAX40_Hybrid_Pro.mq5 |
//|                                    Copyright 2024, Trading Systems |
//|                                   Professional DAX40 Expert Advisor |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trading Systems"
#property link      "https://github.com/lucciola85"
#property version   "1.00"
#property description "DAX40 Hybrid Pro - Professional Expert Advisor for GER40"
#property description "Hybrid technology with adaptive market regime detection"
#property description "Optimized for daily profitable trading on DAX index"
#property strict

//--- Include standard library files
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Enumerations                                                      |
//+------------------------------------------------------------------+
enum ENUM_LOT_MODE
{
   LOT_MODE_FIXED = 0,        // Fixed Lot Size
   LOT_MODE_COMPOUND = 1,     // Compound Interest (% Risk)
   LOT_MODE_BALANCE = 2       // Balance Based Progressive
};

enum ENUM_MARKET_REGIME
{
   REGIME_TRENDING_UP = 0,    // Strong Uptrend
   REGIME_TRENDING_DOWN = 1,  // Strong Downtrend
   REGIME_RANGING = 2,        // Ranging/Consolidation
   REGIME_BREAKOUT = 3,       // Breakout Mode
   REGIME_VOLATILE = 4        // High Volatility
};

enum ENUM_TRADE_DIRECTION
{
   TRADE_BOTH = 0,            // Both Directions
   TRADE_BUY_ONLY = 1,        // Buy Only
   TRADE_SELL_ONLY = 2        // Sell Only
};

//+------------------------------------------------------------------+
//| Input Parameters - General Settings                               |
//+------------------------------------------------------------------+
input group "═══════════ GENERAL SETTINGS ═══════════"
input string            InpEAName           = "DAX40_Hybrid_Pro";  // EA Name
input int               InpMagicNumber      = 404040;              // Magic Number
input string            InpTradeComment     = "DAX40_HP";          // Trade Comment
input ENUM_TIMEFRAMES   InpTimeframe        = PERIOD_H1;           // Main Timeframe
input ENUM_TRADE_DIRECTION InpTradeDirection = TRADE_BOTH;         // Trade Direction

//+------------------------------------------------------------------+
//| Input Parameters - Money Management                               |
//+------------------------------------------------------------------+
input group "═══════════ MONEY MANAGEMENT ═══════════"
input ENUM_LOT_MODE     InpLotMode          = LOT_MODE_COMPOUND;   // Lot Calculation Mode
input double            InpFixedLot         = 0.1;                 // Fixed Lot Size
input double            InpRiskPercent      = 1.0;                 // Risk per Trade (%)
input double            InpCompoundFactor   = 1.0;                 // Compound Growth Factor
input double            InpMinLotSize       = 0.01;                // Minimum Lot Size
input double            InpMaxLotSize       = 5.0;                 // Maximum Lot Size
input int               InpMaxPositions     = 2;                   // Max Open Positions

//+------------------------------------------------------------------+
//| Input Parameters - Protection System                              |
//+------------------------------------------------------------------+
input group "═══════════ PROTECTION SYSTEM ═══════════"
input double            InpMaxDailyLoss     = 3.0;                 // Max Daily Loss (%)
input double            InpMaxDrawdown      = 10.0;                // Max Total Drawdown (%)
input double            InpMaxDailyProfit   = 5.0;                 // Max Daily Profit Target (%)
input int               InpMaxDailyTrades   = 5;                   // Max Trades per Day
input int               InpMaxConsLosses    = 3;                   // Max Consecutive Losses
input double            InpMinMarginLevel   = 200.0;               // Min Margin Level (%)
input bool              InpCloseOnFriday    = true;                // Close Positions on Friday
input int               InpFridayCloseHour  = 20;                  // Friday Close Hour (Server)

//+------------------------------------------------------------------+
//| Input Parameters - DAX Session Timing                             |
//+------------------------------------------------------------------+
input group "═══════════ DAX SESSION TIMING ═══════════"
input bool              InpUseSessionFilter = true;                // Enable Session Filter
input int               InpSessionStart     = 8;                   // Session Start (Server Time)
input int               InpSessionEnd       = 17;                  // Session End (Server Time)
input bool              InpAvoidLunchHour   = true;                // Avoid Lunch Hour (12-13)
input bool              InpTradeUSOverlap   = true;                // Trade US/EU Overlap (14-17)

//+------------------------------------------------------------------+
//| Input Parameters - Market Regime Detection                        |
//+------------------------------------------------------------------+
input group "═══════════ MARKET REGIME DETECTION ═══════════"
input bool              InpUseHybridMode    = true;                // Enable Hybrid Mode
input int               InpADXPeriod        = 14;                  // ADX Period (Trend Strength)
input int               InpADXTrendLevel    = 25;                  // ADX Trend Threshold
input int               InpATRPeriod        = 14;                  // ATR Period (Volatility)
input double            InpATRVolatileMult  = 1.5;                 // ATR Volatile Multiplier
input int               InpBBPeriod         = 20;                  // Bollinger Bands Period
input double            InpBBDeviation      = 2.0;                 // Bollinger Bands Deviation

//+------------------------------------------------------------------+
//| Input Parameters - Trend Strategy                                 |
//+------------------------------------------------------------------+
input group "═══════════ TREND STRATEGY ═══════════"
input bool              InpUseTrendStrategy = true;                // Enable Trend Strategy
input int               InpEMAFast          = 8;                   // Fast EMA Period
input int               InpEMASlow          = 21;                  // Slow EMA Period
input int               InpEMAFilter        = 50;                  // Trend Filter EMA
input int               InpMACDFast         = 12;                  // MACD Fast
input int               InpMACDSlow         = 26;                  // MACD Slow
input int               InpMACDSignal       = 9;                   // MACD Signal

//+------------------------------------------------------------------+
//| Input Parameters - Range Strategy                                 |
//+------------------------------------------------------------------+
input group "═══════════ RANGE STRATEGY ═══════════"
input bool              InpUseRangeStrategy = true;                // Enable Range Strategy
input int               InpRSIPeriod        = 14;                  // RSI Period
input int               InpRSIOverbought    = 70;                  // RSI Overbought
input int               InpRSIOversold      = 30;                  // RSI Oversold
input int               InpStochKPeriod     = 14;                  // Stochastic K Period
input int               InpStochDPeriod     = 3;                   // Stochastic D Period
input int               InpStochSlowing     = 3;                   // Stochastic Slowing

//+------------------------------------------------------------------+
//| Input Parameters - Breakout Strategy                              |
//+------------------------------------------------------------------+
input group "═══════════ BREAKOUT STRATEGY ═══════════"
input bool              InpUseBreakoutStrategy = true;             // Enable Breakout Strategy
input int               InpBreakoutPeriod   = 20;                  // Breakout Lookback Period
input double            InpBreakoutATRMult  = 0.5;                 // Breakout ATR Filter Mult
input bool              InpConfirmVolume    = true;                // Confirm with Volume

//+------------------------------------------------------------------+
//| Input Parameters - Stop Loss & Take Profit                        |
//+------------------------------------------------------------------+
input group "═══════════ STOP LOSS & TAKE PROFIT ═══════════"
input bool              InpUseDynamicSLTP   = true;                // Use Dynamic SL/TP (ATR-based)
input int               InpFixedSL          = 300;                 // Fixed Stop Loss (Points)
input int               InpFixedTP          = 600;                 // Fixed Take Profit (Points)
input double            InpSLATRMultiplier  = 2.0;                 // SL ATR Multiplier
input double            InpTPATRMultiplier  = 4.0;                 // TP ATR Multiplier
input int               InpMinSLPoints      = 150;                 // Minimum SL (Points)
input int               InpMaxSLPoints      = 500;                 // Maximum SL (Points)

//+------------------------------------------------------------------+
//| Input Parameters - Take Profit Management                         |
//+------------------------------------------------------------------+
input group "═══════════ TAKE PROFIT MANAGEMENT ═══════════"
input bool              InpUsePartialClose  = true;                // Enable Partial Close
input double            InpPartialClosePercent = 50.0;             // Partial Close (% of position)
input double            InpPartialCloseRatio = 0.5;                // Partial Close at TP Ratio
input bool              InpUseBreakeven     = true;                // Enable Breakeven
input int               InpBreakevenStart   = 200;                 // Breakeven Activation (Points)
input int               InpBreakevenOffset  = 20;                  // Breakeven Offset (Points)
input bool              InpUseTrailingStop  = true;                // Enable Trailing Stop
input int               InpTrailingStart    = 300;                 // Trailing Start (Points)
input int               InpTrailingStep     = 100;                 // Trailing Step (Points)
input int               InpTrailingDistance = 150;                 // Trailing Distance (Points)

//+------------------------------------------------------------------+
//| Input Parameters - Display Settings                               |
//+------------------------------------------------------------------+
input group "═══════════ DISPLAY SETTINGS ═══════════"
input bool              InpShowDashboard    = true;                // Show Dashboard Panel
input color             InpDashboardColor   = clrDarkSlateGray;    // Dashboard Background
input color             InpTextColor        = clrWhite;            // Text Color
input color             InpProfitColor      = clrLime;             // Profit Color
input color             InpLossColor        = clrRed;              // Loss Color

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
CTrade          g_trade;
CSymbolInfo     g_symbolInfo;
CPositionInfo   g_positionInfo;
CAccountInfo    g_accountInfo;

// Indicator handles
int g_handleEMAFast, g_handleEMASlow, g_handleEMAFilter;
int g_handleMACD, g_handleRSI, g_handleStoch;
int g_handleADX, g_handleATR, g_handleBB;
int g_handleVolume;

// Indicator buffers
double g_bufEMAFast[], g_bufEMASlow[], g_bufEMAFilter[];
double g_bufMACDMain[], g_bufMACDSignal[];
double g_bufRSI[], g_bufStochMain[], g_bufStochSignal[];
double g_bufADX[], g_bufADXPlus[], g_bufADXMinus[];
double g_bufATR[];
double g_bufBBUpper[], g_bufBBMiddle[], g_bufBBLower[];
double g_bufVolume[];

// Trading state variables
double g_initialBalance;
double g_dailyStartBalance;
double g_highestBalance;
datetime g_lastBarTime;
datetime g_lastTradeDay;
int g_dailyTradeCount;
int g_consecutiveLosses;
double g_dailyPnL;
ENUM_MARKET_REGIME g_currentRegime;
bool g_partialCloseDone[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Validate symbol
   string symbol = _Symbol;
   if(StringFind(symbol, "GER40") < 0 && StringFind(symbol, "DAX") < 0 && 
      StringFind(symbol, "DE40") < 0 && StringFind(symbol, "GER30") < 0)
   {
      Print("WARNING: This EA is optimized for DAX/GER40. Current symbol: ", symbol);
   }
   
   // Initialize symbol info
   if(!g_symbolInfo.Name(_Symbol))
   {
      Print("Error: Failed to initialize symbol info for ", _Symbol);
      return(INIT_FAILED);
   }
   
   // Set up trade object
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(30); // Higher deviation for indices
   g_trade.SetAsyncMode(false);
   SetOptimalFillingType();
   
   // Create indicator handles
   if(!CreateIndicatorHandles())
      return(INIT_FAILED);
   
   // Initialize buffers as series
   InitializeBuffers();
   
   // Initialize state variables
   g_initialBalance = g_accountInfo.Balance();
   g_dailyStartBalance = g_initialBalance;
   g_highestBalance = g_initialBalance;
   g_lastBarTime = 0;
   g_lastTradeDay = 0;
   g_dailyTradeCount = 0;
   g_consecutiveLosses = 0;
   g_dailyPnL = 0;
   g_currentRegime = REGIME_RANGING;
   ArrayResize(g_partialCloseDone, 100);
   ArrayInitialize(g_partialCloseDone, false);
   
   // Create dashboard
   if(InpShowDashboard)
      CreateDashboard();
   
   Print("═══════════════════════════════════════════════════");
   Print("  ", InpEAName, " initialized successfully");
   Print("  Account: ", g_accountInfo.Name());
   Print("  Balance: ", g_accountInfo.Balance(), " ", g_accountInfo.Currency());
   Print("  Leverage: 1:", g_accountInfo.Leverage());
   Print("  Symbol: ", _Symbol);
   Print("  Lot Mode: ", EnumToString(InpLotMode));
   Print("  Hybrid Mode: ", InpUseHybridMode ? "ENABLED" : "DISABLED");
   Print("═══════════════════════════════════════════════════");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release indicator handles
   if(g_handleEMAFast != INVALID_HANDLE) IndicatorRelease(g_handleEMAFast);
   if(g_handleEMASlow != INVALID_HANDLE) IndicatorRelease(g_handleEMASlow);
   if(g_handleEMAFilter != INVALID_HANDLE) IndicatorRelease(g_handleEMAFilter);
   if(g_handleMACD != INVALID_HANDLE) IndicatorRelease(g_handleMACD);
   if(g_handleRSI != INVALID_HANDLE) IndicatorRelease(g_handleRSI);
   if(g_handleStoch != INVALID_HANDLE) IndicatorRelease(g_handleStoch);
   if(g_handleADX != INVALID_HANDLE) IndicatorRelease(g_handleADX);
   if(g_handleATR != INVALID_HANDLE) IndicatorRelease(g_handleATR);
   if(g_handleBB != INVALID_HANDLE) IndicatorRelease(g_handleBB);
   
   // Delete dashboard objects
   ObjectsDeleteAll(0, "DAX_");
   
   Print(InpEAName, " deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Update symbol info
   if(!g_symbolInfo.RefreshRates())
      return;
   
   // Check for new day
   CheckNewDay();
   
   // Update dashboard every tick
   if(InpShowDashboard)
      UpdateDashboard();
   
   // Manage existing positions (every tick)
   ManagePositions();
   
   // Check for new bar
   datetime currentBarTime = iTime(_Symbol, InpTimeframe, 0);
   if(currentBarTime == g_lastBarTime)
      return;
   g_lastBarTime = currentBarTime;
   
   // Run protection checks
   if(!PassProtectionChecks())
      return;
   
   // Check trading session
   if(InpUseSessionFilter && !IsValidTradingSession())
      return;
   
   // Friday close check
   if(InpCloseOnFriday && IsFridayCloseTime())
   {
      CloseAllPositions("Friday close");
      return;
   }
   
   // Copy indicator buffers
   if(!CopyIndicatorBuffers())
      return;
   
   // Detect market regime
   g_currentRegime = DetectMarketRegime();
   
   // Get trade signal based on regime
   int signal = GetTradeSignal();
   
   // Execute trade if signal and conditions met
   if(signal != 0 && CountPositions() < InpMaxPositions)
   {
      ExecuteTrade(signal);
   }
}

//+------------------------------------------------------------------+
//| Create indicator handles                                         |
//+------------------------------------------------------------------+
bool CreateIndicatorHandles()
{
   // EMAs for trend
   g_handleEMAFast = iMA(_Symbol, InpTimeframe, InpEMAFast, 0, MODE_EMA, PRICE_CLOSE);
   g_handleEMASlow = iMA(_Symbol, InpTimeframe, InpEMASlow, 0, MODE_EMA, PRICE_CLOSE);
   g_handleEMAFilter = iMA(_Symbol, InpTimeframe, InpEMAFilter, 0, MODE_EMA, PRICE_CLOSE);
   
   if(g_handleEMAFast == INVALID_HANDLE || g_handleEMASlow == INVALID_HANDLE || 
      g_handleEMAFilter == INVALID_HANDLE)
   {
      Print("Error: Failed to create EMA handles");
      return false;
   }
   
   // MACD
   g_handleMACD = iMACD(_Symbol, InpTimeframe, InpMACDFast, InpMACDSlow, InpMACDSignal, PRICE_CLOSE);
   if(g_handleMACD == INVALID_HANDLE)
   {
      Print("Error: Failed to create MACD handle");
      return false;
   }
   
   // RSI
   g_handleRSI = iRSI(_Symbol, InpTimeframe, InpRSIPeriod, PRICE_CLOSE);
   if(g_handleRSI == INVALID_HANDLE)
   {
      Print("Error: Failed to create RSI handle");
      return false;
   }
   
   // Stochastic
   g_handleStoch = iStochastic(_Symbol, InpTimeframe, InpStochKPeriod, InpStochDPeriod, 
                               InpStochSlowing, MODE_SMA, STO_LOWHIGH);
   if(g_handleStoch == INVALID_HANDLE)
   {
      Print("Error: Failed to create Stochastic handle");
      return false;
   }
   
   // ADX
   g_handleADX = iADX(_Symbol, InpTimeframe, InpADXPeriod);
   if(g_handleADX == INVALID_HANDLE)
   {
      Print("Error: Failed to create ADX handle");
      return false;
   }
   
   // ATR
   g_handleATR = iATR(_Symbol, InpTimeframe, InpATRPeriod);
   if(g_handleATR == INVALID_HANDLE)
   {
      Print("Error: Failed to create ATR handle");
      return false;
   }
   
   // Bollinger Bands
   g_handleBB = iBands(_Symbol, InpTimeframe, InpBBPeriod, 0, InpBBDeviation, PRICE_CLOSE);
   if(g_handleBB == INVALID_HANDLE)
   {
      Print("Error: Failed to create Bollinger Bands handle");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Initialize indicator buffers                                      |
//+------------------------------------------------------------------+
void InitializeBuffers()
{
   ArraySetAsSeries(g_bufEMAFast, true);
   ArraySetAsSeries(g_bufEMASlow, true);
   ArraySetAsSeries(g_bufEMAFilter, true);
   ArraySetAsSeries(g_bufMACDMain, true);
   ArraySetAsSeries(g_bufMACDSignal, true);
   ArraySetAsSeries(g_bufRSI, true);
   ArraySetAsSeries(g_bufStochMain, true);
   ArraySetAsSeries(g_bufStochSignal, true);
   ArraySetAsSeries(g_bufADX, true);
   ArraySetAsSeries(g_bufADXPlus, true);
   ArraySetAsSeries(g_bufADXMinus, true);
   ArraySetAsSeries(g_bufATR, true);
   ArraySetAsSeries(g_bufBBUpper, true);
   ArraySetAsSeries(g_bufBBMiddle, true);
   ArraySetAsSeries(g_bufBBLower, true);
}

//+------------------------------------------------------------------+
//| Copy indicator buffers                                           |
//+------------------------------------------------------------------+
bool CopyIndicatorBuffers()
{
   int bars = 50;
   
   if(CopyBuffer(g_handleEMAFast, 0, 0, bars, g_bufEMAFast) < bars) return false;
   if(CopyBuffer(g_handleEMASlow, 0, 0, bars, g_bufEMASlow) < bars) return false;
   if(CopyBuffer(g_handleEMAFilter, 0, 0, bars, g_bufEMAFilter) < bars) return false;
   if(CopyBuffer(g_handleMACD, 0, 0, bars, g_bufMACDMain) < bars) return false;
   if(CopyBuffer(g_handleMACD, 1, 0, bars, g_bufMACDSignal) < bars) return false;
   if(CopyBuffer(g_handleRSI, 0, 0, bars, g_bufRSI) < bars) return false;
   if(CopyBuffer(g_handleStoch, 0, 0, bars, g_bufStochMain) < bars) return false;
   if(CopyBuffer(g_handleStoch, 1, 0, bars, g_bufStochSignal) < bars) return false;
   if(CopyBuffer(g_handleADX, 0, 0, bars, g_bufADX) < bars) return false;
   if(CopyBuffer(g_handleADX, 1, 0, bars, g_bufADXPlus) < bars) return false;
   if(CopyBuffer(g_handleADX, 2, 0, bars, g_bufADXMinus) < bars) return false;
   if(CopyBuffer(g_handleATR, 0, 0, bars, g_bufATR) < bars) return false;
   if(CopyBuffer(g_handleBB, 0, 0, bars, g_bufBBMiddle) < bars) return false;
   if(CopyBuffer(g_handleBB, 1, 0, bars, g_bufBBUpper) < bars) return false;
   if(CopyBuffer(g_handleBB, 2, 0, bars, g_bufBBLower) < bars) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Detect current market regime                                      |
//+------------------------------------------------------------------+
ENUM_MARKET_REGIME DetectMarketRegime()
{
   if(!InpUseHybridMode)
      return REGIME_TRENDING_UP; // Default to trend mode if hybrid disabled
   
   double adx = g_bufADX[0];
   double adxPlus = g_bufADXPlus[0];
   double adxMinus = g_bufADXMinus[0];
   double atr = g_bufATR[0];
   double atrAvg = 0;
   
   // Calculate average ATR
   for(int i = 0; i < 20; i++)
      atrAvg += g_bufATR[i];
   atrAvg /= 20;
   
   // Bollinger Band width for volatility
   double bbWidth = (g_bufBBUpper[0] - g_bufBBLower[0]) / g_bufBBMiddle[0] * 100;
   
   // Check for high volatility
   if(atr > atrAvg * InpATRVolatileMult)
      return REGIME_VOLATILE;
   
   // Check for breakout (price near BB bands with expanding width)
   double price = g_symbolInfo.Bid();
   if((price > g_bufBBUpper[0] || price < g_bufBBLower[0]) && bbWidth > 2.0)
      return REGIME_BREAKOUT;
   
   // Check for trend
   if(adx >= InpADXTrendLevel)
   {
      if(adxPlus > adxMinus)
         return REGIME_TRENDING_UP;
      else
         return REGIME_TRENDING_DOWN;
   }
   
   // Default to ranging
   return REGIME_RANGING;
}

//+------------------------------------------------------------------+
//| Get trade signal based on market regime                          |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
   int signal = 0;
   
   switch(g_currentRegime)
   {
      case REGIME_TRENDING_UP:
      case REGIME_TRENDING_DOWN:
         if(InpUseTrendStrategy)
            signal = GetTrendSignal();
         break;
         
      case REGIME_RANGING:
         if(InpUseRangeStrategy)
            signal = GetRangeSignal();
         break;
         
      case REGIME_BREAKOUT:
         if(InpUseBreakoutStrategy)
            signal = GetBreakoutSignal();
         break;
         
      case REGIME_VOLATILE:
         // In volatile regime, we can use either range or breakout
         if(InpUseRangeStrategy)
            signal = GetRangeSignal();
         break;
   }
   
   // Apply direction filter
   if(InpTradeDirection == TRADE_BUY_ONLY && signal < 0)
      signal = 0;
   if(InpTradeDirection == TRADE_SELL_ONLY && signal > 0)
      signal = 0;
   
   return signal;
}

//+------------------------------------------------------------------+
//| Get trend following signal                                        |
//+------------------------------------------------------------------+
int GetTrendSignal()
{
   // EMA crossover with trend filter
   bool fastAboveSlow = g_bufEMAFast[0] > g_bufEMASlow[0];
   bool fastBelowSlow = g_bufEMAFast[0] < g_bufEMASlow[0];
   bool priceAboveFilter = g_symbolInfo.Bid() > g_bufEMAFilter[0];
   bool priceBelowFilter = g_symbolInfo.Bid() < g_bufEMAFilter[0];
   
   // MACD confirmation
   bool macdBullish = g_bufMACDMain[0] > g_bufMACDSignal[0];
   bool macdBearish = g_bufMACDMain[0] < g_bufMACDSignal[0];
   
   // Crossover detection
   bool bullishCrossover = g_bufEMAFast[1] <= g_bufEMASlow[1] && fastAboveSlow;
   bool bearishCrossover = g_bufEMAFast[1] >= g_bufEMASlow[1] && fastBelowSlow;
   
   // Buy signal
   if(bullishCrossover && priceAboveFilter && macdBullish)
      return 1;
   
   // Sell signal
   if(bearishCrossover && priceBelowFilter && macdBearish)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Get range/mean reversion signal                                   |
//+------------------------------------------------------------------+
int GetRangeSignal()
{
   double rsi = g_bufRSI[0];
   double stochMain = g_bufStochMain[0];
   double stochSignal = g_bufStochSignal[0];
   double price = g_symbolInfo.Bid();
   
   // Oversold conditions (buy)
   bool rsiOversold = rsi < InpRSIOversold;
   bool stochOversold = stochMain < 20 && stochSignal < 20;
   bool nearLowerBB = price <= g_bufBBLower[0] * 1.001;
   bool stochCrossUp = g_bufStochMain[1] < g_bufStochSignal[1] && stochMain > stochSignal;
   
   // Overbought conditions (sell)
   bool rsiOverbought = rsi > InpRSIOverbought;
   bool stochOverbought = stochMain > 80 && stochSignal > 80;
   bool nearUpperBB = price >= g_bufBBUpper[0] * 0.999;
   bool stochCrossDown = g_bufStochMain[1] > g_bufStochSignal[1] && stochMain < stochSignal;
   
   // Buy signal - mean reversion from oversold
   if((rsiOversold || stochOversold) && nearLowerBB && stochCrossUp)
      return 1;
   
   // Sell signal - mean reversion from overbought
   if((rsiOverbought || stochOverbought) && nearUpperBB && stochCrossDown)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Get breakout signal                                               |
//+------------------------------------------------------------------+
int GetBreakoutSignal()
{
   double price = g_symbolInfo.Bid();
   double atr = g_bufATR[0];
   
   // Find highest high and lowest low
   double highestHigh = 0;
   double lowestLow = DBL_MAX;
   
   for(int i = 1; i <= InpBreakoutPeriod; i++)
   {
      double high = iHigh(_Symbol, InpTimeframe, i);
      double low = iLow(_Symbol, InpTimeframe, i);
      if(high > highestHigh) highestHigh = high;
      if(low < lowestLow) lowestLow = low;
   }
   
   // ATR filter for significant breakout
   double breakoutThreshold = atr * InpBreakoutATRMult;
   
   // Bullish breakout
   if(price > highestHigh + breakoutThreshold)
   {
      // Confirm with ADX rising
      if(g_bufADX[0] > g_bufADX[1])
         return 1;
   }
   
   // Bearish breakout
   if(price < lowestLow - breakoutThreshold)
   {
      // Confirm with ADX rising
      if(g_bufADX[0] > g_bufADX[1])
         return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Execute trade                                                     |
//+------------------------------------------------------------------+
void ExecuteTrade(int signal)
{
   double lotSize = CalculateLotSize();
   double sl, tp;
   double ask = g_symbolInfo.Ask();
   double bid = g_symbolInfo.Bid();
   double point = g_symbolInfo.Point();
   int digits = (int)g_symbolInfo.Digits();
   
   // Calculate SL/TP
   double slPoints, tpPoints;
   
   if(InpUseDynamicSLTP)
   {
      double atr = g_bufATR[0];
      slPoints = MathMax(InpMinSLPoints, MathMin(InpMaxSLPoints, (atr / point) * InpSLATRMultiplier));
      tpPoints = slPoints * (InpTPATRMultiplier / InpSLATRMultiplier);
   }
   else
   {
      slPoints = InpFixedSL;
      tpPoints = InpFixedTP;
   }
   
   if(signal > 0)  // Buy
   {
      sl = NormalizeDouble(ask - slPoints * point, digits);
      tp = NormalizeDouble(ask + tpPoints * point, digits);
      
      if(g_trade.Buy(lotSize, _Symbol, ask, sl, tp, InpTradeComment))
      {
         Print("BUY opened: Lot=", lotSize, " Price=", ask, " SL=", sl, " TP=", tp, 
               " Regime=", EnumToString(g_currentRegime));
         g_dailyTradeCount++;
      }
      else
      {
         Print("Error opening BUY: ", g_trade.ResultRetcode(), " - ", g_trade.ResultRetcodeDescription());
      }
   }
   else if(signal < 0)  // Sell
   {
      sl = NormalizeDouble(bid + slPoints * point, digits);
      tp = NormalizeDouble(bid - tpPoints * point, digits);
      
      if(g_trade.Sell(lotSize, _Symbol, bid, sl, tp, InpTradeComment))
      {
         Print("SELL opened: Lot=", lotSize, " Price=", bid, " SL=", sl, " TP=", tp,
               " Regime=", EnumToString(g_currentRegime));
         g_dailyTradeCount++;
      }
      else
      {
         Print("Error opening SELL: ", g_trade.ResultRetcode(), " - ", g_trade.ResultRetcodeDescription());
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size based on mode                                  |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   double lotSize = InpFixedLot;
   
   switch(InpLotMode)
   {
      case LOT_MODE_FIXED:
         lotSize = InpFixedLot;
         break;
         
      case LOT_MODE_COMPOUND:
         {
            double balance = g_accountInfo.Balance();
            double tickValue = g_symbolInfo.TickValue();
            double tickSize = g_symbolInfo.TickSize();
            double point = g_symbolInfo.Point();
            
            // Risk amount based on compound factor
            double riskAmount = balance * (InpRiskPercent / 100.0) * InpCompoundFactor;
            
            // Calculate SL points for lot sizing
            double slPoints;
            if(InpUseDynamicSLTP)
            {
               double atr = g_bufATR[0];
               slPoints = MathMax(InpMinSLPoints, MathMin(InpMaxSLPoints, (atr / point) * InpSLATRMultiplier));
            }
            else
            {
               slPoints = InpFixedSL;
            }
            
            double slValue = slPoints * point;
            double slTicks = slValue / tickSize;
            
            if(tickValue > 0 && slTicks > 0)
               lotSize = riskAmount / (slTicks * tickValue);
         }
         break;
         
      case LOT_MODE_BALANCE:
         {
            // Progressive lot based on balance growth
            double balance = g_accountInfo.Balance();
            double balanceGrowth = (balance - g_initialBalance) / g_initialBalance;
            double multiplier = 1.0 + (balanceGrowth * InpCompoundFactor);
            multiplier = MathMax(1.0, MathMin(3.0, multiplier)); // Cap at 3x
            lotSize = InpFixedLot * multiplier;
         }
         break;
   }
   
   // Normalize lot size
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
//| Manage existing positions                                         |
//+------------------------------------------------------------------+
void ManagePositions()
{
   int total = PositionsTotal();
   double point = g_symbolInfo.Point();
   int digits = (int)g_symbolInfo.Digits();
   
   for(int i = total - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0) continue;
      
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      double currentPrice = (posType == POSITION_TYPE_BUY) ? g_symbolInfo.Bid() : g_symbolInfo.Ask();
      double profitPoints = (posType == POSITION_TYPE_BUY) ? 
                           (currentPrice - openPrice) / point :
                           (openPrice - currentPrice) / point;
      
      // Breakeven management
      if(InpUseBreakeven && profitPoints >= InpBreakevenStart)
      {
         double newSL;
         if(posType == POSITION_TYPE_BUY)
         {
            newSL = NormalizeDouble(openPrice + InpBreakevenOffset * point, digits);
            if(currentSL < newSL)
               g_trade.PositionModify(ticket, newSL, currentTP);
         }
         else
         {
            newSL = NormalizeDouble(openPrice - InpBreakevenOffset * point, digits);
            if(currentSL > newSL || currentSL == 0)
               g_trade.PositionModify(ticket, newSL, currentTP);
         }
      }
      
      // Partial close management
      if(InpUsePartialClose && !g_partialCloseDone[i % 100])
      {
         double tpDistance = MathAbs(currentTP - openPrice) / point;
         double partialTrigger = tpDistance * InpPartialCloseRatio;
         
         if(profitPoints >= partialTrigger)
         {
            double closeVolume = NormalizeDouble(volume * (InpPartialClosePercent / 100.0), 2);
            closeVolume = MathMax(closeVolume, g_symbolInfo.LotsMin());
            
            if(closeVolume < volume)
            {
               g_trade.PositionClosePartial(ticket, closeVolume);
               g_partialCloseDone[i % 100] = true;
               Print("Partial close executed: ", closeVolume, " lots at ", profitPoints, " points profit");
            }
         }
      }
      
      // Trailing stop management
      if(InpUseTrailingStop && profitPoints >= InpTrailingStart)
      {
         double newSL;
         if(posType == POSITION_TYPE_BUY)
         {
            newSL = NormalizeDouble(currentPrice - InpTrailingDistance * point, digits);
            if(newSL > currentSL + InpTrailingStep * point)
               g_trade.PositionModify(ticket, newSL, currentTP);
         }
         else
         {
            newSL = NormalizeDouble(currentPrice + InpTrailingDistance * point, digits);
            if(newSL < currentSL - InpTrailingStep * point || currentSL == 0)
               g_trade.PositionModify(ticket, newSL, currentTP);
         }
      }
   }
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
//| Protection checks                                                 |
//+------------------------------------------------------------------+
bool PassProtectionChecks()
{
   // Check daily loss limit
   double currentBalance = g_accountInfo.Balance();
   double dailyLossPercent = ((g_dailyStartBalance - currentBalance) / g_dailyStartBalance) * 100;
   
   if(dailyLossPercent >= InpMaxDailyLoss)
   {
      Print("Daily loss limit reached: ", dailyLossPercent, "%");
      return false;
   }
   
   // Check daily profit target (optional stop)
   double dailyProfitPercent = ((currentBalance - g_dailyStartBalance) / g_dailyStartBalance) * 100;
   if(dailyProfitPercent >= InpMaxDailyProfit)
   {
      Print("Daily profit target reached: ", dailyProfitPercent, "%");
      return false;
   }
   
   // Check total drawdown
   if(currentBalance > g_highestBalance)
      g_highestBalance = currentBalance;
   
   double totalDrawdown = ((g_highestBalance - currentBalance) / g_highestBalance) * 100;
   if(totalDrawdown >= InpMaxDrawdown)
   {
      Print("Maximum drawdown reached: ", totalDrawdown, "%");
      return false;
   }
   
   // Check daily trade limit
   if(g_dailyTradeCount >= InpMaxDailyTrades)
   {
      return false;
   }
   
   // Check consecutive losses
   if(g_consecutiveLosses >= InpMaxConsLosses)
   {
      Print("Maximum consecutive losses reached: ", g_consecutiveLosses);
      return false;
   }
   
   // Check margin level
   double marginLevel = g_accountInfo.MarginLevel();
   if(marginLevel > 0 && marginLevel < InpMinMarginLevel)
   {
      Print("Margin level too low: ", marginLevel, "%");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if valid trading session                                    |
//+------------------------------------------------------------------+
bool IsValidTradingSession()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Weekend check
   if(dt.day_of_week == 0 || dt.day_of_week == 6)
      return false;
   
   // Session hours check
   if(dt.hour < InpSessionStart || dt.hour >= InpSessionEnd)
      return false;
   
   // Lunch hour avoidance
   if(InpAvoidLunchHour && dt.hour >= 12 && dt.hour < 13)
      return false;
   
   // US/EU overlap preference
   if(InpTradeUSOverlap && dt.hour >= 14 && dt.hour < 17)
      return true; // Best time
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if Friday close time                                        |
//+------------------------------------------------------------------+
bool IsFridayCloseTime()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   return (dt.day_of_week == 5 && dt.hour >= InpFridayCloseHour);
}

//+------------------------------------------------------------------+
//| Close all positions                                               |
//+------------------------------------------------------------------+
void CloseAllPositions(string reason)
{
   int total = PositionsTotal();
   
   for(int i = total - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
         {
            g_trade.PositionClose(ticket);
            Print("Position closed: ", reason);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check for new trading day                                         |
//+------------------------------------------------------------------+
void CheckNewDay()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime today = StringToTime(IntegerToString(dt.year) + "." + 
                                 IntegerToString(dt.mon) + "." + 
                                 IntegerToString(dt.day));
   
   if(today != g_lastTradeDay)
   {
      g_lastTradeDay = today;
      g_dailyStartBalance = g_accountInfo.Balance();
      g_dailyTradeCount = 0;
      g_consecutiveLosses = 0;
      ArrayInitialize(g_partialCloseDone, false);
      Print("New trading day started. Balance: ", g_dailyStartBalance);
   }
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
//| Create dashboard panel                                            |
//+------------------------------------------------------------------+
void CreateDashboard()
{
   int x = 10, y = 30;
   int width = 280, height = 400;
   
   // Background
   ObjectCreate(0, "DAX_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "DAX_BG", OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, "DAX_BG", OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, "DAX_BG", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, "DAX_BG", OBJPROP_YSIZE, height);
   ObjectSetInteger(0, "DAX_BG", OBJPROP_BGCOLOR, InpDashboardColor);
   ObjectSetInteger(0, "DAX_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "DAX_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "DAX_BG", OBJPROP_BACK, false);
   
   // Title
   CreateLabel("DAX_Title", x + 10, y + 10, InpEAName, clrGold, 12);
   CreateLabel("DAX_Symbol", x + 10, y + 35, "Symbol: " + _Symbol, InpTextColor, 9);
   
   // Info labels
   CreateLabel("DAX_Regime", x + 10, y + 60, "Regime: ---", InpTextColor, 9);
   CreateLabel("DAX_Balance", x + 10, y + 80, "Balance: ---", InpTextColor, 9);
   CreateLabel("DAX_Equity", x + 10, y + 100, "Equity: ---", InpTextColor, 9);
   CreateLabel("DAX_DailyPnL", x + 10, y + 120, "Daily P/L: ---", InpTextColor, 9);
   CreateLabel("DAX_Drawdown", x + 10, y + 140, "Drawdown: ---", InpTextColor, 9);
   CreateLabel("DAX_Positions", x + 10, y + 160, "Positions: ---", InpTextColor, 9);
   CreateLabel("DAX_DailyTrades", x + 10, y + 180, "Daily Trades: ---", InpTextColor, 9);
   CreateLabel("DAX_LotMode", x + 10, y + 200, "Lot Mode: ---", InpTextColor, 9);
   CreateLabel("DAX_NextLot", x + 10, y + 220, "Next Lot: ---", InpTextColor, 9);
   
   // Indicators section
   CreateLabel("DAX_IndTitle", x + 10, y + 250, "=== INDICATORS ===", clrYellow, 9);
   CreateLabel("DAX_ADX", x + 10, y + 270, "ADX: ---", InpTextColor, 9);
   CreateLabel("DAX_RSI", x + 10, y + 290, "RSI: ---", InpTextColor, 9);
   CreateLabel("DAX_ATR", x + 10, y + 310, "ATR: ---", InpTextColor, 9);
   
   // Session info
   CreateLabel("DAX_Session", x + 10, y + 340, "Session: ---", InpTextColor, 9);
   CreateLabel("DAX_Time", x + 10, y + 360, "Server Time: ---", InpTextColor, 9);
   CreateLabel("DAX_Status", x + 10, y + 380, "Status: READY", clrLime, 9);
}

//+------------------------------------------------------------------+
//| Create label helper                                               |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr, int fontSize)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
}

//+------------------------------------------------------------------+
//| Update dashboard                                                  |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   double balance = g_accountInfo.Balance();
   double equity = g_accountInfo.Equity();
   double dailyPnL = balance - g_dailyStartBalance;
   double dailyPnLPercent = (dailyPnL / g_dailyStartBalance) * 100;
   double drawdown = ((g_highestBalance - balance) / g_highestBalance) * 100;
   
   // Update regime
   string regimeStr;
   color regimeColor;
   switch(g_currentRegime)
   {
      case REGIME_TRENDING_UP: regimeStr = "TREND UP"; regimeColor = clrLime; break;
      case REGIME_TRENDING_DOWN: regimeStr = "TREND DOWN"; regimeColor = clrRed; break;
      case REGIME_RANGING: regimeStr = "RANGING"; regimeColor = clrYellow; break;
      case REGIME_BREAKOUT: regimeStr = "BREAKOUT"; regimeColor = clrOrange; break;
      case REGIME_VOLATILE: regimeStr = "VOLATILE"; regimeColor = clrMagenta; break;
      default: regimeStr = "UNKNOWN"; regimeColor = clrGray;
   }
   ObjectSetString(0, "DAX_Regime", OBJPROP_TEXT, "Regime: " + regimeStr);
   ObjectSetInteger(0, "DAX_Regime", OBJPROP_COLOR, regimeColor);
   
   // Update financial info
   ObjectSetString(0, "DAX_Balance", OBJPROP_TEXT, StringFormat("Balance: %.2f %s", balance, g_accountInfo.Currency()));
   ObjectSetString(0, "DAX_Equity", OBJPROP_TEXT, StringFormat("Equity: %.2f %s", equity, g_accountInfo.Currency()));
   
   color pnlColor = (dailyPnL >= 0) ? InpProfitColor : InpLossColor;
   ObjectSetString(0, "DAX_DailyPnL", OBJPROP_TEXT, StringFormat("Daily P/L: %.2f (%.2f%%)", dailyPnL, dailyPnLPercent));
   ObjectSetInteger(0, "DAX_DailyPnL", OBJPROP_COLOR, pnlColor);
   
   ObjectSetString(0, "DAX_Drawdown", OBJPROP_TEXT, StringFormat("Drawdown: %.2f%%", drawdown));
   ObjectSetInteger(0, "DAX_Drawdown", OBJPROP_COLOR, (drawdown > InpMaxDrawdown * 0.7) ? InpLossColor : InpTextColor);
   
   ObjectSetString(0, "DAX_Positions", OBJPROP_TEXT, StringFormat("Positions: %d / %d", CountPositions(), InpMaxPositions));
   ObjectSetString(0, "DAX_DailyTrades", OBJPROP_TEXT, StringFormat("Daily Trades: %d / %d", g_dailyTradeCount, InpMaxDailyTrades));
   ObjectSetString(0, "DAX_LotMode", OBJPROP_TEXT, "Lot Mode: " + EnumToString(InpLotMode));
   ObjectSetString(0, "DAX_NextLot", OBJPROP_TEXT, StringFormat("Next Lot: %.2f", CalculateLotSize()));
   
   // Update indicators
   if(ArraySize(g_bufADX) > 0)
      ObjectSetString(0, "DAX_ADX", OBJPROP_TEXT, StringFormat("ADX: %.1f", g_bufADX[0]));
   if(ArraySize(g_bufRSI) > 0)
      ObjectSetString(0, "DAX_RSI", OBJPROP_TEXT, StringFormat("RSI: %.1f", g_bufRSI[0]));
   if(ArraySize(g_bufATR) > 0)
      ObjectSetString(0, "DAX_ATR", OBJPROP_TEXT, StringFormat("ATR: %.1f pts", g_bufATR[0] / g_symbolInfo.Point()));
   
   // Session info
   string sessionStatus = IsValidTradingSession() ? "ACTIVE" : "CLOSED";
   color sessionColor = IsValidTradingSession() ? clrLime : clrRed;
   ObjectSetString(0, "DAX_Session", OBJPROP_TEXT, "Session: " + sessionStatus);
   ObjectSetInteger(0, "DAX_Session", OBJPROP_COLOR, sessionColor);
   
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   ObjectSetString(0, "DAX_Time", OBJPROP_TEXT, StringFormat("Server: %02d:%02d", dt.hour, dt.min));
   
   // Status
   string status = "READY";
   color statusColor = clrLime;
   if(!PassProtectionChecks())
   {
      status = "PROTECTED";
      statusColor = clrOrange;
   }
   if(!IsValidTradingSession())
   {
      status = "WAITING";
      statusColor = clrYellow;
   }
   ObjectSetString(0, "DAX_Status", OBJPROP_TEXT, "Status: " + status);
   ObjectSetInteger(0, "DAX_Status", OBJPROP_COLOR, statusColor);
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
      
      g_dailyPnL += netProfit;
      
      if(netProfit < 0)
         g_consecutiveLosses++;
      else
         g_consecutiveLosses = 0;
      
      Print("Trade closed. Profit: ", netProfit, " Consecutive Losses: ", g_consecutiveLosses);
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
   double winRate = TesterStatistics(STAT_PROFIT_TRADES) / MathMax(1, trades) * 100;
   
   // Custom optimization: Profit / Drawdown * ProfitFactor * (WinRate bonus)
   if(drawdown > 0 && trades >= 30)
   {
      double winRateBonus = (winRate > 50) ? 1.0 + (winRate - 50) / 100 : 1.0;
      return (profit / drawdown) * profitFactor * winRateBonus;
   }
   
   return 0;
}
//+------------------------------------------------------------------+
