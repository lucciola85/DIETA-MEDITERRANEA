//+------------------------------------------------------------------+
//|                                                      GAMORAFX.mq5 |
//|                                    Copyright 2024, GAMORAFX Team |
//|                                             https://gamorafx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, GAMORAFX Team"
#property link      "https://gamorafx.com"
#property version   "1.00"
#property description "GAMORAFX - Professional Forex Expert Advisor"
#property description "Multi-strategy trading system with advanced risk management"
#property strict

//--- Include standard library files
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Input Parameters                                                  |
//+------------------------------------------------------------------+
input group "=== General Settings ==="
input ENUM_TIMEFRAMES   InpTimeframe        = PERIOD_H1;        // Timeframe
input int               InpMagicNumber      = 123456;           // Magic Number
input string            InpTradeComment     = "GAMORAFX";       // Trade Comment

input group "=== Risk Management ==="
input double            InpRiskPercent      = 2.0;              // Risk per Trade (%)
input double            InpMaxDrawdown      = 20.0;             // Max Drawdown (%)
input int               InpMaxPositions     = 3;                // Max Open Positions
input double            InpMinLotSize       = 0.01;             // Minimum Lot Size
input double            InpMaxLotSize       = 10.0;             // Maximum Lot Size

input group "=== Moving Average Strategy ==="
input bool              InpUseMAStrategy    = true;             // Enable MA Strategy
input int               InpFastMAPeriod     = 12;               // Fast MA Period
input int               InpSlowMAPeriod     = 26;               // Slow MA Period
input ENUM_MA_METHOD    InpMAMethod         = MODE_EMA;         // MA Method

input group "=== RSI Strategy ==="
input bool              InpUseRSIStrategy   = true;             // Enable RSI Strategy
input int               InpRSIPeriod        = 14;               // RSI Period
input int               InpRSIOverbought    = 70;               // RSI Overbought Level
input int               InpRSIOversold      = 30;               // RSI Oversold Level

input group "=== MACD Strategy ==="
input bool              InpUseMACDStrategy  = true;             // Enable MACD Strategy
input int               InpMACDFast         = 12;               // MACD Fast EMA
input int               InpMACDSlow         = 26;               // MACD Slow EMA
input int               InpMACDSignal       = 9;                // MACD Signal Period

input group "=== Stop Loss & Take Profit ==="
input int               InpStopLoss         = 50;               // Stop Loss (Points)
input int               InpTakeProfit       = 100;              // Take Profit (Points)
input bool              InpUseTrailingStop  = true;             // Use Trailing Stop
input int               InpTrailingStart    = 30;               // Trailing Start (Points)
input int               InpTrailingStep     = 10;               // Trailing Step (Points)

input group "=== Trading Hours ==="
input bool              InpUseTradingHours  = false;            // Use Trading Hours Filter
input int               InpStartHour        = 8;                // Start Hour (Server Time)
input int               InpEndHour          = 20;               // End Hour (Server Time)

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
CTrade          g_trade;
CSymbolInfo     g_symbolInfo;
CPositionInfo   g_positionInfo;
CAccountInfo    g_accountInfo;

int             g_handleFastMA;
int             g_handleSlowMA;
int             g_handleRSI;
int             g_handleMACD;

double          g_bufferFastMA[];
double          g_bufferSlowMA[];
double          g_bufferRSI[];
double          g_bufferMACDMain[];
double          g_bufferMACDSignal[];

