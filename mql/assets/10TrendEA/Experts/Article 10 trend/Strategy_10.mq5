//+------------------------------------------------------------------+
//|                                                  Strategy_10.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alexander Fedosov"
#property link      "https://www.mql5.com/en/users/alex2356"
#property version   "1.00"

#include "TradeFunctions.mqh" 
#include <SmoothAlgorithms.mqh> 

CTradeBase Trade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Mode          // Type of constant
  {
   Mode_1 = 0,     // Baseline
   Mode_2,         // Upper line
   Mode_3          // Lower line
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPLE_,//Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+------------------------------------------------------------------+
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+
input string               Inp_EaComment="Strategy #10";                 //EA Comment
input double               Inp_Lot=0.01;                                //Lot
input MarginMode           Inp_MMode=LOT;                               //MM
input int                  Inp_MagicNum=1111;                           //Magic number
input int                  Inp_StopLoss=400;                            //Stop Loss(points)
input int                  Inp_TakeProfit=600;                          //Take Profit(points)
input int                  Inp_Deviation = 20;                          //Deviation(points)

//--- Average Change indicator parameters
input Smooth_Method        MA_Method1=MODE_SMMA_;                       //smoothing method of moving average
input int                  Length1=12;                                  //smoothing depth of moving average                    
input int                  Phase1=15;                                   //moving average smoothing parameter
input Applied_price_       IPC1=PRICE_CLOSE_;                           //moving average price constant

input Smooth_Method        MA_Method2=MODE_EMA_;                        //indicator smoothing method
input int                  Length2 = 5;                                 //indicator smoothing depth
input int                  Phase2=100;                                  //indicator smoothing parameter
input Applied_price_       IPC2=PRICE_CLOSE_;                           //price constant for smoothing

input double               Pow=5;                                       //power
input int                  Shift=0;                                     //horizontal shift of the indicator in bars

//--- Indicator parameters
input uint                 StartPeriod=6;                               //initial period
input uint                 Step_=6;                                     //periods calculation step
input uint                 Total=36;                                    //number of Moving Averages
input ENUM_MA_METHOD       MAType=MODE_EMA;                             //Moving Averages smoothing type
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;                         //price timeseries of Moving Averages
input int                  Shift1=0;                                    //Horizontal shift of the indicator in bars  

int InpInd_Handle1,InpInd_Handle2;
double avr_change[],fig_series[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Checking connection to a trade server

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Print(Inp_EaComment,": No Connection!");
      return(INIT_FAILED);
     }
//--- Checking if automated trading is enabled

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Print(Inp_EaComment,": Trade is not allowed!");
      return(INIT_FAILED);
     }
//--- Getting the handle of the Average Change indicator

   InpInd_Handle1=iCustom(Symbol(),PERIOD_H4,"10Trend\\averagechange",
                          MA_Method1,
                          Length1,
                          Phase1,
                          IPC1,

                          MA_Method2,
                          Length2,
                          Phase2,
                          IPC2,

                          Pow,
                          Shift
                          );
   if(InpInd_Handle1==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get Average Change handle");
      Print("Handle = ",InpInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- Getting handle of the FigurelliSeries indicator

   InpInd_Handle2=iCustom(Symbol(),PERIOD_H4,"10Trend\\figurelliseries",
                          StartPeriod,
                          Step_,
                          Total,
                          MAType,
                          MAPrice,
                          Shift1
                          );
   if(InpInd_Handle2==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get FigurelliSeries handle");
      Print("Handle = ",InpInd_Handle2,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//---
   ArrayInitialize(avr_change,0.0);
   ArrayInitialize(fig_series,0.0);

   ArraySetAsSeries(avr_change,true);
   ArraySetAsSeries(fig_series,true);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Checking orders previously opened by the EA
   if(!Trade.IsOpened(Inp_MagicNum))
     {
      //--- Getting data for calculations

      if(!GetIndValue())
         return;
      //--- Opening an order if there is a buy signal

      if(BuySignal())
         Trade.BuyPositionOpen(true,Symbol(),Inp_Lot,Inp_MMode,Inp_Deviation,Inp_StopLoss,Inp_TakeProfit,Inp_MagicNum,Inp_EaComment);
      //--- Opening an order if there is a sell signal

      if(SellSignal())
         Trade.SellPositionOpen(true,Symbol(),Inp_Lot,Inp_MMode,Inp_Deviation,Inp_StopLoss,Inp_TakeProfit,Inp_MagicNum,Inp_EaComment);
     }
  }
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   return(avr_change[1]<1 && avr_change[0]>1 && fig_series[0]>0)?true:false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(avr_change[1]>1 && avr_change[0]<1 && fig_series[0]<0)?true:false;
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(InpInd_Handle1,0,0,2,avr_change)<=0 ||
          CopyBuffer(InpInd_Handle2,0,0,2,fig_series)<=0
          )?false:true;
  }
//+------------------------------------------------------------------+
