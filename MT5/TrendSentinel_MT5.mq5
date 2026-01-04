//+------------------------------------------------------------------+
//|                                          TrendSentinel_MT5.mq5   |
//|                           Copyright 2024, Trend Sentinel Team    |
//|                                      https://trendsentinel.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trend Sentinel Team"
#property link      "https://trendsentinel.com"
#property version   "1.00"
#property description "Trend Sentinel EA - Multi-timeframe trend detection with stop entry orders"
#property description "Scans markets for high-quality trend starts with triple confirmation"

//--- Include standard library files
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Enums and Structures                                              |
//+------------------------------------------------------------------+
// Enum for trend direction
enum ENUM_TREND_DIRECTION
{
    TREND_NONE = 0,
    TREND_BULLISH = 1,
    TREND_BEARISH = -1
};

// Signal structure
struct STrendSignal
{
    string symbol;
    bool valid;
    ENUM_TREND_DIRECTION direction;
    ENUM_ORDER_TYPE orderType;
    double entryPrice;
    double stopLoss;
    double takeProfit;
    double partialTP;
    int quality;
    datetime timestamp;
};

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+
input group "=== SCANNER SETTINGS ==="
input int               ScanInterval = 300;                    // Scan Interval (seconds)
input bool              ScanAllSymbols = true;                 // Scan All Market Watch Symbols
input string            CustomSymbols = "";                    // Custom Symbols (comma separated)

input group "=== TREND DETECTION ==="
input ENUM_TIMEFRAMES   SignalTF = PERIOD_M15;                 // Signal Timeframe
input ENUM_TIMEFRAMES   ConfirmTF1 = PERIOD_H1;                // Confirmation Timeframe 1
input ENUM_TIMEFRAMES   ConfirmTF2 = PERIOD_H4;                // Confirmation Timeframe 2
input ENUM_TIMEFRAMES   FilterTF = PERIOD_D1;                  // Filter Timeframe
input int               MA_Fast_Period = 8;                    // EMA Fast Period
input int               MA_Slow_Period = 21;                   // EMA Slow Period
input int               MA_Trend_Period = 50;                  // EMA Trend Period
input int               Donchian_Period = 20;                  // Donchian Channel Period
input double            ADX_Threshold = 25.0;                  // ADX Threshold
input int               RSI_Period = 14;                       // RSI Period
input int               Volume_Lookback = 5;                   // Volume Lookback Period

input group "=== ENTRY & EXIT ==="
input bool              UseStopEntry = true;                   // Use Stop Entry Orders
input double            EntryDistance_ATR = 0.5;               // Entry Distance (ATR multiplier)
input double            SL_ATR_Multiplier = 1.8;               // Stop Loss (ATR multiplier)
input double            TP_RiskReward = 2.5;                   // Take Profit (Risk:Reward)
input bool              UsePartialClose = true;                // Use Partial Close
input double            PartialClose_At = 1.0;                 // Partial Close at R:R

input group "=== RISK MANAGEMENT ==="
input double            RiskPerTrade = 0.5;                    // Risk Per Trade (%)
input double            MaxDailyRisk = 2.0;                    // Max Daily Risk (%)
input int               MaxOpenTrades = 3;                     // Max Open Trades Per Symbol
input int               MaxTotalTrades = 10;                   // Max Total Open Trades
input bool              UseCorrelationFilter = true;           // Use Correlation Filter
input double            MaxCorrelation = 0.7;                  // Max Correlation

input group "=== ADVANCED FILTERS ==="
input int               MinTrendQuality = 7;                   // Min Trend Quality (0-10)
input bool              FilterNews = true;                     // Filter News Events
input int               NewsMinutesBefore = 60;                // News Minutes Before
input int               NewsMinutesAfter = 30;                 // News Minutes After
input bool              OnlyTradingHours = false;              // Only Trade During Hours
input string            TradingHoursStart = "08:00";           // Trading Hours Start
input string            TradingHoursEnd = "20:00";             // Trading Hours End

input group "=== GENERAL SETTINGS ==="
input int               MagicNumber = 123456;                  // Magic Number
input string            TradeComment = "TrendSentinel";        // Trade Comment

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
CTrade          g_trade;
CAccountInfo    g_account;
CSymbolInfo     g_symbolInfo;
CPositionInfo   g_positionInfo;

datetime        g_lastScanTime = 0;
double          g_dailyRisk = 0.0;
datetime        g_lastResetDate = 0;

string          g_symbolList[];
int             g_symbolCount = 0;

