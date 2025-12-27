//+------------------------------------------------------------------+
//|                                          NASDAQ_US500_Hybrid.mq5 |
//|                                    Copyright 2024, Trading Systems |
//|                     Hybrid Trend Following + Breakout Expert Advisor |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trading Systems"
#property link      "https://github.com/lucciola85"
#property version   "1.00"
#property description "NASDAQ/US500 Hybrid - Trend Following + Breakout System"
#property description "Optimized for directional US equity indices"
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
   LOT_MODE_FIXED = 0,
   LOT_MODE_COMPOUND = 1,
   LOT_MODE_BALANCE = 2
};

enum ENUM_MARKET_REGIME
{
   REGIME_STRONG_TREND = 0,
   REGIME_WEAK_TREND = 1,
   REGIME_BREAKOUT = 2,
   REGIME_CONSOLIDATION = 3
};

enum ENUM_TRADE_DIRECTION
{
   TRADE_BOTH = 0,
   TRADE_BUY_ONLY = 1,
   TRADE_SELL_ONLY = 2
};

//+------------------------------------------------------------------+
//| Input Parameters - General Settings                               |
//+------------------------------------------------------------------+
input group "═══════════ GENERAL SETTINGS ═══════════"
input string            InpEAName           = "NASDAQ_US500_Hybrid";
input int               InpMagicNumber      = 505050;
input string            InpTradeComment     = "NQ_SP_Hybrid";
input ENUM_TIMEFRAMES   InpTimeframe        = PERIOD_H1;
input ENUM_TRADE_DIRECTION InpTradeDirection = TRADE_BOTH;

//+------------------------------------------------------------------+
//| Input Parameters - Money Management                               |
//+------------------------------------------------------------------+
input group "═══════════ MONEY MANAGEMENT ═══════════"
input ENUM_LOT_MODE     InpLotMode          = LOT_MODE_COMPOUND;
input double            InpFixedLot         = 0.1;
input double            InpRiskPercent      = 1.5;
input double            InpCompoundFactor   = 1.0;
input double            InpMinLotSize       = 0.01;
input double            InpMaxLotSize       = 5.0;
input int               InpMaxPositions     = 2;

//+------------------------------------------------------------------+
//| Input Parameters - Protection System                              |
//+------------------------------------------------------------------+
input group "═══════════ PROTECTION SYSTEM ═══════════"
input double            InpMaxDailyLoss     = 3.0;
input double            InpMaxDrawdown      = 10.0;
input double            InpMaxDailyProfit   = 5.0;
input int               InpMaxDailyTrades   = 5;
input int               InpMaxConsLosses    = 3;
input double            InpMinMarginLevel   = 200.0;
input bool              InpCloseOnFriday    = true;
input int               InpFridayCloseHour  = 20;

//+------------------------------------------------------------------+
//| Input Parameters - US Session Timing                              |
//+------------------------------------------------------------------+
input group "═══════════ US SESSION TIMING ═══════════"
input bool              InpUseSessionFilter = true;
input int               InpSessionStart     = 14;
input int               InpSessionEnd       = 21;
input bool              InpAvoidLunchHour   = false;
input bool              InpTradeOpeningHour = true;

//+------------------------------------------------------------------+
//| Input Parameters - Trend Strategy                                 |
//+------------------------------------------------------------------+
input group "═══════════ TREND STRATEGY ═══════════"
input bool              InpUseTrendStrategy = true;
input int               InpEMAFast          = 9;
input int               InpEMASlow          = 21;
input int               InpEMAFilter        = 50;
input int               InpADXPeriod        = 14;
input int               InpADXTrendLevel    = 25;
input int               InpMACDFast         = 12;
input int               InpMACDSlow         = 26;
input int               InpMACDSignal       = 9;

//+------------------------------------------------------------------+
//| Input Parameters - Breakout Strategy                              |
//+------------------------------------------------------------------+
input group "═══════════ BREAKOUT STRATEGY ═══════════"
input bool              InpUseBreakoutStrategy = true;
input int               InpDonchianPeriod   = 20;
input int               InpATRPeriod        = 14;
input double            InpATRBreakoutMult  = 0.5;
input bool              InpConfirmVolume    = true;
input double            InpVolumeMult       = 1.3;

