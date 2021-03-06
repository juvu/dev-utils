//+---------------------------------------------------------------------+
//|                                                Bear_Bulls_Power.mq5 | 
//|                                 Copyright © 2006, Eng. Waddah Attar | 
//|                                             waddahattar@hotmail.com | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, Eng. Waddah Attar"
#property link "waddahattar@hotmail.com"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator Plotting Options   |
//+-----------------------------------+
//---- drawing indicator as a multi-color histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the three color histogram
#property indicator_color1  clrBlue,clrGray,clrHotPink
//---- indicator histogram - a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "Bear_Bulls_Power"
//+-----------------------------------+
//|  CXMA class description             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
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
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_SMA_; //Indicator smoothing method 
input uint Length1=12; //Depth of indicator averaging                   
input int Phase1=15; //Parameter of of indicator averaging
//---- for JJMA within the range of -100 ... +100 it influences the quality of the transition process;
//---- for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method MA_Method2=MODE_JJMA; //Smoothing method for the final indicator
input uint Length2 = 5; //Final indicator smoothing depth
input int Phase2=15;  //Final indicator smoothing parameter
//---- for JJMA within the range of -100 ... +100 it influences the quality of the transition process;
//--- for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE_;    //Price constant
input int Shift=0; // Horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that further 
// will be used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//---- Declaration of the integer variables for the start of data calculation
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+   
//| Bear_Bulls_Power indicator initialization function               | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_1=GetStartBars(MA_Method1, Length1, Phase1);
   min_rates_total=min_rates_1+GetStartBars(MA_Method2, Length2, Phase2);
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);  
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);     
//---- initializations of variable for indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"Bear_Bulls_Power(",Length1,", ",Smooth1,", ",Length2,", ",Smooth2,")");
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   
//---- determine the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| Bear_Bulls_Power iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaring floating point variables  
   double price,xma,bulls_bears,xbulls_bears;
//---- Declaration of integer variables and getting calculated bars
   int first,bar,clr;

//---- calculation of the 'first' starting number for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // check for the first start of calculation of an indicator
      first=0; // starting index for calculation of all bars
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- Main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      xma=XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price,bar,false);
      bulls_bears=(high[bar]+low[bar]-2*xma)/2.0;      
      xbulls_bears=XMA2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,bulls_bears,bar,false);
      IndBuffer[bar]=xbulls_bears/_Point;
     }

//---- correction of the first variable value
   if(prev_calculated>rates_total || prev_calculated<=0) // check for the first start of calculation of an indicator
      first=min_rates_total;     // starting index for calculation of all bars
           
//---- Main loop of the signal line coloring
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      clr=1;
      if(IndBuffer[bar-1]<IndBuffer[bar]) clr=0;
      if(IndBuffer[bar-1]>IndBuffer[bar]) clr=2;
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