//+------------------------------------------------------------------+
//| CSymbolScanner Class - Scans symbols from Market Watch           |
//+------------------------------------------------------------------+
class CSymbolScanner
{
private:
    string m_symbols[];
    int m_count;

public:
    CSymbolScanner() : m_count(0) {}
    
    bool Initialize(bool scanAll, string customList)
    {
        ArrayResize(m_symbols, 0);
        m_count = 0;
        
        if(scanAll)
        {
            // Scan all symbols in Market Watch
            for(int i = 0; i < SymbolsTotal(true); i++)
            {
                string symbol = SymbolName(i, true);
                if(symbol != "" && SymbolSelect(symbol, true))
                {
                    ArrayResize(m_symbols, m_count + 1);
                    m_symbols[m_count] = symbol;
                    m_count++;
                }
            }
        }
        else if(customList != "")
        {
            // Parse custom symbol list
            string symbols[];
            StringSplit(customList, ',', symbols);
            
            for(int i = 0; i < ArraySize(symbols); i++)
            {
                string symbol = symbols[i];
                StringTrimLeft(symbol);
                StringTrimRight(symbol);
                
                if(symbol != "" && SymbolSelect(symbol, true))
                {
                    ArrayResize(m_symbols, m_count + 1);
                    m_symbols[m_count] = symbol;
                    m_count++;
                }
            }
        }
        
        Print("Scanner initialized with ", m_count, " symbols");
        return m_count > 0;
    }
    
    int GetSymbolCount() { return m_count; }
    string GetSymbol(int index) 
    { 
        if(index >= 0 && index < m_count)
            return m_symbols[index];
        return "";
    }
};

//+------------------------------------------------------------------+
//| CTrendDetector Class - Multi-timeframe trend detection           |
//+------------------------------------------------------------------+
class CTrendDetector
{
private:
    int m_handleEMAFast[];
    int m_handleEMASlow[];
    int m_handleEMATrend[];
    int m_handleATR[];
    int m_handleADX[];
    int m_handleRSI[];
    
    string m_currentSymbol;
    
    // Donchian Channel calculation
    double GetDonchianHigh(string symbol, ENUM_TIMEFRAMES tf, int period, int shift)
    {
        double high = 0;
        for(int i = shift; i < shift + period; i++)
        {
            double h = iHigh(symbol, tf, i);
            if(h > high) high = h;
        }
        return high;
    }
    
    double GetDonchianLow(string symbol, ENUM_TIMEFRAMES tf, int period, int shift)
    {
        double low = DBL_MAX;
        for(int i = shift; i < shift + period; i++)
        {
            double l = iLow(symbol, tf, i);
            if(l < low) low = l;
        }
        return low;
    }
    
    // Calculate average volume
    double GetAverageVolume(string symbol, ENUM_TIMEFRAMES tf, int period, int shift)
    {
        double sum = 0;
        for(int i = shift; i < shift + period; i++)
        {
            sum += (double)iVolume(symbol, tf, i);
        }
        return sum / period;
    }

public:
    CTrendDetector() : m_currentSymbol("") {}
    
    bool InitializeForSymbol(string symbol)
    {
        m_currentSymbol = symbol;
        
        // Create indicator handles for all timeframes
        ENUM_TIMEFRAMES timeframes[4] = {SignalTF, ConfirmTF1, ConfirmTF2, FilterTF};
        
        ArrayResize(m_handleEMAFast, 4);
        ArrayResize(m_handleEMASlow, 4);
        ArrayResize(m_handleEMATrend, 4);
        ArrayResize(m_handleATR, 4);
        ArrayResize(m_handleADX, 4);
        ArrayResize(m_handleRSI, 4);
        
        for(int i = 0; i < 4; i++)
        {
            m_handleEMAFast[i] = iMA(symbol, timeframes[i], MA_Fast_Period, 0, MODE_EMA, PRICE_CLOSE);
            m_handleEMASlow[i] = iMA(symbol, timeframes[i], MA_Slow_Period, 0, MODE_EMA, PRICE_CLOSE);
            m_handleEMATrend[i] = iMA(symbol, timeframes[i], MA_Trend_Period, 0, MODE_EMA, PRICE_CLOSE);
            m_handleATR[i] = iATR(symbol, timeframes[i], 14);
            m_handleADX[i] = iADX(symbol, timeframes[i], 14);
            m_handleRSI[i] = iRSI(symbol, timeframes[i], RSI_Period, PRICE_CLOSE);
            
            if(m_handleEMAFast[i] == INVALID_HANDLE || m_handleEMASlow[i] == INVALID_HANDLE ||
               m_handleEMATrend[i] == INVALID_HANDLE || m_handleATR[i] == INVALID_HANDLE ||
               m_handleADX[i] == INVALID_HANDLE || m_handleRSI[i] == INVALID_HANDLE)
            {
                Print("Failed to create indicators for ", symbol);
                return false;
            }
        }
        
        return true;
    }
    
