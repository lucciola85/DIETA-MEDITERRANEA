//+------------------------------------------------------------------+
//|                                            PullbackMaster_EA.mq5 |
//|                                    Copyright 2024, Trading Systems |
//|                        Pullback/Bounce Expert Advisor for MT5     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trading Systems"
#property link      "https://github.com/lucciola85"
#property version   "1.00"
#property description "PullbackMaster EA - Specialized in pullback trading"
#property description "Trades bounces at support/resistance without breakouts"
#property description "Optimized for intraday trading with high winrate"
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
   LOT_FIXED = 0,              // Fixed Lot Size
   LOT_RISK_PERCENT = 1,       // Risk Percentage
   LOT_BALANCE_PERCENT = 2     // Balance Percentage
};

enum ENUM_SR_METHOD
{
   SR_SWING_POINTS = 0,        // Swing Points (Classic)
   SR_FRACTALS = 1             // Fractals Based
};

enum ENUM_TRADE_DIRECTION
{
   TRADE_BOTH = 0,             // Both Directions
   TRADE_BUY_ONLY = 1,         // Buy Only
   TRADE_SELL_ONLY = 2         // Sell Only
};

//+------------------------------------------------------------------+
//| Input Parameters - General Settings                               |
//+------------------------------------------------------------------+
input group "═══════════ GENERAL SETTINGS ═══════════"
input string            InpEAName           = "PullbackMaster";    // EA Name
input int               InpMagicNumber      = 202412;              // Magic Number
input string            InpTradeComment     = "PBM";               // Trade Comment
input ENUM_TIMEFRAMES   InpTimeframe        = PERIOD_M15;          // Main Timeframe
input ENUM_TRADE_DIRECTION InpTradeDirection = TRADE_BOTH;         // Trade Direction

//+------------------------------------------------------------------+
//| Input Parameters - Support/Resistance Detection                   |
//+------------------------------------------------------------------+
input group "═══════════ S/R DETECTION ═══════════"
input ENUM_SR_METHOD    InpSRMethod         = SR_SWING_POINTS;     // S/R Detection Method
input int               InpSwingLookback    = 10;                  // Swing Point Lookback Bars
input int               InpSRStrength       = 2;                   // S/R Strength (min touches)
input double            InpSRZoneATRMult    = 0.3;                 // S/R Zone Width (ATR mult)
input int               InpMaxSRLevels      = 5;                   // Max S/R Levels to Track

//+------------------------------------------------------------------+
//| Input Parameters - Pullback Detection                             |
//+------------------------------------------------------------------+
input group "═══════════ PULLBACK DETECTION ═══════════"
input double            InpBounceATRMult    = 0.5;                 // Bounce Proximity (ATR mult)
input int               InpMinBounceCandles = 2;                   // Min Candles for Bounce Confirm
input bool              InpRequireRejection = true;                // Require Wick Rejection
input double            InpMinWickRatio     = 0.5;                 // Min Wick/Body Ratio

//+------------------------------------------------------------------+
//| Input Parameters - Trend Filter                                   |
//+------------------------------------------------------------------+
input group "═══════════ TREND FILTER ═══════════"
input bool              InpUseTrendFilter   = true;                // Enable Trend Filter
input int               InpEMAPeriod        = 50;                  // EMA Period for Trend
input ENUM_TIMEFRAMES   InpTrendTimeframe   = PERIOD_H1;           // Trend Timeframe

//+------------------------------------------------------------------+
//| Input Parameters - RSI Filter                                     |
//+------------------------------------------------------------------+
input group "═══════════ RSI FILTER ═══════════"
input bool              InpUseRSIFilter     = true;                // Enable RSI Filter
input int               InpRSIPeriod        = 14;                  // RSI Period
input int               InpRSIOverbought    = 65;                  // RSI Overbought (for sells)
input int               InpRSIOversold      = 35;                  // RSI Oversold (for buys)

//+------------------------------------------------------------------+
//| Input Parameters - Money Management                               |
//+------------------------------------------------------------------+
input group "═══════════ MONEY MANAGEMENT ═══════════"
input ENUM_LOT_MODE     InpLotMode          = LOT_RISK_PERCENT;    // Lot Calculation Mode
input double            InpFixedLot         = 0.1;                 // Fixed Lot Size
input double            InpRiskPercent      = 1.0;                 // Risk per Trade (%)
input double            InpMinLotSize       = 0.01;                // Minimum Lot Size
input double            InpMaxLotSize       = 5.0;                 // Maximum Lot Size
input int               InpMaxPositions     = 2;                   // Max Open Positions

