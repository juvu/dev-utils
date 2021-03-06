//+------------------------------------------------------------------+
//|                                               TradeFunctions.mqh |
//|                                     Copyright 2017, Alex Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
//|   Алгоритмы для торговых операций                                |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017, Alex Fedosov"
#property link      "https://www.mql5.com/ru/users/alex2356"
#property version   "1.51"
#include <Trade\PositionInfo.mqh>
//+------------------------------------------------------------------+
//|  Перечисление для вариантов расчёта лота                         |
//+------------------------------------------------------------------+
enum MarginMode
  {
   FREEMARGIN=0,     //MM Free Margin
   BALANCE,          //MM Balance
   LOT               //Constant Lot
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTradeBase
  {
protected:

public:
                     CTradeBase(void);
                    ~CTradeBase(void);
   CPositionInfo     m_position;                   // trade position object
   bool              BuyPositionOpen(bool BUY_Signal,const string symbol,double Money_Management,int Margin_Mode,uint deviation,int StopLoss,int Takeprofit,int MagicNumber,string  TradeComm);
   bool              SellPositionOpen(bool SELL_Signal,const string symbol,double Money_Management,int Margin_Mode,uint deviation,int StopLoss,int Takeprofit,int MagicNumber,string  TradeComm);
   bool              IsOpened(int magic_num);
   double            Dig(void);
private:

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeBase::CTradeBase(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeBase::~CTradeBase(void)
  {
  }
//+------------------------------------------------------------------+
//| Открываем длинную позицию                                        |
//+------------------------------------------------------------------+
bool CTradeBase::BuyPositionOpen
(
 bool BUY_Signal,// флаг разрешения на сделку
 const string symbol,        // торговая пара сделки
 double Money_Management,    // MM
 int Margin_Mode,            // способ расчёта величины лота
 uint deviation,             // слиппаж
 int StopLoss,               // стоплосс в пунктах
 int Takeprofit,             // тейкпрофит в пунктах
 int MagicNumber,            // меджик
 string  TradeComm=""        // комментарии
 )
  {
//----
   if(!BUY_Signal) return(true);

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;
//---- Проверка на истечение временного лимита для предыдущей сделки и полноты объёма
//if(!TradeTimeLevelCheck(symbol,PosType,TimeLevel)) return(true);

//---- Проверка на наличие открытой позиции
//if(PositionSelect(symbol)) return(true);

//----
   double volume=BuyLotCount(symbol,Money_Management,Margin_Mode,StopLoss,deviation);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Ask;
//----   
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask)) return(true);

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции
   request.type   = ORDER_TYPE_BUY;
   request.price  = Ask;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.magic  = MagicNumber;
   request.comment= TradeComm;

//---- Определение расстояния до стоплосса в единицах ценового графика
   if(StopLoss)
     {
      if(!StopCorrect(symbol,StopLoss))return(false);
      double dStopLoss=StopLoss*point;
      request.sl=NormalizeDouble(request.price-dStopLoss,int(digit));
     }
   else
      request.sl=0.0;

//---- Определение расстояния до тейкпрофита единицах ценового графика
   if(Takeprofit)
     {
      if(!StopCorrect(symbol,Takeprofit))return(false);
      double dTakeprofit=Takeprofit*point;
      request.tp=NormalizeDouble(request.price+dTakeprofit,int(digit));
     }
   else
      request.tp=0.0;

//----
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment," ============ Open Buy position to ",symbol," ============");
   Print(comment);

//---- Открываем BUY позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      //TradeTimeLevelSet(symbol,PosType,TimeLevel);
      BUY_Signal=false;
      comment="";
      StringConcatenate(comment,"============ Buy position to ",symbol," opened ============");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Открываем короткую позицию                                       |
//+------------------------------------------------------------------+
bool CTradeBase::SellPositionOpen
(
 bool SELL_Signal,// флаг разрешения на сделку
 const string symbol,        // торговая пара сделки
 double Money_Management,    // MM
 int Margin_Mode,            // способ расчёта величины лота
 uint deviation,             // слиппаж
 int StopLoss,               // стоплосс в пунктах
 int Takeprofit,             // тейкпрофит в пунктах
 int MagicNumber,            //меджик
 string  TradeComm=""        // комментарии  
 )
//SellPositionOpen(SELL_Signal,symbol,TimeLevel,Money_Management,deviation,Margin_Mode,StopLoss,Takeprofit);
  {
//----
   if(!SELL_Signal) return(true);

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;
//---- Проверка на истечение временного лимита для предыдущей сделки и полноты объёма
//if(!TradeTimeLevelCheck(symbol,PosType,TimeLevel)) return(true);

//---- Проверка на наличие открытой позиции
   if(PositionSelect(symbol)) return(true);

//----
   double volume=SellLotCount(symbol,Money_Management,Margin_Mode,StopLoss,deviation);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Bid;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid)) return(true);

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания SELL позиции
   request.type   = ORDER_TYPE_SELL;
   request.price  = Bid;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.magic=MagicNumber;
   request.comment=TradeComm;

