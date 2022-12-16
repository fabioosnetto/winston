//+------------------------------------------------------------------+
//|                                                 TEST - Trend.mq5 |
//|                                            Copyright 2022, FABIO |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, FABIO"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <WINSTON - Library.mqh>

input ENUM_TIMEFRAMES Timeframe = PERIOD_M5;

//--- Moving Averages
input int                GrayMAMPeriod       =          15; //Gray MA Period     
input int                PinkMAMPeriod       =          15; //Pink MA Period
input int                RedMAMPeriod        =          27; //Red MA Period
input int                WhiteMAPeriod       =         200; //White MA Period
input ENUM_MA_METHOD     GrayMAMethod        =   MODE_LWMA; //Gray MA Method
input ENUM_MA_METHOD     PinkMAMethod        =    MODE_EMA; //Pink MA Method
input ENUM_MA_METHOD     RedMAMethod         =   MODE_SMMA; //Red MA Method
input ENUM_MA_METHOD     WhiteMAMethod       =    MODE_SMA; //White MA Method
input ENUM_APPLIED_PRICE GrayMAAppliedPrice  = PRICE_CLOSE; //Gray MA Applied Price
input ENUM_APPLIED_PRICE PinkMAAppliedPrice  = PRICE_CLOSE; //Pink MA Applied Price
input ENUM_APPLIED_PRICE RedMAAppliedPrice   =  PRICE_OPEN; //Red MA Applied Price
input ENUM_APPLIED_PRICE WhiteMAAppliedPrice = PRICE_CLOSE; //White MA Applied Price

//--- MACD
input int                MACDFastEMA      =            17; //MACD Fast EMA
input int                MACDSlowEMA      =           100; //MACD Slow EMA
input int                MACDSignalP      =             9; //MACD Signal
input ENUM_APPLIED_PRICE MACDAppliedPrice = PRICE_TYPICAL; //MACD Applied Price

double Open[];
double High[];
double Low[];
double Close[];

//--- MOVING AVERAGES
double GrayMA[];
double PinkMA[];
double RedMA[];
double WhiteMA[];
int    GrayMAHandle;
int    PinkMAHandle;
int    RedMAHandle;
int    WhiteMAHandle;

//--- MACD
double MACDMain[];
double MACDSignal[];
int    MACDHandle;

