//+------------------------------------------------------------------+
//|                                             PORTFOLIO_MANAGER.mq5 |
//|                                    Copyright 2024, Trading Portfolio |
//|                      EA 4: Portfolio Controller & Risk Manager     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trading Portfolio"
#property link      "https://github.com/lucciola85"
#property version   "1.00"
#property description "PORTFOLIO_MANAGER - Master Portfolio Controller"
#property description "Manages portfolio-level risk, correlation, and capital allocation"
#property description "Works with TREND_TURTLE, RANGE_PANTHER, MOMENTUM_SCALPER"
#property strict

//--- Include standard library files
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Constants - Magic Numbers for Portfolio EAs                       |
//+------------------------------------------------------------------+
#define MAGIC_TREND_TURTLE    111001
#define MAGIC_RANGE_PANTHER   111002
#define MAGIC_MOMENTUM_SCALPER 111003

//+------------------------------------------------------------------+
//| Enumerations                                                      |
//+------------------------------------------------------------------+
enum ENUM_CIRCUIT_BREAKER_STATUS
{
    CB_NORMAL = 0,           // Trading Normal
    CB_WARNING = 1,          // Warning - Approaching Limits
    CB_TRIGGERED = 2         // Circuit Breaker Active - Trading Halted
};

enum ENUM_REBALANCE_MODE
{
    REBALANCE_NONE = 0,      // No Rebalancing
    REBALANCE_MONTHLY = 1,   // Monthly Rebalancing
    REBALANCE_WEEKLY = 2,    // Weekly Rebalancing
    REBALANCE_ON_DRIFT = 3   // Rebalance on Target Drift
};

//+------------------------------------------------------------------+
//| Input Parameters - General Settings                               |
//+------------------------------------------------------------------+
input group "═══════════ GENERAL SETTINGS ═══════════"
input string            InpEAName           = "PORTFOLIO_MANAGER";  // EA Name
input int               InpMagicNumber      = 111000;               // Magic Number (Manager)
input bool              InpEnableManager    = true;                 // Enable Portfolio Manager

//+------------------------------------------------------------------+
//| Input Parameters - Capital Allocation                             |
//+------------------------------------------------------------------+
input group "═══════════ CAPITAL ALLOCATION ═══════════"
input double            InpTotalCapital     = 100000.0;             // Total Portfolio Capital
input double            InpAllocTrendTurtle = 40.0;                 // Allocation TREND_TURTLE (%)
input double            InpAllocRangePanther = 30.0;                // Allocation RANGE_PANTHER (%)
input double            InpAllocMomentumScalper = 30.0;             // Allocation MOMENTUM_SCALPER (%)

//+------------------------------------------------------------------+
//| Input Parameters - Portfolio Symbols                              |
//+------------------------------------------------------------------+
input group "═══════════ PORTFOLIO SYMBOLS ═══════════"
input string            InpSymbolTrend      = "US30";               // TREND_TURTLE Symbol (US30)
input string            InpSymbolRange      = "EURGBP";             // RANGE_PANTHER Symbol (EURGBP)
input string            InpSymbolMomentum   = "XAUUSD";             // MOMENTUM_SCALPER Symbol (XAUUSD)

//+------------------------------------------------------------------+
//| Input Parameters - Portfolio Risk Management                      |
//+------------------------------------------------------------------+
input group "═══════════ PORTFOLIO RISK ═══════════"
input double            InpMaxPortfolioDD   = 12.0;                 // Max Portfolio Drawdown (%)
input double            InpWarningDD        = 8.0;                  // Warning Drawdown Level (%)
input double            InpMaxDailyLoss     = 3.0;                  // Max Daily Loss (%)
input int               InpMaxTotalPositions = 5;                   // Max Total Positions

//+------------------------------------------------------------------+
//| Input Parameters - Circuit Breaker                                |
//+------------------------------------------------------------------+
input group "═══════════ CIRCUIT BREAKER ═══════════"
input bool              InpEnableCircuitBreaker = true;             // Enable Circuit Breaker
input double            InpCBTriggerDD      = 12.0;                 // Circuit Breaker Trigger DD (%)
input int               InpCBPauseDays      = 1;                    // Pause Trading Days After Trigger
input bool              InpCBCloseAll       = true;                 // Close All Positions on Trigger