double          g_initialBalance;
datetime        g_lastBarTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- Validate inputs
    if(!ValidateInputs())
        return(INIT_PARAMETERS_INCORRECT);
    
    //--- Initialize symbol info
    if(!g_symbolInfo.Name(_Symbol))
    {
        Print("Error: Failed to initialize symbol info for ", _Symbol);
        return(INIT_FAILED);
    }
    
    //--- Set up trade object
    g_trade.SetExpertMagicNumber(InpMagicNumber);
    g_trade.SetDeviationInPoints(10);
    g_trade.SetAsyncMode(false);
    
    //--- Determine optimal filling type for the symbol
    SetOptimalFillingType();
    
    //--- Create indicator handles
    if(!CreateIndicatorHandles())
        return(INIT_FAILED);
    
    //--- Set up buffers as series
    ArraySetAsSeries(g_bufferFastMA, true);
    ArraySetAsSeries(g_bufferSlowMA, true);
    ArraySetAsSeries(g_bufferRSI, true);
    ArraySetAsSeries(g_bufferMACDMain, true);
    ArraySetAsSeries(g_bufferMACDSignal, true);
    
    //--- Store initial balance
    g_initialBalance = g_accountInfo.Balance();
    g_lastBarTime = 0;
    
    Print("GAMORAFX Expert Advisor initialized successfully");
    Print("Account: ", g_accountInfo.Name());
    Print("Balance: ", g_accountInfo.Balance(), " ", g_accountInfo.Currency());
    Print("Leverage: 1:", g_accountInfo.Leverage());
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- Release indicator handles
    if(g_handleFastMA != INVALID_HANDLE) IndicatorRelease(g_handleFastMA);
    if(g_handleSlowMA != INVALID_HANDLE) IndicatorRelease(g_handleSlowMA);
    if(g_handleRSI != INVALID_HANDLE) IndicatorRelease(g_handleRSI);
    if(g_handleMACD != INVALID_HANDLE) IndicatorRelease(g_handleMACD);
    
    Print("GAMORAFX Expert Advisor deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    //--- Check for new bar
    datetime currentBarTime = iTime(_Symbol, InpTimeframe, 0);
    if(currentBarTime == g_lastBarTime)
        return;
    g_lastBarTime = currentBarTime;
    
    //--- Update symbol info
    if(!g_symbolInfo.RefreshRates())
        return;
    
    //--- Check drawdown limit
    if(CheckDrawdownLimit())
    {
        Print("Warning: Maximum drawdown reached. Trading suspended.");
        return;
    }
    
    //--- Check trading hours
    if(InpUseTradingHours && !IsTradingTime())
        return;
    
    //--- Copy indicator buffers
    if(!CopyIndicatorBuffers())
        return;
    
    //--- Manage trailing stop
    if(InpUseTrailingStop)
        ManageTrailingStop();
    
    //--- Check for trade signals
    int signal = GetTradeSignal();
    
    //--- Execute trades based on signal
    if(signal != 0 && CountPositions() < InpMaxPositions)
    {
        ExecuteTrade(signal);
    }
}

