//+------------------------------------------------------------------+
//|                                                   TREND_TURTLE.mq5 |
//|                                    Copyright 2024, Trading Portfolio |
//|                      EA 1: Trend-Following Strategy for US30 (D1) |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trading Portfolio"
#property link      "https://github.com/lucciola85"
#property version   "1.00"
#property description "TREND_TURTLE - Trend-Following Expert Advisor"
#property description "Designed for US30 (Dow Jones) on Daily timeframe"
#property description "Uses EMA crossovers with ADX filter and ATR-based stops"
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
input string            InpEAName           = "TREND_TURTLE";      // EA Name
input int               InpMagicNumber      = 111001;              // Magic Number
input string            InpTradeComment     = "TT_D1";             // Trade Comment
input ENUM_TIMEFRAMES   InpTimeframe        = PERIOD_D1;           // Main Timeframe (D1 recommended)

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
//| Input Parameters - Trend Strategy (EMA Crossover)                 |
//+------------------------------------------------------------------+
input group "═══════════ TREND STRATEGY ═══════════"
input int               InpEMAFast          = 50;                  // Fast EMA Period
input int               InpEMASlow          = 200;                 // Slow EMA Period
input int               InpADXPeriod        = 14;                  // ADX Period
input int               InpADXThreshold     = 25;                  // ADX Minimum for Entry

//+------------------------------------------------------------------+
//| Input Parameters - ATR-Based Stop Loss                            |
//+------------------------------------------------------------------+
input group "═══════════ STOP LOSS MANAGEMENT ═══════════"
input int               InpATRPeriod        = 14;                  // ATR Period
input double            InpATRMultiplierSL  = 2.5;                 // ATR Multiplier for Initial SL
input double            InpATRMoveThreshold = 1.0;                 // ATR Movement before Trailing

//+------------------------------------------------------------------+
//| Input Parameters - Volatility Filter                              |
//+------------------------------------------------------------------+
input group "═══════════ VOLATILITY FILTER ═══════════"
input bool              InpUseATRFilter     = true;                // Enable ATR Volatility Filter
input double            InpATRMinPercent    = 0.5;                 // Min ATR as % of Price
input double            InpATRMaxPercent    = 3.0;                 // Max ATR as % of Price

//+------------------------------------------------------------------+
//| Input Parameters - Trading Hours/Session                          |
//+------------------------------------------------------------------+
input group "═══════════ SESSION FILTER ═══════════"
input bool              InpUseSessionFilter = false;               // Enable Session Filter (D1 usually no)
input int               InpSessionStart     = 0;                   // Session Start Hour
input int               InpSessionEnd       = 24;                  // Session End Hour

//+------------------------------------------------------------------+
//| Input Parameters - Pyramiding (Add to Winners)                    |
//+------------------------------------------------------------------+
input group "═══════════ PYRAMIDING ═══════════"
input bool              InpUsePyramiding    = false;               // Enable Pyramiding
input double            InpPyramidThreshold = 2.0;                 // Add when profit > X * Initial Risk
input int               InpMaxPyramidUnits  = 3;                   // Max Pyramid Units

//+------------------------------------------------------------------+
//| Input Parameters - Weekly Filter (Higher TF)                      |
//+------------------------------------------------------------------+
input group "═══════════ WEEKLY TREND FILTER ═══════════"
input bool              InpUseWeeklyFilter  = true;                // Use Weekly Trend Filter
input int               InpWeeklyEMA        = 50;                  // Weekly EMA Period

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
int g_handleEMAFast, g_handleEMASlow;
int g_handleADX, g_handleATR;
int g_handleWeeklyEMA;

// Indicator buffers
double g_bufEMAFast[], g_bufEMASlow[];
double g_bufADX[], g_bufADXPlus[], g_bufADXMinus[];
double g_bufATR[];
double g_bufWeeklyEMA[];