//+------------------------------------------------------------------+
//| Input Parameters - Correlation Management                         |
//+------------------------------------------------------------------+
input group "═══════════ CORRELATION MANAGEMENT ═══════════"
input bool              InpMonitorCorrelation = true;               // Monitor Correlation
input double            InpCorrelationThreshold = 0.7;              // Correlation Alert Threshold
input int               InpCorrelationPeriod = 20;                  // Correlation Lookback Period
input bool              InpBlockCorrelatedTrades = false;           // Block Highly Correlated Trades

//+------------------------------------------------------------------+
//| Input Parameters - Rebalancing                                    |
//+------------------------------------------------------------------+
input group "═══════════ REBALANCING ═══════════"
input ENUM_REBALANCE_MODE InpRebalanceMode  = REBALANCE_MONTHLY;    // Rebalancing Mode
input double            InpRebalanceDrift   = 10.0;                 // Max Allocation Drift (%)
input int               InpRebalanceDay     = 1;                    // Day of Month for Rebalance

//+------------------------------------------------------------------+
//| Input Parameters - Dashboard                                      |
//+------------------------------------------------------------------+
input group "═══════════ DASHBOARD ═══════════"
input bool              InpShowDashboard    = true;                 // Show Dashboard Panel
input color             InpDashboardColor   = clrDarkSlateGray;     // Dashboard Background
input color             InpTextColor        = clrWhite;             // Text Color
input color             InpProfitColor      = clrLime;              // Profit Color
input color             InpLossColor        = clrRed;               // Loss Color
input color             InpWarningColor     = clrOrange;            // Warning Color

//+------------------------------------------------------------------+
//| Input Parameters - Logging & Alerts                               |
//+------------------------------------------------------------------+
input group "═══════════ LOGGING & ALERTS ═══════════"
input bool              InpEnableLogging    = true;                 // Enable CSV Logging
input bool              InpEnableAlerts     = true;                 // Enable Alerts
input bool              InpEmailAlerts      = false;                // Send Email Alerts

//+------------------------------------------------------------------+
//| Structure for EA Performance Tracking                             |
//+------------------------------------------------------------------+
struct EAPerformance
{
    string name;
    int magicNumber;
    string symbol;
    double allocatedCapital;
    double currentCapital;
    double targetAllocation;
    double currentAllocation;
    double pnl;
    double drawdown;
    int openPositions;
    double exposure;
};

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
CTrade          g_trade;
CAccountInfo    g_accountInfo;

// Portfolio state
EAPerformance g_eaPerf[3];
double g_portfolioCapital;
double g_portfolioEquity;
double g_portfolioHighWater;
double g_portfolioDrawdown;
double g_dailyStartEquity;
double g_dailyPnL;
ENUM_CIRCUIT_BREAKER_STATUS g_cbStatus;
datetime g_cbTriggerTime;
datetime g_lastRebalanceTime;
datetime g_lastBarTime;
int g_fileHandle;