    void ReleaseHandles()
    {
        for(int i = 0; i < ArraySize(m_handleEMAFast); i++)
        {
            if(m_handleEMAFast[i] != INVALID_HANDLE) IndicatorRelease(m_handleEMAFast[i]);
            if(m_handleEMASlow[i] != INVALID_HANDLE) IndicatorRelease(m_handleEMASlow[i]);
            if(m_handleEMATrend[i] != INVALID_HANDLE) IndicatorRelease(m_handleEMATrend[i]);
            if(m_handleATR[i] != INVALID_HANDLE) IndicatorRelease(m_handleATR[i]);
            if(m_handleADX[i] != INVALID_HANDLE) IndicatorRelease(m_handleADX[i]);
            if(m_handleRSI[i] != INVALID_HANDLE) IndicatorRelease(m_handleRSI[i]);
        }
    }
    
    // Analyze trend and generate signal
    STrendSignal AnalyzeTrend(string symbol)
    {
        STrendSignal signal;
        signal.symbol = symbol;
        signal.valid = false;
        signal.direction = TREND_NONE;
        signal.quality = 0;
        signal.timestamp = TimeCurrent();
        
        if(!InitializeForSymbol(symbol))
        {
            ReleaseHandles();
            return signal;
        }
        
        // Get indicator values
        double emaFast[], emaSlow[], emaTrend[], atr[], adxMain[], adxPlus[], adxMinus[], rsi[];
        ArraySetAsSeries(emaFast, true);
        ArraySetAsSeries(emaSlow, true);
        ArraySetAsSeries(emaTrend, true);
        ArraySetAsSeries(atr, true);
        ArraySetAsSeries(adxMain, true);
        ArraySetAsSeries(adxPlus, true);
        ArraySetAsSeries(adxMinus, true);
        ArraySetAsSeries(rsi, true);
        
        // Copy buffers for signal timeframe
        if(CopyBuffer(m_handleEMAFast[0], 0, 0, 3, emaFast) <= 0 ||
           CopyBuffer(m_handleEMASlow[0], 0, 0, 3, emaSlow) <= 0 ||
           CopyBuffer(m_handleEMATrend[2], 0, 0, 3, emaTrend) <= 0 ||
           CopyBuffer(m_handleATR[0], 0, 0, 3, atr) <= 0 ||
           CopyBuffer(m_handleADX[0], MAIN_LINE, 0, 3, adxMain) <= 0 ||
           CopyBuffer(m_handleADX[0], PLUSDI_LINE, 0, 3, adxPlus) <= 0 ||
           CopyBuffer(m_handleADX[0], MINUSDI_LINE, 0, 3, adxMinus) <= 0 ||
           CopyBuffer(m_handleRSI[0], 0, 0, 3, rsi) <= 0)
        {
            ReleaseHandles();
            return signal;
        }
        
        double close = iClose(symbol, SignalTF, 0);
        double donchianHigh = GetDonchianHigh(symbol, SignalTF, Donchian_Period, 1);
        double donchianLow = GetDonchianLow(symbol, SignalTF, Donchian_Period, 1);
        
        double currentVolume = (double)iVolume(symbol, SignalTF, 0);
        double avgVolume = GetAverageVolume(symbol, SignalTF, Volume_Lookback, 1);
        
        // Calculate trend quality score (0-10)
        int qualityScore = 0;
        
        // Check for bullish trend
        bool bullish = false;
        if(emaFast[0] > emaSlow[0] && emaFast[0] > emaTrend[0] && 
           close > donchianHigh && adxPlus[0] > adxMinus[0])
        {
            bullish = true;
            signal.direction = TREND_BULLISH;
            
            // Multi-timeframe alignment (max 4 points)
            if(CheckTrendAlignment(symbol, TREND_BULLISH))
                qualityScore += 4;
            else
                qualityScore += 2;
            
            // ADX strength (max 2 points)
            if(adxMain[0] > ADX_Threshold + 10)
                qualityScore += 2;
            else if(adxMain[0] > ADX_Threshold)
                qualityScore += 1;
            
            // Momentum (max 2 points)
            if(rsi[0] > 50 && rsi[0] < 70)
                qualityScore += 2;
            else if(rsi[0] > 50)
                qualityScore += 1;
            
            // Volume (max 1 point)
            if(currentVolume > avgVolume * 1.2)
                qualityScore += 1;
            
            // Structure break (max 1 point)
            if(close > donchianHigh)
                qualityScore += 1;
        }
        
        // Check for bearish trend
        bool bearish = false;
        if(emaFast[0] < emaSlow[0] && emaFast[0] < emaTrend[0] && 
           close < donchianLow && adxMinus[0] > adxPlus[0])
        {
            bearish = true;
            signal.direction = TREND_BEARISH;
            
            // Multi-timeframe alignment (max 4 points)
            if(CheckTrendAlignment(symbol, TREND_BEARISH))
                qualityScore += 4;
            else
                qualityScore += 2;
            
            // ADX strength (max 2 points)
            if(adxMain[0] > ADX_Threshold + 10)
                qualityScore += 2;
            else if(adxMain[0] > ADX_Threshold)
                qualityScore += 1;
            
            // Momentum (max 2 points)
            if(rsi[0] < 50 && rsi[0] > 30)
                qualityScore += 2;
            else if(rsi[0] < 50)
                qualityScore += 1;
            
            // Volume (max 1 point)
            if(currentVolume > avgVolume * 1.2)
                qualityScore += 1;
            
            // Structure break (max 1 point)
            if(close < donchianLow)
                qualityScore += 1;
        }
        
        signal.quality = qualityScore;
        
        // Check if signal meets minimum quality
        if((bullish || bearish) && qualityScore >= MinTrendQuality)
        {
            signal.valid = true;
            
            // Calculate entry, SL and TP
            CSymbolInfo symInfo;
            symInfo.Name(symbol);
            symInfo.RefreshRates();
            
            double atrValue = atr[0];
            double slDistance = atrValue * SL_ATR_Multiplier;
            
            if(bullish)
            {
                if(UseStopEntry)
                {
                    signal.entryPrice = symInfo.Ask() + atrValue * EntryDistance_ATR;
                    signal.orderType = ORDER_TYPE_BUY_STOP;
                }
                else
                {
                    signal.entryPrice = symInfo.Ask();
                    signal.orderType = ORDER_TYPE_BUY;
                }
                
                signal.stopLoss = signal.entryPrice - slDistance;
                signal.takeProfit = signal.entryPrice + (slDistance * TP_RiskReward);
                signal.partialTP = signal.entryPrice + (slDistance * PartialClose_At);
            }
            else if(bearish)
            {
                if(UseStopEntry)
                {
                    signal.entryPrice = symInfo.Bid() - atrValue * EntryDistance_ATR;
                    signal.orderType = ORDER_TYPE_SELL_STOP;
                }
                else
                {
                    signal.entryPrice = symInfo.Bid();
                    signal.orderType = ORDER_TYPE_SELL;
                }
                
                signal.stopLoss = signal.entryPrice + slDistance;
                signal.takeProfit = signal.entryPrice - (slDistance * TP_RiskReward);
                signal.partialTP = signal.entryPrice - (slDistance * PartialClose_At);
            }
            
            // Normalize prices
            signal.entryPrice = NormalizeDouble(signal.entryPrice, symInfo.Digits());
            signal.stopLoss = NormalizeDouble(signal.stopLoss, symInfo.Digits());
            signal.takeProfit = NormalizeDouble(signal.takeProfit, symInfo.Digits());
            signal.partialTP = NormalizeDouble(signal.partialTP, symInfo.Digits());
        }
        
        ReleaseHandles();
        return signal;
    }
    