//+------------------------------------------------------------------+
//| Input Parameters - Stop Loss & Take Profit                        |
//+------------------------------------------------------------------+
input group "═══════════ STOP LOSS & TAKE PROFIT ═══════════"
input bool              InpUseDynamicSLTP   = true;
input int               InpFixedSL          = 200;
input int               InpFixedTP          = 400;
input double            InpSLATRMultiplier  = 2.0;
input double            InpTPATRMultiplier  = 3.0;
input int               InpMinSLPoints      = 100;
input int               InpMaxSLPoints      = 400;

//+------------------------------------------------------------------+
//| Input Parameters - Position Management                            |
//+------------------------------------------------------------------+
input group "═══════════ POSITION MANAGEMENT ═══════════"
input bool              InpUsePartialClose  = true;
input double            InpPartialClosePercent = 50.0;
input double            InpPartialCloseRatio = 0.5;
input bool              InpUseBreakeven     = true;
input int               InpBreakevenStart   = 150;
input int               InpBreakevenOffset  = 20;
input bool              InpUseTrailingStop  = true;
input int               InpTrailingStart    = 200;
input int               InpTrailingStep     = 80;
input int               InpTrailingDistance = 120;

//+------------------------------------------------------------------+
//| Input Parameters - Display Settings                               |
//+------------------------------------------------------------------+
input group "═══════════ DISPLAY SETTINGS ═══════════"
input bool              InpShowDashboard    = true;
input color             InpDashboardColor   = clrDarkSlateGray;
input color             InpTextColor        = clrWhite;
input color             InpProfitColor      = clrLime;
input color             InpLossColor        = clrRed;

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
CTrade          g_trade;
CSymbolInfo     g_symbolInfo;
CPositionInfo   g_positionInfo;
CAccountInfo    g_accountInfo;

int g_handleEMAFast, g_handleEMASlow, g_handleEMAFilter;
int g_handleMACD, g_handleADX, g_handleATR;

