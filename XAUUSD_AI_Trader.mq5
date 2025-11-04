//+------------------------------------------------------------------+
//|                                          XAUUSD_AI_Trader.mq5   |
//|                        AI Trading System for XAUUSD (Gold)      |
//|                    Multi-Strategy with Risk Management          |
//+------------------------------------------------------------------+
#property copyright "AI Trader System"
#property link      ""
#property version   "1.00"

#include <Trade\Trade.mqh>

//--- Input Parameters
input group "=== RISK MANAGEMENT ==="
input double   RiskPercent        = 1.5;          // Risk per trade (%)
input double   MaxDailyRisk       = 5.0;          // Maximum daily risk (%)
input double   MaxDrawdown        = 20.0;         // Maximum drawdown (%)
input int      MaxOpenPositions   = 2;            // Maximum open positions
input int      MaxTradesPerDay    = 10;           // Maximum trades per day

input group "=== STRATEGY SELECTION ==="
input bool     EnableStrategy1    = true;         // Multi-Timeframe Momentum
input bool     EnableStrategy2    = true;         // Support/Resistance Breakout
input bool     EnableStrategy3    = true;         // Scalping Strategy

input group "=== INDICATOR PARAMETERS ==="
input int      EMA_Fast           = 9;            // Fast EMA Period
input int      EMA_Medium         = 50;           // Medium EMA Period
input int      EMA_Slow           = 100;          // Slow EMA Period
input int      EMA_Trend          = 200;          // Trend EMA Period
input int      RSI_Period         = 14;           // RSI Period
input int      MACD_Fast          = 12;           // MACD Fast EMA
input int      MACD_Slow          = 26;           // MACD Slow EMA
input int      MACD_Signal        = 9;            // MACD Signal Period
input int      ATR_Period         = 14;           // ATR Period
input int      Stochastic_K       = 14;           // Stochastic %K
input int      Stochastic_D       = 3;            // Stochastic %D
input int      Stochastic_Slow    = 3;            // Stochastic Slowing

input group "=== TRADE MANAGEMENT ==="
input double   RiskRewardRatio    = 2.0;          // Risk:Reward Ratio
input bool     UseTrailingStop    = true;         // Enable Trailing Stop
input double   TrailingStart      = 1.0;          // Trailing Start (RR ratio)
input double   TrailingStep       = 1.0;          // Trailing Step (ATR multiplier)
input bool     UseBreakeven       = true;         // Move to Breakeven
input double   BreakevenTrigger   = 1.0;          // Breakeven Trigger (RR ratio)
input bool     UsePartialClose    = true;         // Enable Partial Close
input double   PartialCloseAt     = 1.5;          // Partial Close at (RR ratio)

input group "=== SESSION FILTER ==="
input bool     UseSessionFilter   = true;         // Enable Session Filter
input int      StartHour          = 8;            // Trading Start Hour (GMT)
input int      EndHour            = 20;           // Trading End Hour (GMT)

input group "=== MONEY MANAGEMENT ==="
input double   InitialBalance     = 100.0;        // Initial Account Balance
input int      MagicNumber        = 123456;       // Magic Number

//--- Global Variables
CTrade trade;
datetime lastBarTime = 0;
int dailyTradeCount = 0;
double dailyProfit = 0;
double dailyLossLimit = 0;
datetime lastTradeTime = 0;
int consecutiveLosses = 0;
double accountStartBalance = 0;
datetime lastResetTime = 0;

//--- Indicator Handles
int emaFast_H1, emaMedium_H1, emaSlow_H1, emaTrend_H1;
int emaFast_M15, emaMedium_M15;
int emaFast_M5, emaMedium_M5;
int rsi_M15, rsi_M5;
int macd_M15, macd_M5;
int atr_M15, atr_M5;
int stoch_M5;
int bb_M15;
int volume_M15, volume_M5;