    // Check trend alignment across multiple timeframes
    bool CheckTrendAlignment(string symbol, ENUM_TREND_DIRECTION direction)
    {
        int alignedCount = 0;
        ENUM_TIMEFRAMES timeframes[3] = {ConfirmTF1, ConfirmTF2, FilterTF};
        
        for(int i = 0; i < 3; i++)
        {
            double emaFast[], emaSlow[];
            ArraySetAsSeries(emaFast, true);
            ArraySetAsSeries(emaSlow, true);
            
            int tfIndex = i + 1; // Skip signal TF (index 0)
            
            if(CopyBuffer(m_handleEMAFast[tfIndex], 0, 0, 2, emaFast) > 0 &&
               CopyBuffer(m_handleEMASlow[tfIndex], 0, 0, 2, emaSlow) > 0)
            {
                if(direction == TREND_BULLISH && emaFast[0] > emaSlow[0])
                    alignedCount++;
                else if(direction == TREND_BEARISH && emaFast[0] < emaSlow[0])
                    alignedCount++;
            }
        }
        
        return alignedCount >= 2; // At least 2 out of 3 timeframes aligned
    }
};

//+------------------------------------------------------------------+
//| CRiskManager Class - Risk and position sizing management         |
//+------------------------------------------------------------------+
class CRiskManager
{
private:
    double m_dailyRisk;
    datetime m_lastResetDate;
    
public:
    CRiskManager() : m_dailyRisk(0.0), m_lastResetDate(0) {}
    