int OnInit()
  {
   //--- SET HANDLE VALUES
   GrayMAHandle  = iMA(  _Symbol, Timeframe, GrayMAMPeriod, 0, GrayMAMethod,  GrayMAAppliedPrice);
   PinkMAHandle  = iMA(  _Symbol, Timeframe, PinkMAMPeriod, 0, PinkMAMethod,  PinkMAAppliedPrice);
   RedMAHandle   = iMA(  _Symbol, Timeframe, RedMAMPeriod,  0, RedMAMethod,   RedMAAppliedPrice);
   WhiteMAHandle = iMA(  _Symbol, Timeframe, WhiteMAPeriod, 0, WhiteMAMethod, WhiteMAAppliedPrice);
   MACDHandle    = iMACD(_Symbol, Timeframe, MACDFastEMA, MACDSlowEMA, MACDSignalP, MACDAppliedPrice);
   //+------------------------------------------------------------------+
   
   //+------------------------------------------------------------------+
   if(GrayMAHandle == INVALID_HANDLE)
     {
      Print("Error to Set Gray MA Handle - ", GetLastError());
      return(INIT_FAILED);
     }
   if(PinkMAHandle == INVALID_HANDLE)
     {
      Print("Error to Set Pink MA Handle - ", GetLastError());
      return(INIT_FAILED);
     }
   if(RedMAHandle == INVALID_HANDLE)
     {
      Print("Error to Set Red MA Handle - ", GetLastError());
      return(INIT_FAILED);
     }
   if(WhiteMAHandle == INVALID_HANDLE)
     {
      Print("Error to Set White MA Handle - ", GetLastError());
      return(INIT_FAILED);
     }
   if(MACDHandle == INVALID_HANDLE)
     {
      Print("Error to Set MACD Handle - ", GetLastError());
      return(INIT_FAILED);
     }
     
   if(!ArraySetAsSeries(Open, true))
     {
      Print("ERROR - Open is Not a Series. ");
      return(INIT_FAILED);
     }
   if(!ArraySetAsSeries(High, true))
     {
      Print("ERROR - High is Not a Series. ");
      return(INIT_FAILED);
     }
   if(!ArraySetAsSeries(Low, true))
     {
      Print("ERROR - Low is Not a Series. ");
      return(INIT_FAILED);
     }  
   if(!ArraySetAsSeries(Close, true))
     {
      Print("ERROR - Close is Not a Series. ");
      return(INIT_FAILED);
     }  
   if(!ArraySetAsSeries(GrayMA, true))
     {
      Print("ERROR - Gray MA is Not a Series. ");
      return(INIT_FAILED);
     }
   if(!ArraySetAsSeries(PinkMA, true))
     {
      Print("ERROR - Pink MA is Not a Series. ");
      return(INIT_FAILED);
     }
   if(!ArraySetAsSeries(RedMA, true))
     {
      Print("ERROR - Red MA is Not a Series. ");
      return(INIT_FAILED);
     }
   if(!ArraySetAsSeries(WhiteMA, true))
     {
      Print("ERROR - White MA is Not a Series. ");
      return(INIT_FAILED);
     }
   if(!ArraySetAsSeries(MACDMain, true))
     {
      Print("ERROR - MACD Main is Not a Series. ");
      return(INIT_FAILED);
     }
   if(!ArraySetAsSeries(MACDSignal, true))
     {
      Print("ERROR - MACD Signal is Not a Series. ");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

  }

void OnTick()
  {
   CopyOpen (_Symbol, Timeframe, 0, 150, Open);
   CopyHigh (_Symbol, Timeframe, 0, 150, High);
   CopyLow  (_Symbol, Timeframe, 0, 150, Low);
   CopyClose(_Symbol, Timeframe, 0, 150, Close);
   CopyBuffer(GrayMAHandle,  0, 0, 100, GrayMA);
   CopyBuffer(PinkMAHandle,  0, 0, 100, PinkMA);
   CopyBuffer(RedMAHandle,   0, 0, 100, RedMA);
   CopyBuffer(WhiteMAHandle, 0, 0, 100, WhiteMA);
   CopyBuffer(MACDHandle,    0, 0, 100, MACDMain);
   CopyBuffer(MACDHandle,    1, 0, 100, MACDSignal);
   
   struct trendIs
     {
      string comm;
     };
   
   bool Bull1 = Trend(Bullish_LVL1, true, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   bool Bull2 = Trend(Bullish_LVL2, true, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   bool Bull3 = Trend(Bullish_LVL3, true, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   
   bool Bear1 = Trend(Bearish_LVL1, true, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   bool Bear2 = Trend(Bearish_LVL2, true, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   bool Bear3 = Trend(Bearish_LVL3, true, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   
   bool side = Trend(Side_Trend,    true, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   
   trendIs obj;
   obj.comm = Bull1? "BULLISH TREND LVL 1" : obj.comm;
   obj.comm = Bull2? "BULLISH TREND LVL 2" : obj.comm;
   obj.comm = Bull3? "BULLISH TREND LVL 3" : obj.comm;
   
   obj.comm = Bear1? "BEARISH TREND LVL 1" : obj.comm;
   obj.comm = Bear2? "BEARISH TREND LVL 2" : obj.comm;
   obj.comm = Bear3? "BEARISH TREND LVL 3" : obj.comm;
   
   obj.comm = side? "SIDE TREND" : obj.comm;
   
   Comment(obj.comm);
  }
//+------------------------------------------------------------------+