// State variables
double g_initialCapital;
double g_highestEquity;
double g_currentDrawdown;
datetime g_lastBarTime;
double g_entryPrice;
double g_initialSL;
double g_initialRiskPips;
int g_pyramidCount;
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
    g_trade.SetDeviationInPoints(30);
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
    g_entryPrice = 0;
    g_initialSL = 0;
    g_initialRiskPips = 0;
    g_pyramidCount = 0;
    
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
    
    //--- Clean orphan positions
    CleanOrphanPositions();
    
    Print("═══════════════════════════════════════════════════");
    Print("  ", InpEAName, " initialized successfully");
    Print("  Symbol: ", _Symbol);
    Print("  Timeframe: ", EnumToString(InpTimeframe));
    Print("  Allocated Capital: ", InpAllocatedCapital);
    Print("  Risk per Trade: ", InpRiskPercent, "%");
    Print("  EMA Fast: ", InpEMAFast, " | EMA Slow: ", InpEMASlow);
    Print("  ADX Threshold: ", InpADXThreshold);
    Print("═══════════════════════════════════════════════════");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- Release indicator handles
    if(g_handleEMAFast != INVALID_HANDLE) IndicatorRelease(g_handleEMAFast);
    if(g_handleEMASlow != INVALID_HANDLE) IndicatorRelease(g_handleEMASlow);
    if(g_handleADX != INVALID_HANDLE) IndicatorRelease(g_handleADX);
    if(g_handleATR != INVALID_HANDLE) IndicatorRelease(g_handleATR);
    if(g_handleWeeklyEMA != INVALID_HANDLE) IndicatorRelease(g_handleWeeklyEMA);
    
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
    
    //--- Check for new bar (all decisions on new bar only)
    datetime currentBarTime = iTime(_Symbol, InpTimeframe, 0);
    if(currentBarTime == g_lastBarTime)
    {
        //--- Only manage trailing stop on existing bars
        ManageTrailingStop();
        return;
    }
    g_lastBarTime = currentBarTime;
    
    //--- Clean orphan positions at start of new bar
    CleanOrphanPositions();
    
    //--- Update drawdown calculation
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
    
    //--- Manage existing positions (trailing stop update)
    ManageTrailingStop();
    
    //--- Check for pyramiding opportunity
    if(InpUsePyramiding && HasOpenPosition())
    {
        CheckPyramidingOpportunity();
    }
    
    //--- Check for new entry signals
    if(CountPositions() < InpMaxPositions)
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
    //--- Check if symbol is available for trading
    if(!g_symbolInfo.IsSynchronized())
    {
        Print("Error: Symbol not synchronized");
        return false;
    }
    
    //--- Check if algo trading is allowed
    if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
    {
        Print("Error: Algorithmic trading not allowed");
        return false;
    }
    
    //--- Check terminal connection
    if(!TerminalInfoInteger(TERMINAL_CONNECTED))
    {
        Print("Error: Terminal not connected to server");
        return false;
    }
    
    //--- Check sufficient historical data
    int barsAvailable = Bars(_Symbol, InpTimeframe);
    int barsNeeded = MathMax(InpEMASlow, InpATRPeriod) + 50;
    if(barsAvailable < barsNeeded)
    {
        Print("Error: Insufficient historical data. Need ", barsNeeded, " bars, have ", barsAvailable);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Create indicator handles                                         |
//+------------------------------------------------------------------+
bool CreateIndicatorHandles()
{
    //--- Fast EMA
    g_handleEMAFast = iMA(_Symbol, InpTimeframe, InpEMAFast, 0, MODE_EMA, PRICE_CLOSE);
    if(g_handleEMAFast == INVALID_HANDLE)
    {
        Print("Error: Failed to create Fast EMA handle");
        return false;
    }
    
    //--- Slow EMA
    g_handleEMASlow = iMA(_Symbol, InpTimeframe, InpEMASlow, 0, MODE_EMA, PRICE_CLOSE);
    if(g_handleEMASlow == INVALID_HANDLE)
    {
        Print("Error: Failed to create Slow EMA handle");
        return false;
    }
    
    //--- ADX
    g_handleADX = iADX(_Symbol, InpTimeframe, InpADXPeriod);
    if(g_handleADX == INVALID_HANDLE)
    {
        Print("Error: Failed to create ADX handle");
        return false;
    }
    
    //--- ATR
    g_handleATR = iATR(_Symbol, InpTimeframe, InpATRPeriod);
    if(g_handleATR == INVALID_HANDLE)
    {
        Print("Error: Failed to create ATR handle");
        return false;
    }
    
    //--- Weekly EMA (if using filter)
    if(InpUseWeeklyFilter)
    {
        g_handleWeeklyEMA = iMA(_Symbol, PERIOD_W1, InpWeeklyEMA, 0, MODE_EMA, PRICE_CLOSE);
        if(g_handleWeeklyEMA == INVALID_HANDLE)
        {
            Print("Warning: Failed to create Weekly EMA handle. Disabling weekly filter.");
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Initialize buffers                                               |
//+------------------------------------------------------------------+
void InitializeBuffers()
{
    ArraySetAsSeries(g_bufEMAFast, true);
    ArraySetAsSeries(g_bufEMASlow, true);
    ArraySetAsSeries(g_bufADX, true);
    ArraySetAsSeries(g_bufADXPlus, true);
    ArraySetAsSeries(g_bufADXMinus, true);
    ArraySetAsSeries(g_bufATR, true);
    ArraySetAsSeries(g_bufWeeklyEMA, true);
}

//+------------------------------------------------------------------+
//| Copy indicator buffers                                           |
//+------------------------------------------------------------------+
bool CopyIndicatorBuffers()
{
    int bars = 10;
    
    if(CopyBuffer(g_handleEMAFast, 0, 0, bars, g_bufEMAFast) < bars) return false;
    if(CopyBuffer(g_handleEMASlow, 0, 0, bars, g_bufEMASlow) < bars) return false;
    if(CopyBuffer(g_handleADX, 0, 0, bars, g_bufADX) < bars) return false;
    if(CopyBuffer(g_handleADX, 1, 0, bars, g_bufADXPlus) < bars) return false;
    if(CopyBuffer(g_handleADX, 2, 0, bars, g_bufADXMinus) < bars) return false;
    if(CopyBuffer(g_handleATR, 0, 0, bars, g_bufATR) < bars) return false;
    
    if(InpUseWeeklyFilter && g_handleWeeklyEMA != INVALID_HANDLE)
    {
        if(CopyBuffer(g_handleWeeklyEMA, 0, 0, 3, g_bufWeeklyEMA) < 3) return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get trade signal                                                  |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
    //--- Previous bar values (bar index 1 = closed bar)
    double emaFast = g_bufEMAFast[1];
    double emaSlow = g_bufEMASlow[1];
    double emaFastPrev = g_bufEMAFast[2];
    double emaSlowPrev = g_bufEMASlow[2];
    double adx = g_bufADX[1];
    double close = iClose(_Symbol, InpTimeframe, 1);
    
    //--- ADX filter: Only trade when trend is strong enough
    if(adx < InpADXThreshold)
        return 0;
    
    //--- Weekly trend filter
    if(InpUseWeeklyFilter && g_handleWeeklyEMA != INVALID_HANDLE && ArraySize(g_bufWeeklyEMA) >= 1)
    {
        double weeklyEMA = g_bufWeeklyEMA[0];
        double weeklyClose = iClose(_Symbol, PERIOD_W1, 0);
        
        // Don't go long if price below weekly EMA
        if(emaFast > emaSlow && weeklyClose < weeklyEMA)
            return 0;
        // Don't go short if price above weekly EMA
        if(emaFast < emaSlow && weeklyClose > weeklyEMA)
            return 0;
    }
    
    //--- LONG conditions:
    // 1. EMA(50) above EMA(200)
    // 2. Price closed above EMA(50)
    // 3. No existing LONG position
    if(emaFast > emaSlow && close > emaFast)
    {
        if(!HasPositionType(POSITION_TYPE_BUY))
            return 1; // BUY signal
    }
    
    //--- SHORT conditions (inverse):
    // 1. EMA(50) below EMA(200)
    // 2. Price closed below EMA(50)
    // 3. No existing SHORT position
    if(emaFast < emaSlow && close < emaFast)
    {
        if(!HasPositionType(POSITION_TYPE_SELL))
            return -1; // SELL signal
    }
    
    return 0;
}

//+------------------------------------------------------------------+
//| Execute trade                                                     |
//+------------------------------------------------------------------+
void ExecuteTrade(int signal)
{
    double atr = g_bufATR[1];
    double lotSize = CalculateLotSize(atr);
    double ask = g_symbolInfo.Ask();
    double bid = g_symbolInfo.Bid();
    double point = g_symbolInfo.Point();
    int digits = (int)g_symbolInfo.Digits();
    
    //--- Calculate SL based on ATR
    double slDistance = atr * InpATRMultiplierSL;
    double sl, tp;
    
    if(signal > 0) // BUY
    {
        sl = NormalizeDouble(ask - slDistance, digits);
        tp = 0; // No TP - we exit via trailing stop
        
        if(g_trade.Buy(lotSize, _Symbol, ask, sl, tp, InpTradeComment))
        {
            g_entryPrice = ask;
            g_initialSL = sl;
            g_initialRiskPips = slDistance / point;
            g_pyramidCount = 1;
            
            LogTrade("BUY", ask, sl, tp, lotSize, "EMA Crossover LONG");
            
            if(InpEnableAlerts)
                Alert(InpEAName, ": BUY opened on ", _Symbol, " at ", ask);
        }
        else
        {
            Print("Error opening BUY: ", g_trade.ResultRetcode(), " - ", g_trade.ResultRetcodeDescription());
        }
    }
    else if(signal < 0) // SELL
    {
        sl = NormalizeDouble(bid + slDistance, digits);
        tp = 0; // No TP - we exit via trailing stop
        
        if(g_trade.Sell(lotSize, _Symbol, bid, sl, tp, InpTradeComment))
        {
            g_entryPrice = bid;
            g_initialSL = sl;
            g_initialRiskPips = slDistance / point;
            g_pyramidCount = 1;
            
            LogTrade("SELL", bid, sl, tp, lotSize, "EMA Crossover SHORT");
            
            if(InpEnableAlerts)
                Alert(InpEAName, ": SELL opened on ", _Symbol, " at ", bid);
        }
        else
        {
            Print("Error opening SELL: ", g_trade.ResultRetcode(), " - ", g_trade.ResultRetcodeDescription());
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate lot size using position sizing formula                  |
//+------------------------------------------------------------------+
double CalculateLotSize(double atr)
{
    //--- Dynamic risk adjustment based on current drawdown
    double riskPercent = InpRiskBase;
    if(g_currentDrawdown > 0)
    {
        // Reduce risk proportionally to drawdown
        riskPercent = InpRiskBase * (1.0 - (g_currentDrawdown / InpMaxDrawdownPct));
        riskPercent = MathMax(riskPercent, InpRiskBase * 0.25); // Min 25% of base risk
    }
    
    //--- Calculate risk amount
    double riskAmount = InpAllocatedCapital * (riskPercent / 100.0);
    
    //--- Calculate SL distance in price
    double slDistance = atr * InpATRMultiplierSL;
    
    //--- Get value per pip/point
    double tickValue = g_symbolInfo.TickValue();
    double tickSize = g_symbolInfo.TickSize();
    
    if(tickValue <= 0 || tickSize <= 0)
    {
        Print("Error: Invalid tick value or size");
        return InpMinLotSize;
    }
    
    //--- Calculate lot size
    // Formula: Lot = RiskAmount / (SL_Ticks * TickValue)
    double slTicks = slDistance / tickSize;
    double lotSize = riskAmount / (slTicks * tickValue);
    
    //--- Normalize lot size
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
//| Manage trailing stop (on EMA50)                                   |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
    int total = PositionsTotal();
    double point = g_symbolInfo.Point();
    int digits = (int)g_symbolInfo.Digits();
    double atr = g_bufATR[1];
    double emaFast = g_bufEMAFast[1];
    
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
        
        //--- Only start trailing after price moved 1 ATR in our favor
        if(profitDistance < atr * InpATRMoveThreshold)
            continue;
        
        //--- Trail SL to EMA(50)
        double newSL;
        if(posType == POSITION_TYPE_BUY)
        {
            //--- For LONG: SL at EMA50 (below price)
            newSL = NormalizeDouble(emaFast, digits);
            
            //--- Only move SL up, never down
            if(newSL > currentSL)
            {
                if(g_trade.PositionModify(ticket, newSL, currentTP))
                {
                    LogTrade("MODIFY_SL", currentPrice, newSL, currentTP, 0, "Trailing to EMA50");
                }
            }
        }
        else // SELL
        {
            //--- For SHORT: SL at EMA50 (above price)
            newSL = NormalizeDouble(emaFast, digits);
            
            //--- Only move SL down, never up
            if(newSL < currentSL || currentSL == 0)
            {
                if(g_trade.PositionModify(ticket, newSL, currentTP))
                {
                    LogTrade("MODIFY_SL", currentPrice, newSL, currentTP, 0, "Trailing to EMA50");
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check pyramiding opportunity                                      |
//+------------------------------------------------------------------+
void CheckPyramidingOpportunity()
{
    if(g_pyramidCount >= InpMaxPyramidUnits)
        return;
    
    int total = PositionsTotal();
    
    for(int i = 0; i < total; i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) continue;
        
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
        
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        double point = g_symbolInfo.Point();
        
        double currentPrice = (posType == POSITION_TYPE_BUY) ? g_symbolInfo.Bid() : g_symbolInfo.Ask();
        double profitPips = (posType == POSITION_TYPE_BUY) ? 
                           (currentPrice - openPrice) / point :
                           (openPrice - currentPrice) / point;
        
        //--- Check if profit exceeds threshold
        double riskPips = g_initialRiskPips;
        if(profitPips >= riskPips * InpPyramidThreshold)
        {
            //--- Check if ADX is still rising (trend strengthening)
            if(g_bufADX[1] > g_bufADX[2])
            {
                //--- Add to position
                double atr = g_bufATR[1];
                double lotSize = CalculateLotSize(atr) * 0.5; // Half size for pyramiding
                
                if(posType == POSITION_TYPE_BUY)
                {
                    double sl = NormalizeDouble(g_bufEMAFast[1], (int)g_symbolInfo.Digits());
                    if(g_trade.Buy(lotSize, _Symbol, g_symbolInfo.Ask(), sl, 0, InpTradeComment + "_PYR"))
                    {
                        g_pyramidCount++;
                        LogTrade("PYRAMID_BUY", g_symbolInfo.Ask(), sl, 0, lotSize, "Pyramiding unit " + IntegerToString(g_pyramidCount));
                    }
                }
                else
                {
                    double sl = NormalizeDouble(g_bufEMAFast[1], (int)g_symbolInfo.Digits());
                    if(g_trade.Sell(lotSize, _Symbol, g_symbolInfo.Bid(), sl, 0, InpTradeComment + "_PYR"))
                    {
                        g_pyramidCount++;
                        LogTrade("PYRAMID_SELL", g_symbolInfo.Bid(), sl, 0, lotSize, "Pyramiding unit " + IntegerToString(g_pyramidCount));
                    }
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
    //--- Check drawdown limit
    if(g_currentDrawdown >= InpMaxDrawdownPct)
    {
        Print("Trading suspended: Drawdown limit reached (", g_currentDrawdown, "%)");
        return false;
    }
    
    //--- Check margin level
    double marginLevel = g_accountInfo.MarginLevel();
    if(marginLevel > 0 && marginLevel < 200)
    {
        Print("Trading suspended: Low margin level (", marginLevel, "%)");
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
    
    if(atrPercent < InpATRMinPercent)
    {
        Print("Volatility too low: ATR% = ", atrPercent);
        return false;
    }
    
    if(atrPercent > InpATRMaxPercent)
    {
        Print("Volatility too high: ATR% = ", atrPercent);
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
//| Check if has open position                                        |
//+------------------------------------------------------------------+
bool HasOpenPosition()
{
    return CountPositions() > 0;
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
//| Clean orphan positions                                            |
//+------------------------------------------------------------------+
void CleanOrphanPositions()
{
    // This function identifies and closes positions that may have been
    // left open due to connection issues or other errors
    // In this implementation, we only manage positions with our magic number
    // so orphan cleanup is minimal
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
    
    Print(InpEAName, " | ", action, " | Price: ", price, " | SL: ", sl, " | Lots: ", lots, " | ", reason);
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
        
        //--- Reset pyramid count on close
        if(CountPositions() == 0)
            g_pyramidCount = 0;
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
    
    if(drawdown > 0 && trades >= 20)
        return (profit / drawdown) * profitFactor;
    
    return 0;
}
//+------------------------------------------------------------------+