    void Initialize()
    {
        m_dailyRisk = 0.0;
        m_lastResetDate = TimeCurrent();
    }
    
    void ResetDailyIfNeeded()
    {
        MqlDateTime currentTime;
        TimeToStruct(TimeCurrent(), currentTime);
        
        MqlDateTime lastResetTime;
        TimeToStruct(m_lastResetDate, lastResetTime);
        
        if(currentTime.day != lastResetTime.day || currentTime.mon != lastResetTime.mon || currentTime.year != lastResetTime.year)
        {
            m_dailyRisk = 0.0;
            m_lastResetDate = TimeCurrent();
            Print("Daily risk reset");
        }
    }
    
    bool CanOpenNewTrade()
    {
        ResetDailyIfNeeded();
        
        double balance = g_account.Balance();
        double maxDailyRiskAmount = balance * MaxDailyRisk / 100.0;
        
        if(m_dailyRisk >= maxDailyRiskAmount)
        {
            Print("Daily risk limit reached: ", m_dailyRisk, " / ", maxDailyRiskAmount);
            return false;
        }
        
        return true;
    }
    
    double CalculateLotSize(string symbol, double entryPrice, double stopLoss)
    {
        CSymbolInfo symInfo;
        if(!symInfo.Name(symbol))
            return 0.0;
        
        symInfo.RefreshRates();
        
        double balance = g_account.Balance();
        double riskAmount = balance * RiskPerTrade / 100.0;
        
        double slDistance = MathAbs(entryPrice - stopLoss);
        if(slDistance <= 0)
            return 0.0;
        
        double tickValue = symInfo.TickValue();
        double tickSize = symInfo.TickSize();
        
        double lotSize = (riskAmount / slDistance) * tickSize / tickValue;
        
        // Normalize to lot step
        double lotStep = symInfo.LotsStep();
        lotSize = MathFloor(lotSize / lotStep) * lotStep;
        
        // Check limits
        double minLot = symInfo.LotsMin();
        double maxLot = symInfo.LotsMax();
        
        if(lotSize < minLot) lotSize = minLot;
        if(lotSize > maxLot) lotSize = maxLot;
        
        return NormalizeDouble(lotSize, 2);
    }
    
    void AddRisk(double riskAmount)
    {
        m_dailyRisk += riskAmount;
    }
    
    double GetDailyRisk() { return m_dailyRisk; }
};

//+------------------------------------------------------------------+
//| COrderManager Class - Order and position management              |
//+------------------------------------------------------------------+
class COrderManager
{
private:
    CTrade m_trade;
    
public:
    COrderManager() {}
    
    void Initialize()
    {
        m_trade.SetExpertMagicNumber(MagicNumber);
        m_trade.SetDeviationInPoints(10);
        m_trade.SetAsyncMode(false);
        m_trade.SetTypeFilling(ORDER_FILLING_FOK);
    }
    
    bool PlaceOrder(STrendSignal &signal, double lotSize)
    {
        bool result = false;
        
        if(signal.orderType == ORDER_TYPE_BUY || signal.orderType == ORDER_TYPE_BUY_STOP)
        {
            if(UseStopEntry && signal.orderType == ORDER_TYPE_BUY_STOP)
            {
                result = m_trade.BuyStop(lotSize, signal.entryPrice, signal.symbol, 
                                         signal.stopLoss, signal.takeProfit, 
                                         ORDER_TIME_GTC, 0, TradeComment);
            }
            else
            {
                result = m_trade.Buy(lotSize, signal.symbol, signal.entryPrice,
                                    signal.stopLoss, signal.takeProfit, TradeComment);
            }
        }
        else if(signal.orderType == ORDER_TYPE_SELL || signal.orderType == ORDER_TYPE_SELL_STOP)
        {
            if(UseStopEntry && signal.orderType == ORDER_TYPE_SELL_STOP)
            {
                result = m_trade.SellStop(lotSize, signal.entryPrice, signal.symbol,
                                          signal.stopLoss, signal.takeProfit,
                                          ORDER_TIME_GTC, 0, TradeComment);
            }
            else
            {
                result = m_trade.Sell(lotSize, signal.symbol, signal.entryPrice,
                                     signal.stopLoss, signal.takeProfit, TradeComment);
            }
        }
        
        if(result)
        {
            Print("Order placed successfully: ", signal.symbol, " ", EnumToString(signal.orderType),
                  " Entry: ", signal.entryPrice, " SL: ", signal.stopLoss, " TP: ", signal.takeProfit,
                  " Quality: ", signal.quality);
        }
        else
        {
            Print("Failed to place order: ", signal.symbol, " Error: ", GetLastError());
        }
        
        return result;
    }
    