//---- Определение расстояния до стоплосса в единицах ценового графика
   if(StopLoss!=0)
     {
      if(!StopCorrect(symbol,StopLoss))return(false);
      double dStopLoss=StopLoss*point;
      request.sl=NormalizeDouble(request.price+dStopLoss,int(digit));
     }
   else request.sl=0.0;

//---- Определение расстояния до тейкпрофита единицах ценового графика
   if(Takeprofit!=0)
     {
      if(!StopCorrect(symbol,Takeprofit))return(false);
      double dTakeprofit=Takeprofit*point;
      request.tp=NormalizeDouble(request.price-dTakeprofit,int(digit));
     }
   else request.tp=0.0;
//----
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"============ Open Sell position to ",symbol," ============");
   Print(comment);

//---- Открываем SELL позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      //TradeTimeLevelSet(symbol,PosType,TimeLevel);
      SELL_Signal=false;
      comment="";
      StringConcatenate(comment,"============ Sell position to ",symbol," opened ============");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//|  Определение количества знаков                                   |
//+------------------------------------------------------------------+
double CTradeBase::Dig(void)
  {
//--- tuning for 3 or 5 digits
   long digits=SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
   int digits_adjust=1;
   digits_adjust=((digits==5 || digits==3 || digits==1)?10:1);
   return(Point()*digits_adjust);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradeBase:: IsOpened(int m_magic)
  {
   int pos=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
     {
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            pos++;
     }

   return((pos>0)?true:false);
  }
//+===================================================================================+
//|   Прочие вспомогательные функции                                                  |
//+===================================================================================+

//+------------------------------------------------------------------+
//| Расчёт размера лота для открывания лонга                         |  
//+------------------------------------------------------------------+
double BuyLotCount
(
 string symbol,
 double Money_Management,
 int Margin_Mode,
 int STOPLOSS,
 uint Slippage_
 )
  {
//----
   double margin,Lot;

//--- РАСЧЁТ ВЕЛИЧИНЫ ЛОТА ДЛЯ ОТКРЫВАНИЯ ПОЗИЦИИ
   if(Money_Management<0) Lot=MathAbs(Money_Management);
   else
   switch(Margin_Mode)
     {
      //---- Расчёт лота от свободных средств на счёте
      case  0:
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_BUY,margin);
         break;

         //---- Расчёт лота от баланса средств на счёте
      case  1:
         margin=AccountInfoDouble(ACCOUNT_BALANCE)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_BUY,margin);
         break;

         //---- Расчёт лота без изменения
      case  2:
        {
         Lot=MathAbs(Money_Management);
         break;
        }

      //---- Расчёт лота от свободных средств на счёте по умолчанию
      default:
        {
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_BUY,margin);
        }
     }

//---- нормирование величины лота до ближайшего стандартного значения 
   if(!LotCorrect(symbol,Lot,POSITION_TYPE_BUY)) return(-1);
//----
   return(Lot);
  }
//+------------------------------------------------------------------+
//| Расчёт размера лота для открывания шорта                         |  
//+------------------------------------------------------------------+
/*                                                                   |
 Внешняя  переменная Margin_Mode определяет способ расчёта  величины | 
 лота                                                                |
 0 - MM по свободным средствам на счёте                              |
 1 - MM по балансу средств на счёте                                  |
 2 - MM по убыткам от свободных средств на счёте                     |
 3 - MM по убыткам от баланса средств на счёте                       |
 по умолчанию - MM по свободным средствам на счёте                   |
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
 если Money_Management меньше нуля,  то торговая  функция в качестве | 
 величины  лота  использует  округлённую  до ближайшего стандартного |
 значения абсолютную величину Money_Management.                      |
*///                                                                 |
//+------------------------------------------------------------------+
double SellLotCount
(
 string symbol,
 double Money_Management,
 int Margin_Mode,
 int STOPLOSS,
 uint Slippage_
 )
// (string symbol, double Money_Management, int Margin_Mode, int STOPLOSS)
  {
//----
   double margin,Lot;

//---1+ РАСЧЁТ ВЕЛИЧИНЫ ЛОТА ДЛЯ ОТКРЫВАНИЯ ПОЗИЦИИ
   if(Money_Management<0) Lot=MathAbs(Money_Management);
   else
   switch(Margin_Mode)
     {
      //---- Расчёт лота от свободных средств на счёте
      case  0:
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_SELL,margin);
         break;

         //---- Расчёт лота от баланса средств на счёте
      case  1:
         margin=AccountInfoDouble(ACCOUNT_BALANCE)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_SELL,margin);
         break;

         //---- Расчёт лота без изменения
      case  2:
        {
         Lot=MathAbs(Money_Management);
         break;
        }

      //---- Расчёт лота от свободных средств на счёте по умолчанию
      default:
        {
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_SELL,margin);
        }
     }