//--- Arrays for indicator data
double emaFast_H1_Buffer[], emaMedium_H1_Buffer[], emaSlow_H1_Buffer[], emaTrend_H1_Buffer[];
double emaFast_M15_Buffer[], emaMedium_M15_Buffer[];
double emaFast_M5_Buffer[], emaMedium_M5_Buffer[];
double rsi_M15_Buffer[], rsi_M5_Buffer[];
double macd_Main_M15[], macd_Signal_M15[], macd_Main_M5[], macd_Signal_M5[];
double atr_M15_Buffer[], atr_M5_Buffer[];
double stoch_Main_M5[], stoch_Signal_M5[];
double bb_Upper_M15[], bb_Lower_M15[], bb_Middle_M15[];
long volume_M15_Buffer[], volume_M5_Buffer[];

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set trade parameters
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(10);
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   trade.SetAsyncMode(false);
   
   // Initialize indicator handles
   if(!InitializeIndicators())
   {
      Print("Failed to initialize indicators!");
      return INIT_FAILED;
   }
   
   // Initialize tracking variables
   accountStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   lastResetTime = TimeCurrent();
   dailyLossLimit = accountStartBalance * (MaxDailyRisk / 100.0);
   
   Print("=== XAUUSD AI Trader Initialized ===");
   Print("Account Balance: $", accountStartBalance);
   Print("Risk per Trade: ", RiskPercent, "%");
   Print("Daily Loss Limit: $", dailyLossLimit);
   Print("Trading Symbol: ", _Symbol);
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release indicator handles
   IndicatorRelease(emaFast_H1);
   IndicatorRelease(emaMedium_H1);
   IndicatorRelease(emaSlow_H1);
   IndicatorRelease(emaTrend_H1);
   IndicatorRelease(emaFast_M15);
   IndicatorRelease(emaMedium_M15);
   IndicatorRelease(emaFast_M5);
   IndicatorRelease(emaMedium_M5);
   IndicatorRelease(rsi_M15);
   IndicatorRelease(rsi_M5);
   IndicatorRelease(macd_M15);
   IndicatorRelease(macd_M5);
   IndicatorRelease(atr_M15);
   IndicatorRelease(atr_M5);
   IndicatorRelease(stoch_M5);
   IndicatorRelease(bb_M15);
   IndicatorRelease(volume_M15);
   IndicatorRelease(volume_M5);
   
   Print("=== XAUUSD AI Trader Stopped ===");
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
   // Reset daily counters at midnight
   ResetDailyCounters();
   
   // Check if trading is allowed
   if(!IsTradingAllowed())
      return;
   
   // Check for new bar
   datetime currentBarTime = iTime(_Symbol, PERIOD_M15, 0);
   bool isNewBar = (currentBarTime != lastBarTime);
   
   if(isNewBar)
   {
      lastBarTime = currentBarTime;
   }
   
   // Manage existing positions
   ManageOpenPositions();
   
   // Check for new entry signals
   if(isNewBar && CountOpenPositions() < MaxOpenPositions)
   {
      CheckForSignals();
   }
}