    int CountPositions(string symbol = "")
    {
        int count = 0;
        
        for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
            if(g_positionInfo.SelectByIndex(i))
            {
                if(g_positionInfo.Magic() == MagicNumber)
                {
                    if(symbol == "" || g_positionInfo.Symbol() == symbol)
                        count++;
                }
            }
        }
        
        return count;
    }
    
    void ManagePositions()
    {
        for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
            if(!g_positionInfo.SelectByIndex(i))
                continue;
            
            if(g_positionInfo.Magic() != MagicNumber)
                continue;
            
            string symbol = g_positionInfo.Symbol();
            double currentPrice = g_positionInfo.PriceCurrent();
            double entryPrice = g_positionInfo.PriceOpen();
            double sl = g_positionInfo.StopLoss();
            double tp = g_positionInfo.TakeProfit();
            
            CSymbolInfo symInfo;
            if(!symInfo.Name(symbol))
                continue;
            
            symInfo.RefreshRates();
            
            // Calculate ATR for trailing stop
            int atrHandle = iATR(symbol, SignalTF, 14);
            if(atrHandle == INVALID_HANDLE)
                continue;
            
            double atr[];
            ArraySetAsSeries(atr, true);
            if(CopyBuffer(atrHandle, 0, 0, 1, atr) <= 0)
            {
                IndicatorRelease(atrHandle);
                continue;
            }
            
            double atrValue = atr[0];
            IndicatorRelease(atrHandle);
            
            // Trailing stop logic
            if(g_positionInfo.Type() == POSITION_TYPE_BUY)
            {
                double slDistance = MathAbs(entryPrice - sl);
                double profit = currentPrice - entryPrice;
                
                // Partial close at target
                if(UsePartialClose && profit >= slDistance * PartialClose_At)
                {
                    double currentVolume = g_positionInfo.Volume();
                    double closeVolume = NormalizeDouble(currentVolume * 0.5, 2);
                    
                    if(closeVolume >= symInfo.LotsMin())
                    {
                        m_trade.PositionClosePartial(g_positionInfo.Ticket(), closeVolume);
                        
                        // Move SL to breakeven
                        if(sl < entryPrice)
                            m_trade.PositionModify(g_positionInfo.Ticket(), entryPrice, tp);
                    }
                }
                
                // Trailing stop
                double newSL = currentPrice - atrValue * SL_ATR_Multiplier;
                if(newSL > sl && newSL < currentPrice)
                {
                    m_trade.PositionModify(g_positionInfo.Ticket(), newSL, tp);
                }
            }
            else if(g_positionInfo.Type() == POSITION_TYPE_SELL)
            {
                double slDistance = MathAbs(entryPrice - sl);
                double profit = entryPrice - currentPrice;
                
                // Partial close at target
                if(UsePartialClose && profit >= slDistance * PartialClose_At)
                {
                    double currentVolume = g_positionInfo.Volume();
                    double closeVolume = NormalizeDouble(currentVolume * 0.5, 2);
                    
                    if(closeVolume >= symInfo.LotsMin())
                    {
                        m_trade.PositionClosePartial(g_positionInfo.Ticket(), closeVolume);
                        
                        // Move SL to breakeven
                        if(sl > entryPrice)
                            m_trade.PositionModify(g_positionInfo.Ticket(), entryPrice, tp);
                    }
                }
                
                // Trailing stop
                double newSL = currentPrice + atrValue * SL_ATR_Multiplier;
                if(newSL < sl && newSL > currentPrice)
                {
                    m_trade.PositionModify(g_positionInfo.Ticket(), newSL, tp);
                }
            }
        }
    }
};

//+------------------------------------------------------------------+
//| Global Class Instances                                           |
//+------------------------------------------------------------------+
CSymbolScanner  g_scanner;
CRiskManager    g_riskManager;
COrderManager   g_orderManager;