//---1+ 

//---- нормирование величины лота до ближайшего стандартного значения 
   if(!LotCorrect(symbol,Lot,POSITION_TYPE_SELL)) return(-1);
//----
   return(Lot);
  }
//+------------------------------------------------------------------+
//| расчёт размер лота для открывания позиции с маржой lot_margin    |
//+------------------------------------------------------------------+
double GetLotForOpeningPos(string symbol,ENUM_POSITION_TYPE direction,double lot_margin)
  {
//----
   double price=0.0,n_margin;
   if(direction==POSITION_TYPE_BUY)  if(!SymbolInfoDouble(symbol,SYMBOL_ASK,price)) return(0);
   if(direction==POSITION_TYPE_SELL) if(!SymbolInfoDouble(symbol,SYMBOL_BID,price)) return(0);
   if(!price) return(NULL);

   if(!OrderCalcMargin(ENUM_ORDER_TYPE(direction),symbol,1,price,n_margin) || !n_margin) return(0);
   double lot=lot_margin/n_margin;

//---- получение торговых констант
   double LOTSTEP,MaxLot,MinLot;
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,LOTSTEP)) return(0);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot)) return(0);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot)) return(0);

//---- нормирование величины лота до ближайшего стандартного значения 
   lot=LOTSTEP*MathFloor(lot/LOTSTEP);

//---- проверка лота на минимальное допустимое значение
   if(lot<MinLot) lot=0;
//---- проверка лота на максимальное допустимое значение       
   if(lot>MaxLot) lot=MaxLot;
//----
   return(lot);
  }
//+------------------------------------------------------------------+
//| коррекция размера отложенного ордера до допустимого значения     |
//+------------------------------------------------------------------+
bool StopCorrect(string symbol,int &Stop)
  {
//----
   long Extrem_Stop;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL,Extrem_Stop)) return(false);
   if(Stop<Extrem_Stop) Stop=int(Extrem_Stop);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| коррекция размера отложенного ордера до допустимого значения     |
//+------------------------------------------------------------------+
bool dStopCorrect
(
 string symbol,
 double &dStopLoss,
 double &dTakeprofit,
 ENUM_POSITION_TYPE trade_operation
 )
// dStopCorrect(symbol,dStopLoss,dTakeprofit,trade_operation)
  {
//----
   if(!dStopLoss && !dTakeprofit) return(true);

   if(dStopLoss<0)
     {
      Print(__FUNCTION__,"(): A negative value stoploss!");
      return(false);
     }

   if(dTakeprofit<0)
     {
      Print(__FUNCTION__,"(): A negative value takeprofit!");
      return(false);
     }
//---- 
   int Stop;
   long digit;
   double point,dStop,ExtrStop,ExtrTake;

//---- получаем минимальное расстояние до отложенного ордера 
   Stop=0;
   if(!StopCorrect(symbol,Stop))return(false);
//----   
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point)) return(false);
   dStop=Stop*point;

//---- коррекция размера отложенного ордера для лонга
   if(trade_operation==POSITION_TYPE_BUY)
     {
      double Ask;
      if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask)) return(false);

      ExtrStop=NormalizeDouble(Ask-dStop,int(digit));
      ExtrTake=NormalizeDouble(Ask+dStop,int(digit));

      if(dStopLoss>ExtrStop && dStopLoss) dStopLoss=ExtrStop;
      if(dTakeprofit<ExtrTake && dTakeprofit) dTakeprofit=ExtrTake;
     }