//+------------------------------------------------------------------+
//| Initialize all indicators                                          |
//+------------------------------------------------------------------+
bool InitializeIndicators()
{
   // H1 EMAs
   emaFast_H1 = iMA(_Symbol, PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
   emaMedium_H1 = iMA(_Symbol, PERIOD_H1, EMA_Medium, 0, MODE_EMA, PRICE_CLOSE);
   emaSlow_H1 = iMA(_Symbol, PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
   emaTrend_H1 = iMA(_Symbol, PERIOD_H1, EMA_Trend, 0, MODE_EMA, PRICE_CLOSE);
   
   // M15 EMAs
   emaFast_M15 = iMA(_Symbol, PERIOD_M15, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
   emaMedium_M15 = iMA(_Symbol, PERIOD_M15, EMA_Medium, 0, MODE_EMA, PRICE_CLOSE);
   
   // M5 EMAs
   emaFast_M5 = iMA(_Symbol, PERIOD_M5, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
   emaMedium_M5 = iMA(_Symbol, PERIOD_M5, EMA_Medium, 0, MODE_EMA, PRICE_CLOSE);
   
   // RSI
   rsi_M15 = iRSI(_Symbol, PERIOD_M15, RSI_Period, PRICE_CLOSE);
   rsi_M5 = iRSI(_Symbol, PERIOD_M5, RSI_Period, PRICE_CLOSE);
   
   // MACD
   macd_M15 = iMACD(_Symbol, PERIOD_M15, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
   macd_M5 = iMACD(_Symbol, PERIOD_M5, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
   
   // ATR
   atr_M15 = iATR(_Symbol, PERIOD_M15, ATR_Period);
   atr_M5 = iATR(_Symbol, PERIOD_M5, ATR_Period);
   
   // Stochastic
   stoch_M5 = iStochastic(_Symbol, PERIOD_M5, Stochastic_K, Stochastic_D, Stochastic_Slow, MODE_SMA, STO_LOWHIGH);
   
   // Bollinger Bands
   bb_M15 = iBands(_Symbol, PERIOD_M15, 20, 0, 2, PRICE_CLOSE);
   
   // Volume (Tick Volume)
   volume_M15 = iVolumes(_Symbol, PERIOD_M15, VOLUME_TICK);
   volume_M5 = iVolumes(_Symbol, PERIOD_M5, VOLUME_TICK);
   
   // Resize arrays
   ArrayResize(emaFast_H1_Buffer, 3);
   ArrayResize(emaMedium_H1_Buffer, 3);
   ArrayResize(emaSlow_H1_Buffer, 3);
   ArrayResize(emaTrend_H1_Buffer, 3);
   ArrayResize(emaFast_M15_Buffer, 3);
   ArrayResize(emaMedium_M15_Buffer, 3);
   ArrayResize(emaFast_M5_Buffer, 3);
   ArrayResize(emaMedium_M5_Buffer, 3);
   ArrayResize(rsi_M15_Buffer, 3);
   ArrayResize(rsi_M5_Buffer, 3);
   ArrayResize(macd_Main_M15, 3);
   ArrayResize(macd_Signal_M15, 3);
   ArrayResize(macd_Main_M5, 3);
   ArrayResize(macd_Signal_M5, 3);
   ArrayResize(atr_M15_Buffer, 3);
   ArrayResize(atr_M5_Buffer, 3);
   ArrayResize(stoch_Main_M5, 3);
   ArrayResize(stoch_Signal_M5, 3);
   ArrayResize(bb_Upper_M15, 3);
   ArrayResize(bb_Lower_M15, 3);
   ArrayResize(bb_Middle_M15, 3);
   ArrayResize(volume_M15_Buffer, 3);
   ArrayResize(volume_M5_Buffer, 3);
   
   // Check if all handles are valid
   if(emaFast_H1 == INVALID_HANDLE || emaMedium_H1 == INVALID_HANDLE || 
      emaSlow_H1 == INVALID_HANDLE || emaTrend_H1 == INVALID_HANDLE ||
      emaFast_M15 == INVALID_HANDLE || emaMedium_M15 == INVALID_HANDLE ||
      emaFast_M5 == INVALID_HANDLE || emaMedium_M5 == INVALID_HANDLE ||
      rsi_M15 == INVALID_HANDLE || rsi_M5 == INVALID_HANDLE ||
      macd_M15 == INVALID_HANDLE || macd_M5 == INVALID_HANDLE ||
      atr_M15 == INVALID_HANDLE || atr_M5 == INVALID_HANDLE ||
      stoch_M5 == INVALID_HANDLE || bb_M15 == INVALID_HANDLE ||
      volume_M15 == INVALID_HANDLE || volume_M5 == INVALID_HANDLE)
   {
      return false;
   }
   
   // Set array as series
   ArraySetAsSeries(emaFast_H1_Buffer, true);
   ArraySetAsSeries(emaMedium_H1_Buffer, true);
   ArraySetAsSeries(emaSlow_H1_Buffer, true);
   ArraySetAsSeries(emaTrend_H1_Buffer, true);
   ArraySetAsSeries(emaFast_M15_Buffer, true);
   ArraySetAsSeries(emaMedium_M15_Buffer, true);
   ArraySetAsSeries(emaFast_M5_Buffer, true);
   ArraySetAsSeries(emaMedium_M5_Buffer, true);
   ArraySetAsSeries(rsi_M15_Buffer, true);
   ArraySetAsSeries(rsi_M5_Buffer, true);
   ArraySetAsSeries(macd_Main_M15, true);
   ArraySetAsSeries(macd_Signal_M15, true);
   ArraySetAsSeries(macd_Main_M5, true);
   ArraySetAsSeries(macd_Signal_M5, true);
   ArraySetAsSeries(atr_M15_Buffer, true);
   ArraySetAsSeries(atr_M5_Buffer, true);
   ArraySetAsSeries(stoch_Main_M5, true);
   ArraySetAsSeries(stoch_Signal_M5, true);
   ArraySetAsSeries(bb_Upper_M15, true);
   ArraySetAsSeries(bb_Lower_M15, true);
   ArraySetAsSeries(bb_Middle_M15, true);
   ArraySetAsSeries(volume_M15_Buffer, true);
   ArraySetAsSeries(volume_M5_Buffer, true);
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                        |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
{
   // Check if market is open
   if(!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE))
      return false;
   
   // Check session filter
   if(UseSessionFilter)
   {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      if(dt.hour < StartHour || dt.hour >= EndHour)
         return false;
   }
   
   // Check daily trade limit
   if(dailyTradeCount >= MaxTradesPerDay)
      return false;
   
   // Check daily loss limit
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double dailyLoss = accountStartBalance - currentEquity;
   
   if(dailyLoss >= dailyLossLimit)
   {
      Print("Daily loss limit reached: $", dailyLoss);
      return false;
   }
   
   // Check consecutive losses
   if(consecutiveLosses >= 3)
   {
      Print("3 consecutive losses - stopping trading");
      return false;
   }
   
   // Check maximum drawdown
   double drawdownPercent = ((accountStartBalance - currentEquity) / accountStartBalance) * 100.0;
   if(drawdownPercent >= MaxDrawdown)
   {
      Print("Maximum drawdown reached: ", drawdownPercent, "%");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Reset daily counters                                              |
//+------------------------------------------------------------------+
void ResetDailyCounters()
{
   MqlDateTime currentTime, resetTime;
   TimeToStruct(TimeCurrent(), currentTime);
   TimeToStruct(lastResetTime, resetTime);
   
   // Reset at midnight
   if(currentTime.day != resetTime.day)
   {
      dailyTradeCount = 0;
      dailyProfit = 0;
      accountStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      dailyLossLimit = accountStartBalance * (MaxDailyRisk / 100.0);
      lastResetTime = TimeCurrent();
      Print("Daily counters reset. New starting balance: $", accountStartBalance);
   }
}

//+------------------------------------------------------------------+
//| Check for trading signals                                         |
//+------------------------------------------------------------------+
void CheckForSignals()
{
   // Update indicator buffers
   if(!UpdateIndicatorBuffers())
      return;
   
   // Strategy 1: Multi-Timeframe Momentum
   if(EnableStrategy1)
   {
      int signal1 = CheckStrategy1();
      if(signal1 == 1) OpenTrade(ORDER_TYPE_BUY, "Strategy1");
      else if(signal1 == -1) OpenTrade(ORDER_TYPE_SELL, "Strategy1");
   }
   
   // Strategy 2: Support/Resistance Breakout
   if(EnableStrategy2)
   {
      int signal2 = CheckStrategy2();
      if(signal2 == 1) OpenTrade(ORDER_TYPE_BUY, "Strategy2");
      else if(signal2 == -1) OpenTrade(ORDER_TYPE_SELL, "Strategy2");
   }
   
   // Strategy 3: Scalping
   if(EnableStrategy3)
   {
      int signal3 = CheckStrategy3();
      if(signal3 == 1) OpenTrade(ORDER_TYPE_BUY, "Strategy3");
      else if(signal3 == -1) OpenTrade(ORDER_TYPE_SELL, "Strategy3");
   }
}

//+------------------------------------------------------------------+
//| Update all indicator buffers                                      |
//+------------------------------------------------------------------+
bool UpdateIndicatorBuffers()
{
   // Copy indicator data
   if(CopyBuffer(emaFast_H1, 0, 0, 3, emaFast_H1_Buffer) <= 0) return false;
   if(CopyBuffer(emaMedium_H1, 0, 0, 3, emaMedium_H1_Buffer) <= 0) return false;
   if(CopyBuffer(emaSlow_H1, 0, 0, 3, emaSlow_H1_Buffer) <= 0) return false;
   if(CopyBuffer(emaTrend_H1, 0, 0, 3, emaTrend_H1_Buffer) <= 0) return false;
   if(CopyBuffer(emaFast_M15, 0, 0, 3, emaFast_M15_Buffer) <= 0) return false;
   if(CopyBuffer(emaMedium_M15, 0, 0, 3, emaMedium_M15_Buffer) <= 0) return false;
   if(CopyBuffer(emaFast_M5, 0, 0, 3, emaFast_M5_Buffer) <= 0) return false;
   if(CopyBuffer(emaMedium_M5, 0, 0, 3, emaMedium_M5_Buffer) <= 0) return false;
   if(CopyBuffer(rsi_M15, 0, 0, 3, rsi_M15_Buffer) <= 0) return false;
   if(CopyBuffer(rsi_M5, 0, 0, 3, rsi_M5_Buffer) <= 0) return false;
   if(CopyBuffer(macd_M15, 0, 0, 3, macd_Main_M15) <= 0) return false;
   if(CopyBuffer(macd_M15, 1, 0, 3, macd_Signal_M15) <= 0) return false;
   if(CopyBuffer(macd_M5, 0, 0, 3, macd_Main_M5) <= 0) return false;
   if(CopyBuffer(macd_M5, 1, 0, 3, macd_Signal_M5) <= 0) return false;
   if(CopyBuffer(atr_M15, 0, 0, 3, atr_M15_Buffer) <= 0) return false;
   if(CopyBuffer(atr_M5, 0, 0, 3, atr_M5_Buffer) <= 0) return false;
   if(CopyBuffer(stoch_M5, 0, 0, 3, stoch_Main_M5) <= 0) return false;
   if(CopyBuffer(stoch_M5, 1, 0, 3, stoch_Signal_M5) <= 0) return false;
   if(CopyBuffer(bb_M15, 0, 0, 3, bb_Upper_M15) <= 0) return false;
   if(CopyBuffer(bb_M15, 1, 0, 3, bb_Lower_M15) <= 0) return false;
   if(CopyBuffer(bb_M15, 2, 0, 3, bb_Middle_M15) <= 0) return false;
   if(CopyBuffer(volume_M15, 0, 0, 3, volume_M15_Buffer) <= 0) return false;
   if(CopyBuffer(volume_M5, 0, 0, 3, volume_M5_Buffer) <= 0) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Strategy 1: Multi-Timeframe Momentum                             |
//+------------------------------------------------------------------+
int CheckStrategy1()
{
   double currentPrice = iClose(_Symbol, PERIOD_M15, 0);
   
   // Check H1 trend
   bool bullishTrend = (currentPrice > emaFast_H1_Buffer[0] && 
                        emaFast_H1_Buffer[0] > emaMedium_H1_Buffer[0] && 
                        emaMedium_H1_Buffer[0] > emaSlow_H1_Buffer[0]);
   
   bool bearishTrend = (currentPrice < emaFast_H1_Buffer[0] && 
                        emaFast_H1_Buffer[0] < emaMedium_H1_Buffer[0] && 
                        emaMedium_H1_Buffer[0] < emaSlow_H1_Buffer[0]);
   
   // Check M15 signals
   bool macdBullish = (macd_Main_M15[0] > macd_Signal_M15[0] && 
                       macd_Main_M15[1] <= macd_Signal_M15[1]);
   bool macdBearish = (macd_Main_M15[0] < macd_Signal_M15[0] && 
                       macd_Main_M15[1] >= macd_Signal_M15[1]);
   
   // Long signal
   if(bullishTrend && rsi_M15_Buffer[0] > 50 && macdBullish)
   {
      return 1;
   }
   
   // Short signal
   if(bearishTrend && rsi_M15_Buffer[0] < 50 && macdBearish)
   {
      return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Strategy 2: Support/Resistance Breakout                          |
//+------------------------------------------------------------------+
int CheckStrategy2()
{
   // Get previous day high/low
   double prevDayHigh = iHigh(_Symbol, PERIOD_D1, 1);
   double prevDayLow = iLow(_Symbol, PERIOD_D1, 1);
   double currentPrice = iClose(_Symbol, PERIOD_M15, 0);
   double prevPrice = iClose(_Symbol, PERIOD_M15, 1);
   
   // Volume check
   bool highVolume = volume_M15_Buffer[0] > volume_M15_Buffer[1];
   
   // Long breakout
   if(currentPrice > prevDayHigh && prevPrice <= prevDayHigh && 
      rsi_M15_Buffer[0] < 70 && highVolume)
   {
      return 1;
   }
   
   // Short breakdown
   if(currentPrice < prevDayLow && prevPrice >= prevDayLow && 
      rsi_M15_Buffer[0] > 30 && highVolume)
   {
      return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Strategy 3: Scalping Strategy                                    |
//+------------------------------------------------------------------+
int CheckStrategy3()
{
   // Check M5 timeframe
   double currentPrice = iClose(_Symbol, PERIOD_M5, 0);
   bool highVolume = volume_M5_Buffer[0] > volume_M5_Buffer[1];
   
   // Long signal
   if(currentPrice > emaFast_M5_Buffer[0] && 
      stoch_Main_M5[0] > 20 && stoch_Main_M5[1] <= 20 && 
      stoch_Main_M5[0] > stoch_Signal_M5[0] && highVolume)
   {
      return 1;
   }
   
   // Short signal
   if(currentPrice < emaFast_M5_Buffer[0] && 
      stoch_Main_M5[0] < 80 && stoch_Main_M5[1] >= 80 && 
      stoch_Main_M5[0] < stoch_Signal_M5[0] && highVolume)
   {
      return -1;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Open a trade                                                      |
//+------------------------------------------------------------------+
void OpenTrade(ENUM_ORDER_TYPE orderType, string strategy)
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   // Get ATR for stop loss
   double atrValue = atr_M15_Buffer[0];
   double stopLossPips = 2.0 * atrValue / point; // 2x ATR for Strategy 1
   
   // Adjust for scalping (Strategy 3 uses M5 ATR)
   if(strategy == "Strategy3")
   {
      atrValue = atr_M5_Buffer[0];
      stopLossPips = 1.5 * atrValue / point; // 1.5x ATR for scalping
      if(stopLossPips < 10) stopLossPips = 10; // Minimum 10 pips
      if(stopLossPips > 15) stopLossPips = 15; // Maximum 15 pips
   }
   else if(strategy == "Strategy2")
   {
      stopLossPips = 1.5 * atrValue / point; // 1.5x ATR for breakout
   }
   
   // Calculate position size
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = accountBalance * (RiskPercent / 100.0);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double pipValue = (tickValue / tickSize) * point;
   
   double lotSize = riskAmount / (stopLossPips * pipValue);
   
   // Normalize lot size
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   if(lotSize < minLot) lotSize = minLot;
   if(lotSize > maxLot) lotSize = maxLot;
   
   // Calculate stop loss and take profit
   double sl, tp;
   if(orderType == ORDER_TYPE_BUY)
   {
      sl = ask - stopLossPips * point;
      tp = ask + stopLossPips * point * RiskRewardRatio;
   }
   else
   {
      sl = bid + stopLossPips * point;
      tp = bid - stopLossPips * point * RiskRewardRatio;
   }
   
   // Normalize prices
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);
   
   // Open the trade
   string comment = StringFormat("%s_Risk%.1f%%", strategy, RiskPercent);
   if(trade.PositionOpen(_Symbol, orderType, lotSize, 
                         (orderType == ORDER_TYPE_BUY) ? ask : bid, 
                         sl, tp, comment))
   {
      dailyTradeCount++;
      lastTradeTime = TimeCurrent();
      Print("Trade opened: ", strategy, " | Type: ", EnumToString(orderType), 
            " | Lots: ", lotSize, " | SL: ", sl, " | TP: ", tp);
   }
   else
   {
      Print("Failed to open trade: ", trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| Manage open positions                                             |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0) continue;
      
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      
      // Get position details
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      double lots = PositionGetDouble(POSITION_VOLUME);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double currentPrice = (posType == POSITION_TYPE_BUY) ? bid : ask;
      
      // Calculate current profit in pips
      double profitPips = 0;
      double stopLossPips = 0;
      if(posType == POSITION_TYPE_BUY)
      {
         profitPips = (currentPrice - openPrice) / point;
         if(currentSL > 0) stopLossPips = (openPrice - currentSL) / point;
      }
      else
      {
         profitPips = (openPrice - currentPrice) / point;
         if(currentSL > 0) stopLossPips = (currentSL - openPrice) / point;
      }
      
      // Get ATR for calculations
      double atrValue = atr_M15_Buffer[0];
      double atrPips = atrValue / point;
      
      // Breakeven logic
      if(UseBreakeven && stopLossPips > 0)
      {
         double breakevenTriggerPips = stopLossPips * BreakevenTrigger;
         if(profitPips >= breakevenTriggerPips && currentSL != openPrice)
         {
            double newSL = NormalizeDouble(openPrice, digits);
            if(trade.PositionModify(ticket, newSL, currentTP))
            {
               Print("Stop loss moved to breakeven for ticket: ", ticket);
            }
         }
      }
      
      // Partial close logic
      if(UsePartialClose && stopLossPips > 0)
      {
         double partialCloseTriggerPips = stopLossPips * PartialCloseAt;
         if(profitPips >= partialCloseTriggerPips)
         {
            // Check if we haven't already done partial close (by checking if lots are still original)
            // This is a simplified check - in production, you'd track this per position
            double closeLots = NormalizeDouble(lots * 0.5, 2);
            if(closeLots >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
            {
               if(trade.PositionClosePartial(ticket, closeLots))
               {
                  Print("Partial close executed for ticket: ", ticket, " | Closed: ", closeLots, " lots");
               }
            }
         }
      }
      
      // Trailing stop logic
      if(UseTrailingStop && stopLossPips > 0)
      {
         double trailingStartPips = stopLossPips * TrailingStart;
         if(profitPips >= trailingStartPips)
         {
            double trailingStepPips = atrPips * TrailingStep;
            double newSL = 0;
            
            if(posType == POSITION_TYPE_BUY)
            {
               newSL = currentPrice - trailingStepPips * point;
               if(newSL > currentSL && newSL < currentPrice)
               {
                  newSL = NormalizeDouble(newSL, digits);
                  if(trade.PositionModify(ticket, newSL, currentTP))
                  {
                     Print("Trailing stop updated for ticket: ", ticket, " | New SL: ", newSL);
                  }
               }
            }
            else
            {
               newSL = currentPrice + trailingStepPips * point;
               if((currentSL == 0 || newSL < currentSL) && newSL > currentPrice)
               {
                  newSL = NormalizeDouble(newSL, digits);
                  if(trade.PositionModify(ticket, newSL, currentTP))
                  {
                     Print("Trailing stop updated for ticket: ", ticket, " | New SL: ", newSL);
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Count open positions                                              |
//+------------------------------------------------------------------+
int CountOpenPositions()
{
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionGetTicket(i) > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
            PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Trade event handler                                                |
//+------------------------------------------------------------------+
void OnTrade()
{
   // Check for closed positions to update statistics
   HistorySelect(TimeCurrent() - 86400, TimeCurrent());
   
   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket <= 0) continue;
      
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != MagicNumber) continue;
      if(HistoryDealGetInteger(ticket, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
      
      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
      
      if(profit < 0)
      {
         consecutiveLosses++;
         Print("Trade closed with loss. Consecutive losses: ", consecutiveLosses);
      }
      else
      {
         consecutiveLosses = 0;
      }
      
      dailyProfit += profit;
      break; // Only process the most recent closed deal
   }
}

//+------------------------------------------------------------------+