// Correlation matrix
double g_correlationMatrix[3][3];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if(!InpEnableManager)
    {
        Print("Portfolio Manager is disabled");
        return(INIT_SUCCEEDED);
    }
    
    //--- Initialize EA performance tracking
    InitializeEATracking();
    
    //--- Set up trade object
    g_trade.SetExpertMagicNumber(InpMagicNumber);
    g_trade.SetDeviationInPoints(50);
    g_trade.SetAsyncMode(false);
    
    //--- Initialize state
    g_portfolioCapital = InpTotalCapital;
    g_portfolioEquity = g_accountInfo.Equity();
    g_portfolioHighWater = g_portfolioEquity;
    g_portfolioDrawdown = 0;
    g_dailyStartEquity = g_portfolioEquity;
    g_dailyPnL = 0;
    g_cbStatus = CB_NORMAL;
    g_cbTriggerTime = 0;
    g_lastRebalanceTime = 0;
    g_lastBarTime = 0;
    
    //--- Initialize correlation matrix
    for(int i = 0; i < 3; i++)
    {
        for(int j = 0; j < 3; j++)
        {
            g_correlationMatrix[i][j] = (i == j) ? 1.0 : 0.0;
        }
    }
    
    //--- Open log file
    if(InpEnableLogging)
    {
        string filename = InpEAName + "_Portfolio_Log.csv";
        g_fileHandle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_COMMON, ',');
        if(g_fileHandle != INVALID_HANDLE)
        {
            FileWrite(g_fileHandle, "Timestamp", "Event", "EA", "Symbol", "Details", "PortfolioEquity", "PortfolioDD");
        }
    }
    
    //--- Create dashboard
    if(InpShowDashboard)
        CreateDashboard();
    
    Print("═══════════════════════════════════════════════════");
    Print("  ", InpEAName, " initialized successfully");
    Print("  Total Portfolio Capital: ", InpTotalCapital);
    Print("  TREND_TURTLE (", InpSymbolTrend, "): ", InpAllocTrendTurtle, "%");
    Print("  RANGE_PANTHER (", InpSymbolRange, "): ", InpAllocRangePanther, "%");
    Print("  MOMENTUM_SCALPER (", InpSymbolMomentum, "): ", InpAllocMomentumScalper, "%");
    Print("  Max Portfolio DD: ", InpMaxPortfolioDD, "%");
    Print("═══════════════════════════════════════════════════");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- Delete dashboard objects
    ObjectsDeleteAll(0, "PM_");
    
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
    if(!InpEnableManager)
        return;
    
    //--- Check for new day
    CheckNewDay();
    
    //--- Update portfolio metrics every tick
    UpdatePortfolioMetrics();
    
    //--- Update dashboard
    if(InpShowDashboard)
        UpdateDashboard();
    
    //--- Check for new bar (hourly checks)
    datetime currentBarTime = iTime(_Symbol, PERIOD_H1, 0);
    if(currentBarTime == g_lastBarTime)
        return;
    g_lastBarTime = currentBarTime;
    
    //--- Circuit breaker check
    if(InpEnableCircuitBreaker)
        CheckCircuitBreaker();
    
    //--- If circuit breaker is triggered, don't allow new trades
    if(g_cbStatus == CB_TRIGGERED)
    {
        if(InpCBCloseAll)
            CloseAllPortfolioPositions("Circuit Breaker Triggered");
        return;
    }
    
    //--- Update correlation matrix
    if(InpMonitorCorrelation)
        UpdateCorrelationMatrix();
    
    //--- Check rebalancing
    if(InpRebalanceMode != REBALANCE_NONE)
        CheckRebalancing();
    
    //--- Check exposure limits
    CheckExposureLimits();
}

//+------------------------------------------------------------------+
//| Initialize EA performance tracking                                |
//+------------------------------------------------------------------+
void InitializeEATracking()
{
    //--- TREND_TURTLE
    g_eaPerf[0].name = "TREND_TURTLE";
    g_eaPerf[0].magicNumber = MAGIC_TREND_TURTLE;
    g_eaPerf[0].symbol = InpSymbolTrend;
    g_eaPerf[0].targetAllocation = InpAllocTrendTurtle / 100.0;
    g_eaPerf[0].allocatedCapital = InpTotalCapital * g_eaPerf[0].targetAllocation;
    g_eaPerf[0].currentCapital = g_eaPerf[0].allocatedCapital;
    g_eaPerf[0].currentAllocation = g_eaPerf[0].targetAllocation;
    g_eaPerf[0].pnl = 0;
    g_eaPerf[0].drawdown = 0;
    g_eaPerf[0].openPositions = 0;
    g_eaPerf[0].exposure = 0;
    
    //--- RANGE_PANTHER
    g_eaPerf[1].name = "RANGE_PANTHER";
    g_eaPerf[1].magicNumber = MAGIC_RANGE_PANTHER;
    g_eaPerf[1].symbol = InpSymbolRange;
    g_eaPerf[1].targetAllocation = InpAllocRangePanther / 100.0;
    g_eaPerf[1].allocatedCapital = InpTotalCapital * g_eaPerf[1].targetAllocation;
    g_eaPerf[1].currentCapital = g_eaPerf[1].allocatedCapital;
    g_eaPerf[1].currentAllocation = g_eaPerf[1].targetAllocation;
    g_eaPerf[1].pnl = 0;
    g_eaPerf[1].drawdown = 0;
    g_eaPerf[1].openPositions = 0;
    g_eaPerf[1].exposure = 0;
    
    //--- MOMENTUM_SCALPER
    g_eaPerf[2].name = "MOMENTUM_SCALPER";
    g_eaPerf[2].magicNumber = MAGIC_MOMENTUM_SCALPER;
    g_eaPerf[2].symbol = InpSymbolMomentum;
    g_eaPerf[2].targetAllocation = InpAllocMomentumScalper / 100.0;
    g_eaPerf[2].allocatedCapital = InpTotalCapital * g_eaPerf[2].targetAllocation;
    g_eaPerf[2].currentCapital = g_eaPerf[2].allocatedCapital;
    g_eaPerf[2].currentAllocation = g_eaPerf[2].targetAllocation;
    g_eaPerf[2].pnl = 0;
    g_eaPerf[2].drawdown = 0;
    g_eaPerf[2].openPositions = 0;
    g_eaPerf[2].exposure = 0;
}