//+------------------------------------------------------------------+
//| Utility Functions                                                |
//+------------------------------------------------------------------+
bool IsTradingHours()
{
    if(!OnlyTradingHours)
        return true;
    
    MqlDateTime currentTime;
    TimeToStruct(TimeCurrent(), currentTime);
    
    int startHour, startMin, endHour, endMin;
    string startParts[], endParts[];
    
    StringSplit(TradingHoursStart, ':', startParts);
    StringSplit(TradingHoursEnd, ':', endParts);
    
    if(ArraySize(startParts) < 2 || ArraySize(endParts) < 2)
        return true;
    
    startHour = (int)StringToInteger(startParts[0]);
    startMin = (int)StringToInteger(startParts[1]);
    endHour = (int)StringToInteger(endParts[0]);
    endMin = (int)StringToInteger(endParts[1]);
    
    int currentMinutes = currentTime.hour * 60 + currentTime.min;
    int startMinutes = startHour * 60 + startMin;
    int endMinutes = endHour * 60 + endMin;
    
    return (currentMinutes >= startMinutes && currentMinutes <= endMinutes);
}

bool IsImportantNewsPending()
{
    if(!FilterNews)
        return false;
    
    // Note: This is a placeholder. Real implementation would require
    // an economic calendar integration or external news feed
    // For now, return false to allow trading
    return false;
}

double GetSymbolCorrelation(string symbol1, string symbol2)
{
    if(!UseCorrelationFilter)
        return 0.0;
    
    // Simple correlation calculation based on price movements
    int periods = 20;
    double returns1[], returns2[];
    
    ArrayResize(returns1, periods);
    ArrayResize(returns2, periods);
    
    for(int i = 0; i < periods; i++)
    {
        double close1_curr = iClose(symbol1, PERIOD_H1, i);
        double close1_prev = iClose(symbol1, PERIOD_H1, i + 1);
        double close2_curr = iClose(symbol2, PERIOD_H1, i);
        double close2_prev = iClose(symbol2, PERIOD_H1, i + 1);
        
        if(close1_prev > 0 && close2_prev > 0)
        {
            returns1[i] = (close1_curr - close1_prev) / close1_prev;
            returns2[i] = (close2_curr - close2_prev) / close2_prev;
        }
    }
    
    // Calculate correlation coefficient
    double mean1 = 0, mean2 = 0;
    for(int i = 0; i < periods; i++)
    {
        mean1 += returns1[i];
        mean2 += returns2[i];
    }
    mean1 /= periods;
    mean2 /= periods;
    
    double numerator = 0, denom1 = 0, denom2 = 0;
    for(int i = 0; i < periods; i++)
    {
        double dev1 = returns1[i] - mean1;
        double dev2 = returns2[i] - mean2;
        numerator += dev1 * dev2;
        denom1 += dev1 * dev1;
        denom2 += dev2 * dev2;
    }
    
    if(denom1 <= 0 || denom2 <= 0)
        return 0.0;
    
    return numerator / MathSqrt(denom1 * denom2);
}

