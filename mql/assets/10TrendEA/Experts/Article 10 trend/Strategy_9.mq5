//+------------------------------------------------------------------+
//|                                                   Strategy_9.mq5 |
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
input string               Inp_EaComment="Strategy #9";                 //EA Comment
input double               Inp_Lot=0.01;                                //Lot
input MarginMode           Inp_MMode=LOT;                               //MM
input int                  Inp_MagicNum=1111;                           //Magic number
input int                  Inp_StopLoss=400;                            //Stop Loss(points)
input int                  Inp_TakeProfit=600;                          //Take Profit(points)
input int                  Inp_Deviation = 20;                          //Deviation(points)

input uint                 BuyLevel=50;                                 //Overbuying zone
input double               SellLevel=-50;                               //Overselling zone
//--- i-KlPrice indicator parameters

input Smooth_Method        MA_Method1=MODE_ParMA;                        //smoothing method of moving average
input uint                 Length1=100;                                 //smoothing depth of moving average                  
input int                  Phase1=15;                                   //moving average smoothing parameter

input Smooth_Method        MA_Method2=MODE_SMMA_;                        //candles size smoothing method
input uint                 Length2=20;                                  //smoothing depth of candles size 
input int                  Phase2=100;                                  //candles size smoothing parameter

input double               Deviation=2.0;                               //channel expansion ratio
input uint                 Smooth=20;                                   //indicator smoothing period

input Applied_price_       IPC=PRICE_TYPICAL_;                            //price constant
input int                  Shift=0;                                     //horizontal shift of the indicator in bars

//--- iTrend indicator parameters

input Applied_price_       Price_Type=PRICE_TYPICAL_;
//--- Moving Average parameters
input uint                 MAPeriod=14;
input ENUM_MA_METHOD       MAType=MODE_EMA;
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;
//--- Bollinger parameters
input uint                 BBPeriod=14;
input double               deviation_=2.0;
input ENUM_APPLIED_PRICE   BBPrice=PRICE_CLOSE;
input Mode                 BBMode=Mode_1;

int InpInd_Handle1,InpInd_Handle2;
double klprice[],itrend_h[],itrend_l[];
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
//--- Getting handle of the i-KlPrice indicator

   InpInd_Handle1=iCustom(Symbol(),PERIOD_H1,"10Trend\\i-klprice",
                          MA_Method1,
                          Length1,
                          Phase1,

                          MA_Method2,
                          Length2,
                          Phase2,

                          Deviation,
                          Smooth,

                          IPC,
                          BuyLevel,
                          SellLevel,
                          Shift
                          );
   if(InpInd_Handle1==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get i-KlPrice handle");
      Print("Handle = ",InpInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- Getting handle of the iTrend indicator

   InpInd_Handle2=iCustom(Symbol(),PERIOD_H1,"10Trend\\i_trend",
                          Price_Type,
                          MAPeriod,
                          MAType,
                          MAPrice,

                          BBPeriod,
                          deviation_,
                          BBPrice,
                          BBMode
                          );
   if(InpInd_Handle2==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get iTrend handle");
      Print("Handle = ",InpInd_Handle2,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//---
   ArrayInitialize(klprice,0.0);
   ArrayInitialize(itrend_h,0.0);
   ArrayInitialize(itrend_l,0.0);

   ArraySetAsSeries(klprice,true);
   ArraySetAsSeries(itrend_h,true);
   ArraySetAsSeries(itrend_l,true);
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
   return(klprice[0]>BuyLevel && itrend_h[0]>itrend_l[0])?true:false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(klprice[0]<SellLevel && itrend_h[0]<itrend_l[0])?true:false;
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(InpInd_Handle1,0,0,2,klprice)<=0 ||
          CopyBuffer(InpInd_Handle2,0,0,2,itrend_h)<=0 ||
          CopyBuffer(InpInd_Handle2,1,0,2,itrend_l)<=0
          )?false:true;
  }
//+------------------------------------------------------------------+