//+------------------------------------------------------------------+
//| Update portfolio metrics                                          |
//+------------------------------------------------------------------+
void UpdatePortfolioMetrics()
{
    //--- Update portfolio equity
    g_portfolioEquity = g_accountInfo.Equity();
    
    //--- Update high water mark
    if(g_portfolioEquity > g_portfolioHighWater)
        g_portfolioHighWater = g_portfolioEquity;
    
    //--- Calculate drawdown
    if(g_portfolioHighWater > 0)
        g_portfolioDrawdown = ((g_portfolioHighWater - g_portfolioEquity) / g_portfolioHighWater) * 100;
    
    //--- Update daily PnL
    g_dailyPnL = g_portfolioEquity - g_dailyStartEquity;
    
    //--- Update individual EA metrics
    for(int ea = 0; ea < 3; ea++)
    {
        g_eaPerf[ea].openPositions = 0;
        g_eaPerf[ea].exposure = 0;
        g_eaPerf[ea].pnl = 0;
        
        //--- Scan positions
        int total = PositionsTotal();
        for(int i = 0; i < total; i++)
        {
            ulong ticket = PositionGetTicket(i);
            if(ticket <= 0) continue;
            
            if(PositionGetInteger(POSITION_MAGIC) == g_eaPerf[ea].magicNumber)
            {
                g_eaPerf[ea].openPositions++;
                g_eaPerf[ea].pnl += PositionGetDouble(POSITION_PROFIT);
                g_eaPerf[ea].exposure += PositionGetDouble(POSITION_VOLUME);
            }
        }
        
        //--- Update current capital estimate
        g_eaPerf[ea].currentCapital = g_eaPerf[ea].allocatedCapital + g_eaPerf[ea].pnl;
        
        //--- Update current allocation
        if(g_portfolioEquity > 0)
            g_eaPerf[ea].currentAllocation = g_eaPerf[ea].currentCapital / g_portfolioEquity;
    }
}

//+------------------------------------------------------------------+
//| Check circuit breaker conditions                                  |
//+------------------------------------------------------------------+
void CheckCircuitBreaker()
{
    //--- Check if still in cooldown period
    if(g_cbStatus == CB_TRIGGERED)
    {
        int daysPassed = (int)((TimeCurrent() - g_cbTriggerTime) / 86400);
        if(daysPassed >= InpCBPauseDays)
        {
            g_cbStatus = CB_NORMAL;
            LogEvent("CIRCUIT_BREAKER", "ALL", "ALL", "Circuit breaker reset after cooldown");
            
            if(InpEnableAlerts)
                Alert(InpEAName, ": Circuit breaker reset. Trading resumed.");
        }
        return;
    }
    
    //--- Check portfolio drawdown
    if(g_portfolioDrawdown >= InpCBTriggerDD)
    {
        g_cbStatus = CB_TRIGGERED;
        g_cbTriggerTime = TimeCurrent();
        
        LogEvent("CIRCUIT_BREAKER", "ALL", "ALL", 
                 "TRIGGERED! Drawdown: " + DoubleToString(g_portfolioDrawdown, 2) + "%");
        
        if(InpEnableAlerts)
        {
            Alert(InpEAName, ": CIRCUIT BREAKER TRIGGERED! DD: ", g_portfolioDrawdown, "%");
            
            if(InpEmailAlerts)
                SendMail(InpEAName + " - Circuit Breaker", 
                        "Circuit breaker triggered due to portfolio drawdown of " + 
                        DoubleToString(g_portfolioDrawdown, 2) + "%");
        }
        return;
    }
    
    //--- Check daily loss
    double dailyLossPercent = 0;
    if(g_dailyStartEquity > 0)
        dailyLossPercent = ((g_dailyStartEquity - g_portfolioEquity) / g_dailyStartEquity) * 100;
    
    if(dailyLossPercent >= InpMaxDailyLoss)
    {
        g_cbStatus = CB_TRIGGERED;
        g_cbTriggerTime = TimeCurrent();
        
        LogEvent("CIRCUIT_BREAKER", "ALL", "ALL", 
                 "TRIGGERED! Daily loss: " + DoubleToString(dailyLossPercent, 2) + "%");
        
        if(InpEnableAlerts)
            Alert(InpEAName, ": CIRCUIT BREAKER - Daily loss limit reached: ", dailyLossPercent, "%");
        
        return;
    }
    
    //--- Warning level
    if(g_portfolioDrawdown >= InpWarningDD && g_cbStatus == CB_NORMAL)
    {
        g_cbStatus = CB_WARNING;
        LogEvent("WARNING", "ALL", "ALL", 
                 "Warning level reached. Drawdown: " + DoubleToString(g_portfolioDrawdown, 2) + "%");
    }
    else if(g_portfolioDrawdown < InpWarningDD && g_cbStatus == CB_WARNING)
    {
        g_cbStatus = CB_NORMAL;
    }
}

