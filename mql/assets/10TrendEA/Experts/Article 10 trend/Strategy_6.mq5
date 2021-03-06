//+------------------------------------------------------------------+
//|                                                   Strategy_4.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alexander Fedosov"
#property link      "https://www.mql5.com/en/users/alex2356"
#property version   "1.00"

#include "TradeFunctions.mqh" 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeBase Trade;
//+------------------------------------------------------------------+
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+
input string               Inp_EaComment="Strategy #6";                 //EA Comment
input double               Inp_Lot=0.01;                                //Lot
input MarginMode           Inp_MMode=LOT;                               //MM
input  int                 Inp_MagicNum=1111;                           //Magic number
input int                  Inp_StopLoss=400;                            //Stop Loss(points)
input int                  Inp_TakeProfit=600;                          //Take Profit(points)
input int                  Inp_Deviation = 20;                          //Deviation(points)
//--- LeMan Objective indicator parameters

input int                  Sample=20;
input int                  Quartile_1 = 25;
input int                  Quartile_2 = 50;
input int                  Quartile_3 = 75;
input int                  Shift=0;
//--- Weight Oscillator indicator parameters
//---- RSI
input double               RSIWeight=1.0;
input uint                 RSIPeriod=14;
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;
//---- MFI
input double               MFIWeight=1.0;
input uint                 MFIPeriod=14;
input ENUM_APPLIED_VOLUME  MFIVolumeType=VOLUME_TICK;
//---- WPR
input double               WPRWeight=1.0;
input uint                 WPRPeriod=12;
//---- DeMarker
input double               DeMarkerWeight=1.0;
input uint                 DeMarkerPeriod=10;
//----
input Smooth_Method        bMA_Method=MODE_SMMA_;
input uint                 bLength=5;
input int                  bPhase=100;

int InpInd_Handle1,InpInd_Handle2;
double obj_q3_b[],obj_q3_s[],wo[],close[];
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
//--- Getting the handle of the LeMan Objective indicator

   InpInd_Handle1=iCustom(Symbol(),PERIOD_H4,"10Trend\\objective",
                          Sample,
                          Quartile_1,
                          Quartile_2,
                          Quartile_3,
                          Shift
                          );
   if(InpInd_Handle1==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get LeMan Objective handle");
      Print("Handle = ",InpInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- Getting the handle of the Weight Oscillator indicator

   InpInd_Handle2=iCustom(Symbol(),PERIOD_H4,"10Trend\\WeightOscillator",
                          RSIWeight,
                          RSIPeriod,
                          RSIPrice,

                          MFIWeight,
                          MFIPeriod,
                          MFIVolumeType,

                          WPRWeight,
                          WPRPeriod,

                          DeMarkerWeight,
                          DeMarkerPeriod,

                          bMA_Method,
                          bLength,
                          bPhase
                          );
   if(InpInd_Handle2==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get Weight Oscillator handle");
      Print("Handle = ",InpInd_Handle2,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//---
   ArrayInitialize(wo,0.0);
   ArrayInitialize(obj_q3_b,0.0);
   ArrayInitialize(obj_q3_s,0.0);
   ArrayInitialize(close,0.0);

   ArraySetAsSeries(obj_q3_b,true);
   ArraySetAsSeries(obj_q3_s,true);
   ArraySetAsSeries(wo,true);
   ArraySetAsSeries(close,true);
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
   return(wo[0]>wo[1] && close[0]>obj_q3_b[0])?true:false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(wo[0]<wo[1] && close[0]<obj_q3_s[0])?true:false;
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(InpInd_Handle1,6,0,2,obj_q3_b)<=0 ||
          CopyBuffer(InpInd_Handle1,2,0,2,obj_q3_s)<=0 ||
          CopyBuffer(InpInd_Handle2,0,0,2,wo)<=0 || 
          CopyClose(Symbol(),PERIOD_H4,0,2,close)<=0
          )?false:true;
  }
//+------------------------------------------------------------------+