//---- коррекция размера отложенного ордера для шорта
   if(trade_operation==POSITION_TYPE_SELL)
     {
      double Bid;
      if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid)) return(false);

      ExtrStop=NormalizeDouble(Bid+dStop,int(digit));
      ExtrTake=NormalizeDouble(Bid-dStop,int(digit));

      if(dStopLoss<ExtrStop && dStopLoss) dStopLoss=ExtrStop;
      if(dTakeprofit>ExtrTake && dTakeprofit) dTakeprofit=ExtrTake;
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| возврат стрингового результата торговой операции по его коду     |
//+------------------------------------------------------------------+
string ResultRetcodeDescription(int retcode)
  {
   string str;
//----
   switch(retcode)
     {
      case TRADE_RETCODE_REQUOTE: str="Requote"; break;
      case TRADE_RETCODE_REJECT: str="Request rejected"; break;
      case TRADE_RETCODE_CANCEL: str="Request canceled by trader"; break;
      case TRADE_RETCODE_PLACED: str="Order placed"; break;
      case TRADE_RETCODE_DONE: str="Request completed"; break;
      case TRADE_RETCODE_DONE_PARTIAL: str="Only part of the request was completed"; break;
      case TRADE_RETCODE_ERROR: str="Request processing error"; break;
      case TRADE_RETCODE_TIMEOUT: str="Request canceled by timeout";break;
      case TRADE_RETCODE_INVALID: str="Invalid request"; break;
      case TRADE_RETCODE_INVALID_VOLUME: str="Invalid volume in the request"; break;
      case TRADE_RETCODE_INVALID_PRICE: str="Invalid price in the request"; break;
      case TRADE_RETCODE_INVALID_STOPS: str="Invalid stops in the request"; break;
      case TRADE_RETCODE_TRADE_DISABLED: str="Trade is disabled"; break;
      case TRADE_RETCODE_MARKET_CLOSED: str="Market is closed"; break;
      case TRADE_RETCODE_NO_MONEY: str="There is not enough money to complete the request"; break;
      case TRADE_RETCODE_PRICE_CHANGED: str="Prices changed"; break;
      case TRADE_RETCODE_PRICE_OFF: str="There are no quotes to process the request"; break;
      case TRADE_RETCODE_INVALID_EXPIRATION: str="Invalid order expiration date in the request"; break;
      case TRADE_RETCODE_ORDER_CHANGED: str="Order state changed"; break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS: str="Too frequent requests"; break;
      case TRADE_RETCODE_NO_CHANGES: str="No changes in request"; break;
      case TRADE_RETCODE_SERVER_DISABLES_AT: str="Autotrading disabled by server"; break;
      case TRADE_RETCODE_CLIENT_DISABLES_AT: str="Autotrading disabled by client terminal"; break;
      case TRADE_RETCODE_LOCKED: str="Request locked for processing"; break;
      case TRADE_RETCODE_FROZEN: str="Order or position frozen"; break;
      case TRADE_RETCODE_INVALID_FILL: str="Invalid order filling type"; break;
      case TRADE_RETCODE_CONNECTION: str="No connection with the trade server"; break;
      case TRADE_RETCODE_ONLY_REAL: str="Operation is allowed only for live accounts"; break;
      case TRADE_RETCODE_LIMIT_ORDERS: str="The number of pending orders has reached the limit"; break;
      case TRADE_RETCODE_LIMIT_VOLUME: str="The volume of orders and positions for the symbol has reached the limit"; break;
      default: str="Unknown result";
     }
//----
   return(str);
  }
//+------------------------------------------------------------------+
//| коррекция размера лота до ближайшего допустимого значения        |
//+------------------------------------------------------------------+
bool LotCorrect
(
 string symbol,
 double &Lot,
 ENUM_POSITION_TYPE trade_operation
 )
//LotCorrect(string symbol, double& Lot, ENUM_POSITION_TYPE trade_operation)
  {
//---- получение данных для расчёта   
   double Step,MaxLot,MinLot;
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,Step)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot)) return(false);

//---- нормирование величины лота до ближайшего стандартного значения 
   Lot=Step*MathFloor(Lot/Step);

//---- проверка лота на минимальное допустимое значение
   if(Lot<MinLot) Lot=MinLot;
//---- проверка лота на максимальное допустимое значение       
   if(Lot>MaxLot) Lot=MaxLot;

//---- проверка средств на достаточность
   if(!LotFreeMarginCorrect(symbol,Lot,trade_operation))return(false);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| ограничение размера лота возможностями депозита                  |
//+------------------------------------------------------------------+
bool LotFreeMarginCorrect
(
 string symbol,
 double &Lot,
 ENUM_POSITION_TYPE trade_operation
 )
//(string symbol, double& Lot, ENUM_POSITION_TYPE trade_operation)
  {
//---- проверка средств на достаточность
   double freemargin=AccountInfoDouble(ACCOUNT_FREEMARGIN);
   if(freemargin<=0) return(false);

//---- получение данных для расчёта   
   double Step,MaxLot,MinLot;
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,Step)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot)) return(false);

   double ExtremLot=GetLotForOpeningPos(symbol,trade_operation,freemargin);
//---- нормирование величины лота до ближайшего стандартного значения 
   ExtremLot=Step*MathFloor(ExtremLot/Step);

   if(ExtremLot<MinLot) return(false); // недостаточно денег даже на минимальный лот!
   if(Lot>ExtremLot) Lot=ExtremLot; // урезаем размер лота до того, что есть на депозите!
   if(Lot>MaxLot) Lot=MaxLot; // урезаем размер лота до масимально допустимого
//----
   return(true);
  }
//+------------------------------------------------------------------+