void LogSignal(STrendSignal &signal)
{
    string filename = "TrendSentinel_Signals_" + IntegerToString(g_account.Login()) + ".csv";
    int fileHandle = FileOpen(filename, FILE_WRITE | FILE_READ | FILE_CSV | FILE_ANSI, ',');
    
    if(fileHandle == INVALID_HANDLE)
    {
        Print("Failed to open log file: ", GetLastError());
        return;
    }
    
    // Check if file is empty (write header)
    if(FileSize(fileHandle) == 0)
    {
        FileWrite(fileHandle, "Timestamp", "Symbol", "Direction", "Entry", "SL", "TP", "Quality");
    }
    
    FileSeek(fileHandle, 0, SEEK_END);
    FileWrite(fileHandle, TimeToString(signal.timestamp), signal.symbol, 
              EnumToString(signal.direction), 
              DoubleToString(signal.entryPrice, 5),
              DoubleToString(signal.stopLoss, 5),
              DoubleToString(signal.takeProfit, 5),
              IntegerToString(signal.quality));
    
    FileClose(fileHandle);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("=== TrendSentinel EA Initializing ===");
    
    // Initialize account info
    if(!g_account.Login())
    {
        Print("Failed to get account info");
        return INIT_FAILED;
    }
    
    // Initialize trade object
    g_trade.SetExpertMagicNumber(MagicNumber);
    g_trade.SetDeviationInPoints(10);
    g_trade.SetAsyncMode(false);
    
    // Initialize scanner
    if(!g_scanner.Initialize(ScanAllSymbols, CustomSymbols))
    {
        Print("Failed to initialize symbol scanner");
        return INIT_FAILED;
    }
    
    // Initialize risk manager
    g_riskManager.Initialize();
    
    // Initialize order manager
    g_orderManager.Initialize();
    
    // Set up timer for scanning
    if(!EventSetTimer(ScanInterval))
    {
        Print("Failed to set timer");
        return INIT_FAILED;
    }
    
    Print("TrendSentinel EA initialized successfully");
    Print("Account: ", g_account.Name(), " #", g_account.Login());
    Print("Balance: ", g_account.Balance(), " ", g_account.Currency());
    Print("Scanning ", g_scanner.GetSymbolCount(), " symbols every ", ScanInterval, " seconds");
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    EventKillTimer();
    Print("TrendSentinel EA deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Manage existing positions (trailing stop, partial close)
    g_orderManager.ManagePositions();
}

//+------------------------------------------------------------------+
//| Timer function - Scheduled scanning                              |
//+------------------------------------------------------------------+
void OnTimer()
{
    datetime currentTime = TimeCurrent();
    
    // Check if it's time to scan
    if(currentTime - g_lastScanTime < ScanInterval)
        return;
    
    g_lastScanTime = currentTime;
    
    Print("=== Starting Market Scan ===");
    
    // Check trading hours
    if(!IsTradingHours())
    {
        Print("Outside trading hours");
        return;
    }
    
    // Check for important news
    if(IsImportantNewsPending())
    {
        Print("Important news pending, skipping scan");
        return;
    }
    
    // Check if we can open new trades
    if(!g_riskManager.CanOpenNewTrade())
    {
        Print("Daily risk limit reached");
        return;
    }
    
    // Check total positions
    int totalPositions = g_orderManager.CountPositions();
    if(totalPositions >= MaxTotalTrades)
    {
        Print("Maximum total positions reached: ", totalPositions);
        return;
    }
    
    // Scan all symbols
    int signalsFound = 0;
    
    for(int i = 0; i < g_scanner.GetSymbolCount(); i++)
    {
        string symbol = g_scanner.GetSymbol(i);
        
        // Check positions for this symbol
        int symbolPositions = g_orderManager.CountPositions(symbol);
        if(symbolPositions >= MaxOpenTrades)
        {
            continue;
        }
        
        // Check correlation with existing positions
        if(UseCorrelationFilter && totalPositions > 0)
        {
            bool highCorrelation = false;
            
            for(int j = PositionsTotal() - 1; j >= 0; j--)
            {
                if(g_positionInfo.SelectByIndex(j) && g_positionInfo.Magic() == MagicNumber)
                {
                    string openSymbol = g_positionInfo.Symbol();
                    double correlation = GetSymbolCorrelation(symbol, openSymbol);
                    
                    if(MathAbs(correlation) > MaxCorrelation)
                    {
                        highCorrelation = true;
                        break;
                    }
                }
            }
            
            if(highCorrelation)
            {
                Print(symbol, " - High correlation with existing position, skipping");
                continue;
            }
        }
        
        // Analyze trend for this symbol
        CTrendDetector detector;
        STrendSignal signal = detector.AnalyzeTrend(symbol);
        
        if(signal.valid)
        {
            signalsFound++;
            Print("Signal found: ", signal.symbol, " Direction: ", EnumToString(signal.direction),
                  " Quality: ", signal.quality, "/10");
            
            // Calculate lot size
            double lotSize = g_riskManager.CalculateLotSize(signal.symbol, signal.entryPrice, signal.stopLoss);
            
            if(lotSize > 0)
            {
                // Place order
                if(g_orderManager.PlaceOrder(signal, lotSize))
                {
                    // Add risk
                    double riskAmount = g_account.Balance() * RiskPerTrade / 100.0;
                    g_riskManager.AddRisk(riskAmount);
                    
                    // Log signal
                    LogSignal(signal);
                    
                    // Update position count
                    totalPositions++;
                    
                    // Check if we've reached max total trades
                    if(totalPositions >= MaxTotalTrades)
                    {
                        Print("Maximum total positions reached after placing order");
                        break;
                    }
                }
            }
        }
    }
    
    Print("Scan completed. Signals found: ", signalsFound, " Total positions: ", totalPositions);
}

//+------------------------------------------------------------------+
//| Trade transaction function                                        |
//+------------------------------------------------------------------+
void OnTrade()
{
    // Update performance metrics when trades are executed
    // This can be expanded to track more detailed statistics
}

//+------------------------------------------------------------------+
