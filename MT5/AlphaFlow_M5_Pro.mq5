//+------------------------------------------------------------------+
//|                                              AlphaFlow_M5_Pro.mq5 |
//|                                    Copyright 2024, Trading Systems |
//|                         Advanced M5 Expert Advisor - High PF & RF |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trading Systems"
#property link      "https://github.com/lucciola85"
#property version   "1.00"
#property description "AlphaFlow M5 Pro - Advanced Expert Advisor for 5-Minute Trading"
#property description "Optimized for High Profit Factor and Recovery Factor"
#property description "Multi-strategy with adaptive market regime detection"
#property strict

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
   LOT_MODE_RISK = 1,         // Risk Percent per Trade
   LOT_MODE_RECOVERY = 2      // Recovery Mode (Progressive)
};

enum ENUM_MARKET_REGIME
{
   REGIME_STRONG_TREND = 0,   // Strong Trend
   REGIME_WEAK_TREND = 1,     // Weak Trend
   REGIME_RANGING = 2,        // Ranging/Consolidation
   REGIME_BREAKOUT = 3,       // Breakout Mode
   REGIME_HIGH_VOLATILITY = 4 // High Volatility
};

enum ENUM_SIGNAL_STRENGTH
{
   SIGNAL_NONE = 0,           // No Signal
   SIGNAL_WEAK = 1,           // Weak Signal (1 confirmation)
   SIGNAL_MEDIUM = 2,         // Medium Signal (2 confirmations)
   SIGNAL_STRONG = 3          // Strong Signal (3+ confirmations)
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
input string            InpEAName           = "AlphaFlow_M5_Pro";  // EA Name
input int               InpMagicNumber      = 505050;              // Magic Number
input string            InpTradeComment     = "AFM5";              // Trade Comment
input ENUM_TIMEFRAMES   InpTimeframe        = PERIOD_M5;           // Main Timeframe (M5)
input ENUM_TIMEFRAMES   InpHTFFilter        = PERIOD_M15;          // Higher TF Filter
input ENUM_TRADE_DIRECTION InpTradeDirection = TRADE_BOTH;         // Trade Direction

//+------------------------------------------------------------------+
//| Input Parameters - Money Management (High Recovery Focus)         |
//+------------------------------------------------------------------+
input group "═══════════ MONEY MANAGEMENT ═══════════"
input ENUM_LOT_MODE     InpLotMode          = LOT_MODE_RISK;       // Lot Calculation Mode
input double            InpFixedLot         = 0.1;                 // Fixed Lot Size
input double            InpRiskPercent      = 1.0;                 // Risk per Trade (%)
input double            InpRecoveryFactor   = 1.2;                 // Recovery Multiplier (after loss)
input int               InpRecoveryTrades   = 2;                   // Recovery Trades Count
input double            InpMinLotSize       = 0.01;                // Minimum Lot Size
input double            InpMaxLotSize       = 10.0;                // Maximum Lot Size
input int               InpMaxPositions     = 1;                   // Max Open Positions

//+------------------------------------------------------------------+
//| Input Parameters - Protection (High Recovery Factor)              |
//+------------------------------------------------------------------+
input group "═══════════ PROTECTION SYSTEM ═══════════"
input double            InpMaxDailyLoss     = 3.0;                 // Max Daily Loss (%)
input double            InpMaxDrawdown      = 8.0;                 // Max Total Drawdown (%)
input double            InpDailyTarget      = 2.0;                 // Daily Profit Target (%)
input int               InpMaxDailyTrades   = 10;                  // Max Trades per Day
input int               InpMaxConsLosses    = 3;                   // Max Consecutive Losses
input int               InpCooldownMinutes  = 15;                  // Cooldown after Loss (min)

//+------------------------------------------------------------------+
//| Input Parameters - Session Filter                                 |
//+------------------------------------------------------------------+
input group "═══════════ SESSION TIMING ═══════════"
input bool              InpUseSessionFilter = true;                // Enable Session Filter
input int               InpSessionStart     = 8;                   // Session Start Hour
input int               InpSessionEnd       = 20;                  // Session End Hour
input bool              InpAvoidNews        = true;                // Avoid High Impact News Times
input bool              InpCloseOnFriday    = true;                // Close Before Weekend
input int               InpFridayCloseHour  = 20;                  // Friday Close Hour

//+------------------------------------------------------------------+
//| Input Parameters - Market Regime Detection                        |
//+------------------------------------------------------------------+
input group "═══════════ MARKET ANALYSIS ═══════════"
input int               InpADXPeriod        = 10;                  // ADX Period (faster for M5)
input int               InpADXStrongLevel   = 30;                  // ADX Strong Trend Level
input int               InpADXWeakLevel     = 20;                  // ADX Weak Trend Level
input int               InpATRPeriod        = 10;                  // ATR Period
input double            InpATRVolatileMult  = 1.8;                 // ATR Volatility Multiplier
input int               InpBBPeriod         = 14;                  // Bollinger Period (M5)
input double            InpBBDeviation      = 2.0;                 // Bollinger Deviation

//+------------------------------------------------------------------+
//| Input Parameters - Signal Generation (High Profit Factor)         |
//+------------------------------------------------------------------+
input group "═══════════ SIGNAL PARAMETERS ═══════════"
input int               InpEMAFast          = 5;                   // Fast EMA (M5 optimized)
input int               InpEMASlow          = 13;                  // Slow EMA (M5 optimized)
input int               InpEMAFilter        = 34;                  // Trend Filter EMA
input int               InpRSIPeriod        = 10;                  // RSI Period
input int               InpRSIOverbought    = 70;                  // RSI Overbought
input int               InpRSIOversold      = 30;                  // RSI Oversold
input int               InpMACDFast         = 8;                   // MACD Fast
input int               InpMACDSlow         = 17;                  // MACD Slow
input int               InpMACDSignal       = 9;                   // MACD Signal
input int               InpMinSignalStrength = 2;                  // Min Signal Confirmations

//+------------------------------------------------------------------+
//| Input Parameters - SL/TP (High R:R for Profit Factor)             |
//+------------------------------------------------------------------+
input group "═══════════ STOP LOSS & TAKE PROFIT ═══════════"
input bool              InpUseDynamicSLTP   = true;                // Dynamic SL/TP (ATR-based)
input int               InpFixedSL          = 100;                 // Fixed SL (Points)
input int               InpFixedTP          = 200;                 // Fixed TP (Points)
input double            InpSLATRMult        = 1.5;                 // SL ATR Multiplier
input double            InpTPATRMult        = 3.0;                 // TP ATR Multiplier (2:1 R:R)
input int               InpMinSLPoints      = 50;                  // Minimum SL (Points)
input int               InpMaxSLPoints      = 200;                 // Maximum SL (Points)

//+------------------------------------------------------------------+
//| Input Parameters - Trade Management                               |
//+------------------------------------------------------------------+
input group "═══════════ TRADE MANAGEMENT ═══════════"
input bool              InpUseBreakeven     = true;                // Enable Breakeven
input double            InpBEActivation     = 1.0;                 // BE at x*SL profit
input int               InpBEOffset         = 5;                   // BE Offset (Points)
input bool              InpUseTrailing      = true;                // Enable Trailing Stop
input double            InpTrailActivation  = 1.5;                 // Trail at x*SL profit
input double            InpTrailDistance    = 0.5;                 // Trail Distance (x*SL)
input bool              InpUsePartialClose  = true;                // Enable Partial Close
input double            InpPartialAt        = 1.0;                 // Partial at x*SL profit
input double            InpPartialPercent   = 50.0;                // Partial Close %

//+------------------------------------------------------------------+
//| Input Parameters - Display                                        |
//+------------------------------------------------------------------+
input group "═══════════ DISPLAY ═══════════"
input bool              InpShowDashboard    = true;                // Show Dashboard
input color             InpPanelColor       = clrDarkSlateGray;    // Panel Color
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
int g_hEMAFast, g_hEMASlow, g_hEMAFilter, g_hEMAFastHTF, g_hEMASlowHTF;
int g_hMACD, g_hRSI, g_hADX, g_hATR, g_hBB;

// Indicator buffers
double g_bufEMAFast[], g_bufEMASlow[], g_bufEMAFilter[];
double g_bufEMAFastHTF[], g_bufEMASlowHTF[];
double g_bufMACDMain[], g_bufMACDSignal[];
double g_bufRSI[], g_bufADX[], g_bufADXPlus[], g_bufADXMinus[];
double g_bufATR[], g_bufBBUpper[], g_bufBBMiddle[], g_bufBBLower[];

// State variables
double g_initialBalance, g_dailyStartBalance, g_peakBalance;
datetime g_lastBarTime, g_lastTradeDay, g_lastLossTime;
int g_dailyTrades, g_consecutiveLosses, g_recoveryTradesLeft;
ENUM_MARKET_REGIME g_currentRegime;
bool g_partialDone;
double g_lastSLPoints;

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!g_symbolInfo.Name(_Symbol))
   {
      Print("Error: Failed to initialize symbol");
      return INIT_FAILED;
   }
   
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(20);
   g_trade.SetAsyncMode(false);
   SetFillingType();
   
   if(!CreateHandles()) return INIT_FAILED;
   InitBuffers();
   
   g_initialBalance = g_accountInfo.Balance();
   g_dailyStartBalance = g_initialBalance;
   g_peakBalance = g_initialBalance;
   g_lastBarTime = 0;
   g_lastTradeDay = 0;
   g_lastLossTime = 0;
   g_dailyTrades = 0;
   g_consecutiveLosses = 0;
   g_recoveryTradesLeft = 0;
   g_currentRegime = REGIME_RANGING;
   g_partialDone = false;
   g_lastSLPoints = InpFixedSL;
   
   if(InpShowDashboard) CreateDashboard();
   
   Print("═══════════════════════════════════════════");
   Print("  ", InpEAName, " initialized");
   Print("  Symbol: ", _Symbol, " | TF: M5");
   Print("  Balance: ", g_initialBalance);
   Print("  Target R:R: 1:", InpTPATRMult/InpSLATRMult);
   Print("═══════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_hEMAFast != INVALID_HANDLE) IndicatorRelease(g_hEMAFast);
   if(g_hEMASlow != INVALID_HANDLE) IndicatorRelease(g_hEMASlow);
   if(g_hEMAFilter != INVALID_HANDLE) IndicatorRelease(g_hEMAFilter);
   if(g_hEMAFastHTF != INVALID_HANDLE) IndicatorRelease(g_hEMAFastHTF);
   if(g_hEMASlowHTF != INVALID_HANDLE) IndicatorRelease(g_hEMASlowHTF);
   if(g_hMACD != INVALID_HANDLE) IndicatorRelease(g_hMACD);
   if(g_hRSI != INVALID_HANDLE) IndicatorRelease(g_hRSI);
   if(g_hADX != INVALID_HANDLE) IndicatorRelease(g_hADX);
   if(g_hATR != INVALID_HANDLE) IndicatorRelease(g_hATR);
   if(g_hBB != INVALID_HANDLE) IndicatorRelease(g_hBB);
   
   ObjectsDeleteAll(0, "AF_");
   Print(InpEAName, " stopped. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!g_symbolInfo.RefreshRates()) return;
   
   CheckNewDay();
   if(InpShowDashboard) UpdateDashboard();
   ManagePositions();
   
   datetime barTime = iTime(_Symbol, InpTimeframe, 0);
   if(barTime == g_lastBarTime) return;
   g_lastBarTime = barTime;
   
   if(!CheckProtections()) return;
   if(InpUseSessionFilter && !IsValidSession()) return;
   if(InpCloseOnFriday && IsFridayClose())
   {
      CloseAll("Weekend");
      return;
   }
   
   if(!CopyBuffers()) return;
   
   g_currentRegime = DetectRegime();
   
   int signal = 0;
   ENUM_SIGNAL_STRENGTH strength = GetSignal(signal);
   
   if(signal != 0 && (int)strength >= InpMinSignalStrength && CountPositions() < InpMaxPositions)
   {
      OpenTrade(signal, strength);
   }
}

//+------------------------------------------------------------------+
//| Create indicator handles                                         |
//+------------------------------------------------------------------+
bool CreateHandles()
{
   g_hEMAFast = iMA(_Symbol, InpTimeframe, InpEMAFast, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMASlow = iMA(_Symbol, InpTimeframe, InpEMASlow, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMAFilter = iMA(_Symbol, InpTimeframe, InpEMAFilter, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMAFastHTF = iMA(_Symbol, InpHTFFilter, InpEMAFast, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMASlowHTF = iMA(_Symbol, InpHTFFilter, InpEMASlow, 0, MODE_EMA, PRICE_CLOSE);
   g_hMACD = iMACD(_Symbol, InpTimeframe, InpMACDFast, InpMACDSlow, InpMACDSignal, PRICE_CLOSE);
   g_hRSI = iRSI(_Symbol, InpTimeframe, InpRSIPeriod, PRICE_CLOSE);
   g_hADX = iADX(_Symbol, InpTimeframe, InpADXPeriod);
   g_hATR = iATR(_Symbol, InpTimeframe, InpATRPeriod);
   g_hBB = iBands(_Symbol, InpTimeframe, InpBBPeriod, 0, InpBBDeviation, PRICE_CLOSE);
   
   if(g_hEMAFast == INVALID_HANDLE || g_hEMASlow == INVALID_HANDLE || 
      g_hEMAFilter == INVALID_HANDLE || g_hMACD == INVALID_HANDLE ||
      g_hRSI == INVALID_HANDLE || g_hADX == INVALID_HANDLE ||
      g_hATR == INVALID_HANDLE || g_hBB == INVALID_HANDLE)
   {
      Print("Error creating indicators");
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Initialize buffers                                               |
//+------------------------------------------------------------------+
void InitBuffers()
{
   ArraySetAsSeries(g_bufEMAFast, true);
   ArraySetAsSeries(g_bufEMASlow, true);
   ArraySetAsSeries(g_bufEMAFilter, true);
   ArraySetAsSeries(g_bufEMAFastHTF, true);
   ArraySetAsSeries(g_bufEMASlowHTF, true);
   ArraySetAsSeries(g_bufMACDMain, true);
   ArraySetAsSeries(g_bufMACDSignal, true);
   ArraySetAsSeries(g_bufRSI, true);
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
bool CopyBuffers()
{
   int bars = 30;
   if(CopyBuffer(g_hEMAFast, 0, 0, bars, g_bufEMAFast) < bars) return false;
   if(CopyBuffer(g_hEMASlow, 0, 0, bars, g_bufEMASlow) < bars) return false;
   if(CopyBuffer(g_hEMAFilter, 0, 0, bars, g_bufEMAFilter) < bars) return false;
   if(CopyBuffer(g_hEMAFastHTF, 0, 0, bars, g_bufEMAFastHTF) < bars) return false;
   if(CopyBuffer(g_hEMASlowHTF, 0, 0, bars, g_bufEMASlowHTF) < bars) return false;
   if(CopyBuffer(g_hMACD, 0, 0, bars, g_bufMACDMain) < bars) return false;
   if(CopyBuffer(g_hMACD, 1, 0, bars, g_bufMACDSignal) < bars) return false;
   if(CopyBuffer(g_hRSI, 0, 0, bars, g_bufRSI) < bars) return false;
   if(CopyBuffer(g_hADX, 0, 0, bars, g_bufADX) < bars) return false;
   if(CopyBuffer(g_hADX, 1, 0, bars, g_bufADXPlus) < bars) return false;
   if(CopyBuffer(g_hADX, 2, 0, bars, g_bufADXMinus) < bars) return false;
   if(CopyBuffer(g_hATR, 0, 0, bars, g_bufATR) < bars) return false;
   if(CopyBuffer(g_hBB, 0, 0, bars, g_bufBBMiddle) < bars) return false;
   if(CopyBuffer(g_hBB, 1, 0, bars, g_bufBBUpper) < bars) return false;
   if(CopyBuffer(g_hBB, 2, 0, bars, g_bufBBLower) < bars) return false;
   return true;
}

//+------------------------------------------------------------------+
//| Detect market regime                                             |
//+------------------------------------------------------------------+
ENUM_MARKET_REGIME DetectRegime()
{
   double adx = g_bufADX[0];
   double atr = g_bufATR[0];
   double atrAvg = 0;
   for(int i = 0; i < 20; i++) atrAvg += g_bufATR[i];
   atrAvg /= 20;
   
   double bbWidth = (g_bufBBUpper[0] - g_bufBBLower[0]) / g_bufBBMiddle[0] * 100;
   double price = g_symbolInfo.Bid();
   
   if(atr > atrAvg * InpATRVolatileMult)
      return REGIME_HIGH_VOLATILITY;
   
   if((price > g_bufBBUpper[0] || price < g_bufBBLower[0]) && adx > InpADXWeakLevel)
      return REGIME_BREAKOUT;
   
   if(adx >= InpADXStrongLevel)
      return REGIME_STRONG_TREND;
   
   if(adx >= InpADXWeakLevel)
      return REGIME_WEAK_TREND;
   
   return REGIME_RANGING;
}

//+------------------------------------------------------------------+
//| Get trade signal with strength                                   |
//+------------------------------------------------------------------+
ENUM_SIGNAL_STRENGTH GetSignal(int &signal)
{
   signal = 0;
   int buyConf = 0, sellConf = 0;
   
   // 1. EMA Crossover on M5
   bool emaBullish = g_bufEMAFast[0] > g_bufEMASlow[0];
   bool emaBearish = g_bufEMAFast[0] < g_bufEMASlow[0];
   bool emaCrossUp = g_bufEMAFast[1] <= g_bufEMASlow[1] && emaBullish;
   bool emaCrossDown = g_bufEMAFast[1] >= g_bufEMASlow[1] && emaBearish;
   
   // 2. Price vs Trend Filter
   double price = g_symbolInfo.Bid();
   bool aboveFilter = price > g_bufEMAFilter[0];
   bool belowFilter = price < g_bufEMAFilter[0];
   
   // 3. HTF Trend Alignment
   bool htfBullish = g_bufEMAFastHTF[0] > g_bufEMASlowHTF[0];
   bool htfBearish = g_bufEMAFastHTF[0] < g_bufEMASlowHTF[0];
   
   // 4. MACD Confirmation
   bool macdBull = g_bufMACDMain[0] > g_bufMACDSignal[0];
   bool macdBear = g_bufMACDMain[0] < g_bufMACDSignal[0];
   bool macdCrossUp = g_bufMACDMain[1] <= g_bufMACDSignal[1] && macdBull;
   bool macdCrossDown = g_bufMACDMain[1] >= g_bufMACDSignal[1] && macdBear;
   
   // 5. RSI Filter
   double rsi = g_bufRSI[0];
   bool rsiOK_Buy = rsi > 40 && rsi < 70;
   bool rsiOK_Sell = rsi > 30 && rsi < 60;
   bool rsiOversold = rsi < InpRSIOversold;
   bool rsiOverbought = rsi > InpRSIOverbought;
   
   // 6. ADX Trend Strength
   bool adxStrong = g_bufADX[0] >= InpADXWeakLevel;
   bool diPlus = g_bufADXPlus[0] > g_bufADXMinus[0];
   bool diMinus = g_bufADXMinus[0] > g_bufADXPlus[0];
   
   // Count BUY confirmations
   if(emaCrossUp || (emaBullish && macdCrossUp)) buyConf++;
   if(aboveFilter && htfBullish) buyConf++;
   if(macdBull && adxStrong && diPlus) buyConf++;
   if(rsiOK_Buy || rsiOversold) buyConf++;
   
   // Count SELL confirmations
   if(emaCrossDown || (emaBearish && macdCrossDown)) sellConf++;
   if(belowFilter && htfBearish) sellConf++;
   if(macdBear && adxStrong && diMinus) sellConf++;
   if(rsiOK_Sell || rsiOverbought) sellConf++;
   
   // Determine signal
   if(buyConf >= InpMinSignalStrength && buyConf > sellConf)
   {
      signal = 1;
      if(InpTradeDirection == TRADE_SELL_ONLY) signal = 0;
      return (ENUM_SIGNAL_STRENGTH)MathMin(buyConf, 3);
   }
   
   if(sellConf >= InpMinSignalStrength && sellConf > buyConf)
   {
      signal = -1;
      if(InpTradeDirection == TRADE_BUY_ONLY) signal = 0;
      return (ENUM_SIGNAL_STRENGTH)MathMin(sellConf, 3);
   }
   
   return SIGNAL_NONE;
}

//+------------------------------------------------------------------+
//| Open trade                                                       |
//+------------------------------------------------------------------+
void OpenTrade(int signal, ENUM_SIGNAL_STRENGTH strength)
{
   double lot = CalcLotSize();
   double ask = g_symbolInfo.Ask();
   double bid = g_symbolInfo.Bid();
   double point = g_symbolInfo.Point();
   int digits = (int)g_symbolInfo.Digits();
   
   double slPts, tpPts;
   if(InpUseDynamicSLTP)
   {
      double atr = g_bufATR[0];
      slPts = MathMax(InpMinSLPoints, MathMin(InpMaxSLPoints, (atr / point) * InpSLATRMult));
      tpPts = slPts * (InpTPATRMult / InpSLATRMult);
   }
   else
   {
      slPts = InpFixedSL;
      tpPts = InpFixedTP;
   }
   
   // Boost TP for strong signals (higher PF)
   if(strength == SIGNAL_STRONG) tpPts *= 1.2;
   
   g_lastSLPoints = slPts;
   double sl, tp;
   
   if(signal > 0)
   {
      sl = NormalizeDouble(ask - slPts * point, digits);
      tp = NormalizeDouble(ask + tpPts * point, digits);
      
      if(g_trade.Buy(lot, _Symbol, ask, sl, tp, InpTradeComment))
      {
         g_dailyTrades++;
         g_partialDone = false;
         Print("BUY: Lot=", lot, " SL=", slPts, " TP=", tpPts, " Str=", EnumToString(strength));
      }
   }
   else
   {
      sl = NormalizeDouble(bid + slPts * point, digits);
      tp = NormalizeDouble(bid - tpPts * point, digits);
      
      if(g_trade.Sell(lot, _Symbol, bid, sl, tp, InpTradeComment))
      {
         g_dailyTrades++;
         g_partialDone = false;
         Print("SELL: Lot=", lot, " SL=", slPts, " TP=", tpPts, " Str=", EnumToString(strength));
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size with recovery mode                            |
//+------------------------------------------------------------------+
double CalcLotSize()
{
   double lot = InpFixedLot;
   
   if(InpLotMode == LOT_MODE_RISK || InpLotMode == LOT_MODE_RECOVERY)
   {
      double balance = g_accountInfo.Balance();
      double tickVal = g_symbolInfo.TickValue();
      double tickSize = g_symbolInfo.TickSize();
      double point = g_symbolInfo.Point();
      
      double riskPct = InpRiskPercent;
      
      // Recovery mode: increase risk after losses
      if(InpLotMode == LOT_MODE_RECOVERY && g_recoveryTradesLeft > 0)
      {
         riskPct *= InpRecoveryFactor;
      }
      
      double riskAmt = balance * (riskPct / 100.0);
      double slPts = InpUseDynamicSLTP ? 
                     MathMax(InpMinSLPoints, (g_bufATR[0] / point) * InpSLATRMult) : 
                     InpFixedSL;
      
      double slVal = slPts * point;
      double slTicks = slVal / tickSize;
      
      if(tickVal > 0 && slTicks > 0)
         lot = riskAmt / (slTicks * tickVal);
   }
   
   double step = g_symbolInfo.LotsStep();
   lot = MathFloor(lot / step) * step;
   lot = MathMax(InpMinLotSize, MathMin(InpMaxLotSize, lot));
   lot = MathMax(g_symbolInfo.LotsMin(), MathMin(g_symbolInfo.LotsMax(), lot));
   
   return NormalizeDouble(lot, 2);
}

//+------------------------------------------------------------------+
//| Manage positions                                                 |
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
      
      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      double vol = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      double price = (type == POSITION_TYPE_BUY) ? g_symbolInfo.Bid() : g_symbolInfo.Ask();
      double profitPts = (type == POSITION_TYPE_BUY) ? (price - open) / point : (open - price) / point;
      
      double slDist = g_lastSLPoints;
      
      // Breakeven
      if(InpUseBreakeven && profitPts >= slDist * InpBEActivation)
      {
         double newSL;
         if(type == POSITION_TYPE_BUY)
         {
            newSL = NormalizeDouble(open + InpBEOffset * point, digits);
            if(sl < newSL) g_trade.PositionModify(ticket, newSL, tp);
         }
         else
         {
            newSL = NormalizeDouble(open - InpBEOffset * point, digits);
            if(sl > newSL || sl == 0) g_trade.PositionModify(ticket, newSL, tp);
         }
      }
      
      // Partial close
      if(InpUsePartialClose && !g_partialDone && profitPts >= slDist * InpPartialAt)
      {
         double closeVol = NormalizeDouble(vol * InpPartialPercent / 100.0, 2);
         closeVol = MathMax(closeVol, g_symbolInfo.LotsMin());
         if(closeVol < vol)
         {
            g_trade.PositionClosePartial(ticket, closeVol);
            g_partialDone = true;
         }
      }
      
      // Trailing
      if(InpUseTrailing && profitPts >= slDist * InpTrailActivation)
      {
         double trailDist = slDist * InpTrailDistance * point;
         double newSL;
         if(type == POSITION_TYPE_BUY)
         {
            newSL = NormalizeDouble(price - trailDist, digits);
            if(newSL > sl + 10 * point) g_trade.PositionModify(ticket, newSL, tp);
         }
         else
         {
            newSL = NormalizeDouble(price + trailDist, digits);
            if(newSL < sl - 10 * point || sl == 0) g_trade.PositionModify(ticket, newSL, tp);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Protection checks                                                |
//+------------------------------------------------------------------+
bool CheckProtections()
{
   double balance = g_accountInfo.Balance();
   
   // Daily loss
   double dailyLoss = ((g_dailyStartBalance - balance) / g_dailyStartBalance) * 100;
   if(dailyLoss >= InpMaxDailyLoss) return false;
   
   // Daily target
   double dailyProfit = ((balance - g_dailyStartBalance) / g_dailyStartBalance) * 100;
   if(dailyProfit >= InpDailyTarget) return false;
   
   // Drawdown
   if(balance > g_peakBalance) g_peakBalance = balance;
   double dd = ((g_peakBalance - balance) / g_peakBalance) * 100;
   if(dd >= InpMaxDrawdown) return false;
   
   // Daily trades
   if(g_dailyTrades >= InpMaxDailyTrades) return false;
   
   // Consecutive losses
   if(g_consecutiveLosses >= InpMaxConsLosses) return false;
   
   // Cooldown
   if(g_lastLossTime > 0 && TimeCurrent() - g_lastLossTime < InpCooldownMinutes * 60)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Check valid session                                              |
//+------------------------------------------------------------------+
bool IsValidSession()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   if(dt.day_of_week == 0 || dt.day_of_week == 6) return false;
   if(dt.hour < InpSessionStart || dt.hour >= InpSessionEnd) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Friday close check                                               |
//+------------------------------------------------------------------+
bool IsFridayClose()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   return (dt.day_of_week == 5 && dt.hour >= InpFridayCloseHour);
}

//+------------------------------------------------------------------+
//| Count positions                                                  |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetTicket(i) > 0 &&
         PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
         count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAll(string reason)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 &&
         PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
      {
         g_trade.PositionClose(ticket);
         Print("Closed: ", reason);
      }
   }
}

//+------------------------------------------------------------------+
//| Check new day                                                    |
//+------------------------------------------------------------------+
void CheckNewDay()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime today = StringToTime(StringFormat("%d.%02d.%02d", dt.year, dt.mon, dt.day));
   
   if(today != g_lastTradeDay)
   {
      g_lastTradeDay = today;
      g_dailyStartBalance = g_accountInfo.Balance();
      g_dailyTrades = 0;
      g_consecutiveLosses = 0;
      g_lastLossTime = 0;
      Print("New day. Balance: ", g_dailyStartBalance);
   }
}

//+------------------------------------------------------------------+
//| Set filling type                                                 |
//+------------------------------------------------------------------+
void SetFillingType()
{
   uint fill = (uint)g_symbolInfo.TradeFillFlags();
   if(fill & SYMBOL_FILLING_FOK) g_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(fill & SYMBOL_FILLING_IOC) g_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else g_trade.SetTypeFilling(ORDER_FILLING_RETURN);
}

//+------------------------------------------------------------------+
//| OnTrade - Track results                                          |
//+------------------------------------------------------------------+
void OnTrade()
{
   static int lastDeals = 0;
   datetime start = TimeCurrent() - 86400;
   if(!HistorySelect(start, TimeCurrent())) return;
   
   int total = HistoryDealsTotal();
   if(total <= lastDeals) { lastDeals = total; return; }
   
   for(int i = lastDeals; i < total; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket <= 0) continue;
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != InpMagicNumber) continue;
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
      if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
      
      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT) + 
                      HistoryDealGetDouble(ticket, DEAL_COMMISSION) +
                      HistoryDealGetDouble(ticket, DEAL_SWAP);
      
      if(profit < 0)
      {
         g_consecutiveLosses++;
         g_lastLossTime = TimeCurrent();
         g_recoveryTradesLeft = InpRecoveryTrades;
      }
      else
      {
         g_consecutiveLosses = 0;
         if(g_recoveryTradesLeft > 0) g_recoveryTradesLeft--;
      }
   }
   lastDeals = total;
}

//+------------------------------------------------------------------+
//| Create dashboard                                                 |
//+------------------------------------------------------------------+
void CreateDashboard()
{
   int x = 10, y = 30, w = 260, h = 320;
   
   ObjectCreate(0, "AF_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "AF_BG", OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, "AF_BG", OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, "AF_BG", OBJPROP_XSIZE, w);
   ObjectSetInteger(0, "AF_BG", OBJPROP_YSIZE, h);
   ObjectSetInteger(0, "AF_BG", OBJPROP_BGCOLOR, InpPanelColor);
   ObjectSetInteger(0, "AF_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   
   CreateLabel("AF_Title", x+10, y+10, InpEAName, clrGold, 11);
   CreateLabel("AF_Symbol", x+10, y+30, _Symbol + " | M5", InpTextColor, 9);
   CreateLabel("AF_Regime", x+10, y+50, "Regime: ---", InpTextColor, 9);
   CreateLabel("AF_Balance", x+10, y+70, "Balance: ---", InpTextColor, 9);
   CreateLabel("AF_Equity", x+10, y+90, "Equity: ---", InpTextColor, 9);
   CreateLabel("AF_DailyPnL", x+10, y+110, "Daily: ---", InpTextColor, 9);
   CreateLabel("AF_DD", x+10, y+130, "Drawdown: ---", InpTextColor, 9);
   CreateLabel("AF_Trades", x+10, y+150, "Trades: ---", InpTextColor, 9);
   CreateLabel("AF_ConsLoss", x+10, y+170, "Cons.Loss: ---", InpTextColor, 9);
   CreateLabel("AF_Recovery", x+10, y+190, "Recovery: ---", InpTextColor, 9);
   CreateLabel("AF_ADX", x+10, y+220, "ADX: ---", InpTextColor, 9);
   CreateLabel("AF_RSI", x+10, y+240, "RSI: ---", InpTextColor, 9);
   CreateLabel("AF_ATR", x+10, y+260, "ATR: ---", InpTextColor, 9);
   CreateLabel("AF_Status", x+10, y+290, "READY", clrLime, 10);
}

//+------------------------------------------------------------------+
//| Create label                                                     |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr, int size)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
}

//+------------------------------------------------------------------+
//| Update dashboard                                                 |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   double bal = g_accountInfo.Balance();
   double eq = g_accountInfo.Equity();
   double daily = bal - g_dailyStartBalance;
   double dailyPct = (daily / g_dailyStartBalance) * 100;
   double dd = ((g_peakBalance - bal) / g_peakBalance) * 100;
   
   string regime;
   color regClr;
   switch(g_currentRegime)
   {
      case REGIME_STRONG_TREND: regime = "STRONG TREND"; regClr = clrLime; break;
      case REGIME_WEAK_TREND: regime = "WEAK TREND"; regClr = clrYellow; break;
      case REGIME_RANGING: regime = "RANGING"; regClr = clrAqua; break;
      case REGIME_BREAKOUT: regime = "BREAKOUT"; regClr = clrOrange; break;
      default: regime = "HIGH VOL"; regClr = clrMagenta;
   }
   
   ObjectSetString(0, "AF_Regime", OBJPROP_TEXT, "Regime: " + regime);
   ObjectSetInteger(0, "AF_Regime", OBJPROP_COLOR, regClr);
   ObjectSetString(0, "AF_Balance", OBJPROP_TEXT, StringFormat("Balance: %.2f", bal));
   ObjectSetString(0, "AF_Equity", OBJPROP_TEXT, StringFormat("Equity: %.2f", eq));
   ObjectSetString(0, "AF_DailyPnL", OBJPROP_TEXT, StringFormat("Daily: %.2f (%.2f%%)", daily, dailyPct));
   ObjectSetInteger(0, "AF_DailyPnL", OBJPROP_COLOR, daily >= 0 ? InpProfitColor : InpLossColor);
   ObjectSetString(0, "AF_DD", OBJPROP_TEXT, StringFormat("Drawdown: %.2f%%", dd));
   ObjectSetString(0, "AF_Trades", OBJPROP_TEXT, StringFormat("Trades: %d/%d", g_dailyTrades, InpMaxDailyTrades));
   ObjectSetString(0, "AF_ConsLoss", OBJPROP_TEXT, StringFormat("Cons.Loss: %d/%d", g_consecutiveLosses, InpMaxConsLosses));
   ObjectSetString(0, "AF_Recovery", OBJPROP_TEXT, StringFormat("Recovery: %d", g_recoveryTradesLeft));
   
   if(ArraySize(g_bufADX) > 0)
      ObjectSetString(0, "AF_ADX", OBJPROP_TEXT, StringFormat("ADX: %.1f", g_bufADX[0]));
   if(ArraySize(g_bufRSI) > 0)
      ObjectSetString(0, "AF_RSI", OBJPROP_TEXT, StringFormat("RSI: %.1f", g_bufRSI[0]));
   if(ArraySize(g_bufATR) > 0)
      ObjectSetString(0, "AF_ATR", OBJPROP_TEXT, StringFormat("ATR: %.1f", g_bufATR[0]/g_symbolInfo.Point()));
   
   string status = "READY";
   color stClr = clrLime;
   if(!CheckProtections()) { status = "PROTECTED"; stClr = clrOrange; }
   else if(!IsValidSession()) { status = "WAITING"; stClr = clrYellow; }
   ObjectSetString(0, "AF_Status", OBJPROP_TEXT, status);
   ObjectSetInteger(0, "AF_Status", OBJPROP_COLOR, stClr);
}

//+------------------------------------------------------------------+
//| Tester optimization                                              |
//+------------------------------------------------------------------+
double OnTester()
{
   double profit = TesterStatistics(STAT_PROFIT);
   double dd = TesterStatistics(STAT_EQUITY_DD_RELATIVE);
   double trades = TesterStatistics(STAT_TRADES);
   double pf = TesterStatistics(STAT_PROFIT_FACTOR);
   double recovery = (dd > 0) ? profit / dd : 0;
   
   // Optimize for: Profit Factor * Recovery Factor
   if(trades >= 30 && dd > 0)
      return pf * recovery;
   
   return 0;
}
//+------------------------------------------------------------------+