//+------------------------------------------------------------------+
//| Input Parameters - Protection System                              |
//+------------------------------------------------------------------+
input group "═══════════ PROTECTION SYSTEM ═══════════"
input double            InpMaxDailyLoss     = 3.0;                 // Max Daily Loss (%)
input double            InpMaxDrawdown      = 10.0;                // Max Total Drawdown (%)
input int               InpMaxDailyTrades   = 8;                   // Max Trades per Day
input double            InpMinMarginLevel   = 200.0;               // Min Margin Level (%)

//+------------------------------------------------------------------+
//| Input Parameters - Session Filter                                 |
//+------------------------------------------------------------------+
input group "═══════════ SESSION FILTER ═══════════"
input bool              InpUseSessionFilter = true;                // Enable Session Filter
input int               InpSessionStart     = 8;                   // Session Start (Server Time)
input int               InpSessionEnd       = 18;                  // Session End (Server Time)
input bool              InpAvoidNews        = true;                // Avoid High Impact News Hours

//+------------------------------------------------------------------+
//| Input Parameters - Stop Loss & Take Profit                        |
//+------------------------------------------------------------------+
input group "═══════════ STOP LOSS & TAKE PROFIT ═══════════"
input bool              InpUseDynamicSLTP   = true;                // Use Dynamic SL/TP (ATR-based)
input int               InpFixedSL          = 200;                 // Fixed Stop Loss (Points)
input int               InpFixedTP          = 300;                 // Fixed Take Profit (Points)
input double            InpSLATRMultiplier  = 1.5;                 // SL ATR Multiplier
input double            InpRiskReward       = 2.0;                 // Risk/Reward Ratio
input int               InpMinSLPoints      = 100;                 // Minimum SL (Points)
input int               InpMaxSLPoints      = 400;                 // Maximum SL (Points)

//+------------------------------------------------------------------+
//| Input Parameters - Position Management                            |
//+------------------------------------------------------------------+
input group "═══════════ POSITION MANAGEMENT ═══════════"
input bool              InpUseBreakeven     = true;                // Enable Breakeven
input double            InpBreakevenRatio   = 0.5;                 // Breakeven at TP Ratio
input int               InpBreakevenOffset  = 10;                  // Breakeven Offset (Points)
input bool              InpUseTrailingStop  = true;                // Enable Trailing Stop
input double            InpTrailingRatio    = 0.7;                 // Trailing Start at TP Ratio
input int               InpTrailingDistance = 100;                 // Trailing Distance (Points)
input bool              InpUsePartialClose  = false;               // Enable Partial Close
input double            InpPartialPercent   = 50.0;                // Partial Close (%)
input double            InpPartialRatio     = 0.5;                 // Partial Close at TP Ratio

//+------------------------------------------------------------------+
//| Input Parameters - Display Settings                               |
//+------------------------------------------------------------------+
input group "═══════════ DISPLAY ═══════════"
input bool              InpShowDashboard    = true;                // Show Dashboard
input bool              InpShowSRLevels     = true;                // Draw S/R Levels on Chart
input color             InpSupportColor     = clrLime;             // Support Level Color
input color             InpResistanceColor  = clrRed;              // Resistance Level Color

//+------------------------------------------------------------------+
//| Structure for S/R Levels                                          |
//+------------------------------------------------------------------+
struct SRLevel
{
   double   price;
   int      touches;
   bool     isSupport;
   datetime lastTouch;
};

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
CTrade          g_trade;
CSymbolInfo     g_symbolInfo;
CPositionInfo   g_positionInfo;
CAccountInfo    g_accountInfo;

// Indicator handles
int g_handleEMA;
int g_handleEMATrend;
int g_handleRSI;
int g_handleATR;

// Indicator buffers
double g_bufEMA[];
double g_bufEMATrend[];
double g_bufRSI[];
double g_bufATR[];

// S/R Levels storage
SRLevel g_supportLevels[];
SRLevel g_resistanceLevels[];