//+------------------------------------------------------------------+
//| Validate input parameters                                        |
//+------------------------------------------------------------------+
bool ValidateInputs()
{
    if(InpRiskPercent <= 0 || InpRiskPercent > 10)
    {
        Print("Error: Risk percent must be between 0 and 10");
        return false;
    }
    
    if(InpMaxDrawdown <= 0 || InpMaxDrawdown > 50)
    {
        Print("Error: Max drawdown must be between 0 and 50");
        return false;
    }
    
    if(InpFastMAPeriod >= InpSlowMAPeriod)
    {
        Print("Error: Fast MA period must be less than Slow MA period");
        return false;
    }
    
    if(InpStopLoss <= 0 || InpTakeProfit <= 0)
    {
        Print("Error: Stop Loss and Take Profit must be greater than 0");
        return false;
    }
    
    if(InpStartHour >= InpEndHour)
    {
        Print("Error: Start hour must be less than End hour");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Create indicator handles                                         |
//+------------------------------------------------------------------+
bool CreateIndicatorHandles()
{
    //--- Moving Averages
    if(InpUseMAStrategy)
    {
        g_handleFastMA = iMA(_Symbol, InpTimeframe, InpFastMAPeriod, 0, InpMAMethod, PRICE_CLOSE);
        g_handleSlowMA = iMA(_Symbol, InpTimeframe, InpSlowMAPeriod, 0, InpMAMethod, PRICE_CLOSE);
        
        if(g_handleFastMA == INVALID_HANDLE || g_handleSlowMA == INVALID_HANDLE)
        {
            Print("Error: Failed to create MA indicator handles");
            return false;
        }
    }
    
    //--- RSI
    if(InpUseRSIStrategy)
    {
        g_handleRSI = iRSI(_Symbol, InpTimeframe, InpRSIPeriod, PRICE_CLOSE);
        
        if(g_handleRSI == INVALID_HANDLE)
        {
            Print("Error: Failed to create RSI indicator handle");
            return false;
        }
    }
    
    //--- MACD
    if(InpUseMACDStrategy)
    {
        g_handleMACD = iMACD(_Symbol, InpTimeframe, InpMACDFast, InpMACDSlow, InpMACDSignal, PRICE_CLOSE);
        
        if(g_handleMACD == INVALID_HANDLE)
        {
            Print("Error: Failed to create MACD indicator handle");
            return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Copy indicator buffers                                           |
//+------------------------------------------------------------------+
bool CopyIndicatorBuffers()
{
    int barsNeeded = 3;
    
    if(InpUseMAStrategy)
    {
        if(CopyBuffer(g_handleFastMA, 0, 0, barsNeeded, g_bufferFastMA) != barsNeeded)
            return false;
        if(CopyBuffer(g_handleSlowMA, 0, 0, barsNeeded, g_bufferSlowMA) != barsNeeded)
            return false;
    }
    
    if(InpUseRSIStrategy)
    {
        if(CopyBuffer(g_handleRSI, 0, 0, barsNeeded, g_bufferRSI) != barsNeeded)
            return false;
    }
    
    if(InpUseMACDStrategy)
    {
        if(CopyBuffer(g_handleMACD, 0, 0, barsNeeded, g_bufferMACDMain) != barsNeeded)
            return false;
        if(CopyBuffer(g_handleMACD, 1, 0, barsNeeded, g_bufferMACDSignal) != barsNeeded)
            return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get trade signal based on enabled strategies                     |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
    int buySignals = 0;
    int sellSignals = 0;
    int totalStrategies = 0;
    
    //--- MA Strategy Signal
    if(InpUseMAStrategy)
    {
        totalStrategies++;
        int maSignal = GetMASignal();
        if(maSignal > 0) buySignals++;
        else if(maSignal < 0) sellSignals++;
    }
    
    //--- RSI Strategy Signal
    if(InpUseRSIStrategy)
    {
        totalStrategies++;
        int rsiSignal = GetRSISignal();
        if(rsiSignal > 0) buySignals++;
        else if(rsiSignal < 0) sellSignals++;
    }
    
    //--- MACD Strategy Signal
    if(InpUseMACDStrategy)
    {
        totalStrategies++;
        int macdSignal = GetMACDSignal();
        if(macdSignal > 0) buySignals++;
        else if(macdSignal < 0) sellSignals++;
    }
    
    //--- Require majority of signals to agree (at least 2 out of 3)
    //--- For 1 strategy: need 1, for 2 strategies: need 2, for 3 strategies: need 2
    int requiredSignals = MathMax(1, (totalStrategies + 1) / 2);
    
    if(buySignals >= requiredSignals)
        return 1;   // Buy signal
    if(sellSignals >= requiredSignals)
        return -1;  // Sell signal
    
    return 0;       // No signal
}

//+------------------------------------------------------------------+
//| Get Moving Average crossover signal                              |
//+------------------------------------------------------------------+
int GetMASignal()
{
    //--- Check for bullish crossover
    if(g_bufferFastMA[1] <= g_bufferSlowMA[1] && g_bufferFastMA[0] > g_bufferSlowMA[0])
        return 1;
    
    //--- Check for bearish crossover
    if(g_bufferFastMA[1] >= g_bufferSlowMA[1] && g_bufferFastMA[0] < g_bufferSlowMA[0])
        return -1;
    
    return 0;
}

//+------------------------------------------------------------------+
//| Get RSI signal                                                   |
//+------------------------------------------------------------------+
int GetRSISignal()
{
    //--- Oversold to normal - Buy signal
    if(g_bufferRSI[1] < InpRSIOversold && g_bufferRSI[0] >= InpRSIOversold)
        return 1;
    
    //--- Overbought to normal - Sell signal
    if(g_bufferRSI[1] > InpRSIOverbought && g_bufferRSI[0] <= InpRSIOverbought)
        return -1;
    
    return 0;
}

//+------------------------------------------------------------------+
//| Get MACD signal                                                  |
//+------------------------------------------------------------------+
int GetMACDSignal()
{
    //--- Bullish crossover
    if(g_bufferMACDMain[1] <= g_bufferMACDSignal[1] && g_bufferMACDMain[0] > g_bufferMACDSignal[0])
        return 1;
    
    //--- Bearish crossover
    if(g_bufferMACDMain[1] >= g_bufferMACDSignal[1] && g_bufferMACDMain[0] < g_bufferMACDSignal[0])
        return -1;
    
    return 0;
}

//+------------------------------------------------------------------+
//| Execute trade based on signal                                    |
//+------------------------------------------------------------------+
void ExecuteTrade(int signal)
{
    double lotSize = CalculateLotSize();
    double sl, tp;
    double ask = g_symbolInfo.Ask();
    double bid = g_symbolInfo.Bid();
    double point = g_symbolInfo.Point();
    int digits = (int)g_symbolInfo.Digits();
    
    if(signal > 0)  // Buy
    {
        sl = NormalizeDouble(ask - InpStopLoss * point, digits);
        tp = NormalizeDouble(ask + InpTakeProfit * point, digits);
        
        if(g_trade.Buy(lotSize, _Symbol, ask, sl, tp, InpTradeComment))
        {
            Print("Buy order opened: Lot=", lotSize, " Price=", ask, " SL=", sl, " TP=", tp);
        }
        else
        {
            Print("Error opening Buy order: ", g_trade.ResultRetcode(), " - ", g_trade.ResultRetcodeDescription());
        }
    }
    else if(signal < 0)  // Sell
    {
        sl = NormalizeDouble(bid + InpStopLoss * point, digits);
        tp = NormalizeDouble(bid - InpTakeProfit * point, digits);
        
        if(g_trade.Sell(lotSize, _Symbol, bid, sl, tp, InpTradeComment))
        {
            Print("Sell order opened: Lot=", lotSize, " Price=", bid, " SL=", sl, " TP=", tp);
        }
        else
        {
            Print("Error opening Sell order: ", g_trade.ResultRetcode(), " - ", g_trade.ResultRetcodeDescription());
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk management                      |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
    double balance = g_accountInfo.Balance();
    double tickValue = g_symbolInfo.TickValue();
    double tickSize = g_symbolInfo.TickSize();
    double point = g_symbolInfo.Point();
    
    //--- Calculate risk amount
    double riskAmount = balance * (InpRiskPercent / 100.0);
    
    //--- Calculate lot size based on stop loss
    double slPoints = InpStopLoss * point;
    double slTicks = slPoints / tickSize;
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
//| Count open positions for this EA                                 |
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
//| Check if maximum drawdown has been reached                       |
//+------------------------------------------------------------------+
bool CheckDrawdownLimit()
{
    double currentBalance = g_accountInfo.Balance();
    double drawdown = ((g_initialBalance - currentBalance) / g_initialBalance) * 100;
    
    return (drawdown >= InpMaxDrawdown);
}

//+------------------------------------------------------------------+
//| Check if current time is within trading hours                    |
//+------------------------------------------------------------------+
bool IsTradingTime()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    return (dt.hour >= InpStartHour && dt.hour < InpEndHour);
}

//+------------------------------------------------------------------+
//| Manage trailing stop for open positions                          |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
    int total = PositionsTotal();
    double point = g_symbolInfo.Point();
    int digits = (int)g_symbolInfo.Digits();
    
    for(int i = 0; i < total; i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0)
        {
            if(PositionGetString(POSITION_SYMBOL) != _Symbol ||
               PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
                continue;
            
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double currentSL = PositionGetDouble(POSITION_SL);
            double currentTP = PositionGetDouble(POSITION_TP);
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            
            if(posType == POSITION_TYPE_BUY)
            {
                double bid = g_symbolInfo.Bid();
                double profitPoints = (bid - openPrice) / point;
                
                if(profitPoints >= InpTrailingStart)
                {
                    double newSL = NormalizeDouble(bid - InpTrailingStep * point, digits);
                    if(newSL > currentSL)
                    {
                        g_trade.PositionModify(ticket, newSL, currentTP);
                    }
                }
            }
            else if(posType == POSITION_TYPE_SELL)
            {
                double ask = g_symbolInfo.Ask();
                double profitPoints = (openPrice - ask) / point;
                
                if(profitPoints >= InpTrailingStart)
                {
                    double newSL = NormalizeDouble(ask + InpTrailingStep * point, digits);
                    if(newSL < currentSL || currentSL == 0)
                    {
                        g_trade.PositionModify(ticket, newSL, currentTP);
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Set optimal filling type based on symbol properties              |
//+------------------------------------------------------------------+
void SetOptimalFillingType()
{
    //--- Get symbol filling mode
    uint filling = (uint)g_symbolInfo.TradeFillFlags();
    
    //--- Try to set the most appropriate filling type
    if((filling & SYMBOL_FILLING_FOK) != 0)
        g_trade.SetTypeFilling(ORDER_FILLING_FOK);
    else if((filling & SYMBOL_FILLING_IOC) != 0)
        g_trade.SetTypeFilling(ORDER_FILLING_IOC);
    else
        g_trade.SetTypeFilling(ORDER_FILLING_RETURN);
}

//+------------------------------------------------------------------+
//| OnTrade function - Called on trade events                        |
//+------------------------------------------------------------------+
void OnTrade()
{
    //--- Log trade events
    static int lastDealsCount = 0;
    static datetime lastHistoryTime = 0;
    int currentDeals = HistoryDealsTotal();
    
    if(currentDeals > lastDealsCount)
    {
        //--- New deal detected - select only recent history (last 24 hours) for efficiency
        datetime startTime = (lastHistoryTime > 0) ? lastHistoryTime : TimeCurrent() - 86400;
        if(HistorySelect(startTime, TimeCurrent()))
        {
            int total = HistoryDealsTotal();
            if(total > 0)
            {
                ulong ticket = HistoryDealGetTicket(total - 1);
                if(ticket > 0)
                {
                    if(HistoryDealGetInteger(ticket, DEAL_MAGIC) == InpMagicNumber)
                    {
                        double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                        ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
                        
                        string dealTypeStr = (dealType == DEAL_TYPE_BUY) ? "BUY" : 
                                            (dealType == DEAL_TYPE_SELL) ? "SELL" : "OTHER";
                        
                        Print("Deal closed: Type=", dealTypeStr, " Profit=", profit, " ", g_accountInfo.Currency());
                    }
                }
            }
        }
        lastDealsCount = currentDeals;
        lastHistoryTime = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    //--- Handle chart events if needed
}

//+------------------------------------------------------------------+
//| Tester function - For strategy tester statistics                 |
//+------------------------------------------------------------------+
double OnTester()
{
    //--- Calculate custom optimization criterion
    double profit = TesterStatistics(STAT_PROFIT);
    double drawdown = TesterStatistics(STAT_EQUITY_DD_RELATIVE);
    double trades = TesterStatistics(STAT_TRADES);
    double profitFactor = TesterStatistics(STAT_PROFIT_FACTOR);
    
    //--- Return optimization criterion (higher is better)
    if(drawdown > 0 && trades >= 10)
        return profit / drawdown * profitFactor;
    
    return 0;
}
//+------------------------------------------------------------------+