//+------------------------------------------------------------------+
//| Update correlation matrix                                         |
//+------------------------------------------------------------------+
void UpdateCorrelationMatrix()
{
    double returns[3][];
    
    //--- Get returns for each symbol
    for(int ea = 0; ea < 3; ea++)
    {
        ArrayResize(returns[ea], InpCorrelationPeriod);
        
        for(int i = 0; i < InpCorrelationPeriod; i++)
        {
            double close0 = iClose(g_eaPerf[ea].symbol, PERIOD_D1, i);
            double close1 = iClose(g_eaPerf[ea].symbol, PERIOD_D1, i + 1);
            
            if(close1 > 0)
                returns[ea][i] = (close0 - close1) / close1;
            else
                returns[ea][i] = 0;
        }
    }
    
    //--- Calculate correlation matrix
    for(int i = 0; i < 3; i++)
    {
        for(int j = i; j < 3; j++)
        {
            if(i == j)
            {
                g_correlationMatrix[i][j] = 1.0;
            }
            else
            {
                double corr = CalculateCorrelation(returns[i], returns[j], InpCorrelationPeriod);
                g_correlationMatrix[i][j] = corr;
                g_correlationMatrix[j][i] = corr;
            }
        }
    }
    
    //--- Check for high correlations
    for(int i = 0; i < 3; i++)
    {
        for(int j = i + 1; j < 3; j++)
        {
            if(MathAbs(g_correlationMatrix[i][j]) >= InpCorrelationThreshold)
            {
                string msg = g_eaPerf[i].name + " & " + g_eaPerf[j].name + 
                            " correlation: " + DoubleToString(g_correlationMatrix[i][j], 2);
                LogEvent("CORRELATION_WARNING", g_eaPerf[i].name, g_eaPerf[i].symbol, msg);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate correlation between two arrays                          |
//+------------------------------------------------------------------+
double CalculateCorrelation(double &arr1[], double &arr2[], int size)
{
    if(size <= 1) return 0;
    
    double mean1 = 0, mean2 = 0;
    for(int i = 0; i < size; i++)
    {
        mean1 += arr1[i];
        mean2 += arr2[i];
    }
    mean1 /= size;
    mean2 /= size;
    
    double cov = 0, std1 = 0, std2 = 0;
    for(int i = 0; i < size; i++)
    {
        double d1 = arr1[i] - mean1;
        double d2 = arr2[i] - mean2;
        cov += d1 * d2;
        std1 += d1 * d1;
        std2 += d2 * d2;
    }
    
    double denominator = MathSqrt(std1 * std2);
    if(denominator == 0) return 0;
    
    return cov / denominator;
}

//+------------------------------------------------------------------+
//| Check and execute rebalancing                                     |
//+------------------------------------------------------------------+
void CheckRebalancing()
{
    bool shouldRebalance = false;
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    switch(InpRebalanceMode)
    {
        case REBALANCE_MONTHLY:
            if(dt.day == InpRebalanceDay)
            {
                //--- Check if already rebalanced this month
                MqlDateTime lastRebal;
                TimeToStruct(g_lastRebalanceTime, lastRebal);
                if(lastRebal.mon != dt.mon || lastRebal.year != dt.year)
                    shouldRebalance = true;
            }
            break;
            
        case REBALANCE_WEEKLY:
            if(dt.day_of_week == 1) // Monday
            {
                datetime weekStart = TimeCurrent() - (TimeCurrent() % 604800);
                if(g_lastRebalanceTime < weekStart)
                    shouldRebalance = true;
            }
            break;
            
        case REBALANCE_ON_DRIFT:
            //--- Check allocation drift
            for(int ea = 0; ea < 3; ea++)
            {
                double drift = MathAbs(g_eaPerf[ea].currentAllocation - g_eaPerf[ea].targetAllocation);
                if(drift * 100 >= InpRebalanceDrift)
                {
                    shouldRebalance = true;
                    break;
                }
            }
            break;
    }
    
    if(shouldRebalance)
    {
        ExecuteRebalancing();
        g_lastRebalanceTime = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| Execute portfolio rebalancing                                     |
//+------------------------------------------------------------------+
void ExecuteRebalancing()
{
    LogEvent("REBALANCING", "ALL", "ALL", "Starting portfolio rebalancing");
    
    //--- Calculate new allocations based on current portfolio equity
    for(int ea = 0; ea < 3; ea++)
    {
        double targetCapital = g_portfolioEquity * g_eaPerf[ea].targetAllocation;
        double currentCapital = g_eaPerf[ea].currentCapital;
        double difference = targetCapital - currentCapital;
        
        //--- Update allocated capital (virtual rebalancing)
        g_eaPerf[ea].allocatedCapital = targetCapital;
        
        string msg = "Rebalanced: Old=" + DoubleToString(currentCapital, 2) + 
                    " New=" + DoubleToString(targetCapital, 2) +
                    " Diff=" + DoubleToString(difference, 2);
        
        LogEvent("REBALANCING", g_eaPerf[ea].name, g_eaPerf[ea].symbol, msg);
    }
    
    if(InpEnableAlerts)
        Alert(InpEAName, ": Portfolio rebalancing completed");
}

//+------------------------------------------------------------------+
//| Check exposure limits                                             |
//+------------------------------------------------------------------+
void CheckExposureLimits()
{
    //--- Count total positions
    int totalPositions = 0;
    for(int ea = 0; ea < 3; ea++)
    {
        totalPositions += g_eaPerf[ea].openPositions;
    }
    
    //--- Check max positions
    if(totalPositions >= InpMaxTotalPositions)
    {
        LogEvent("EXPOSURE_LIMIT", "ALL", "ALL", 
                 "Max positions reached: " + IntegerToString(totalPositions));
    }
}

//+------------------------------------------------------------------+
//| Close all portfolio positions                                     |
//+------------------------------------------------------------------+
void CloseAllPortfolioPositions(string reason)
{
    int total = PositionsTotal();
    
    for(int i = total - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) continue;
        
        long magic = PositionGetInteger(POSITION_MAGIC);
        
        //--- Check if this position belongs to our portfolio
        if(magic == MAGIC_TREND_TURTLE || 
           magic == MAGIC_RANGE_PANTHER || 
           magic == MAGIC_MOMENTUM_SCALPER)
        {
            string symbol = PositionGetString(POSITION_SYMBOL);
            
            g_trade.PositionClose(ticket);
            LogEvent("CLOSE_ALL", "PORTFOLIO", symbol, reason);
        }
    }
    
    if(InpEnableAlerts)
        Alert(InpEAName, ": All portfolio positions closed. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Check for new trading day                                         |
//+------------------------------------------------------------------+
void CheckNewDay()
{
    static datetime lastDay = 0;
    
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    datetime today = StringToTime(IntegerToString(dt.year) + "." + 
                                  IntegerToString(dt.mon) + "." + 
                                  IntegerToString(dt.day));
    
    if(today != lastDay)
    {
        lastDay = today;
        g_dailyStartEquity = g_accountInfo.Equity();
        
        LogEvent("NEW_DAY", "ALL", "ALL", 
                 "New trading day. Starting equity: " + DoubleToString(g_dailyStartEquity, 2));
    }
}

//+------------------------------------------------------------------+
//| Create dashboard                                                  |
//+------------------------------------------------------------------+
void CreateDashboard()
{
    int x = 10, y = 30;
    int width = 400, height = 500;
    
    //--- Background
    ObjectCreate(0, "PM_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "PM_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "PM_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "PM_BG", OBJPROP_XSIZE, width);
    ObjectSetInteger(0, "PM_BG", OBJPROP_YSIZE, height);
    ObjectSetInteger(0, "PM_BG", OBJPROP_BGCOLOR, InpDashboardColor);
    ObjectSetInteger(0, "PM_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, "PM_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    
    //--- Title
    CreateLabel("PM_Title", x + 10, y + 10, "═══ PORTFOLIO MANAGER ═══", clrGold, 11);
    
    //--- Portfolio metrics
    CreateLabel("PM_Equity", x + 10, y + 40, "Portfolio Equity: ---", InpTextColor, 9);
    CreateLabel("PM_DD", x + 10, y + 60, "Drawdown: ---", InpTextColor, 9);
    CreateLabel("PM_DailyPnL", x + 10, y + 80, "Daily P/L: ---", InpTextColor, 9);
    CreateLabel("PM_Status", x + 10, y + 100, "Status: ---", InpTextColor, 9);
    
    //--- Separator
    CreateLabel("PM_Sep1", x + 10, y + 125, "════════════════════════════════", clrGray, 8);
    
    //--- EA 1: TREND_TURTLE
    CreateLabel("PM_EA1_Name", x + 10, y + 145, "TREND_TURTLE (US30 D1)", clrAqua, 9);
    CreateLabel("PM_EA1_Alloc", x + 10, y + 165, "Allocation: ---", InpTextColor, 9);
    CreateLabel("PM_EA1_PnL", x + 10, y + 185, "P/L: ---", InpTextColor, 9);
    CreateLabel("PM_EA1_Pos", x + 10, y + 205, "Positions: ---", InpTextColor, 9);
    
    //--- EA 2: RANGE_PANTHER
    CreateLabel("PM_EA2_Name", x + 10, y + 230, "RANGE_PANTHER (EURGBP H4)", clrYellow, 9);
    CreateLabel("PM_EA2_Alloc", x + 10, y + 250, "Allocation: ---", InpTextColor, 9);
    CreateLabel("PM_EA2_PnL", x + 10, y + 270, "P/L: ---", InpTextColor, 9);
    CreateLabel("PM_EA2_Pos", x + 10, y + 290, "Positions: ---", InpTextColor, 9);
    
    //--- EA 3: MOMENTUM_SCALPER
    CreateLabel("PM_EA3_Name", x + 10, y + 315, "MOMENTUM_SCALPER (XAUUSD H1)", clrOrange, 9);
    CreateLabel("PM_EA3_Alloc", x + 10, y + 335, "Allocation: ---", InpTextColor, 9);
    CreateLabel("PM_EA3_PnL", x + 10, y + 355, "P/L: ---", InpTextColor, 9);
    CreateLabel("PM_EA3_Pos", x + 10, y + 375, "Positions: ---", InpTextColor, 9);
    
    //--- Separator
    CreateLabel("PM_Sep2", x + 10, y + 400, "════════════════════════════════", clrGray, 8);
    
    //--- Correlation
    CreateLabel("PM_Corr_Title", x + 10, y + 420, "Correlation Matrix:", InpTextColor, 9);
    CreateLabel("PM_Corr1", x + 10, y + 440, "TT-RP: ---  TT-MS: ---  RP-MS: ---", InpTextColor, 8);
    
    //--- Last update
    CreateLabel("PM_LastUpdate", x + 10, y + 470, "Last Update: ---", clrGray, 8);
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
    ObjectSetString(0, name, OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
}

//+------------------------------------------------------------------+
//| Update dashboard                                                  |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
    //--- Portfolio metrics
    ObjectSetString(0, "PM_Equity", OBJPROP_TEXT, 
                   StringFormat("Portfolio Equity: %.2f %s", g_portfolioEquity, g_accountInfo.Currency()));
    
    color ddColor = (g_portfolioDrawdown > InpWarningDD) ? InpWarningColor : 
                    (g_portfolioDrawdown > 0) ? InpTextColor : InpProfitColor;
    ObjectSetString(0, "PM_DD", OBJPROP_TEXT, 
                   StringFormat("Drawdown: %.2f%%", g_portfolioDrawdown));
    ObjectSetInteger(0, "PM_DD", OBJPROP_COLOR, ddColor);
    
    color pnlColor = (g_dailyPnL >= 0) ? InpProfitColor : InpLossColor;
    ObjectSetString(0, "PM_DailyPnL", OBJPROP_TEXT, 
                   StringFormat("Daily P/L: %.2f", g_dailyPnL));
    ObjectSetInteger(0, "PM_DailyPnL", OBJPROP_COLOR, pnlColor);
    
    //--- Status
    string status;
    color statusColor;
    switch(g_cbStatus)
    {
        case CB_NORMAL: status = "NORMAL"; statusColor = InpProfitColor; break;
        case CB_WARNING: status = "WARNING"; statusColor = InpWarningColor; break;
        case CB_TRIGGERED: status = "CIRCUIT BREAKER"; statusColor = InpLossColor; break;
    }
    ObjectSetString(0, "PM_Status", OBJPROP_TEXT, "Status: " + status);
    ObjectSetInteger(0, "PM_Status", OBJPROP_COLOR, statusColor);
    
    //--- EA 1: TREND_TURTLE
    ObjectSetString(0, "PM_EA1_Alloc", OBJPROP_TEXT, 
                   StringFormat("Allocation: %.1f%% (Target: %.1f%%)", 
                               g_eaPerf[0].currentAllocation * 100, g_eaPerf[0].targetAllocation * 100));
    color ea1PnLColor = (g_eaPerf[0].pnl >= 0) ? InpProfitColor : InpLossColor;
    ObjectSetString(0, "PM_EA1_PnL", OBJPROP_TEXT, StringFormat("P/L: %.2f", g_eaPerf[0].pnl));
    ObjectSetInteger(0, "PM_EA1_PnL", OBJPROP_COLOR, ea1PnLColor);
    ObjectSetString(0, "PM_EA1_Pos", OBJPROP_TEXT, StringFormat("Positions: %d", g_eaPerf[0].openPositions));
    
    //--- EA 2: RANGE_PANTHER
    ObjectSetString(0, "PM_EA2_Alloc", OBJPROP_TEXT, 
                   StringFormat("Allocation: %.1f%% (Target: %.1f%%)", 
                               g_eaPerf[1].currentAllocation * 100, g_eaPerf[1].targetAllocation * 100));
    color ea2PnLColor = (g_eaPerf[1].pnl >= 0) ? InpProfitColor : InpLossColor;
    ObjectSetString(0, "PM_EA2_PnL", OBJPROP_TEXT, StringFormat("P/L: %.2f", g_eaPerf[1].pnl));
    ObjectSetInteger(0, "PM_EA2_PnL", OBJPROP_COLOR, ea2PnLColor);
    ObjectSetString(0, "PM_EA2_Pos", OBJPROP_TEXT, StringFormat("Positions: %d", g_eaPerf[1].openPositions));
    
    //--- EA 3: MOMENTUM_SCALPER
    ObjectSetString(0, "PM_EA3_Alloc", OBJPROP_TEXT, 
                   StringFormat("Allocation: %.1f%% (Target: %.1f%%)", 
                               g_eaPerf[2].currentAllocation * 100, g_eaPerf[2].targetAllocation * 100));
    color ea3PnLColor = (g_eaPerf[2].pnl >= 0) ? InpProfitColor : InpLossColor;
    ObjectSetString(0, "PM_EA3_PnL", OBJPROP_TEXT, StringFormat("P/L: %.2f", g_eaPerf[2].pnl));
    ObjectSetInteger(0, "PM_EA3_PnL", OBJPROP_COLOR, ea3PnLColor);
    ObjectSetString(0, "PM_EA3_Pos", OBJPROP_TEXT, StringFormat("Positions: %d", g_eaPerf[2].openPositions));
    
    //--- Correlation
    ObjectSetString(0, "PM_Corr1", OBJPROP_TEXT, 
                   StringFormat("TT-RP: %.2f  TT-MS: %.2f  RP-MS: %.2f", 
                               g_correlationMatrix[0][1], g_correlationMatrix[0][2], g_correlationMatrix[1][2]));
    
    //--- Last update
    ObjectSetString(0, "PM_LastUpdate", OBJPROP_TEXT, 
                   "Last Update: " + TimeToString(TimeCurrent(), TIME_MINUTES|TIME_SECONDS));
}

//+------------------------------------------------------------------+
//| Log event to CSV                                                  |
//+------------------------------------------------------------------+
void LogEvent(string eventType, string ea, string symbol, string details)
{
    if(!InpEnableLogging || g_fileHandle == INVALID_HANDLE)
        return;
    
    string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
    FileWrite(g_fileHandle, timestamp, eventType, ea, symbol, details, 
              g_portfolioEquity, g_portfolioDrawdown);
    FileFlush(g_fileHandle);
    
    Print(InpEAName, " | ", eventType, " | ", ea, " | ", symbol, " | ", details);
}

//+------------------------------------------------------------------+
//| OnTrade - Track portfolio trade events                            |
//+------------------------------------------------------------------+
void OnTrade()
{
    //--- Update metrics on every trade event
    UpdatePortfolioMetrics();
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
    double sharpe = TesterStatistics(STAT_SHARPE_RATIO);
    
    // Portfolio optimization: Balance profit, risk, and consistency
    if(drawdown > 0 && trades >= 50 && profitFactor > 1.0)
    {
        double criterion = (profit / drawdown) * profitFactor * MathMax(0.5, sharpe);
        return criterion;
    }
    
    return 0;
}
//+------------------------------------------------------------------+