double g_bufEMAFast[], g_bufEMASlow[], g_bufEMAFilter[];
double g_bufMACDMain[], g_bufMACDSignal[];
double g_bufADX[], g_bufADXPlus[], g_bufADXMinus[];
double g_bufATR[];

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
   string symbol = _Symbol;
   if(StringFind(symbol, "NAS") < 0 && StringFind(symbol, "USTEC") < 0 && 
      StringFind(symbol, "US500") < 0 && StringFind(symbol, "SPX") < 0 &&
      StringFind(symbol, "NDX") < 0 && StringFind(symbol, "SP500") < 0)
   {
      Print("WARNING: This EA is optimized for NASDAQ/US500. Current symbol: ", symbol);
   }
   
   if(!g_symbolInfo.Name(_Symbol))
   {
      Print("Error: Failed to initialize symbol info for ", _Symbol);
      return(INIT_FAILED);
   }
   
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(30);
   g_trade.SetAsyncMode(false);
   SetOptimalFillingType();
   
   if(!CreateIndicatorHandles())
      return(INIT_FAILED);
   
   InitializeBuffers();
   
   g_initialBalance = g_accountInfo.Balance();
   g_dailyStartBalance = g_initialBalance;
   g_highestBalance = g_initialBalance;
   g_lastBarTime = 0;
   g_lastTradeDay = 0;
   g_dailyTradeCount = 0;
   g_consecutiveLosses = 0;
   g_dailyPnL = 0;
   g_currentRegime = REGIME_CONSOLIDATION;
   ArrayResize(g_partialCloseDone, 100);
   ArrayInitialize(g_partialCloseDone, false);
   
   if(InpShowDashboard)
      CreateDashboard();
   
   Print("═══════════════════════════════════════════════════");
   Print("  ", InpEAName, " initialized successfully");
   Print("  Symbol: ", _Symbol);
   Print("  Account Balance: ", g_accountInfo.Balance());
   Print("  Trend Strategy: ", InpUseTrendStrategy ? "ON" : "OFF");
   Print("  Breakout Strategy: ", InpUseBreakoutStrategy ? "ON" : "OFF");
   Print("═══════════════════════════════════════════════════");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_handleEMAFast != INVALID_HANDLE) IndicatorRelease(g_handleEMAFast);
   if(g_handleEMASlow != INVALID_HANDLE) IndicatorRelease(g_handleEMASlow);
   if(g_handleEMAFilter != INVALID_HANDLE) IndicatorRelease(g_handleEMAFilter);
   if(g_handleMACD != INVALID_HANDLE) IndicatorRelease(g_handleMACD);
   if(g_handleADX != INVALID_HANDLE) IndicatorRelease(g_handleADX);
   if(g_handleATR != INVALID_HANDLE) IndicatorRelease(g_handleATR);
   
   ObjectsDeleteAll(0, "NQSP_");
   Print(InpEAName, " deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!g_symbolInfo.RefreshRates())
      return;
   
   CheckNewDay();
   
   if(InpShowDashboard)
      UpdateDashboard();
   
   ManagePositions();
   
   datetime currentBarTime = iTime(_Symbol, InpTimeframe, 0);
   if(currentBarTime == g_lastBarTime)
      return;
   g_lastBarTime = currentBarTime;
   
   if(!PassProtectionChecks())
      return;
   
   if(InpUseSessionFilter && !IsValidTradingSession())
      return;
   
   if(InpCloseOnFriday && IsFridayCloseTime())
   {
      CloseAllPositions("Friday close");
      return;
   }
   
   if(!CopyIndicatorBuffers())
      return;
   
   g_currentRegime = DetectMarketRegime();
   
   int signal = GetTradeSignal();
   
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
   g_handleEMAFast = iMA(_Symbol, InpTimeframe, InpEMAFast, 0, MODE_EMA, PRICE_CLOSE);
   g_handleEMASlow = iMA(_Symbol, InpTimeframe, InpEMASlow, 0, MODE_EMA, PRICE_CLOSE);
   g_handleEMAFilter = iMA(_Symbol, InpTimeframe, InpEMAFilter, 0, MODE_EMA, PRICE_CLOSE);
   
   if(g_handleEMAFast == INVALID_HANDLE || g_handleEMASlow == INVALID_HANDLE || 
      g_handleEMAFilter == INVALID_HANDLE)
   {
      Print("Error: Failed to create EMA handles");
      return false;
   }
   
   g_handleMACD = iMACD(_Symbol, InpTimeframe, InpMACDFast, InpMACDSlow, InpMACDSignal, PRICE_CLOSE);
   if(g_handleMACD == INVALID_HANDLE)
   {
      Print("Error: Failed to create MACD handle");
      return false;
   }
   
   g_handleADX = iADX(_Symbol, InpTimeframe, InpADXPeriod);
   if(g_handleADX == INVALID_HANDLE)
   {
      Print("Error: Failed to create ADX handle");
      return false;
   }
   
   g_handleATR = iATR(_Symbol, InpTimeframe, InpATRPeriod);
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
   ArraySetAsSeries(g_bufEMAFast, true);
   ArraySetAsSeries(g_bufEMASlow, true);
   ArraySetAsSeries(g_bufEMAFilter, true);
   ArraySetAsSeries(g_bufMACDMain, true);
   ArraySetAsSeries(g_bufMACDSignal, true);
   ArraySetAsSeries(g_bufADX, true);
   ArraySetAsSeries(g_bufADXPlus, true);
   ArraySetAsSeries(g_bufADXMinus, true);
   ArraySetAsSeries(g_bufATR, true);
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
   if(CopyBuffer(g_handleADX, 0, 0, bars, g_bufADX) < bars) return false;
   if(CopyBuffer(g_handleADX, 1, 0, bars, g_bufADXPlus) < bars) return false;
   if(CopyBuffer(g_handleADX, 2, 0, bars, g_bufADXMinus) < bars) return false;
   if(CopyBuffer(g_handleATR, 0, 0, bars, g_bufATR) < bars) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Detect current market regime                                      |
//+------------------------------------------------------------------+
ENUM_MARKET_REGIME DetectMarketRegime()
{
   double adx = g_bufADX[0];
   double adxPlus = g_bufADXPlus[0];
   double adxMinus = g_bufADXMinus[0];
   double atr = g_bufATR[0];
   double atrAvg = 0;
   
   for(int i = 0; i < 20; i++)
      atrAvg += g_bufATR[i];
   atrAvg /= 20;
   
   // Breakout detection: high ATR with price beyond recent range
   if(atr > atrAvg * 1.3)
   {
      double highestHigh = 0;
      double lowestLow = DBL_MAX;
      for(int i = 1; i <= InpDonchianPeriod; i++)
      {
         double high = iHigh(_Symbol, InpTimeframe, i);
         double low = iLow(_Symbol, InpTimeframe, i);
         if(high > highestHigh) highestHigh = high;
         if(low < lowestLow) lowestLow = low;
      }
      
      double price = g_symbolInfo.Bid();
      if(price > highestHigh || price < lowestLow)
         return REGIME_BREAKOUT;
   }
   
   // Strong trend
   if(adx >= InpADXTrendLevel + 5)
      return REGIME_STRONG_TREND;
   
   // Weak trend
   if(adx >= InpADXTrendLevel)
      return REGIME_WEAK_TREND;
   
   return REGIME_CONSOLIDATION;
}

//+------------------------------------------------------------------+
//| Get trade signal based on market regime                          |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
   int signal = 0;
   
   switch(g_currentRegime)
   {
      case REGIME_STRONG_TREND:
      case REGIME_WEAK_TREND:
         if(InpUseTrendStrategy)
            signal = GetTrendSignal();
         break;
         
      case REGIME_BREAKOUT:
         if(InpUseBreakoutStrategy)
            signal = GetBreakoutSignal();
         else if(InpUseTrendStrategy)
            signal = GetTrendSignal();
         break;
         
      case REGIME_CONSOLIDATION:
         // In consolidation, wait for breakout or trend confirmation
         if(InpUseBreakoutStrategy)
            signal = GetBreakoutSignal();
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
   bool fastAboveSlow = g_bufEMAFast[0] > g_bufEMASlow[0];
   bool fastBelowSlow = g_bufEMAFast[0] < g_bufEMASlow[0];
   bool priceAboveFilter = g_symbolInfo.Bid() > g_bufEMAFilter[0];
   bool priceBelowFilter = g_symbolInfo.Bid() < g_bufEMAFilter[0];
   
   bool macdBullish = g_bufMACDMain[0] > g_bufMACDSignal[0];
   bool macdBearish = g_bufMACDMain[0] < g_bufMACDSignal[0];
   
   bool bullishCrossover = g_bufEMAFast[1] <= g_bufEMASlow[1] && fastAboveSlow;
   bool bearishCrossover = g_bufEMAFast[1] >= g_bufEMASlow[1] && fastBelowSlow;
   
   // ADX direction confirmation
   bool adxBullish = g_bufADXPlus[0] > g_bufADXMinus[0];
   bool adxBearish = g_bufADXMinus[0] > g_bufADXPlus[0];
   
   // Buy signal
   if(bullishCrossover && priceAboveFilter && macdBullish && adxBullish)
      return 1;
   
   // Sell signal
   if(bearishCrossover && priceBelowFilter && macdBearish && adxBearish)
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
   
   // Calculate Donchian channels
   double highestHigh = 0;
   double lowestLow = DBL_MAX;
   
   for(int i = 1; i <= InpDonchianPeriod; i++)
   {
      double high = iHigh(_Symbol, InpTimeframe, i);
      double low = iLow(_Symbol, InpTimeframe, i);
      if(high > highestHigh) highestHigh = high;
      if(low < lowestLow) lowestLow = low;
   }
   
   double breakoutThreshold = atr * InpATRBreakoutMult;
   
   // Volume confirmation
   bool volumeConfirmed = true;
   if(InpConfirmVolume)
   {
      long currentVol = iVolume(_Symbol, InpTimeframe, 0);
      long avgVol = 0;
      for(int i = 1; i <= 20; i++)
         avgVol += iVolume(_Symbol, InpTimeframe, i);
      avgVol /= 20;
      volumeConfirmed = (currentVol > avgVol * InpVolumeMult);
   }
   
   // Bullish breakout
   if(price > highestHigh + breakoutThreshold && volumeConfirmed)
   {
      if(g_bufADX[0] > g_bufADX[1])
         return 1;
   }
   
   // Bearish breakout
   if(price < lowestLow - breakoutThreshold && volumeConfirmed)
   {
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
   
   if(signal > 0)
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
   else if(signal < 0)
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
            
            double riskAmount = balance * (InpRiskPercent / 100.0) * InpCompoundFactor;
            
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
            double balance = g_accountInfo.Balance();
            double balanceGrowth = (balance - g_initialBalance) / g_initialBalance;
            double multiplier = 1.0 + (balanceGrowth * InpCompoundFactor);
            multiplier = MathMax(1.0, MathMin(3.0, multiplier));
            lotSize = InpFixedLot * multiplier;
         }
         break;
   }
   
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
      
      // Breakeven
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
      
      // Partial close
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
               Print("Partial close: ", closeVolume, " lots at ", profitPoints, " points profit");
            }
         }
      }
      
      // Trailing stop
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
   double currentBalance = g_accountInfo.Balance();
   double dailyLossPercent = ((g_dailyStartBalance - currentBalance) / g_dailyStartBalance) * 100;
   
   if(dailyLossPercent >= InpMaxDailyLoss)
   {
      Print("Daily loss limit reached: ", dailyLossPercent, "%");
      return false;
   }
   
   double dailyProfitPercent = ((currentBalance - g_dailyStartBalance) / g_dailyStartBalance) * 100;
   if(dailyProfitPercent >= InpMaxDailyProfit)
   {
      Print("Daily profit target reached: ", dailyProfitPercent, "%");
      return false;
   }
   
   if(currentBalance > g_highestBalance)
      g_highestBalance = currentBalance;
   
   double totalDrawdown = ((g_highestBalance - currentBalance) / g_highestBalance) * 100;
   if(totalDrawdown >= InpMaxDrawdown)
   {
      Print("Maximum drawdown reached: ", totalDrawdown, "%");
      return false;
   }
   
   if(g_dailyTradeCount >= InpMaxDailyTrades)
      return false;
   
   if(g_consecutiveLosses >= InpMaxConsLosses)
   {
      Print("Maximum consecutive losses reached: ", g_consecutiveLosses);
      return false;
   }
   
   double marginLevel = g_accountInfo.MarginLevel();
   if(marginLevel > 0 && marginLevel < InpMinMarginLevel)
   {
      Print("Margin level too low: ", marginLevel, "%");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if valid trading session (US market hours)                  |
//+------------------------------------------------------------------+
bool IsValidTradingSession()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   if(dt.day_of_week == 0 || dt.day_of_week == 6)
      return false;
   
   if(dt.hour < InpSessionStart || dt.hour >= InpSessionEnd)
      return false;
   
   // Opening hour boost (first hour of NY session)
   if(InpTradeOpeningHour && dt.hour >= 14 && dt.hour < 15)
      return true;
   
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
      Print("New trading day. Balance: ", g_dailyStartBalance);
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
   int width = 280, height = 380;
   
   ObjectCreate(0, "NQSP_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "NQSP_BG", OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, "NQSP_BG", OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, "NQSP_BG", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, "NQSP_BG", OBJPROP_YSIZE, height);
   ObjectSetInteger(0, "NQSP_BG", OBJPROP_BGCOLOR, InpDashboardColor);
   ObjectSetInteger(0, "NQSP_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "NQSP_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "NQSP_BG", OBJPROP_BACK, false);
   
   CreateLabel("NQSP_Title", x + 10, y + 10, InpEAName, clrGold, 12);
   CreateLabel("NQSP_Symbol", x + 10, y + 35, "Symbol: " + _Symbol, InpTextColor, 9);
   CreateLabel("NQSP_Regime", x + 10, y + 60, "Regime: ---", InpTextColor, 9);
   CreateLabel("NQSP_Balance", x + 10, y + 85, "Balance: ---", InpTextColor, 9);
   CreateLabel("NQSP_Equity", x + 10, y + 105, "Equity: ---", InpTextColor, 9);
   CreateLabel("NQSP_DailyPnL", x + 10, y + 125, "Daily P/L: ---", InpTextColor, 9);
   CreateLabel("NQSP_Drawdown", x + 10, y + 145, "Drawdown: ---", InpTextColor, 9);
   CreateLabel("NQSP_Positions", x + 10, y + 165, "Positions: ---", InpTextColor, 9);
   CreateLabel("NQSP_DailyTrades", x + 10, y + 185, "Daily Trades: ---", InpTextColor, 9);
   CreateLabel("NQSP_LotMode", x + 10, y + 205, "Lot Mode: ---", InpTextColor, 9);
   CreateLabel("NQSP_NextLot", x + 10, y + 225, "Next Lot: ---", InpTextColor, 9);
   CreateLabel("NQSP_IndTitle", x + 10, y + 255, "=== INDICATORS ===", clrYellow, 9);
   CreateLabel("NQSP_ADX", x + 10, y + 275, "ADX: ---", InpTextColor, 9);
   CreateLabel("NQSP_ATR", x + 10, y + 295, "ATR: ---", InpTextColor, 9);
   CreateLabel("NQSP_Session", x + 10, y + 325, "Session: ---", InpTextColor, 9);
   CreateLabel("NQSP_Time", x + 10, y + 345, "Server Time: ---", InpTextColor, 9);
   CreateLabel("NQSP_Status", x + 10, y + 365, "Status: READY", clrLime, 9);
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
   
   string regimeStr;
   color regimeColor;
   switch(g_currentRegime)
   {
      case REGIME_STRONG_TREND: regimeStr = "STRONG TREND"; regimeColor = clrLime; break;
      case REGIME_WEAK_TREND: regimeStr = "WEAK TREND"; regimeColor = clrYellow; break;
      case REGIME_BREAKOUT: regimeStr = "BREAKOUT"; regimeColor = clrOrange; break;
      case REGIME_CONSOLIDATION: regimeStr = "CONSOLIDATION"; regimeColor = clrGray; break;
      default: regimeStr = "UNKNOWN"; regimeColor = clrGray;
   }
   ObjectSetString(0, "NQSP_Regime", OBJPROP_TEXT, "Regime: " + regimeStr);
   ObjectSetInteger(0, "NQSP_Regime", OBJPROP_COLOR, regimeColor);
   
   ObjectSetString(0, "NQSP_Balance", OBJPROP_TEXT, StringFormat("Balance: %.2f %s", balance, g_accountInfo.Currency()));
   ObjectSetString(0, "NQSP_Equity", OBJPROP_TEXT, StringFormat("Equity: %.2f %s", equity, g_accountInfo.Currency()));
   
   color pnlColor = (dailyPnL >= 0) ? InpProfitColor : InpLossColor;
   ObjectSetString(0, "NQSP_DailyPnL", OBJPROP_TEXT, StringFormat("Daily P/L: %.2f (%.2f%%)", dailyPnL, dailyPnLPercent));
   ObjectSetInteger(0, "NQSP_DailyPnL", OBJPROP_COLOR, pnlColor);
   
   ObjectSetString(0, "NQSP_Drawdown", OBJPROP_TEXT, StringFormat("Drawdown: %.2f%%", drawdown));
   ObjectSetInteger(0, "NQSP_Drawdown", OBJPROP_COLOR, (drawdown > InpMaxDrawdown * 0.7) ? InpLossColor : InpTextColor);
   
   ObjectSetString(0, "NQSP_Positions", OBJPROP_TEXT, StringFormat("Positions: %d / %d", CountPositions(), InpMaxPositions));
   ObjectSetString(0, "NQSP_DailyTrades", OBJPROP_TEXT, StringFormat("Daily Trades: %d / %d", g_dailyTradeCount, InpMaxDailyTrades));
   ObjectSetString(0, "NQSP_LotMode", OBJPROP_TEXT, "Lot Mode: " + EnumToString(InpLotMode));
   ObjectSetString(0, "NQSP_NextLot", OBJPROP_TEXT, StringFormat("Next Lot: %.2f", CalculateLotSize()));
   
   if(ArraySize(g_bufADX) > 0)
      ObjectSetString(0, "NQSP_ADX", OBJPROP_TEXT, StringFormat("ADX: %.1f", g_bufADX[0]));
   if(ArraySize(g_bufATR) > 0)
      ObjectSetString(0, "NQSP_ATR", OBJPROP_TEXT, StringFormat("ATR: %.1f pts", g_bufATR[0] / g_symbolInfo.Point()));
   
   string sessionStatus = IsValidTradingSession() ? "ACTIVE" : "CLOSED";
   color sessionColor = IsValidTradingSession() ? clrLime : clrRed;
   ObjectSetString(0, "NQSP_Session", OBJPROP_TEXT, "Session: " + sessionStatus);
   ObjectSetInteger(0, "NQSP_Session", OBJPROP_COLOR, sessionColor);
   
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   ObjectSetString(0, "NQSP_Time", OBJPROP_TEXT, StringFormat("Server: %02d:%02d", dt.hour, dt.min));
   
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
   ObjectSetString(0, "NQSP_Status", OBJPROP_TEXT, "Status: " + status);
   ObjectSetInteger(0, "NQSP_Status", OBJPROP_COLOR, statusColor);
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
   
   if(drawdown > 0 && trades >= 30)
   {
      double winRateBonus = (winRate > 50) ? 1.0 + (winRate - 50) / 100 : 1.0;
      return (profit / drawdown) * profitFactor * winRateBonus;
   }
   
   return 0;
}
//+------------------------------------------------------------------+
