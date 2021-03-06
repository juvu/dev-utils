//+------------------------------------------------------------------+
//|                                                   Strategy_3.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alexander Fedosov"
#property link      "https://www.mql5.com/en/users/alex2356"
#property version   "1.00"
//--- A library of trade functions

#include "TradeFunctions.mqh" 
#include <SmoothAlgorithms.mqh>

CTradeBase Trade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Applied_price_      //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+------------------------------------------------------------------+
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+
input string               Inp_EaComment="Strategy #2";                 //EA Comment
input double               Inp_Lot=0.01;                                //Lot
input MarginMode           Inp_MMode=LOT;                               //MM
input  int                 Inp_MagicNum=1111;                           //Magic number
input int                  Inp_StopLoss=400;                            //Stop Loss(points)
input int                  Inp_TakeProfit=600;                          //Take Profit(points)
input int                  Inp_Deviation = 20;                          //Deviation(points)
//--- Bears_Bull_power indicator parameters

input Smooth_Method        MA_Method1=MODE_AMA;                         //Averaging method
input uint                 Length1=12;                                  //Averaging depth                  
input int                  Phase1=15;                                   //Averaging parameter
input Smooth_Method        MA_Method2=MODE_ParMA;                       //Smoothing period
input uint                 Length2=5;                                   //Smoothing depth
input int                  Phase2=15;                                   //Smoothing parameter
input Applied_price_       IPC=PRICE_WEIGHTED_;                         //Applied price
input int                  Shift=0;                                     //Shift
//--- CronexAC indicator parameters

input Smooth_Method        XMA_Method=MODE_SMMA_;                       //Smoothing Method
input uint                 FastPeriod=9;                                //Fast smoothing period
input uint                 SlowPeriod=21;                               //Slow smoothing period
input int                  XPhase=15;                                   //Smoothing parameter

int InpInd_Handle1,InpInd_Handle2;
double bb_power[],ac_fast[],ac_slow[];
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
//--- Getting handle of the Bear_Bulls_Power indicator

   InpInd_Handle1=iCustom(Symbol(),PERIOD_H1,"10Trend\\Bear_Bulls_Power",
                          MA_Method1,
                          Length1,
                          Phase1,
                          MA_Method2,
                          Length2,
                          Phase2,
                          IPC,
                          Shift
                          );
   if(InpInd_Handle1==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get Bear_Bulls_Power handle");
      Print("Handle = ",InpInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- Getting handle of the CronexAC indicator

   InpInd_Handle2=iCustom(Symbol(),PERIOD_H1,"10Trend\\cronexac",
                          XMA_Method,
                          FastPeriod,
                          SlowPeriod,
                          XPhase
                          );
   if(InpInd_Handle2==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get CronexAC handle");
      Print("Handle = ",InpInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//---
   ArrayInitialize(bb_power,0.0);
   ArrayInitialize(ac_fast,0.0);
   ArrayInitialize(ac_slow,0.0);

   ArraySetAsSeries(bb_power,true);
   ArraySetAsSeries(ac_fast,true);
   ArraySetAsSeries(ac_slow,true);
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
   return(ac_fast[0]>ac_slow[0] && bb_power[0]>bb_power[1] && (bb_power[0]<0 && bb_power[1]<0))?true:false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(ac_fast[0]<ac_slow[0] && bb_power[0]<bb_power[1] && (bb_power[0]>0 && bb_power[1]>0))?true:false;
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(InpInd_Handle1,0,0,2,bb_power)<=0 ||
          CopyBuffer(InpInd_Handle2,0,0,2,ac_fast)<=0 ||
          CopyBuffer(InpInd_Handle2,1,0,2,ac_slow)<=0
          )?false:true;
  }
//+------------------------------------------------------------------+