// Trading state variables
double g_initialBalance;
double g_dailyStartBalance;
double g_highestBalance;
datetime g_lastBarTime;
datetime g_lastTradeDay;
int g_dailyTradeCount;
bool g_partialCloseDone[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize symbol info
   if(!g_symbolInfo.Name(_Symbol))
   {
      Print("Error: Failed to initialize symbol info for ", _Symbol);
      return(INIT_FAILED);
   }
   
   // Set up trade object
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(20);
   g_trade.SetAsyncMode(false);
   SetOptimalFillingType();
   
   // Create indicator handles
   if(!CreateIndicatorHandles())
      return(INIT_FAILED);
   
   // Initialize buffers as series
   InitializeBuffers();
   
   // Initialize S/R arrays
   ArrayResize(g_supportLevels, InpMaxSRLevels);
   ArrayResize(g_resistanceLevels, InpMaxSRLevels);
   ClearSRLevels();
   
   // Initialize state variables
   g_initialBalance = g_accountInfo.Balance();
   g_dailyStartBalance = g_initialBalance;
   g_highestBalance = g_initialBalance;
   g_lastBarTime = 0;
   g_lastTradeDay = 0;
   g_dailyTradeCount = 0;
   ArrayResize(g_partialCloseDone, 50);
   ArrayInitialize(g_partialCloseDone, false);
   
   // Create dashboard
   if(InpShowDashboard)
      CreateDashboard();
   
   Print("═══════════════════════════════════════════════════");
   Print("  ", InpEAName, " initialized successfully");
   Print("  Symbol: ", _Symbol);
   Print("  Timeframe: ", EnumToString(InpTimeframe));
   Print("  Account: ", g_accountInfo.Name());
   Print("  Balance: ", g_accountInfo.Balance(), " ", g_accountInfo.Currency());
   Print("  Mode: Pullback Trading at S/R Levels");
   Print("═══════════════════════════════════════════════════");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release indicator handles
   if(g_handleEMA != INVALID_HANDLE) IndicatorRelease(g_handleEMA);
   if(g_handleEMATrend != INVALID_HANDLE) IndicatorRelease(g_handleEMATrend);
   if(g_handleRSI != INVALID_HANDLE) IndicatorRelease(g_handleRSI);
   if(g_handleATR != INVALID_HANDLE) IndicatorRelease(g_handleATR);
   
   // Delete chart objects
   ObjectsDeleteAll(0, "PBM_");
   
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
   
   // Update dashboard
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
   
   // Copy indicator buffers
   if(!CopyIndicatorBuffers())
      return;
   
   // Update S/R levels
   UpdateSRLevels();
   
   // Draw S/R levels on chart
   if(InpShowSRLevels)
      DrawSRLevels();
   
   // Get pullback signal
   int signal = GetPullbackSignal();
   
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
   // EMA on main timeframe
   g_handleEMA = iMA(_Symbol, InpTimeframe, InpEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(g_handleEMA == INVALID_HANDLE)
   {
      Print("Error: Failed to create EMA handle");
      return false;
   }
   
   // EMA on trend timeframe
   g_handleEMATrend = iMA(_Symbol, InpTrendTimeframe, InpEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(g_handleEMATrend == INVALID_HANDLE)
   {
      Print("Error: Failed to create Trend EMA handle");
      return false;
   }
   
   // RSI
   g_handleRSI = iRSI(_Symbol, InpTimeframe, InpRSIPeriod, PRICE_CLOSE);
   if(g_handleRSI == INVALID_HANDLE)
   {
      Print("Error: Failed to create RSI handle");
      return false;
   }
   
   // ATR
   g_handleATR = iATR(_Symbol, InpTimeframe, 14);
   if(g_handleATR == INVALID_HANDLE)
   {
      Print("Error: Failed to create ATR handle");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Initialize indicator buffers                                      |
//+------------------------------------------------------------------+
void InitializeBuffers()
{
   ArraySetAsSeries(g_bufEMA, true);
   ArraySetAsSeries(g_bufEMATrend, true);
   ArraySetAsSeries(g_bufRSI, true);
   ArraySetAsSeries(g_bufATR, true);
}

//+------------------------------------------------------------------+
//| Copy indicator buffers                                           |
//+------------------------------------------------------------------+
bool CopyIndicatorBuffers()
{
   int bars = 100;
   
   if(CopyBuffer(g_handleEMA, 0, 0, bars, g_bufEMA) < bars) return false;
   if(CopyBuffer(g_handleEMATrend, 0, 0, 10, g_bufEMATrend) < 10) return false;
   if(CopyBuffer(g_handleRSI, 0, 0, bars, g_bufRSI) < bars) return false;
   if(CopyBuffer(g_handleATR, 0, 0, bars, g_bufATR) < bars) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Clear S/R levels                                                  |
//+------------------------------------------------------------------+
void ClearSRLevels()
{
   for(int i = 0; i < InpMaxSRLevels; i++)
   {
      g_supportLevels[i].price = 0;
      g_supportLevels[i].touches = 0;
      g_supportLevels[i].isSupport = true;
      g_supportLevels[i].lastTouch = 0;
      
      g_resistanceLevels[i].price = 0;
      g_resistanceLevels[i].touches = 0;
      g_resistanceLevels[i].isSupport = false;
      g_resistanceLevels[i].lastTouch = 0;
   }
}

//+------------------------------------------------------------------+
//| Update Support/Resistance levels                                  |
//+------------------------------------------------------------------+
void UpdateSRLevels()
{
   double atr = g_bufATR[0];
   double zoneWidth = atr * InpSRZoneATRMult;
   
   // Temporary arrays for swing points
   double swingHighs[];
   double swingLows[];
   ArrayResize(swingHighs, 0);
   ArrayResize(swingLows, 0);
   
   // Find swing points
   int lookback = InpSwingLookback;
   int barsToCheck = lookback * 10; // Check more bars for history
   
   for(int i = lookback; i < barsToCheck; i++)
   {
      // Check for swing high
      if(IsSwingHigh(i, lookback))
      {
         double high = iHigh(_Symbol, InpTimeframe, i);
         AddToArray(swingHighs, high);
      }
      
      // Check for swing low
      if(IsSwingLow(i, lookback))
      {
         double low = iLow(_Symbol, InpTimeframe, i);
         AddToArray(swingLows, low);
      }
   }
   
   // Cluster swing highs into resistance levels
   ClusterLevels(swingHighs, g_resistanceLevels, zoneWidth, false);
   
   // Cluster swing lows into support levels
   ClusterLevels(swingLows, g_supportLevels, zoneWidth, true);
}

//+------------------------------------------------------------------+
//| Check if bar is a swing high                                      |
//+------------------------------------------------------------------+
bool IsSwingHigh(int bar, int lookback)
{
   double high = iHigh(_Symbol, InpTimeframe, bar);
   
   for(int i = 1; i <= lookback; i++)
   {
      if(iHigh(_Symbol, InpTimeframe, bar - i) >= high) return false;
      if(iHigh(_Symbol, InpTimeframe, bar + i) >= high) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if bar is a swing low                                       |
//+------------------------------------------------------------------+
bool IsSwingLow(int bar, int lookback)
{
   double low = iLow(_Symbol, InpTimeframe, bar);
   
   for(int i = 1; i <= lookback; i++)
   {
      if(iLow(_Symbol, InpTimeframe, bar - i) <= low) return false;
      if(iLow(_Symbol, InpTimeframe, bar + i) <= low) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Add value to array                                                |
//+------------------------------------------------------------------+
void AddToArray(double &arr[], double value)
{
   int size = ArraySize(arr);
   ArrayResize(arr, size + 1);
   arr[size] = value;
}

//+------------------------------------------------------------------+
//| Cluster price levels into S/R zones                               |
//+------------------------------------------------------------------+
void ClusterLevels(double &prices[], SRLevel &levels[], double zoneWidth, bool isSupport)
{
   int priceCount = ArraySize(prices);
   if(priceCount == 0) return;
   
   // Sort prices
   ArraySort(prices);
   
   // Cluster prices
   double clusters[];
   int clusterCounts[];
   ArrayResize(clusters, 0);
   ArrayResize(clusterCounts, 0);
   
   for(int i = 0; i < priceCount; i++)
   {
      bool found = false;
      int clusterSize = ArraySize(clusters);
      
      for(int j = 0; j < clusterSize; j++)
      {
         if(MathAbs(prices[i] - clusters[j]) <= zoneWidth)
         {
            // Update cluster average
            clusters[j] = (clusters[j] * clusterCounts[j] + prices[i]) / (clusterCounts[j] + 1);
            clusterCounts[j]++;
            found = true;
            break;
         }
      }
      
      if(!found)
      {
         ArrayResize(clusters, clusterSize + 1);
         ArrayResize(clusterCounts, clusterSize + 1);
         clusters[clusterSize] = prices[i];
         clusterCounts[clusterSize] = 1;
      }
   }
   
   // Sort clusters by touch count (strength)
   int clusterSize = ArraySize(clusters);
   for(int i = 0; i < clusterSize - 1; i++)
   {
      for(int j = i + 1; j < clusterSize; j++)
      {
         if(clusterCounts[j] > clusterCounts[i])
         {
            double tempPrice = clusters[i];
            int tempCount = clusterCounts[i];
            clusters[i] = clusters[j];
            clusterCounts[i] = clusterCounts[j];
            clusters[j] = tempPrice;
            clusterCounts[j] = tempCount;
         }
      }
   }
   
   // Fill levels array with strongest clusters
   int levelsToFill = MathMin(InpMaxSRLevels, clusterSize);
   for(int i = 0; i < InpMaxSRLevels; i++)
   {
      if(i < levelsToFill && clusterCounts[i] >= InpSRStrength)
      {
         levels[i].price = clusters[i];
         levels[i].touches = clusterCounts[i];
         levels[i].isSupport = isSupport;
         levels[i].lastTouch = TimeCurrent();
      }
      else
      {
         levels[i].price = 0;
         levels[i].touches = 0;
      }
   }
}

//+------------------------------------------------------------------+
//| Get pullback signal                                               |
//+------------------------------------------------------------------+
int GetPullbackSignal()
{
   double price = g_symbolInfo.Bid();
   double atr = g_bufATR[0];
   double bounceZone = atr * InpBounceATRMult;
   
   // Check for bounce at support (BUY signal)
   for(int i = 0; i < InpMaxSRLevels; i++)
   {
      if(g_supportLevels[i].price > 0 && g_supportLevels[i].touches >= InpSRStrength)
      {
         double support = g_supportLevels[i].price;
         
         // Price near support level
         if(price >= support - bounceZone && price <= support + bounceZone)
         {
            // Check bounce confirmation
            if(IsBounceConfirmed(true, support))
            {
               // Apply filters
               if(PassBuyFilters())
               {
                  Print("BUY signal at support: ", support, " Touches: ", g_supportLevels[i].touches);
                  return 1;
               }
            }
         }
      }
   }
   
   // Check for bounce at resistance (SELL signal)
   for(int i = 0; i < InpMaxSRLevels; i++)
   {
      if(g_resistanceLevels[i].price > 0 && g_resistanceLevels[i].touches >= InpSRStrength)
      {
         double resistance = g_resistanceLevels[i].price;
         
         // Price near resistance level
         if(price >= resistance - bounceZone && price <= resistance + bounceZone)
         {
            // Check bounce confirmation
            if(IsBounceConfirmed(false, resistance))
            {
               // Apply filters
               if(PassSellFilters())
               {
                  Print("SELL signal at resistance: ", resistance, " Touches: ", g_resistanceLevels[i].touches);
                  return -1;
               }
            }
         }
      }
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Check if bounce is confirmed                                      |
//+------------------------------------------------------------------+
bool IsBounceConfirmed(bool isBuyBounce, double level)
{
   // Check minimum candles for confirmation
   int bullishCount = 0;
   int bearishCount = 0;
   
   for(int i = 1; i <= InpMinBounceCandles + 1; i++)
   {
      double open = iOpen(_Symbol, InpTimeframe, i);
      double close = iClose(_Symbol, InpTimeframe, i);
      
      if(close > open) bullishCount++;
      else if(close < open) bearishCount++;
   }
   
   // For buy bounce: recent candles should turn bullish
   if(isBuyBounce)
   {
      // Current candle should be bullish or at least showing rejection
      double open0 = iOpen(_Symbol, InpTimeframe, 0);
      double close0 = iClose(_Symbol, InpTimeframe, 0);
      double low0 = iLow(_Symbol, InpTimeframe, 0);
      
      bool isBullish = close0 > open0;
      
      // Check wick rejection if required
      if(InpRequireRejection)
      {
         double body = MathAbs(close0 - open0);
         double lowerWick = MathMin(open0, close0) - low0;
         
         // For support bounce, lower wick should be significant
         if(body > 0 && lowerWick / body < InpMinWickRatio)
            return false;
      }
      
      return isBullish || bullishCount >= InpMinBounceCandles;
   }
   else
   {
      // For sell bounce: recent candles should turn bearish
      double open0 = iOpen(_Symbol, InpTimeframe, 0);
      double close0 = iClose(_Symbol, InpTimeframe, 0);
      double high0 = iHigh(_Symbol, InpTimeframe, 0);
      
      bool isBearish = close0 < open0;
      
      // Check wick rejection if required
      if(InpRequireRejection)
      {
         double body = MathAbs(close0 - open0);
         double upperWick = high0 - MathMax(open0, close0);
         
         // For resistance bounce, upper wick should be significant
         if(body > 0 && upperWick / body < InpMinWickRatio)
            return false;
      }
      
      return isBearish || bearishCount >= InpMinBounceCandles;
   }
}

//+------------------------------------------------------------------+
//| Pass buy filters                                                  |
//+------------------------------------------------------------------+
bool PassBuyFilters()
{
   // Direction filter
   if(InpTradeDirection == TRADE_SELL_ONLY)
      return false;
   
   // Trend filter
   if(InpUseTrendFilter)
   {
      double price = g_symbolInfo.Bid();
      // Allow buys in uptrend or ranging (price above or near trend EMA)
      if(price < g_bufEMATrend[0] * 0.995) // 0.5% tolerance
         return false;
   }
   
   // RSI filter
   if(InpUseRSIFilter)
   {
      double rsi = g_bufRSI[0];
      // For buy at support, RSI should be in oversold zone
      if(rsi > InpRSIOversold + 20) // RSI not yet oversold enough
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Pass sell filters                                                 |
//+------------------------------------------------------------------+
bool PassSellFilters()
{
   // Direction filter
   if(InpTradeDirection == TRADE_BUY_ONLY)
      return false;
   
   // Trend filter
   if(InpUseTrendFilter)
   {
      double price = g_symbolInfo.Bid();
      // Allow sells in downtrend or ranging (price below or near trend EMA)
      if(price > g_bufEMATrend[0] * 1.005) // 0.5% tolerance
         return false;
   }
   
   // RSI filter
   if(InpUseRSIFilter)
   {
      double rsi = g_bufRSI[0];
      // For sell at resistance, RSI should be in overbought zone
      if(rsi < InpRSIOverbought - 20) // RSI not yet overbought enough
         return false;
   }
   
   return true;
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
      tpPoints = slPoints * InpRiskReward;
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
         Print("BUY opened: Lot=", lotSize, " Price=", ask, " SL=", sl, " TP=", tp);
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
         Print("SELL opened: Lot=", lotSize, " Price=", bid, " SL=", sl, " TP=", tp);
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
      case LOT_FIXED:
         lotSize = InpFixedLot;
         break;
         
      case LOT_RISK_PERCENT:
         {
            double balance = g_accountInfo.Balance();
            double tickValue = g_symbolInfo.TickValue();
            double tickSize = g_symbolInfo.TickSize();
            double point = g_symbolInfo.Point();
            
            double riskAmount = balance * (InpRiskPercent / 100.0);
            
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
         
      case LOT_BALANCE_PERCENT:
         {
            double balance = g_accountInfo.Balance();
            double contractSize = g_symbolInfo.ContractSize();
            double lotValue = contractSize * g_symbolInfo.Ask();
            
            if(lotValue > 0)
               lotSize = (balance * InpRiskPercent / 100.0) / lotValue;
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
      
      double tpDistance = MathAbs(currentTP - openPrice) / point;
      
      // Breakeven management
      if(InpUseBreakeven && profitPoints >= tpDistance * InpBreakevenRatio)
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
      if(InpUsePartialClose && !g_partialCloseDone[i % 50])
      {
         double partialTrigger = tpDistance * InpPartialRatio;
         
         if(profitPoints >= partialTrigger)
         {
            double closeVolume = NormalizeDouble(volume * (InpPartialPercent / 100.0), 2);
            closeVolume = MathMax(closeVolume, g_symbolInfo.LotsMin());
            
            if(closeVolume < volume)
            {
               g_trade.PositionClosePartial(ticket, closeVolume);
               g_partialCloseDone[i % 50] = true;
               Print("Partial close: ", closeVolume, " lots at ", profitPoints, " points profit");
            }
         }
      }
      
      // Trailing stop management
      if(InpUseTrailingStop && profitPoints >= tpDistance * InpTrailingRatio)
      {
         double newSL;
         if(posType == POSITION_TYPE_BUY)
         {
            newSL = NormalizeDouble(currentPrice - InpTrailingDistance * point, digits);
            if(newSL > currentSL)
               g_trade.PositionModify(ticket, newSL, currentTP);
         }
         else
         {
            newSL = NormalizeDouble(currentPrice + InpTrailingDistance * point, digits);
            if(newSL < currentSL || currentSL == 0)
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
   double currentBalance = g_accountInfo.Balance();
   
   // Check daily loss limit
   double dailyLossPercent = ((g_dailyStartBalance - currentBalance) / g_dailyStartBalance) * 100;
   if(dailyLossPercent >= InpMaxDailyLoss)
   {
      return false;
   }
   
   // Check total drawdown
   if(currentBalance > g_highestBalance)
      g_highestBalance = currentBalance;
   
   double totalDrawdown = ((g_highestBalance - currentBalance) / g_highestBalance) * 100;
   if(totalDrawdown >= InpMaxDrawdown)
   {
      return false;
   }
   
   // Check daily trade limit
   if(g_dailyTradeCount >= InpMaxDailyTrades)
   {
      return false;
   }
   
   // Check margin level
   double marginLevel = g_accountInfo.MarginLevel();
   if(marginLevel > 0 && marginLevel < InpMinMarginLevel)
   {
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
   
   // Avoid news times (typical high-impact news hours)
   if(InpAvoidNews)
   {
      // Avoid first hour of major sessions and typical news release times
      if((dt.hour == 8 && dt.min < 30) ||  // European open
         (dt.hour == 13 && dt.min >= 30 && dt.min < 45) ||  // US news
         (dt.hour == 14 && dt.min < 30))    // US open
         return false;
   }
   
   return true;
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
      ArrayInitialize(g_partialCloseDone, false);
      
      // Recalculate S/R levels at start of day
      ClearSRLevels();
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
//| Draw S/R levels on chart                                          |
//+------------------------------------------------------------------+
void DrawSRLevels()
{
   // Clear existing level lines
   ObjectsDeleteAll(0, "PBM_SR_");
   
   double price = g_symbolInfo.Bid();
   double atr = g_bufATR[0];
   double relevantRange = atr * 20; // Only show levels within relevant range
   
   // Draw support levels
   for(int i = 0; i < InpMaxSRLevels; i++)
   {
      if(g_supportLevels[i].price > 0 && 
         MathAbs(price - g_supportLevels[i].price) <= relevantRange)
      {
         string name = "PBM_SR_S" + IntegerToString(i);
         ObjectCreate(0, name, OBJ_HLINE, 0, 0, g_supportLevels[i].price);
         ObjectSetInteger(0, name, OBJPROP_COLOR, InpSupportColor);
         ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
         ObjectSetString(0, name, OBJPROP_TEXT, 
            StringFormat("Support (T:%d)", g_supportLevels[i].touches));
      }
   }
   
   // Draw resistance levels
   for(int i = 0; i < InpMaxSRLevels; i++)
   {
      if(g_resistanceLevels[i].price > 0 && 
         MathAbs(price - g_resistanceLevels[i].price) <= relevantRange)
      {
         string name = "PBM_SR_R" + IntegerToString(i);
         ObjectCreate(0, name, OBJ_HLINE, 0, 0, g_resistanceLevels[i].price);
         ObjectSetInteger(0, name, OBJPROP_COLOR, InpResistanceColor);
         ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
         ObjectSetString(0, name, OBJPROP_TEXT, 
            StringFormat("Resistance (T:%d)", g_resistanceLevels[i].touches));
      }
   }
}

//+------------------------------------------------------------------+
//| Create dashboard panel                                            |
//+------------------------------------------------------------------+
void CreateDashboard()
{
   int x = 10, y = 30;
   int width = 250, height = 320;
   
   // Background
   ObjectCreate(0, "PBM_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "PBM_BG", OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, "PBM_BG", OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, "PBM_BG", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, "PBM_BG", OBJPROP_YSIZE, height);
   ObjectSetInteger(0, "PBM_BG", OBJPROP_BGCOLOR, clrDarkSlateGray);
   ObjectSetInteger(0, "PBM_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "PBM_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "PBM_BG", OBJPROP_BACK, false);
   
   // Title
   CreateLabel("PBM_Title", x + 10, y + 10, InpEAName, clrGold, 11);
   CreateLabel("PBM_Symbol", x + 10, y + 32, "Symbol: " + _Symbol, clrWhite, 9);
   
   // Info labels
   CreateLabel("PBM_Balance", x + 10, y + 55, "Balance: ---", clrWhite, 9);
   CreateLabel("PBM_Equity", x + 10, y + 75, "Equity: ---", clrWhite, 9);
   CreateLabel("PBM_DailyPnL", x + 10, y + 95, "Daily P/L: ---", clrWhite, 9);
   CreateLabel("PBM_Drawdown", x + 10, y + 115, "Drawdown: ---", clrWhite, 9);
   CreateLabel("PBM_Positions", x + 10, y + 135, "Positions: ---", clrWhite, 9);
   CreateLabel("PBM_DailyTrades", x + 10, y + 155, "Daily Trades: ---", clrWhite, 9);
   
   // Indicators section
   CreateLabel("PBM_IndTitle", x + 10, y + 180, "=== INDICATORS ===", clrYellow, 9);
   CreateLabel("PBM_RSI", x + 10, y + 200, "RSI: ---", clrWhite, 9);
   CreateLabel("PBM_ATR", x + 10, y + 220, "ATR: ---", clrWhite, 9);
   CreateLabel("PBM_Trend", x + 10, y + 240, "Trend: ---", clrWhite, 9);
   
   // S/R info
   CreateLabel("PBM_SRTitle", x + 10, y + 265, "=== S/R LEVELS ===", clrYellow, 9);
   CreateLabel("PBM_Support", x + 10, y + 285, "Nearest Support: ---", InpSupportColor, 9);
   CreateLabel("PBM_Resistance", x + 10, y + 305, "Nearest Resist: ---", InpResistanceColor, 9);
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
   
   // Update financial info
   ObjectSetString(0, "PBM_Balance", OBJPROP_TEXT, 
      StringFormat("Balance: %.2f %s", balance, g_accountInfo.Currency()));
   ObjectSetString(0, "PBM_Equity", OBJPROP_TEXT, 
      StringFormat("Equity: %.2f %s", equity, g_accountInfo.Currency()));
   
   color pnlColor = (dailyPnL >= 0) ? clrLime : clrRed;
   ObjectSetString(0, "PBM_DailyPnL", OBJPROP_TEXT, 
      StringFormat("Daily P/L: %.2f (%.2f%%)", dailyPnL, dailyPnLPercent));
   ObjectSetInteger(0, "PBM_DailyPnL", OBJPROP_COLOR, pnlColor);
   
   ObjectSetString(0, "PBM_Drawdown", OBJPROP_TEXT, 
      StringFormat("Drawdown: %.2f%%", drawdown));
   ObjectSetInteger(0, "PBM_Drawdown", OBJPROP_COLOR, 
      (drawdown > InpMaxDrawdown * 0.7) ? clrRed : clrWhite);
   
   ObjectSetString(0, "PBM_Positions", OBJPROP_TEXT, 
      StringFormat("Positions: %d / %d", CountPositions(), InpMaxPositions));
   ObjectSetString(0, "PBM_DailyTrades", OBJPROP_TEXT, 
      StringFormat("Daily Trades: %d / %d", g_dailyTradeCount, InpMaxDailyTrades));
   
   // Update indicators
   if(ArraySize(g_bufRSI) > 0)
   {
      double rsi = g_bufRSI[0];
      color rsiColor = clrWhite;
      if(rsi > InpRSIOverbought) rsiColor = clrRed;
      else if(rsi < InpRSIOversold) rsiColor = clrLime;
      ObjectSetString(0, "PBM_RSI", OBJPROP_TEXT, StringFormat("RSI: %.1f", rsi));
      ObjectSetInteger(0, "PBM_RSI", OBJPROP_COLOR, rsiColor);
   }
   
   if(ArraySize(g_bufATR) > 0)
      ObjectSetString(0, "PBM_ATR", OBJPROP_TEXT, 
         StringFormat("ATR: %.1f pts", g_bufATR[0] / g_symbolInfo.Point()));
   
   // Update trend
   if(ArraySize(g_bufEMATrend) > 0)
   {
      double price = g_symbolInfo.Bid();
      string trend = (price > g_bufEMATrend[0]) ? "BULLISH" : "BEARISH";
      color trendColor = (price > g_bufEMATrend[0]) ? clrLime : clrRed;
      ObjectSetString(0, "PBM_Trend", OBJPROP_TEXT, "Trend: " + trend);
      ObjectSetInteger(0, "PBM_Trend", OBJPROP_COLOR, trendColor);
   }
   
   // Update nearest S/R levels
   double price = g_symbolInfo.Bid();
   double nearestSupport = 0;
   double nearestResist = DBL_MAX;
   
   for(int i = 0; i < InpMaxSRLevels; i++)
   {
      if(g_supportLevels[i].price > 0 && g_supportLevels[i].price < price)
      {
         if(g_supportLevels[i].price > nearestSupport)
            nearestSupport = g_supportLevels[i].price;
      }
      
      if(g_resistanceLevels[i].price > 0 && g_resistanceLevels[i].price > price)
      {
         if(g_resistanceLevels[i].price < nearestResist)
            nearestResist = g_resistanceLevels[i].price;
      }
   }
   
   if(nearestSupport > 0)
      ObjectSetString(0, "PBM_Support", OBJPROP_TEXT, 
         StringFormat("Nearest Support: %.5f", nearestSupport));
   else
      ObjectSetString(0, "PBM_Support", OBJPROP_TEXT, "Nearest Support: N/A");
   
   if(nearestResist < DBL_MAX)
      ObjectSetString(0, "PBM_Resistance", OBJPROP_TEXT, 
         StringFormat("Nearest Resist: %.5f", nearestResist));
   else
      ObjectSetString(0, "PBM_Resistance", OBJPROP_TEXT, "Nearest Resist: N/A");
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
      
      Print("Trade closed. Net Profit: ", netProfit, " ", g_accountInfo.Currency());
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
   
   // Custom optimization: Balance profit, drawdown, profit factor and win rate
   if(drawdown > 0 && trades >= 20)
   {
      // Favor high win rate for pullback strategy
      double winRateBonus = (winRate > 55) ? 1.0 + (winRate - 55) / 50 : 1.0;
      return (profit / drawdown) * profitFactor * winRateBonus;
   }
   
   return 0;
}
//+------------------------------------------------------------------+
