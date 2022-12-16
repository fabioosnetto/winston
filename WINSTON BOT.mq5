//+------------------------------------------------------------------+
//|                                                  WINSTON BOT.mq5 |
//|                                           Copyright 2021, FABIO. |
//|                              https://instagram.com/fabio.orione/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, FABIO."
#property link      "https://instagram.com/fabio.orione/"
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade trade;

//+------------------------------------------------------------------+
//--- INPUTS
//--- Volume
input double FullVolume    = 6.0; //Full Volume
input double LightVolume   = 4.0; //Light Volume
input double PartialVolume = 2.0; // Parcial Volume

//--- Trading
input ulong                   EAMagicNumber    =               314159; //EA Magic Number
input ENUM_ORDER_TYPE_FILLING OrderTypeFilling = ORDER_FILLING_RETURN; //Order Type Filling
input ulong                   OrderDeviation   =                   15; //Order Deviation
input bool                    AutoTrading      =                 true; //Auto Trading

//--- Times
input ENUM_TIMEFRAMES Timeframe  = PERIOD_M5; //Timeframe
input int             BeginHour  =         9; //Begin Hour
input int             BeginMinut =        10; //Begin Minut
input int             EndHour    =        17; //End Hour
input int             EndMinut   =         1; //End Minut

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

//+------------------------------------------------------------------+
//--- PRICES
MqlRates rates[];
double Open[];
double High[];
double Low[];
double Close[];
double ROpen0;
double ROpen;
double RHigh;
double RLow;
double RClose;
double ROpen2;
double RHigh2;
double RLow2;
double RClose2;
double Ask;
double Bid;
double TickSize;

//--- TIMES
MqlDateTime dt;
MqlDateTime dt_;
MqlDateTime dt_rates;
datetime AtualCandle;
datetime NewCandle;

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

//--- CANDLESTICKS

//--- SUPPORTS & RESISTANCES

//--- FIBONACCI


//+------------------------------------------------------------------+

int OnInit()
  {
   //+------------------------------------------------------------------+
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
   //+------------------------------------------------------------------+
   
   //+------------------------------------------------------------------+
   //--- ARRAY SET AS SERIES
   if(!ArraySetAsSeries(rates, true))
     {
      Print("ERROR - Rates is Not a Series. ");
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
   //+------------------------------------------------------------------+
     
   //+------------------------------------------------------------------+
   if(BeginHour > EndHour)
     {
      Print("ERROR - Begin Hour is Greater than End Hour. ");
      return(INIT_FAILED);
     }
   if(EAMagicNumber <= 0)
     {
      Print("ERROR - EA Magic Number Must Be Greater than Zero. ");
      return(INIT_FAILED);
     }
   if((PartialVolume > FullVolume) || ((FullVolume / 3) != PartialVolume))
     {
      Print("ERROR - Parcial Volume Must Be Lower than Full Volume and 1/3 of Full Volume. ");
      return(INIT_FAILED);
     }
   //+------------------------------------------------------------------+
   
   //+------------------------------------------------------------------+
   //--- TRADING
   trade.SetExpertMagicNumber(EAMagicNumber);
   trade.SetTypeFilling(OrderTypeFilling);
   trade.SetDeviationInPoints(OrderDeviation);
   //+------------------------------------------------------------------+
   
   Print("EA INITIALIZED.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {
   IndicatorRelease(GrayMAHandle);
   IndicatorRelease(PinkMAHandle);
   IndicatorRelease(RedMAHandle);
   IndicatorRelease(WhiteMAHandle);
   IndicatorRelease(MACDHandle);
   Comment("");
   ChartRedraw();
   Print("EA DEINITIALIZED.");
  }

//+------------------------------------------------------------------+

void OnTick()
  {
   TimeToStruct(TimeTradeServer(), dt);
   TimeToStruct(PositionTime(_Symbol), dt_);

   CopyRates(_Symbol, Timeframe, 0, 150, rates);
   CopyOpen (_Symbol, Timeframe, 0, 150, Open);
   CopyHigh (_Symbol, Timeframe, 0, 150, High);
   CopyLow  (_Symbol, Timeframe, 0, 150, Low);
   CopyClose(_Symbol, Timeframe, 0, 150, Close);
   
   Ask      = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Bid      = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   TickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   CopyBuffer(GrayMAHandle,  0, 0, 100, GrayMA);
   CopyBuffer(PinkMAHandle,  0, 0, 100, PinkMA);
   CopyBuffer(RedMAHandle,   0, 0, 100, RedMA);
   CopyBuffer(WhiteMAHandle, 0, 0, 100, WhiteMA);
   CopyBuffer(MACDHandle,    0, 0, 100, MACDMain);
   CopyBuffer(MACDHandle,    1, 0, 100, MACDSignal);

   
   Comment("");
   if(TimeCondition(dt))
     {
      ROpen0  = NormalRoundPrice(Open[0], TickSize);
      
      ROpen   = NormalRoundPrice(Open[1], TickSize);
      RHigh   = NormalRoundPrice(High[1], TickSize);
      RLow    = NormalRoundPrice(Low[1], TickSize);
      RClose  = NormalRoundPrice(Close[1], TickSize);
      
      ROpen2  = NormalRoundPrice(Open[2], TickSize);
      RHigh2  = NormalRoundPrice(High[2], TickSize);
      RLow2   = NormalRoundPrice(Low[2], TickSize);
      RClose2 = NormalRoundPrice(Close[2], TickSize);
      
      bool BullishMACD = MACDMain[1] > MACDSignal[1];
      
      bool BullishCandle1 = BullishOrBearish(Close, Open, 1) == 1;
      bool BullishCandle2 = BullishOrBearish(Close, Open, 2) == 1; 
      bool BullishCandle3 = BullishOrBearish(Close, Open, 3) == 1;
         
      bool BearishCandle1 = BullishOrBearish(Close, Open, 1) == 2; 
      bool BearishCandle2 = BullishOrBearish(Close, Open, 2) == 2;
      bool BearishCandle3 = BullishOrBearish(Close, Open, 3) == 2;  
         
      bool Doji1          = BullishOrBearish(Close, Open, 1) == 0;
      bool Doji2          = BullishOrBearish(Close, Open, 2) == 0;
      
      int Top    = WhereIsTop(High, 2);
      int Bottom = WhereIsBottom(Low, 2);
      
      
      if(BullishMACD)
        { 
         if(IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 1) == "BULLISH TREND LVL 3")
           {
            /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 8))
              {
               if((!OrderInPrice(RHigh + TickSize)) && (Positions(_Symbol) == 0)) 
                 {
                  double RLow0 = NormalRoundPrice(Low[0], TickSize);
                  
                  if(trade.BuyStop(FullVolume, (RHigh + TickSize), _Symbol, (RLow0 - TickSize), 0.0, ORDER_TIME_DAY, 0, NULL))
                    {
                     Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                  else
                    {
                     Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                 }
              }*/
            
            
            /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 3))
              {     
               double Fibo100Top   = High[BiggestTop(High, 2)];
               double Fibo0Bottom  = Low[WhereIsBottom(Low, BiggestTop(High, 2))];
               double Fibo50R      = FiboRetracement(Fibo100Top, Fibo0Bottom, 0.5);
               double Fibo382R     = FiboRetracement(Fibo100Top, Fibo0Bottom, 0.382);
               bool   MA_AwayPrice = MAAwayPrice(GrayMA, PinkMA, Open, High, Low, Close, BiggestTop(High, 2));
               
               if((!OrderInPrice(ROpen0 - (2*TickSize))) && (Positions(_Symbol) == 0) && (Open[0] > Fibo50R) && (High[1] > High[2] && High[1] < Fibo100Top))
                 {
                  if(!MA_AwayPrice)
                    {
                     if((Bid > (ROpen0 - (2*TickSize))))
                       {
                        if(trade.SellStop(LightVolume, (ROpen0 - (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Top, TickSize)+(TickSize*3), NormalRoundPrice(Fibo382R, TickSize), ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                         }
                       }
                     else
                       {
                        if((Bid < (ROpen0 - (2*TickSize))))
                          {
                           if(trade.SellLimit(LightVolume, (ROpen0 - (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Top, TickSize)+(TickSize*3), NormalRoundPrice(Fibo382R, TickSize), ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    } 
                  else
                    {
                     if((Bid > (ROpen0 - (2*TickSize))))
                       {
                        if(trade.SellStop(FullVolume, (ROpen0 - (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Top, TickSize)+(TickSize*3), 0.000, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                         }
                       }
                     else
                       {
                        if((Bid < (ROpen0 - (2*TickSize))))
                          {
                           if(trade.SellLimit(FullVolume, (ROpen0 - (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Top, TickSize)+(TickSize*3), 0.000, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }
                 }       
              }*/
            
            if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 3))
              {     
               if((!OrderInPrice(RHigh + (2*TickSize))) && (Positions(_Symbol) == 0)) 
                 {
                  if((Ask < (RHigh + (2*TickSize))))
                    {
                     if(trade.BuyStop(FullVolume, (RHigh + (2*TickSize)), _Symbol, (RLow - (TickSize * 3)), 0.0, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if((Ask > (RHigh + (2*TickSize))))
                       {
                        if(trade.BuyLimit(FullVolume, (RHigh + (2*TickSize)), _Symbol, (RLow - (TickSize * 3)), 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }       
              }
              
              
            /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 4))
              {     
               if((!OrderInPrice(RHigh2 + (2*TickSize))) && (Positions(_Symbol) == 0)) 
                 {
                  if((Ask < (RHigh2 + (2*TickSize))))
                    {
                     if(trade.BuyStop(FullVolume, (RHigh2 + (2*TickSize)), _Symbol, (RLow - (TickSize * 3)), 0.0, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if((Ask > (RHigh2 + (2*TickSize))))
                       {
                        if(trade.BuyLimit(FullVolume, (RHigh2 + (2*TickSize)), _Symbol, (RLow - (TickSize * 3)), 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }       
              }*/
            Comment("BULLISH TREND LVL 3");
           }
         else
           {
            if(IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 1) == "BULLISH TREND LVL 2")
              {
               /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 8))
                 {
                  if((!OrderInPrice(RHigh + TickSize)) && (Positions(_Symbol) == 0)) 
                    {
                     double RLow0 = NormalRoundPrice(Low[0], TickSize);
                  
                     if(trade.BuyStop(FullVolume, (RHigh + TickSize), _Symbol, (RLow0 - TickSize), 0.0, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                 }*/
                 
               /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 3))
                 {    
                  double Fibo50P   = NormalizeDouble((RHigh + (MathRound(((RHigh - RLow) *   0.5) / TickSize) * TickSize)), _Digits);
                  double Fibo1618P = NormalizeDouble((RLow  - (MathRound(((RHigh - RLow) * 0.618) / TickSize) * TickSize)), _Digits);
                  
                  if((!OrderInPrice(RHigh + (TickSize*2))) && (Positions(_Symbol) == 0)) 
                    {
                     if((Ask < (RHigh + (TickSize*2))))
                       {
                        if(trade.SellLimit(FullVolume, (RHigh + (TickSize*2)), _Symbol, Fibo50P, Fibo1618P, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if((Ask > (RHigh + (TickSize*2))))
                          {
                           if(trade.SellStop(FullVolume, (RHigh + (TickSize*2)), _Symbol, Fibo50P, Fibo1618P, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }       
                 }*/
               
               
               Comment("BULLISH TREND LVL 2");
              }
            else
              {
               if(IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 1) == "BULLISH TREND LVL 1")
                 {
                  if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 3))
                    {     
                     if((!OrderInPrice(RHigh + (2*TickSize))) && (Positions(_Symbol) == 0)) 
                       {
                        if((Ask < (RHigh + (2*TickSize))))
                          {
                           if(trade.BuyStop(FullVolume, (RHigh + (2*TickSize)), _Symbol, (RLow - (TickSize * 3)), 0.0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                        else
                          {
                           if((Ask > (RHigh + (2*TickSize))))
                             {
                              if(trade.BuyLimit(FullVolume, (RHigh + (2*TickSize)), _Symbol, (RLow - (TickSize * 3)), 0.0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else
                                {
                                 Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                          }
                       }       
                    }
                  
                  /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 8))
                    {
                     if((!OrderInPrice(RHigh + TickSize)) && (Positions(_Symbol) == 0)) 
                       {
                        double RLow0 = NormalRoundPrice(Low[0], TickSize);
                  
                        if(trade.BuyStop(FullVolume, (RHigh + TickSize), _Symbol, (RLow0 - TickSize), 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }*/
                    
                  /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 3))
                    {     
                     if(Close[1] < High[Top])
                       {
                        if((!OrderInPrice(RHigh + (2*TickSize))) && (Positions(_Symbol) == 0)) 
                          {
                           if((Ask < (RHigh + (2*TickSize))))
                             {
                              if(trade.BuyStop(FullVolume, (RHigh + (2*TickSize)), _Symbol, (RLow - (TickSize * 3)), 0.0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else
                                {
                                 Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                           else
                             {
                              if((Ask > (RHigh + (2*TickSize))))
                                {
                                 if(trade.BuyLimit(FullVolume, (RHigh + (2*TickSize)), _Symbol, (RLow - (TickSize * 3)), 0.0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                else
                                   {
                                    Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                             }
                          }
                       }
                     else
                       {
                        double HiToTop = High[1] - High[Top];
                        double LoToTop = High[Top] - Low[1];  
                        
                        if((Close[1] > High[Top]) && (HiToTop <= LoToTop))
                          {6
                           if((!OrderInPrice(RHigh + (2*TickSize))) && (Positions(_Symbol) == 0)) 
                             {
                              if((Ask < (RHigh + (2*TickSize))))
                                {
                                 if(trade.BuyStop(LightVolume, (RHigh + (2*TickSize)), _Symbol, (RLow - (TickSize * 3)), 0.0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else
                                   {
                                    Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                              else
                                {
                                 if((Ask > (RHigh + (2*TickSize))))
                                   {
                                    if(trade.BuyLimit(LightVolume, (RHigh + (2*TickSize)), _Symbol, (RLow - (TickSize * 3)), 0.0, ORDER_TIME_DAY, 0, NULL))
                                      {
                                       Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                      }
                                    else
                                      {
                                       Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                      }
                                   }
                                }
                             }
                          }
                       }      
                    }*/
                  Comment("BULLISH TREND LVL 1");
                 }
              }
           }
        }
      else
        {
//----------------------------------------------------------------------------------------------------------------------------------------------------------------
         if(IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 1) == "BEARISH TREND LVL 3")
           {
            /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 7))
              {
               if((!OrderInPrice(RLow - TickSize)) && (Positions(_Symbol) == 0))
                 {
                  double RHigh0  = NormalRoundPrice(High[0], TickSize);
                  
                  if(trade.SellStop(FullVolume, (RLow - TickSize), _Symbol, (RHigh0 + TickSize), 0.000, ORDER_TIME_DAY, 0, NULL))
                    {
                     Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                  else
                    {
                     Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                 }*/
            
            
            /*if(MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 33)
              {
               double Fibo100Bottom = Low[LowerBottom(Low, 2)];
               double Fibo0Top      = High[WhereIsTop(High, LowerBottom(Low, 2))];
               double Fibo50R       = FiboRetracement(Fibo100Bottom, Fibo0Top, 0.5);
               double Fibo382R      = FiboRetracement(Fibo100Bottom, Fibo0Top, 0.382);
               bool   MA_AwayPrice = MAAwayPrice(GrayMA, PinkMA, Open, High, Low, Close, LowerBottom(Low, 2));
               
               if((!OrderInPrice(ROpen0 + (2*TickSize))) && (Positions(_Symbol) == 0) && (Open[0] < Fibo50R) && (Low[1] < Low[2] && Low[1] > Fibo100Bottom))
                 {
                  if(!MA_AwayPrice)
                    {
                     if(Ask < (ROpen0 + (2*TickSize)))
                       {
                        if(trade.BuyStop(LightVolume, (ROpen0 + (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Bottom, TickSize)-(TickSize*3), NormalRoundPrice(Fibo382R, TickSize), ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Ask > (ROpen0 + (2*TickSize)))
                          {
                           if(trade.BuyLimit(LightVolume, (ROpen0 + (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Bottom, TickSize)-(TickSize*3), NormalRoundPrice(Fibo382R, TickSize), ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }
                  else
                    {
                     if(Ask < (ROpen0 + (2*TickSize)))
                       {
                        if(trade.BuyStop(FullVolume, (ROpen0 + (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Bottom, TickSize)-(TickSize*3), 0.000, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Ask > (ROpen0 + (2*TickSize)))
                          {
                           if(trade.BuyLimit(FullVolume, (ROpen0 + (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Bottom, TickSize)-(TickSize*3), 0.000, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }
                 }
              }*/
            
            /*if(MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 33)
              {
               if((!OrderInPrice(RLow - (2*TickSize))) && (Positions(_Symbol) == 0))
                 {
                  if(Bid > (RLow - (2*TickSize)))
                    {
                     if(trade.SellStop(FullVolume, (RLow - (2*TickSize)), _Symbol, (RHigh + (TickSize * 3)), 0.000, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if(Bid < (RLow - (2*TickSize)))
                       {
                        if(trade.SellLimit(FullVolume, (RLow - (2*TickSize)), _Symbol, (RHigh + (TickSize * 3)), 0.000, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }
              }*/
              
              
            /*if(MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 44)
              {
               if((!OrderInPrice(RLow2 - (2*TickSize))) && (Positions(_Symbol) == 0))
                 {
                  if(Bid > (RLow2 - (2*TickSize)))
                    {
                     if(trade.SellStop(FullVolume, (RLow2 - (2*TickSize)), _Symbol, (RHigh + (TickSize * 3)), 0.000, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if(Bid < (RLow2 - (2*TickSize)))
                       {
                        if(trade.SellLimit(FullVolume, (RLow2 - (2*TickSize)), _Symbol, (RHigh + (TickSize * 3)), 0.000, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }
              }*/
            Comment("BEARIISH TREND LVL 3");
           }
         else
           {
            if(IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 1) == "BEARISH TREND LVL 2")
              {
               /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 7))
                 {
                  if((!OrderInPrice(RLow - TickSize)) && (Positions(_Symbol) == 0))
                    {
                     double RHigh0  = NormalRoundPrice(High[0], TickSize);
                  
                     if(trade.SellStop(FullVolume, (RLow - TickSize), _Symbol, (RHigh0 + TickSize), 0.000, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                 }*/
                 
               /*if(MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 33)
                 {
                  double Fibo50P   = NormalizeDouble((RLow  - (MathRound(((RHigh - RLow) *   0.5) / TickSize) * TickSize)), _Digits);             
                  double Fibo1618P = NormalizeDouble((RHigh + (MathRound(((RHigh - RLow) * 0.618) / TickSize) * TickSize)), _Digits);
                  
                  if((!OrderInPrice(RLow - (TickSize*2))) && (Positions(_Symbol) == 0))
                    {
                     if(Bid > (RLow - (TickSize*2)))
                       {
                        if(trade.BuyLimit(FullVolume, (RLow - (TickSize*2)), _Symbol, Fibo50P, Fibo1618P, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Bid < (RLow - (TickSize*2)))
                          {
                           if(trade.BuyStop(FullVolume, (RLow - (TickSize*2)), _Symbol, Fibo50P, Fibo1618P, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }
                 }*/
                 
               
               
               Comment("BEARISH TREND LVL 2");
              }
            else
              {
               if(IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 1) == "BEARISH TREND LVL 1")
                 {
                  /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 7))
                    {
                    if((!OrderInPrice(RLow - TickSize)) && (Positions(_Symbol) == 0))
                       {
                        double RHigh0  = NormalRoundPrice(High[0], TickSize);
                  
                        if(trade.SellStop(FullVolume, (RLow - TickSize), _Symbol, (RHigh0 + TickSize), 0.000, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                         else
                          {
                           Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }*/
                    
                  if(MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 33)
                    {
                     if((!OrderInPrice(RLow - (2*TickSize))) && (Positions(_Symbol) == 0))
                       {
                        if(Bid > (RLow - (2*TickSize)))
                          {
                           if(trade.SellStop(FullVolume, (RLow - (2*TickSize)), _Symbol, (RHigh + (TickSize * 3)), 0.000, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                        else
                          {
                           if(Bid < (RLow - (2*TickSize)))
                             {
                              if(trade.SellLimit(FullVolume, (RLow - (2*TickSize)), _Symbol, (RHigh + (TickSize * 3)), 0.000, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else
                                {
                                 Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                          }
                       }
                    }  
                    
                  /*if(MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 33)
                    {
                     if(Close[1] > Low[Bottom])
                       {
                        if((!OrderInPrice(RLow - (2*TickSize))) && (Positions(_Symbol) == 0))
                          {
                           if(Bid > (RLow - (2*TickSize)))
                             {
                              if(trade.SellStop(FullVolume, (RLow - (2*TickSize)), _Symbol, (RHigh + (TickSize * 3)), 0.000, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else
                                {
                                 Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                           else
                             {
                              if(Bid < (RLow - (2*TickSize)))
                                {
                                 if(trade.SellLimit(FullVolume, (RLow - (2*TickSize)), _Symbol, (RHigh + (TickSize * 3)), 0.000, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else
                                   {
                                    Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                             }
                          }
                       }
                     else
                       {
                        double LoToBottom = Low[Bottom] - Low[1];
                        double HiToBottom = High[1] - Low[Bottom];
                       
                        if((Close[1] < Low[Bottom]) && (LoToBottom <= HiToBottom))
                          {
                           if((!OrderInPrice(RLow - (2*TickSize))) && (Positions(_Symbol) == 0))
                             {
                              if(Bid > (RLow - (2*TickSize)))
                                {
                                 if(trade.SellStop(LightVolume, (RLow - (2*TickSize)), _Symbol, (RHigh + (TickSize * 3)), 0.000, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else
                                   {
                                    Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                              else
                                {
                                 if(Bid < (RLow - (2*TickSize)))
                                   {
                                    if(trade.SellLimit(LightVolume, (RLow - (2*TickSize)), _Symbol, (RHigh + (TickSize * 3)), 0.000, ORDER_TIME_DAY, 0, NULL))
                                      {
                                       Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                      }
                                    else
                                      {
                                       Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                      }
                                   }
                                }
                             }
                          }
                       }
                    }*/
                  Comment("BEARISH TREND LVL 1");
                 }
              }
           }
        }
      
      if(IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 2) == "BULLISH TREND LVL 2")
        {
         /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 3))
           {     
            double Fibo100Top   = High[BiggestTop(High, 2)];
            double Fibo0Bottom  = Low[WhereIsBottom(Low, BiggestTop(High, 2))];
            double Fibo50R      = FiboRetracement(Fibo100Top, Fibo0Bottom, 0.5);
            double Fibo382R     = FiboRetracement(Fibo100Top, Fibo0Bottom, 0.382);
            bool   MA_AwayPrice = MAAwayPrice(GrayMA, PinkMA, Open, High, Low, Close, BiggestTop(High, 2));
               
            if((!OrderInPrice(ROpen0 - (2*TickSize))) && (Positions(_Symbol) == 0) && (Open[0] > Fibo50R) && (High[1] > High[2] && High[1] < Fibo100Top) && (Close[1] < GrayMA[1]))
              {
               if(!MA_AwayPrice)
                 {
                  if((Bid > (ROpen0 - (2*TickSize))))
                    {
                     if(trade.SellStop(LightVolume, (ROpen0 - (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Top, TickSize)+(TickSize*3), NormalRoundPrice(Fibo382R, TickSize), ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if((Bid < (ROpen0 - (2*TickSize))))
                       {
                        if(trade.SellLimit(LightVolume, (ROpen0 - (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Top, TickSize)+(TickSize*3), NormalRoundPrice(Fibo382R, TickSize), ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        }
                    }
                 } 
               else
                 {
                  if((Bid > (ROpen0 - (2*TickSize))))
                    {
                     if(trade.SellStop(FullVolume, (ROpen0 - (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Top, TickSize)+(TickSize*3), 0.000, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }   
                    }
                  else
                    {
                     if((Bid < (ROpen0 - (2*TickSize))))
                       {
                        if(trade.SellLimit(FullVolume, (ROpen0 - (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Top, TickSize)+(TickSize*3), 0.000, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }
              }       
           }*/
           
         /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 3) && (Close[1] > GrayMA[1]))
           {   
            if(BullishCandle1 && !ElephantBar(Open, High, Low, Close, 1))
              {
               if((!OrderInPrice(RLow - (TickSize*1))) && (Positions(_Symbol) == 0)) 
                 {
                  if((Bid > (RLow - (TickSize*1))))
                    {
                     if(trade.SellStop(FullVolume, (RLow - (TickSize*1)), _Symbol, (RHigh + (TickSize * 1)), 0.0, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if((Bid < (RLow - (TickSize*1))))
                       {
                        if(trade.SellLimit(FullVolume, (RLow - (TickSize*1)), _Symbol, (RHigh + (TickSize * 1)), 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                          Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 } 
              }  
            else
              {
               if(BearishCandle1)
                 {
                  if((!OrderInPrice(RLow - (TickSize*1))) && (Positions(_Symbol) == 0)) 
                    {
                     if((Bid > (RLow - (TickSize*1))))
                       {
                        if(trade.SellStop(FullVolume, (RLow - (TickSize*1)), _Symbol, (RHigh + (TickSize * 1)), 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Sell Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Sell Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if((Bid < (RLow - (TickSize*1))))
                          {
                           if(trade.SellLimit(FullVolume, (RLow - (TickSize*1)), _Symbol, (RHigh + (TickSize * 1)), 0.0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Sell Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Sell Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    } 
                 }
              }     
           }*/
        }
      else
        {
         if(IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 2) == "BEARISH TREND LVL 2")
           {
            /*if(MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 33)
              {
               double Fibo100Bottom = Low[LowerBottom(Low, 2)];
               double Fibo0Top      = High[WhereIsTop(High, LowerBottom(Low, 2))];
               double Fibo50R       = FiboRetracement(Fibo100Bottom, Fibo0Top, 0.5);
               double Fibo382R      = FiboRetracement(Fibo100Bottom, Fibo0Top, 0.382);
               bool   MA_AwayPrice = MAAwayPrice(GrayMA, PinkMA, Open, High, Low, Close, LowerBottom(Low, 2));
               
               if((!OrderInPrice(ROpen0 + (2*TickSize))) && (Positions(_Symbol) == 0) && (Open[0] < Fibo50R) && (Low[1] < Low[2] && Low[1] > Fibo100Bottom) && (Close[1] > GrayMA[1]))
                 {
                  if(!MA_AwayPrice)
                    {
                     if(Ask < (ROpen0 + (2*TickSize)))
                       {
                        if(trade.BuyStop(LightVolume, (ROpen0 + (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Bottom, TickSize)-(TickSize*3), NormalRoundPrice(Fibo382R, TickSize), ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Ask > (ROpen0 + (2*TickSize)))
                          {
                           if(trade.BuyLimit(LightVolume, (ROpen0 + (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Bottom, TickSize)-(TickSize*3), NormalRoundPrice(Fibo382R, TickSize), ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }    
                       }
                    }
                  else
                    {
                     if(Ask < (ROpen0 + (2*TickSize)))
                       {
                        if(trade.BuyStop(FullVolume, (ROpen0 + (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Bottom, TickSize)-(TickSize*3), 0.000, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Ask > (ROpen0 + (2*TickSize)))
                          {
                           if(trade.BuyLimit(FullVolume, (ROpen0 + (2*TickSize)), _Symbol, NormalRoundPrice(Fibo100Bottom, TickSize)-(TickSize*3), 0.000, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }
                 }
              }*/
              
            /*if(MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 33 && (Close[1] < GrayMA[1]))
              {
               if(BearishCandle1 && !ElephantBar(Open, High, Low, Close, 1))
                 {
                  if((!OrderInPrice(RHigh + (TickSize*1))) && (Positions(_Symbol) == 0))
                    {
                     if(Ask < (RHigh + (TickSize*1)))
                       {
                        if(trade.BuyStop(FullVolume, (RHigh + (TickSize*1)), _Symbol, (RLow - (TickSize * 1)), 0.000, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Ask > (RHigh + (TickSize*1)))
                          {
                           if(trade.BuyLimit(FullVolume, (RHigh + (TickSize*1)), _Symbol, (RLow - (TickSize * 1)), 0.000, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }
                 }
               else
                 {
                  if(BullishCandle1)
                    {
                     if((!OrderInPrice(RHigh + (TickSize*1))) && (Positions(_Symbol) == 0))
                       {
                        if(Ask < (RHigh + (TickSize*1)))
                          {
                           if(trade.BuyStop(FullVolume, (RHigh + (TickSize*1)), _Symbol, (RLow - (TickSize * 1)), 0.000, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Buy Stop - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("Buy Stop - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                        else
                          {
                           if(Ask > (RHigh + (TickSize*1)))
                             {
                              if(trade.BuyLimit(FullVolume, (RHigh + (TickSize*1)), _Symbol, (RLow - (TickSize * 1)), 0.000, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("Buy Limit - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else
                                {
                                 Print("Buy Limit - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                          }
                       }
                    }
                 }
              }*/
           }
        }
      
      /*bool sidetrend  =    (IsSideTrend(MACDMain, MACDSignal, 1) == "SIDE TREND 1") || (IsSideTrend(MACDMain, MACDSignal, 1) == "SIDE TREND 2") || (IsSideTrend(MACDMain, MACDSignal, 1) == "SIDE TREND 3") || (IsSideTrend(MACDMain, MACDSignal, 1) == "SIDE TREND 4");
      bool side_trend =    (IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 1) == "SIDE TREND") || (IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 1) == "SIDE TREND");
      bool BullishTrend1 = IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 1) == "BULLISH TREND LVL 1";*/
      bool BullishTrend22 = IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 2) == "BULLISH TREND LVL 2";
      /*bool BullishTrend3 = IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 1) == "BULLISH TREND LVL 3";
      bool BearishTrend1 = IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 1) == "BEARISH TREND LVL 1";*/
      bool BearishTrend22 = IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 2) == "BEARISH TREND LVL 2";
      //bool BearishTrend3 = IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 1) == "BEARISH TREND LVL 3";

      if(Positions(_Symbol) == 0)
        {
         if(((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 0) && (MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 0)) && (Orders(_Symbol) > 0))
           {
            CancelOrders();
           }
         else
           {
            if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 1) || (MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 2) || (MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 3) || (MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 4) || (MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 8))
              {
               if((Orders(_Symbol) == 1) /*&& (!BullishTrend22)*/)
                 {
                  if((!OrderInPrice(RHigh + (2*TickSize)) && !OrderInPrice(RHigh2 + (2*TickSize))) || ((!OrderType(ORDER_TYPE_BUY_STOP, _Symbol)) && (!OrderType(ORDER_TYPE_BUY_LIMIT, _Symbol))))
                    {
                     CancelOrders();
                    }
                 }
               else
                 {
                  if((Orders(_Symbol) > 1) /*&& (!BullishTrend22)*/)
                    {
                     for(int i = 0; i < Orders(_Symbol); i++)
                       {
                        if((!OrderInPrice(RHigh + (2*TickSize), i) && !OrderInPrice(RHigh2 + (2*TickSize), i)) || ((!OrderType(ORDER_TYPE_BUY_STOP, _Symbol, i)) && (!OrderType(ORDER_TYPE_BUY_LIMIT, _Symbol, i))))
                          {
                           CancelOrders(NULL, i);
                          }
                       }
                    }
                 }
              }
            else
              {
               if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 11) || (MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 22) || (MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 33) || (MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 44) || (MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 7))
                 {
                  if((Orders(_Symbol) == 1) && (!BearishTrend22))
                    {
                     if((!OrderInPrice(RLow - (2*TickSize)) && !OrderInPrice(RLow2 - (2*TickSize))) || ((!OrderType(ORDER_TYPE_SELL_STOP, _Symbol)) && (!OrderType(ORDER_TYPE_SELL_LIMIT, _Symbol))))
                       {
                        CancelOrders();
                       }
                    }
                  else
                    {
                     if((Orders(_Symbol) > 1) && (!BearishTrend22))
                       {
                        for(int i = 0; i < Orders(_Symbol); i++)
                          {
                           if((!OrderInPrice(RLow - (2*TickSize), i) && !OrderInPrice(RLow2 - (2*TickSize), i)) || ((!OrderType(ORDER_TYPE_SELL_STOP, _Symbol, i)) && (!OrderType(ORDER_TYPE_SELL_LIMIT, _Symbol, i))))
                             {
                              CancelOrders(NULL, i);
                             }
                          }
                       }
                    }
                 }
               else
                 {
                  if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 123) && (BullishTrend22))
                    {
                     if(Orders(_Symbol) > 0)
                       {
                        for(int i = 0; i < Orders(_Symbol); i++)
                          {
                           if((!OrderInPrice(RLow - (1*TickSize), i)) || ((!OrderType(ORDER_TYPE_SELL_STOP, _Symbol, i)) && (!OrderType(ORDER_TYPE_SELL_LIMIT, _Symbol, i))))
                             {
                              CancelOrders(NULL, i);
                             }
                          }
                       }
                    }
                  else
                    {
                     if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 123) && (BearishTrend22))
                       {
                        if(Orders(_Symbol) > 0)
                          {
                           for(int i = 0; i < Orders(_Symbol); i++)
                             {
                              if((!OrderInPrice(RHigh + (1*TickSize), i)) || ((!OrderType(ORDER_TYPE_BUY_STOP, _Symbol, i)) && (!OrderType(ORDER_TYPE_BUY_LIMIT, _Symbol, i))))
                                {
                                 CancelOrders(NULL, i);
                                }
                             }
                          }
                       }
                     else
                       {
                        if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 3) && (!BearishTrend22))
                          {
                           if(Orders(_Symbol) > 0)
                             {
                              for(int i = 0; i < Orders(_Symbol); i++)
                                {
                                 if((!OrderInPrice(ROpen0 - (2*TickSize), i)) || ((!OrderType(ORDER_TYPE_SELL_STOP, _Symbol, i)) && (!OrderType(ORDER_TYPE_SELL_LIMIT, _Symbol, i))))
                                   {
                                    CancelOrders(NULL, i);
                                   }
                                }
                             }
                          }
                        else
                          {
                           if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 33) && (!BearishTrend22))
                             {
                              if(Orders(_Symbol) > 0)
                                {
                                 for(int i = 0; i < Orders(_Symbol); i++)
                                   {
                                    if((!OrderInPrice(ROpen0 + (2*TickSize), i)) || ((!OrderType(ORDER_TYPE_BUY_STOP, _Symbol, i)) && (!OrderType(ORDER_TYPE_BUY_LIMIT, _Symbol, i))))
                                      {
                                       CancelOrders(NULL, i);
                                      }
                                   }
                                }
                             }
                           else
                             {
                              if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 3) && (BearishTrend22))
                                {
                                 if(Orders(_Symbol) > 0)
                                   {
                                    for(int i = 0; i < Orders(_Symbol); i++)
                                      {
                                       if((!OrderInPrice(RHigh + (2*TickSize), i)) || ((!OrderType(ORDER_TYPE_SELL_STOP, _Symbol, i)) && (!OrderType(ORDER_TYPE_SELL_LIMIT, _Symbol, i))))
                                         {
                                          CancelOrders(NULL, i);
                                         }
                                      }   
                                   }
                                }
                              else
                                {
                                 if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 33) && (BearishTrend22))
                                   {
                                    if(Orders(_Symbol) > 0)
                                      {
                                       for(int i = 0; i < Orders(_Symbol); i++)
                                         {
                                          if((!OrderInPrice(RLow - (2*TickSize), i)) || ((!OrderType(ORDER_TYPE_BUY_STOP, _Symbol, i)) && (!OrderType(ORDER_TYPE_BUY_LIMIT, _Symbol, i))))
                                            {
                                             CancelOrders(NULL, i);
                                            }
                                         }   
                                      }
                                   }
                                 else
                                   {
                                    CancelOrders();
                                   }
                                }
                             }
                          }
                       }
                    }
                 }
              }
           }
        }
      
      
      
      if(Positions(_Symbol) == 1)
        {
         int PositionCandle = WhatIsPositionCandle(rates, dt_);  
         
         if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 3) && (Orders(_Symbol) < 3) && (PositionOrders(dt, dt_) || Orders(_Symbol) == 0))
           {
            double Fibo50P   = NormalizeDouble((RHigh + (MathRound(((RHigh - RLow) *   0.5) / TickSize) * TickSize)), _Digits);
            double Fibo618P  = NormalizeDouble((RHigh + (MathRound(((RHigh - RLow) * 0.618) / TickSize) * TickSize)), _Digits);
            double Fibo100P  = NormalizeDouble((RHigh + (MathRound(((RHigh - RLow) *     1) / TickSize) * TickSize)), _Digits);
            double Fibo1618P = NormalizeDouble((RHigh + (MathRound(((RHigh - RLow) * 1.618) / TickSize) * TickSize)), _Digits);
            
            if(IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 1) == "BULLISH TREND LVL 1" && PositionType(POSITION_TYPE_BUY))
              {
               if((!OrderInPrice(Fibo100P)) && (PositionVolume(_Symbol) == (FullVolume)) && (Orders(_Symbol) < 2))
                 {
                  if(Ask < Fibo100P)
                    {
                     if(trade.SellLimit(FullVolume, Fibo100P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL)) //Partial
                       {
                        Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if(Ask > Fibo100P)
                       {
                        if(trade.SellStop(FullVolume, Fibo100P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }
              
               /*if((!OrderInPrice(Fibo1618P)) && (PositionVolume(_Symbol) == FullVolume) && (Orders(_Symbol) < 2))
                 {
                  if(Ask < Fibo1618P)
                    {
                     if(trade.SellLimit(FullVolume/2, Fibo1618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL)) //Light
                       {
                        Print("161,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("161,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if(Ask > Fibo1618P)
                       {
                        if(trade.SellStop(FullVolume/2, Fibo1618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("161,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("161,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }*/
              }
            else
              {
               if(IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 1) == "BULLISH TREND LVL 1" && PositionType(POSITION_TYPE_BUY))
                 {
                  if(Close[1] < High[Top])
                    {
                     if((!OrderInPrice(Fibo1618P)) && (PositionVolume(_Symbol) == FullVolume) && (Orders(_Symbol) < 1))
                       {
                        if(Ask < Fibo1618P)
                          {
                           if(trade.SellLimit(FullVolume, Fibo1618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                        else
                          {
                           if(Ask > Fibo1618P)
                             {
                               if(trade.SellStop(FullVolume, Fibo1618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else
                                {
                                 Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                          }
                       }
                    }
                  else
                    {
                     double HiToTop = High[1] - High[Top];
                     double LoToTop = High[Top] - Low[1];
                     
                     if((Close[1] > High[Top]) && (HiToTop <= LoToTop))
                       {
                        if((!OrderInPrice(Fibo618P)) && (PositionVolume(_Symbol) == LightVolume) && (Orders(_Symbol) < 2))
                          {
                           if(Ask < Fibo618P)
                             {
                              if(trade.SellLimit(FullVolume/2, Fibo618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else
                                {
                                 Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }  
                           else
                             {
                              if(Ask > Fibo618P)
                                {
                                  if(trade.SellStop(FullVolume/2, Fibo618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else
                                   {
                                    Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                             }
                          }
                       
                        if((!OrderInPrice(Fibo1618P)) && (PositionVolume(_Symbol) == LightVolume) && (Orders(_Symbol) < 2))
                          {
                           if(Ask < Fibo1618P)
                             {
                              if(trade.SellLimit(PartialVolume/2, Fibo1618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else
                                {
                                 Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }  
                           else
                             {
                              if(Ask > Fibo1618P)
                                {
                                  if(trade.SellStop(PartialVolume/2, Fibo1618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else
                                   {
                                    Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                             }
                          }
                       }
                    }
                 }
              }
           }
         else
           {
            if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 33) && (Orders(_Symbol) < 3) && (PositionOrders(dt, dt_) || Orders(_Symbol) == 0))
              {  
               double Fibo50P   = NormalizeDouble((RLow - (MathRound(((RHigh - RLow) *   0.5) / TickSize) * TickSize)), _Digits);             
               double Fibo618P  = NormalizeDouble((RLow - (MathRound(((RHigh - RLow) * 0.618) / TickSize) * TickSize)), _Digits);
               double Fibo100P  = NormalizeDouble((RLow - (MathRound(((RHigh - RLow) *     1) / TickSize) * TickSize)), _Digits);
               double Fibo1618P = NormalizeDouble((RLow - (MathRound(((RHigh - RLow) * 1.618) / TickSize) * TickSize)), _Digits);
               
               if(IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 1) == "BEARISH TREND LVL 1" && PositionType(POSITION_TYPE_SELL))
                 {
                  if((!OrderInPrice(Fibo100P)) && (PositionVolume(_Symbol) == (FullVolume)) && (Orders(_Symbol) < 2))
                    {
                     if(Bid > Fibo100P)
                       {
                        if(trade.BuyLimit(FullVolume, Fibo100P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else 
                          {
                           Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Bid < Fibo100P)
                          {
                           if(trade.BuyStop(FullVolume, Fibo100P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else 
                             {
                              Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }
               
                  /*if((!OrderInPrice(Fibo1618P)) && (PositionVolume(_Symbol) == (FullVolume)) && (Orders(_Symbol) < 2))
                    {
                     if(Bid > Fibo1618P)
                       {
                        if(trade.BuyLimit(LightVolume, Fibo1618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("161,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else 
                          {
                           Print("161,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Bid < Fibo1618P)
                           {
                           if(trade.BuyStop(LightVolume, Fibo1618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("161,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else 
                             {
                              Print("161,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }*/
                 }
               else
                 {
                  if(IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 1) == "BEARISH TREND LVL 1" && PositionType(POSITION_TYPE_SELL))
                    {
                     if(Close[1] > Low[Bottom])
                       {
                        if((!OrderInPrice(Fibo1618P)) && (PositionVolume(_Symbol) == (FullVolume)) && (Orders(_Symbol) < 1))
                          {
                           if(Bid > Fibo1618P)
                             {
                              if(trade.BuyLimit(FullVolume, Fibo1618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else 
                                {
                                 Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }   
                           else
                             {
                              if(Bid < Fibo1618P)
                                {
                                 if(trade.BuyStop(FullVolume, Fibo1618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else 
                                   {
                                    Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                             }
                          }
                       }
                     else
                       {
                        double LoToBottom = Low[Bottom] - Low[1];
                        double HiToBottom = High[1] - Low[Bottom];
                        
                        if((Close[1] < Low[Bottom]) && (LoToBottom <= HiToBottom))
                          {
                           if((!OrderInPrice(Fibo618P)) && (PositionVolume(_Symbol) == (LightVolume)) && (Orders(_Symbol) < 2))
                             {
                              if(Bid > Fibo618P)
                                {
                                 if(trade.BuyLimit(FullVolume/2, Fibo618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else 
                                   {
                                    Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }   
                              else
                                {
                                 if(Bid < Fibo618P)
                                  {
                                    if(trade.BuyStop(FullVolume/2, Fibo618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                      {
                                       Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                     }
                                    else 
                                      {
                                       Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                      }
                                   }
                                }
                             }
                          
                           if((!OrderInPrice(Fibo1618P)) && (PositionVolume(_Symbol) == (LightVolume)) && (Orders(_Symbol) < 2))
                             {
                              if(Bid > Fibo1618P)
                                {
                                 if(trade.BuyLimit(PartialVolume/2, Fibo1618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else 
                                   {
                                    Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }   
                              else
                                {
                                 if(Bid < Fibo1618P)
                                   {
                                    if(trade.BuyStop(PartialVolume/2, Fibo1618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                      {
                                       Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                     }
                                    else 
                                      {
                                       Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                      }
                                   }
                                }
                             }
                          }
                       }
                    }
                 }
              } 
            else
              {
               if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 3) && (Orders(_Symbol) < 2) && (PositionOrders(dt, dt_) || Orders(_Symbol) == 0))
                 {
                  double Fibo100Top   = High[BiggestTop(High, 2)];
                  double Fibo0Bottom  = Low[WhereIsBottom(Low, BiggestTop(High, 2))];
                  double Fibo50R      = FiboRetracement(Fibo100Top, Fibo0Bottom, 0.5);
                  double Fibo382R     = FiboRetracement(Fibo100Top, Fibo0Bottom, 0.382);
                  bool   MA_AwayPrice = MAAwayPrice(GrayMA, PinkMA, Open, High, Low, Close, BiggestTop(High, 2));
                  
                  if(MA_AwayPrice)
                    {
                     if((!OrderInPrice(Fibo382R)) && (PositionVolume(_Symbol) == (FullVolume)) && (PositionType(POSITION_TYPE_SELL)))
                       {
                        if(Bid > Fibo382R)
                          {
                           if(trade.BuyLimit(FullVolume/2, NormalRoundPrice(Fibo382R, TickSize), _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("38,2% Retracement FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else 
                             {
                              Print("38,2% Retracement FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }   
                        else
                          {
                          if(Bid < Fibo382R)
                             {
                             if(trade.BuyStop(FullVolume/2, NormalRoundPrice(Fibo382R, TickSize), _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                               {
                                Print("38,2% Retracement FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else 
                                {
                                 Print("38,2% Retracement FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             } 
                          }
                       }
                       
                     if((!OrderInPrice(Fibo0Bottom)) && (PositionVolume(_Symbol) == (FullVolume)) && (PositionType(POSITION_TYPE_SELL)))
                       {
                        if(Bid > Fibo0Bottom)
                          {
                           if(trade.BuyLimit(FullVolume/2, NormalRoundPrice(Fibo0Bottom + (3*TickSize), TickSize), _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("0% Retracement FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else 
                             {
                              Print("0% Retracement FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }   
                        else
                          {
                           if(Bid < Fibo0Bottom)
                             {
                             if(trade.BuyStop(FullVolume/2, NormalRoundPrice(Fibo0Bottom + (3*TickSize), TickSize), _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                               {
                                Print("0% Retracement FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else 
                                {
                                 Print("0% Retracement FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             } 
                          }
                       }
                    }
                 }
               else
                 {
                  if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 33) && (Orders(_Symbol) < 2) && (PositionOrders(dt, dt_) || Orders(_Symbol) == 0))
                    {
                     double Fibo100Bottom = Low[LowerBottom(Low, 2)];
                     double Fibo0Top      = High[WhereIsTop(High, LowerBottom(Low, 2))];
                     double Fibo50R       = FiboRetracement(Fibo100Bottom, Fibo0Top, 0.5);
                     double Fibo382R      = FiboRetracement(Fibo100Bottom, Fibo0Top, 0.382);
                     bool   MA_AwayPrice = MAAwayPrice(GrayMA, PinkMA, Open, High, Low, Close, LowerBottom(Low, 2));
                     
                     if(MA_AwayPrice)
                       {
                        if((!OrderInPrice(Fibo382R)) && (PositionVolume(_Symbol) == (FullVolume)) && (PositionType(POSITION_TYPE_BUY)))
                          {
                           if(Ask < Fibo382R)
                             {
                              if(trade.SellLimit(FullVolume/2, NormalRoundPrice(Fibo382R, TickSize), _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("38,2% Retracement FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else
                                {
                                 Print("38,2% Retracement FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                           else
                             {
                              if(Ask > Fibo382R)
                                {
                                 if(trade.SellStop(FullVolume/2, NormalRoundPrice(Fibo382R, TickSize), _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("38,2% Retracement FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else
                                   {
                                    Print("38,2% Retracement FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                             }
                          }
                          
                        if((!OrderInPrice(Fibo0Top)) && (PositionVolume(_Symbol) == (FullVolume)) && (PositionType(POSITION_TYPE_BUY)))
                          {
                           if(Ask < Fibo0Top)
                             {
                              if(trade.SellLimit(FullVolume/2, NormalRoundPrice(Fibo0Top - (3*TickSize), TickSize), _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("0% Retracement FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else
                                {
                                 Print("0% Retracement FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                           else
                             {
                              if(Ask > Fibo0Top)
                                {
                                 if(trade.SellStop(FullVolume/2, NormalRoundPrice(Fibo0Top - (3*TickSize), TickSize), _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("0% Retracement FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else
                                   {
                                    Print("0% Retracement FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                             }
                          }
                       }
                    }
                 }
              } 
           }
         
         /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, WhatIsPositionCandle(rates,dt_) + 2, TickSize) == 3))
           {
            double PositionHigh1  = High[WhatIsPositionCandle(rates,dt_) + 1];
            double PositionLow1   = Low[WhatIsPositionCandle(rates,dt_) + 1];
            double PositionClose1 = Close[WhatIsPositionCandle(rates,dt_) + 1];
            double PositionGrayMA = GrayMA[WhatIsPositionCandle(rates,dt_) + 1];
            double Fibo50P        = NormalRoundPrice(PositionLow1 - ((PositionHigh1 - PositionLow1) *   0.5), TickSize);        
            double Fibo618P       = NormalRoundPrice(PositionLow1 - ((PositionHigh1 - PositionLow1) * 0.618), TickSize);
            double Fibo100P       = NormalRoundPrice(PositionLow1 - ((PositionHigh1 - PositionLow1) *     1), TickSize);
            double Fibo1618P      = NormalRoundPrice(PositionLow1 - ((PositionHigh1 - PositionLow1) * 1.618), TickSize);
            double RedMAPartial   = NormalRoundPrice(RedMA[0], TickSize);
            double GrayMAPartial  = NormalRoundPrice(GrayMA[0], TickSize);
            
            if(IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, WhatIsPositionCandle(rates,dt_) + 2) == "BULLISH TREND LVL 2"  && (PositionClose1 > PositionGrayMA))
              {
               if((!OrderInPrice(GrayMAPartial) && !OrderInPrice(Fibo100P)) && (PositionVolume(_Symbol) == (FullVolume)) && (Orders(_Symbol) < 1 && PositionOrders(dt, dt_)))
                 {
                  if(PositionSelect(_Symbol))
                    {
                     double PositionPrice    = PositionGetDouble(POSITION_PRICE_OPEN);
                     double PositionToGrayMA = PositionPrice - GrayMAPartial;
                    
                     if(PositionToGrayMA >= (TickSize*2))
                       {
                        if(Bid > GrayMAPartial)
                          {
                           if(trade.BuyLimit(FullVolume/2, GrayMAPartial, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Gray MA Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                            else 
                             {
                              Print("Gray MA Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                        else
                          {
                           if(Bid < GrayMAPartial)
                             {
                              if(trade.BuyStop(FullVolume/2, GrayMAPartial, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("Gray MA Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else 
                                {
                                 Print("Gray MA Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                          }
                       }
                     else
                       {
                        if(Bid > Fibo100P)
                          {
                           if(trade.BuyLimit(FullVolume/2, Fibo100P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("Gray MA Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                            else 
                             {
                              Print("Gray MA Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                        else
                          {
                           if(Bid < Fibo100P)
                             {
                              if(trade.BuyStop(FullVolume/2, Fibo100P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("Gray MA Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else 
                                {
                                 Print("Gray MA Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                          }
                       }
                    }
                 }
                 
               for(int i = 0; i < Orders(_Symbol); i++)
                 {
                  ulong Ticket = OrderGetTicket(i);
                     
                  if(OrderSelect(Ticket))
                    {
                     double OrderPrice  = OrderGetDouble(ORDER_PRICE_OPEN);
                     double OrderGrayMA = MathAbs(OrderPrice - GrayMAPartial); 
                     double OrderRedMA  = MathAbs(OrderPrice - RedMAPartial);
                     bool   Order618    = OrderPrice == Fibo100P;
                        
                     if((OrderGrayMA < OrderRedMA) && (!Order618))
                       {
                        OrderModify(GrayMAPartial, i);
                       }
                     else
                       {
                        if(!Order618)
                          {
                           OrderModify(RedMAPartial, i);
                          }
                       }
                    }
                 }
               
            
               if((!OrderInPrice(RedMAPartial) && (OrderInPrice(GrayMAPartial) || OrderInPrice(Fibo100P))) && (PositionVolume(_Symbol) == (FullVolume)) && (Orders(_Symbol) == 1 && PositionOrders(dt, dt_)))
                 {
                  if(Bid > RedMAPartial)
                    {
                     if(trade.BuyLimit(FullVolume/2, RedMAPartial, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else 
                       {
                        Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if(Bid < RedMAPartial)
                       {
                        if(trade.BuyStop(FullVolume/2, RedMAPartial, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else 
                          {
                           Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }
              }         
           }
         else
           {
            if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, WhatIsPositionCandle(rates,dt_) + 2, TickSize) == 33))
              {
               double PositionHigh1 = High[WhatIsPositionCandle(rates,dt_) + 1];
               double PositionLow1  = Low[WhatIsPositionCandle(rates,dt_) + 1];
               double PositionClose1 = Close[WhatIsPositionCandle(rates,dt_) + 1];
               double PositionGrayMA = GrayMA[WhatIsPositionCandle(rates,dt_) + 1];
               double Fibo50P       = NormalRoundPrice(PositionHigh1 + ((PositionHigh1 - PositionLow1) *   0.5), TickSize);
               double Fibo618P      = NormalRoundPrice(PositionHigh1 + ((PositionHigh1 - PositionLow1) * 0.618), TickSize);
               double Fibo100P      = NormalRoundPrice(PositionHigh1 + ((PositionHigh1 - PositionLow1) *     1), TickSize);
               double Fibo1618P     = NormalRoundPrice(PositionHigh1 + ((PositionHigh1 - PositionLow1) * 1.618), TickSize);
               double RedMAPartial  = NormalRoundPrice(RedMA[0], TickSize);
               double GrayMAPartial = NormalRoundPrice(GrayMA[0], TickSize);
               
               if(IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, WhatIsPositionCandle(rates,dt_) + 2) == "BEARISH TREND LVL 2"  && (PositionClose1 < PositionGrayMA))
                 {
                  if((!OrderInPrice(GrayMAPartial) && !OrderInPrice(Fibo100P)) && (PositionVolume(_Symbol) == (FullVolume)) && (Orders(_Symbol) < 1 && PositionOrders(dt, dt_)))
                    {
                     if(PositionSelect(_Symbol))
                       {
                        double PositionPrice    = PositionGetDouble(POSITION_PRICE_OPEN);
                        double PositionToGrayMA = GrayMAPartial - PositionPrice;
                    
                        if(PositionToGrayMA >= (TickSize*2))
                          {
                           if(Ask < GrayMAPartial)
                             {
                              if(trade.SellLimit(FullVolume/2, GrayMAPartial, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("Gray MA Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else 
                                {
                                 Print("Gray MA Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                           else
                             {
                              if(Ask > GrayMAPartial)
                                {
                                 if(trade.SellStop(FullVolume/2, GrayMAPartial, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("Gray MA Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else 
                                   {
                                    Print("Gray MA Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                             }
                          }
                        else
                          {
                           if(Ask < Fibo100P)
                             {
                              if(trade.SellLimit(FullVolume/2, Fibo100P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                {
                                 Print("Gray MA Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                              else 
                                {
                                 Print("Gray MA Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                }
                             }
                           else
                             {
                              if(Ask > Fibo100P)
                                {
                                 if(trade.SellStop(FullVolume/2, Fibo100P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                                   {
                                    Print("Gray MA Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                 else 
                                   {
                                    Print("Gray MA Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                                   }
                                }
                             }
                          }
                       }
                    }
                    
                  for(int i = 0; i < Orders(_Symbol); i++)
                    {
                     ulong Ticket = OrderGetTicket(i);
                     
                     if(OrderSelect(Ticket))
                       {
                        double OrderPrice  = OrderGetDouble(ORDER_PRICE_OPEN);
                        double OrderGrayMA = MathAbs(OrderPrice - GrayMAPartial); 
                        double OrderRedMA  = MathAbs(OrderPrice - RedMAPartial);
                        bool   Order618    = OrderPrice == Fibo100P;

                        if((OrderGrayMA < OrderRedMA) && (!Order618))
                          {
                           OrderModify(GrayMAPartial, i);
                          }
                        else
                          {
                           if(!Order618)
                             {
                              OrderModify(RedMAPartial, i);
                             }
                          }
                       }
                    }
               
                  if((!OrderInPrice(RedMAPartial) && (OrderInPrice(GrayMAPartial) || OrderInPrice(Fibo100P))) && (PositionVolume(_Symbol) == (FullVolume)) && (Orders(_Symbol) == 1) && (PositionOrders(dt, dt_)))
                    {
                     if(Ask < RedMAPartial)
                       {
                        if(trade.SellLimit(FullVolume/2, RedMAPartial, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else 
                          {
                           Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Ask > RedMAPartial)
                          {
                           if(trade.SellStop(FullVolume/2, RedMAPartial, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("100% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else 
                             {
                              Print("100% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }
                 }
              }
           }*/
         
         /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 4) && (Orders(_Symbol) < 3) && (PositionOrders(dt, dt_) || Orders(_Symbol) == 0))
           {
            double Fibo50P   = NormalizeDouble((RHigh + (MathRound(((RHigh - RLow) *   0.5) / TickSize) * TickSize)), _Digits);
            double Fibo618P  = NormalizeDouble((RHigh + (MathRound(((RHigh - RLow) * 0.618) / TickSize) * TickSize)), _Digits);
            double Fibo100P  = NormalizeDouble((RHigh + (MathRound(((RHigh - RLow) *     1) / TickSize) * TickSize)), _Digits);
            double Fibo1618P = NormalizeDouble((RHigh + (MathRound(((RHigh - RLow) * 1.618) / TickSize) * TickSize)), _Digits);
            
            if((Orders(_Symbol) < 2))
              {
               if((!OrderInPrice(Fibo618P)) && (PositionVolume(_Symbol) == (FullVolume)))
                 {
                  if(Ask < Fibo618P)
                    {
                     if(trade.SellLimit(5.0, Fibo618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("61,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("61,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if(Ask > Fibo618P)
                       {
                        if(trade.SellStop(5.0, Fibo618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("61,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("61,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }
                 
               if((!OrderInPrice(Fibo1618P)) && (PositionVolume(_Symbol) == (FullVolume)) && (Orders(_Symbol)))
                 {
                  if(Ask < Fibo1618P)
                    {
                     if(trade.SellLimit(1.0, Fibo1618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                       {
                        Print("161,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("161,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                  else
                    {
                     if(Ask > Fibo1618P)
                       {
                        if(trade.SellStop(1.0, Fibo1618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("161,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("161,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }
              }
           }
         else
           {
            if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 1, TickSize) == 44) && (Orders(_Symbol) < 3) && (PositionOrders(dt, dt_) || Orders(_Symbol) == 0))
              {  
               double Fibo50P   = NormalizeDouble((RLow - (MathRound(((RHigh - RLow) *   0.5) / TickSize) * TickSize)), _Digits);             
               double Fibo618P  = NormalizeDouble((RLow - (MathRound(((RHigh - RLow) * 0.618) / TickSize) * TickSize)), _Digits);
               double Fibo100P  = NormalizeDouble((RLow - (MathRound(((RHigh - RLow) *     1) / TickSize) * TickSize)), _Digits);
               double Fibo1618P = NormalizeDouble((RLow - (MathRound(((RHigh - RLow) * 1.618) / TickSize) * TickSize)), _Digits);

               if((Orders(_Symbol) < 2))
                 {
                  if((!OrderInPrice(Fibo618P)) && ((PositionVolume(_Symbol) == (FullVolume))))
                    {
                     if(Bid > Fibo618P)
                       {
                        if(trade.BuyLimit(5.0, Fibo618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("61,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                         else
                          {
                           Print("61,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Bid < Fibo618P)
                          {
                           if(trade.BuyStop(5.0, Fibo618P, _Symbol, 0, 0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("61,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else
                             {
                              Print("61,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }
              
                  if((!OrderInPrice(Fibo1618P)) && (PositionVolume(_Symbol) == (FullVolume)) && (Orders(_Symbol) < 2))
                    {
                     if(Bid > Fibo1618P)
                       {
                        if(trade.BuyLimit(1.0, Fibo1618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                          {
                           Print("161,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                        else 
                          {
                           Print("161,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                          }
                       }
                     else
                       {
                        if(Bid < Fibo1618P)
                          {
                           if(trade.BuyStop(1.0, Fibo1618P, _Symbol, 0.0, 0.0, ORDER_TIME_DAY, 0, NULL))
                             {
                              Print("161,8% FIBO Order - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                           else 
                             {
                              Print("161,8% FIBO Order - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                             }
                          }
                       }
                    }
                 }
              }
           }*/
           
         
         if(PositionCandle == 2)
           {
            if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 4, TickSize) == 3) && (PositionType(POSITION_TYPE_SELL)))
              {     
               double Fibo100Top  = High[BiggestTop(High, 4)];
               double Fibo0Bottom = Low[WhereIsBottom(Low, BiggestTop(High, 4))];
               double Fibo50R     = FiboRetracement(Fibo100Top, Fibo0Bottom, 0.5);
               double Fibo382R    = FiboRetracement(Fibo100Top, Fibo0Bottom, 0.382);
              
               if(IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 4) == "BULLISH TREND LVL 3")
                 {
                  if((Low[1] > Low[2]) && (Open[2] > Fibo50R) && (High[3] > High[4] && High[3] < Fibo100Top))
                    {
                     if(High[1] > High[2])
                       {
                        SLModify(RHigh + (3*TickSize));
                       }
                     else
                       {
                        SLModify(RHigh2 + (3*TickSize));
                       }
                    }
                 }
              }
            else
              {
               if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 4, TickSize) == 33) && (PositionType(POSITION_TYPE_BUY)))
                 {
                  double Fibo100Bottom = Low[LowerBottom(Low, 4)];
                  double Fibo0Top      = High[WhereIsTop(High, LowerBottom(Low, 4))];
                  double Fibo50R       = FiboRetracement(Fibo100Bottom, Fibo0Top, 0.5);
                  double Fibo382R      = FiboRetracement(Fibo100Bottom, Fibo0Top, 0.382);
               
                  if(IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 4) == "BEARISH TREND LVL 3")
                    {
                     if((High[1] < High[2]) && (Open[2] < Fibo50R) && (Low[3] < Low[4] && Low[3] > Fibo100Bottom))
                       {
                        if(Low[1] < Low[2])
                          {
                           SLModify(RLow - (3*TickSize));
                          }
                        else
                          {
                           SLModify(RLow2 - (3*TickSize));
                          }
                       }
                    }
                 }
              }
           }
         
         /*if(PositionSelect(_Symbol))
           {
            if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, PositionCandle + 2, TickSize) == 3) && (PositionType(POSITION_TYPE_SELL)))
              {     
               double Fibo100Top  = High[BiggestTop(High, PositionCandle + 2)];
               double Fibo0Bottom = Low[WhereIsBottom(Low, BiggestTop(High, PositionCandle + 2))];
               double Fibo50R     = FiboRetracement(Fibo100Top, Fibo0Bottom, 0.5);
               double Fibo382R    = FiboRetracement(Fibo100Top, Fibo0Bottom, 0.382);
              
               if((Open[PositionCandle] > Fibo50R) && (High[PositionCandle + 1] > High[PositionCandle + 2] && High[PositionCandle + 1] < Fibo100Top))
                 {
                  double AtualSL = PositionGetDouble(POSITION_SL);
                  double NewSL   = NormalRoundPrice(High[PositionCandle] + (3*TickSize), TickSize);
                  
                  if((Bid <= Fibo382R) && (NewSL < AtualSL))
                    {
                     SLModify(NewSL);
                    }
                 }
              }
            else
              {
               if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, PositionCandle + 2, TickSize) == 33) && (PositionType(POSITION_TYPE_BUY)))
                 {
                  double Fibo100Bottom = Low[LowerBottom(Low, PositionCandle + 2)];
                  double Fibo0Top      = High[WhereIsTop(High, LowerBottom(Low, PositionCandle + 2))];
                  double Fibo50R       = FiboRetracement(Fibo100Bottom, Fibo0Top, 0.5);
                  double Fibo382R      = FiboRetracement(Fibo100Bottom, Fibo0Top, 0.382);
               
                  if((Open[PositionCandle] < Fibo50R) && (Low[PositionCandle + 1] < Low[PositionCandle + 2] && Low[PositionCandle + 1] > Fibo100Bottom))
                    {
                     double AtualSL = PositionGetDouble(POSITION_SL);
                     double NewSL   = NormalRoundPrice(High[PositionCandle] + (3*TickSize), TickSize);
                     
                     if((Ask >= Fibo382R) && (NewSL > AtualSL))
                       {
                        SLModify(NewSL);
                       }
                    }
                 }
              }
           }*/
         
         
              
              
         /*if(ElephantBar(Open, High, Low, Close, 1))
           {
            if((PositionType(POSITION_TYPE_BUY)) && (BullishCandle1) && (CandleAmplitude(Close, Open, 1) > (CandleAmplitude(Close, Open, 2) * 0.7)))
              {
               SLModify(RLow - (TickSize * 3));
              }
            else
              {
               if((PositionType(POSITION_TYPE_SELL)) && (BearishCandle1) && (CandleAmplitude(Close, Open, 1) > (CandleAmplitude(Close, Open, 2) * 0.7)))
                 {
                  SLModify(RHigh + (TickSize * 3));
                 }
              }  
           }*/
         
         /*if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 3) && (!BreakevenCondition(Ask, Bid, High, Low, 1, TickSize, WhatIsPositionCandle(rates, dt_))))
           {
            double CandleMiddle2 = (High[2] - ((High[2] - Low[2]) / 2));
            
            if(!ElephantBar(Open, High, Low, Close, 2))
              {
               if((Doji1 || BullishCandle1) && (((CandleAmplitude(Close, Open, 1) < (CandleAmplitude(Close, Open, 2) * 1.5)) && ((High[1] > High[2]) || (Low[1] < Low[2]))) || ((High[1] > High[2]) && (Close[1] < High[2]))))
                 {
                  SLModify(RLow - (TickSize * 3));
                 }
               else
                 {               
                  if((BearishCandle1) && ((High[1] - Open[1]) > (Close[1] - Low[1])))
                    {
                     SLModify(RLow - (TickSize * 3));
                    }
                  else
                    {
                     if((Close[2] > GrayMA[2]) && (Close[1] < GrayMA[1]))
                       {
                        SLModify(RLow - (TickSize * 3));
                       }
                    }
                 }
              }
           }
         else
           {
            if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 33) && (!BreakevenCondition(Ask, Bid, High, Low, 1, TickSize, WhatIsPositionCandle(rates, dt_))))
              {
               double CandleMiddle2 = (Low[2] + ((High[2] - Low[2]) / 2));

               if(!ElephantBar(Open, High, Low, Close, 2))
                 {
                  if((Doji1 || BearishCandle1) && (((CandleAmplitude(Close, Open, 1) < (CandleAmplitude(Close, Open, 2) * 1.5)) && ((Low[1] < Low[2]) || (High[1] > High[2]))) || ((Low[1] < Low[2]) && (Close[1] > Low[2]))))
                    {
                     SLModify(RHigh + (TickSize * 3));
                    }
                  else
                    {
                     if((BullishCandle1) && ((Open[1] - Low[1]) > (High[1] - Close[1])))
                       {
                        SLModify(RHigh + (TickSize * 3));
                       }
                     else
                       {
                        if((Close[2] < GrayMA[2]) && (Close[1] > GrayMA[1]))
                          {
                           SLModify(RHigh + (TickSize * 3));
                          }
                       }
                    }
                 }  
              }*/
            /*else
              {
               if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 4) && (!BreakevenCondition(Ask, Bid, High, Low, 1, TickSize, WhatIsPositionCandle(rates, dt_))))
                 {
                        
                 }
               else
                 {
                  if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 2, TickSize) == 44) && (!BreakevenCondition(Ask, Bid, High, Low, 1, TickSize, WhatIsPositionCandle(rates, dt_))))
                    {
                           
                    }
                 }
              }
           } */
           
        /* if(IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, 3) == "BULLISH TREND LVL 1")
           {
            if(MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 3, TickSize) == 3)
              {
               if((BullishCandle2) && ((High[2] - Close[2]) > (Open[2] - Low[2])) && (Close[1] < High[2]))
                 {
                  SLModify(RLow - (TickSize*1));
                 }
               else
                 {
                  if(((High[2] - Open[2]) > (Close[2] - Low[2])) && (Close[1] < High[2]))
                    {
                     SLModify(RLow - (TickSize*1));
                    }
                 }
              }
           } 
         else
           {
            if(IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, 3) == "BEARISH TREND LVL 1")
              {
               if(MAReturn(PinkMA, GrayMA, Open, High, Low, Close, 3, TickSize) == 33)
                 {
                  if((BearishCandle2) && ((Close[2] - Low[2]) > (High[2] - Open[2])) && (Close[1] > Low[2]))
                    {
                     SLModify(RHigh + (TickSize*1));
                    }
                  else
                    {
                     if(((Open[2] - Low[2]) > (High[2] - Close[2])) && (Close[1] > Low[2]))
                       {
                        SLModify(RHigh + (TickSize*1));
                       }
                    }
                 }
              }
           } */
           
         /*if((PositionVolume(_Symbol) <= (FullVolume/2)) && (!BreakevenCondition(Ask, Bid, High, Low, 1, TickSize, WhatIsPositionCandle(rates, dt_))))
           {
            for(int i = 0; i < Positions(_Symbol); i++)
              {
               ulong Ticket = PositionGetTicket(i);
               
               if(PositionSelectByTicket(Ticket))
                 {
                  double SLAtualValue = MathAbs(PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_SL));
                   
                  int    CandleIndex  = WhatIsPositionCandle(rates, dt_);
                  
                  if(CandleIndex >= 0)
                    {
                     if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                       {
                        if((PositionGetDouble(POSITION_PRICE_OPEN) - Low[CandleIndex]) < (SLAtualValue))
                          {
                           double NewSL = NormalRoundPrice(Low[CandleIndex], TickSize);
                           SLModify(NewSL - (TickSize*3));
                          }
                       }
                     else
                       {
                        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                          {
                           if((High[CandleIndex] - PositionGetDouble(POSITION_PRICE_OPEN)) < (SLAtualValue))
                             {
                              double NewSL = NormalRoundPrice(High[CandleIndex], TickSize);
                              SLModify(NewSL + (TickSize*3));
                             }
                          }
                       }
                    }
                 }
              }
           }*/
           

         if(PositionSelect(_Symbol))
           {
            double PositionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            
            if((PositionType(POSITION_TYPE_BUY)) && (Low[Bottom] > PositionPrice) && (Bottom < WhatIsPositionCandle(rates, dt_)))
              {
               Breakeven(_Symbol, TickSize);
              }
            else
              {
               if((PositionType(POSITION_TYPE_SELL)) && (High[Top] < PositionPrice) && (Top < WhatIsPositionCandle(rates, dt_)))
                 {
                  Breakeven(_Symbol, TickSize);
                 }
              }
           }
         
         /*int PositionIndex1 = WhatIsPositionCandle(rates, dt_) + 1;
         if(PositionSelect(_Symbol))
           {
            double PositionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            
            if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, PositionIndex1, TickSize) == 3) && (IsBullishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Ask, PositionIndex1) == "BULLISH TREND LVL 1"))
              {
               if((Close[1] < GrayMA[1]) && (Close[1] < PositionPrice))
                 {
                  ClosePositions(Ask, Bid, TickSize);
                 }
              }
            else
              {
               if((MAReturn(PinkMA, GrayMA, Open, High, Low, Close, PositionIndex1, TickSize) == 33) && (IsBearishTrend(MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low, Bid, PositionIndex1) == "BEARISH TREND LVL 1"))
                 {
                  if((Close[1] > GrayMA[1]) && (Close[1] > PositionPrice))
                    {
                     ClosePositions(Ask, Bid, TickSize);
                    }
                 }
              }
           }*/
        }
     }   
   else
     {
      if(Positions(_Symbol) > 0)
        {
         ClosePositions(Ask, Bid, TickSize);
        }
      if(Orders(_Symbol) > 0)
        {
         CancelOrders();
        }
      Comment("TIME OUT!");
     }
  }
  
//+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------+
//--- TIME CONDITION
bool TimeCondition(MqlDateTime &dt_str)
  {
   if((dt_str.hour == BeginHour) && (dt_str.min >= BeginMinut))
     {
      return true;
     }
   else
     {
      if((dt_str.hour > BeginHour) && (dt_str.hour < EndHour))
        {
         return true;
        }
      else
        {
         if((dt_str.hour == EndHour) && (dt_str.min <= EndMinut))
           {
            return true;
           }
        }
     }   
   return false;
  }

//+------------------------------------------------------------------+
//--- IS NEW CANDLE 
bool isNewCandle(MqlRates &Rates[])
  {
   datetime OpenTime = Rates[0].time;
   AtualCandle       = OpenTime;

   if(AtualCandle != NewCandle)
     {
      NewCandle = OpenTime;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//--- POSITION ORDERS
bool PositionOrders(MqlDateTime &dt_str, MqlDateTime &dt_positiontime)
  {
   int PositionTimeMin  = (dt_positiontime.min / Timeframe) * Timeframe;
   int PositionTimeHour = dt_positiontime.hour;
   int TimeMax          = PositionTimeMin + Timeframe;
   
   if(dt_str.hour == PositionTimeHour)
     {
      if((dt_str.min < TimeMax) && (dt_str.min >= PositionTimeMin))
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//--- TREND
//--- Is Bullish Trend?
string IsBullishTrend(const double &MACD_Main[], 
                      const double &MACD_Signal[], 
                      const double &Gray_MA[], 
                      const double &Pink_MA[], 
                      const double &Red_MA[], 
                      const double &White_MA[], 
                      const double &ClosePrice[], 
                      const double &HighPrice[],
                      const double &LowPrice[],
                      const double AskPrice,
                      int          Index)
  {
   if(IsSideTrend(MACD_Main, MACD_Signal, Index) == "NO SIDE TREND")
     {
      bool BullishMACD = MACD_Main[Index] > MACD_Signal[Index];
            
      if(BullishMACD)
        {
         bool PrimaryBullishTrend1   = ((ClosePrice[Index] > White_MA[Index]) && (Pink_MA[Index] > White_MA[Index]));
         bool PrimaryBullishTrend2   = (PrimaryBullishTrend1 && (White_MA[Index - 1] > White_MA[Index]));
         
         bool SecondaryBullishTrend1 = ((Pink_MA[Index - 1] > Pink_MA[Index]) && (ClosePrice[Index] > Pink_MA[Index] || AskPrice > Pink_MA[Index - 1]));
         bool SecondaryBullishTrend2 = (SecondaryBullishTrend1 && (Gray_MA[Index] > Red_MA[Index]));
         
         bool GraphicalBullishTrend  = (GraphicalTrend(HighPrice, LowPrice, Index) == "GRAPHICAL BULLISH TREND");
         
         if(GraphicalBullishTrend && PrimaryBullishTrend2 && SecondaryBullishTrend2)
           {
            return "BULLISH TREND LVL 3";
           }
         else
           {
            if(PrimaryBullishTrend2 && SecondaryBullishTrend2)
              {
               return "BULLISH TREND LVL 2";
              }
            else
              {
               if((PrimaryBullishTrend1 && (SecondaryBullishTrend1 || SecondaryBullishTrend2)) && (!GraphicalBullishTrend && !PrimaryBullishTrend2))
                 {
                  return "BULLISH TREND LVL 1";
                 }
              }
           }        
        }
     }
   return "SIDE TREND";
  }
  
//+------------------------------------------------------------------+  
//--- Is Bearish Trend?
string IsBearishTrend(const double &MACD_Main[], 
                      const double &MACD_Signal[], 
                      const double &Gray_MA[], 
                      const double &Pink_MA[], 
                      const double &Red_MA[], 
                      const double &White_MA[], 
                      const double &ClosePrice[],
                      const double &HighPrice[],
                      const double &LowPrice[], 
                      const double BidPrice,
                      int          Index)
  {
   if(IsSideTrend(MACD_Main, MACD_Signal, Index) == "NO SIDE TREND")
     {
      bool BearishMACD = MACD_Main[Index] < MACD_Signal[Index];
      
      if(BearishMACD)
        {
         bool PrimaryBearishTrend1   = ((ClosePrice[Index] < White_MA[Index]) && (Pink_MA[Index] < White_MA[Index]));
         bool PrimaryBearishTrend2   = (PrimaryBearishTrend1 && (WhiteMA[Index - 1] < White_MA[Index]));
             
         bool SecondaryBearishTrend1 = ((Pink_MA[Index - 1] < Pink_MA[Index]) && (ClosePrice[Index] < Pink_MA[Index] || BidPrice < Pink_MA[Index - 1]));
         bool SecondaryBearishTrend2 = (SecondaryBearishTrend1 && (Gray_MA[Index] < Red_MA[Index]));
         
         bool GraphicalBearishTrend  = (GraphicalTrend(HighPrice, LowPrice, Index) == "GRAPHICAL BEARISH TREND");
            
         if(GraphicalBearishTrend && PrimaryBearishTrend2 && SecondaryBearishTrend2)
           {
            return "BEARISH TREND LVL 3";
           } 
         else
           {
            if(PrimaryBearishTrend2 && SecondaryBearishTrend2)
              {
               return "BEARISH TREND LVL 2";
              }
            else
              {
               if((PrimaryBearishTrend1 && (SecondaryBearishTrend1 || SecondaryBearishTrend2)) && (!GraphicalBearishTrend && !PrimaryBearishTrend2))
                 {
                  return "BEARISH TREND LVL 1";
                 }
              }
           }  
        }
     }
   return "SIDE TREND";
  }  
  
//+------------------------------------------------------------------+  
//--- Is Side Trend?  
string IsSideTrend(const double &MACD_Main[], const double &MACD_Signal[], int Index)
  {
   bool Condition1 = MACD_Main[Index] > 0 && MACD_Signal[Index] > 0;
   bool Condition2 = MACD_Main[Index] < 0 && MACD_Signal[Index] < 0;
   bool Condition3 = (MACD_Main[Index] > MACD_Main[Index + 1]) && (MACD_Signal[Index] > MACD_Signal[Index + 1]);
   bool Condition4 = (MACD_Main[Index] < MACD_Main[Index + 1]) && (MACD_Signal[Index] < MACD_Signal[Index + 1]);
      
   if(Condition1)
     {
      if(MACD_Main[Index] < MACD_Signal[Index])
        {
         return "SIDE TREND 1";
        }
     }
   else
     {
      if(Condition2)
        {
         if(MACD_Main[Index] > MACD_Signal[Index])
           {
            return "SIDE TREND 2";
           } 
        }
      else
        {
         if(Condition3)
           {
            if(MACD_Signal[Index] > 0 && MACD_Main[Index] < 0)
              {
               return "SIDE TREND 3";
              }
           }
         else
           {
            if(Condition4)
              {
               if(MACD_Signal[Index] < 0 && MACD_Main[Index] > 0)
                 {
                  return "SIDE TREND 4"; 
                 }
              }
           }
        }
     }
   return "NO SIDE TREND";
  }

//+------------------------------------------------------------------+
//--- What's the Graphical Trend?
string GraphicalTrend(const double &HighPrice[], const double &LowPrice[], int Index)
  {
   if(AscendingTops(HighPrice, Index+1) || AscendingBottoms(LowPrice, Index+1))
     {
      return "GRAPHICAL BULLISH TREND";
     }
   else
     {
      if(DescendingBottoms(LowPrice, Index+1) || DescendingTops(HighPrice, Index+1))
        {
         return "GRAPHICAL BEARISH TREND";
        }
     }
   return "GRAPHICAL TREND WAS NOT IDENTIFIED";
  }
  
//+------------------------------------------------------------------+
//--- TOPS 
int WhereIsTop(const double &HighPrice[], int Index)
  {
   if(ArraySize(HighPrice) >= 98)
     {
      for(int i = Index; i < 98; i++)
        {
         if((HighPrice[i - 1] <= HighPrice[i]) && (HighPrice[i] > HighPrice[i + 1]))
           {
            return i;
           }
        }
      return 0;  
     }
   Print("ERROR! - HighPrice Array Size is < 98 - WhereIsTop Function.");
   return 0; 
  }
  
//+------------------------------------------------------------------+  
//--- BOTTOM
int WhereIsBottom(const double &LowPrice[], int Index)
  {
   if(ArraySize(LowPrice) >= 98)
     {
      for(int i = Index; i < 98; i++)
        {
         if((LowPrice[i - 1] >= LowPrice[i]) && (LowPrice[i] < LowPrice[i + 1]))
           {
            return i;
           }
        }
      return 0;  
     }
   Print("ERROR! - LowPrice Array Size is < 98 - WhereIsBottom Function.");
   return 0;
  }  
  
 //+------------------------------------------------------------------+ 
//--- Are Tops Ascending?
bool AscendingTops(const double &HighPrice[], int Index)
  {
   for(int i = WhereIsTop(HighPrice, Index) + 1; i <= 100; i++)
     {
      if((HighPrice[i - 1] <= HighPrice[i]) && (HighPrice[i] > HighPrice[i + 1]))
        {
         if(HighPrice[i] < HighPrice[WhereIsTop(HighPrice, Index)])
           { 
            return true;
           }
         return false;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//--- Are Tops Descending?
bool DescendingTops(const double &HighPrice[], int Index)
  {
   for(int i = WhereIsTop(HighPrice, Index) + 1; i <= 100; i++)
     {
      if((HighPrice[i - 1] <= HighPrice[i]) && (HighPrice[i] > HighPrice[i + 1]))
        {
         if(HighPrice[i] > HighPrice[WhereIsTop(HighPrice, Index)])
           {
            return true;
           }
         return false;
        }
     }
   return false;
  }
  
//+------------------------------------------------------------------+
//--- Are Bottoms Ascending? 
bool AscendingBottoms(const double &LowPrice[], int Index)
  {
   for(int i = WhereIsBottom(LowPrice, Index) + 1; i <= 100; i++)
     {
      if((LowPrice[i - 1] >= LowPrice[i]) && (LowPrice[i] < LowPrice[i + 1]))
        {
         if(LowPrice[i] < LowPrice[WhereIsBottom(LowPrice, Index)])
           {
            return true;
           }
         return false;
        }
     }
   return false;
  }  
  
//+------------------------------------------------------------------+  
//--- Are Bottoms Descending?
bool DescendingBottoms(const double &LowPrice[], int Index)
  {
   for(int i = WhereIsBottom(LowPrice, Index) + 1; i <= 100; i++)
     {
      if((LowPrice[i - 1] >= LowPrice[i]) && (LowPrice[i] < LowPrice[i + 1]))
        {
         if(LowPrice[i] > LowPrice[WhereIsBottom(LowPrice, Index)])
           {
            return true;
           }
         return false;
        }
     }
   return false;
  }  

//+------------------------------------------------------------------+  
//--- What Is Biggest Top?
int BiggestTop(const double &HighPrice[], int Index)
  {
   for(int i = WhereIsTop(HighPrice, Index) + 3; i < 100; i++)
     {
      if((HighPrice[i - 1] <= HighPrice[i]) && (HighPrice[i] > HighPrice[i + 1]))
        {
         if(HighPrice[i] > HighPrice[WhereIsTop(HighPrice, Index)])
           {
            for(int j = i+3; i < 100; j++)
              {
               if((HighPrice[j - 1] <= HighPrice[j]) && (HighPrice[j] > HighPrice[j + 1]))
                 {
                  if(HighPrice[j] > HighPrice[i])
                    {
                     for(int k = j+3; i < 100; k++)
                       {
                        if((HighPrice[k - 1] <= HighPrice[k]) && (HighPrice[k] > HighPrice[k + 1]))
                          {
                           if(HighPrice[k] > HighPrice[j])
                             {
                              Print("WARNING! - No More Tops Found - Biggest Top.");
                              return k;
                             }
                          }
                        return j;
                       }
                    }
                  else
                    {
                     return i;
                    }
                 }
              }
           }
         else
           {
            return WhereIsTop(HighPrice, Index);
           } 
        }
     }
   Print("ERROR! - Tops Are Not Found - Biggest Top.");
   return 0;
  }

//+------------------------------------------------------------------+  
//--- What Is Lower Bottom?
int LowerBottom(const double &LowPrice[], int Index)
  {
   for(int i = WhereIsBottom(LowPrice, Index) + 3; i < 100; i++)
     {
      if((LowPrice[i - 1] >= LowPrice[i]) && (LowPrice[i] < LowPrice[i + 1]))
        {
         if(LowPrice[i] < LowPrice[WhereIsBottom(LowPrice, Index)])
           {
            for(int j = i+3; i < 100; j++)
              {
               if((LowPrice[j - 1] >= LowPrice[j]) && (LowPrice[j] < LowPrice[j + 1]))
                 {
                  if(LowPrice[j] < LowPrice[i])
                    {
                     for(int k = j+3; i < 100; k++)
                       {
                        if((LowPrice[k - 1] >= LowPrice[k]) && (LowPrice[k] < LowPrice[k + 1]))
                          {
                           if(LowPrice[k] < LowPrice[j])
                             {
                              Print("WARNING! - No More Bottoms Found - Lower Bottom.");
                              return k;
                             }
                          }
                        return j;
                       }
                    }
                  else
                    {
                     return i;
                    }
                 }
              }
           }
         else
           {
            return WhereIsBottom(LowPrice, Index);
           } 
        }
     }
   Print("ERROR! - Bottoms Are Not Found - Lower Bottom.");
   return 0;
  }
  
//+------------------------------------------------------------------+  
//--- Price Away From Moving Averages
bool MAAwayPrice(const double &GrayMAPrice[], const double &PinkMAPrice[], const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index)
  {
   if((ElephantBar(OpenPrice, HighPrice, LowPrice, ClosePrice, Index + 1)) || (ElephantBar(OpenPrice, HighPrice, LowPrice, ClosePrice, Index + 2)) || (ElephantBar(OpenPrice, HighPrice, LowPrice, ClosePrice, Index)))
     {
      if(ClosePrice[Index] > PinkMAPrice[Index])
        {
         if((LowPrice[Index + 1] > GrayMAPrice[Index + 1]) && (LowPrice[Index + 2] > GrayMAPrice[Index + 2]))
           {
            return true;
           }
        }
      else
        {
         if(ClosePrice[Index] < PinkMAPrice[Index])
           {
            if((HighPrice[Index + 1] < GrayMAPrice[Index + 1]) && (HighPrice[Index + 2] < GrayMAPrice[Index + 2]))
              {
               return true;
              }
           }
        }
     }  
   return false; 
  }

//+------------------------------------------------------------------+
//--- CANDLESTICKS PATTERNS                                          |
//+------------------------------------------------------------------+
//--- CANDLE AMPLITUDE
double CandleAmplitude(const double &ClosePrice[], const double &OpenPrice[], int Index)
  {
   if((NormalizeDouble(MathAbs(ClosePrice[Index] - OpenPrice[Index]), _Digits)) > 0)
     {
      return NormalizeDouble(MathAbs(ClosePrice[Index] - OpenPrice[Index]), _Digits);
     }
   return 0;
  }
  
//+------------------------------------------------------------------+
//--- CANDLE AMPLITUDE AVERAGE 
double CandleAmplitude_AVG(const double &ClosePrice[], const double &OpenPrice[], int Index)   
  {
   if(Index > 0)
     {
      double CandleAmplitude1 = NormalizeDouble(MathAbs(ClosePrice[Index]     - OpenPrice[Index]),     _Digits); 
      double CandleAmplitude2 = NormalizeDouble(MathAbs(ClosePrice[Index + 1] - OpenPrice[Index + 1]), _Digits);
      double CandleAmplitude3 = NormalizeDouble(MathAbs(ClosePrice[Index + 2] - OpenPrice[Index + 2]), _Digits);
      double CandleAmplitude4 = NormalizeDouble(MathAbs(ClosePrice[Index + 3] - OpenPrice[Index + 3]), _Digits);
      double CandleAmplitude5 = NormalizeDouble(MathAbs(ClosePrice[Index + 4] - OpenPrice[Index + 4]), _Digits);
      double CandleAmplitude6 = NormalizeDouble(MathAbs(ClosePrice[Index + 5] - OpenPrice[Index + 5]), _Digits);
         
      double CandleAmplPlus   = NormalizeDouble((CandleAmplitude1 + CandleAmplitude2 + CandleAmplitude3 + CandleAmplitude4 + CandleAmplitude5 + CandleAmplitude6), _Digits);    
      double CandleAmpl_AVG  = NormalizeDouble((CandleAmplPlus / 6), _Digits); 
         
      return CandleAmpl_AVG;
     }
   Print("ERROR! - Candle Amplitude Average Function - Index Must Be Greater Than 0.");
   return 0;
  }           
 
//+------------------------------------------------------------------+   
//--- BULLISH OR BEARISH CANDLE?
int BullishOrBearish(const double &ClosePrice[], const double &OpenPrice[], int Index)
  {
   if(ClosePrice[Index] > OpenPrice[Index])
     {
      return 1;
     }
   else
     {
      if(ClosePrice[Index] < OpenPrice[Index])
        {
         return 2;
        }
     } 
   return 0;
  }

//+------------------------------------------------------------------+      
//--- HAMMERS
string Hammers(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index, const double SymbolTickSize)       
  { 
   bool   BullishCandle    = BullishOrBearish(ClosePrice, OpenPrice, Index) == 1;
   bool   BearishCandle    = BullishOrBearish(ClosePrice, OpenPrice, Index) == 2;
   double Candle_Amplitude = CandleAmplitude(ClosePrice, OpenPrice, Index);
   //--- Tails
   double ClHi = NormalizeDouble(HighPrice[Index]  - ClosePrice[Index], _Digits);
   double OpLo = NormalizeDouble(OpenPrice[Index]  - LowPrice[Index],   _Digits);
   double OpHi = NormalizeDouble(HighPrice[Index]  - OpenPrice[Index],  _Digits);
   double ClLo = NormalizeDouble(ClosePrice[Index] - LowPrice[Index],   _Digits);
   
   double x = Candle_Amplitude * 2.2;
   double y = Candle_Amplitude * 1.6;
   
   bool a = ClHi > (x);
   bool b = ClHi < (y);
   bool c = OpLo > (x);
   bool d = OpLo < (y);
   
   bool e = OpHi > (x);
   bool f = OpHi < (y);
   bool g = ClLo > (x);
   bool h = ClLo < (y);
   
   //--- Hammer
   if((Candle_Amplitude > ((SymbolTickSize * 4) * _Point)) && ((BullishCandle && (b && c)) || (BearishCandle == 2 && (f && g))))
     {
      return "HAMMER";
     }
   else
     { 
      //--- Inverted Hammer
      if((Candle_Amplitude > ((SymbolTickSize * 4) * _Point)) && ((BullishCandle && (a && b)) || (BearishCandle && (e && h))))
        {
         return "INVERTED HAMMER";
        }
     }
   return "FALSE";
  }
    
//+------------------------------------------------------------------+                                               
//--- ELEPHANT BAR (MARUBOZU)   
bool ElephantBar(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index) 
  {
   bool BullishCandle = BullishOrBearish(ClosePrice, OpenPrice, Index) == 1;
   bool BearishCandle = BullishOrBearish(ClosePrice, OpenPrice, Index) == 2;
   
   //--- Tails
   double ClHi = NormalizeDouble(HighPrice[Index]  - ClosePrice[Index], _Digits);
   double OpLo = NormalizeDouble(OpenPrice[Index]  - LowPrice[Index],   _Digits);
   double OpHi = NormalizeDouble(HighPrice[Index]  - OpenPrice[Index],  _Digits);
   double ClLo = NormalizeDouble(ClosePrice[Index] - LowPrice[Index],   _Digits);
  
   double aElephant = ClHi + OpLo; 
   double bElephant = (CandleAmplitude(ClosePrice, OpenPrice, Index) / 3) * 2;
   double cElephant = OpHi + ClLo;
   
   if(CandleAmplitude(ClosePrice, OpenPrice, Index) > (CandleAmplitude_AVG(ClosePrice, OpenPrice, Index + 1) * 1.3))
     {
      if((BullishCandle) && ((aElephant) < (bElephant)))
        {
         return true;
        }
      else
        {
         if((BearishCandle) && ((cElephant) < (bElephant)))
           {
            return true;
           }
        }
     }
   return false;
  }
   
//+------------------------------------------------------------------+                                     
//--- ENGULFING
string Engulfing(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index)   
  {      
   bool BullishCandle  = BullishOrBearish(ClosePrice, OpenPrice, Index)     == 1;
   bool BearishCandle  = BullishOrBearish(ClosePrice, OpenPrice, Index)     == 2;
   bool BullishCandle2 = BullishOrBearish(ClosePrice, OpenPrice, Index + 1) == 1;
   bool BearishCandle2 = BullishOrBearish(ClosePrice, OpenPrice, Index + 1) == 2;
  
   //--- Bullish Engulfing
   if((ElephantBar(OpenPrice, HighPrice, LowPrice, ClosePrice, Index)) && ((BearishCandle2 && BullishCandle) && (ClosePrice[Index] > HighPrice[Index + 1])))
     {
      return "BULLISH ENGULFINNG";
     }
   else
     { 
      //--- Bearish Engulfing
      if((BullishCandle2 && BearishCandle) && (ClosePrice[Index] < LowPrice[Index + 1]))
         {
          return "BEARISH ENGULFING";
         }
     }
   return "FALSE";
  }
   
//+------------------------------------------------------------------+
//--- DOJIS    
string Dojis(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index, const double SymbolTickSize)                                 
  {    
   bool BullishCandle = BullishOrBearish(ClosePrice, OpenPrice, Index) == 1;
   bool BearishCandle = BullishOrBearish(ClosePrice, OpenPrice, Index) == 2;
   
   bool ElephantBar   = ElephantBar(OpenPrice, HighPrice, LowPrice, ClosePrice, Index + 1);
   
   //--- Tails
   double ClHi = NormalizeDouble(HighPrice[Index]  - ClosePrice[Index], _Digits);
   double OpLo = NormalizeDouble(OpenPrice[Index]  - LowPrice[Index],   _Digits);
   double OpHi = NormalizeDouble(HighPrice[Index]  - OpenPrice[Index],  _Digits);
   double ClLo = NormalizeDouble(ClosePrice[Index] - LowPrice[Index],   _Digits);
    
   bool Doji           = false;  
   bool FourPricesDoji = false;
   
   if(CandleAmplitude(ClosePrice, OpenPrice, Index) <= ((SymbolTickSize * 4) * _Point))
     {
      if(ClosePrice[Index] == OpenPrice[Index])
        {
         Doji = true;
        }
     
      //--- Four Prices Doji
      if((Doji) && (HighPrice[Index] == OpenPrice[Index] && LowPrice[Index] == OpenPrice[Index]))
        {
         FourPricesDoji = true;
        }
   
      //--- Long Legs Doji
      if(BullishCandle || Doji)
        {
         if((!ElephantBar) && ((ClHi + OpLo) > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 2)) && (MathAbs(OpHi - ClLo) < ((SymbolTickSize * 4) * _Point)))
           {
            return "LONG LEGS DOJI";
           }
         else
           {
            if((ElephantBar) && ((ClHi + OpLo) > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 3)) && (MathAbs(OpHi - ClLo) < ((SymbolTickSize * 4) * _Point)))
              {
               return "LONG LEGS DOJI";
              }
           }
        }
      else
        {
         if(BearishCandle || Doji)
           {
            if((!ElephantBar) && ((OpHi + ClLo) > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 2)) && (MathAbs(OpHi - ClLo) < ((SymbolTickSize * 4) * _Point)))
              {
               return "LONG LEGS DOJI";
              }
            else
              {
               if((ElephantBar) && ((OpHi + ClLo) > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 3)) && (MathAbs(OpHi - ClLo) < ((SymbolTickSize * 4) * _Point)))
                 {
                  return "LONG LEGS DOJI";
                 }
              }
           }
        }
      
      //--- Dragonfly & Gravestone
      if(Doji || BullishCandle)
        {
         if((!ElephantBar) && (OpLo > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 2)) && (ClHi < (OpLo / 2)))
           {
            return "DRAGONFLY";
           }
         else
           {
            if((!ElephantBar) && (ClHi > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 2)) && (OpLo < (ClHi / 2)))
              {
               return "GRAVESTONE";
              }
            else
              {
               if((ElephantBar) && (OpLo > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 3)) && (ClHi < (OpLo / 2)))
                 {
                  return "DRAGONFLY";
                 }
               else
                 {
                  if((ElephantBar) && (ClHi > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 3)) && (OpLo < (ClHi / 2)))
                    {
                     return "GRAVESTONE";
                    }
                 }
              }
           }
        }
      else
        {
         if(Doji || BearishCandle)
           {
            if((!ElephantBar) && (ClLo > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 2)) && (OpHi < (ClLo / 2)))
              {
               return "DRAGONFLY";
              }
            else
              {
               if((!ElephantBar) && (OpHi > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 2)) && (ClLo < (OpHi / 2)))
                 {
                  return "GRAVESTONE";
                 }
               else
                 {
                  if((ElephantBar) && (ClLo > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 3)) && (OpHi < (ClLo / 2)))
                    {
                     return "DRAGONFLY";
                    }
                  else
                    {
                     if((ElephantBar) && (OpHi > (CandleAmplitude(ClosePrice, OpenPrice, Index + 1) / 3)) && (ClLo < (OpHi / 2)))
                       {
                        return "GRAVESTONE";
                       }
                    }
                 }
              }
           }
        } 
     }    
   return "FALSE";
  }
       
//+------------------------------------------------------------------+
//--- INSIDE BAR       
bool InsideBar(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index)                                                  
  {       
   if((HighPrice[Index] < HighPrice[Index + 1]) && (LowPrice[Index] > LowPrice[Index + 1]))
     {
      return true;
     }
   return false;
  }
   
//+------------------------------------------------------------------+
//--- HARAMIS   
string Haramis(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index)   
  {
   //--- Bullish Harami
   if(CandleAmplitude(ClosePrice, OpenPrice, Index + 1) > (CandleAmplitude_AVG(ClosePrice, OpenPrice, Index + 2) * 1.3))
     {
      if((BullishOrBearish(ClosePrice, OpenPrice, Index + 1) == 2) && (HighPrice[Index] < OpenPrice[Index + 1] && LowPrice[Index] > ClosePrice[Index + 1]))
        {
         return "BULLISH HARAMI";
        }
      else
        {
         //--- Bearish Harami
         if((BullishOrBearish(ClosePrice, OpenPrice, Index + 1) == 1) && (HighPrice[Index] < ClosePrice[Index + 1] && LowPrice[Index] > OpenPrice[Index + 1]))
           {
            return "BEARISH HARAMI";
           }
        }
     } 
   return "FALSE";
  }
     
//+------------------------------------------------------------------+
//--- PIERCING PATTERN & DARK CLOUD     
string PiercingPattern_DarkCloud(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index)  
  {  
   double a = CandleAmplitude(ClosePrice, OpenPrice, Index + 1) * 0.5;
   double b = ClosePrice[Index + 1] + a;
   double c = ClosePrice[Index + 1] - a;
                               
   //--- Piercing Pattern
   if(ElephantBar(OpenPrice, HighPrice, LowPrice, ClosePrice, Index + 1))
     {
      if((BullishOrBearish(ClosePrice, OpenPrice, Index + 1) == 2) && ((HighPrice[Index] < HighPrice[Index + 1]) && (ClosePrice[Index] >= b)))
        {
         return "PIERCING PATTERN";
        }
      else
        { 
         //--- Dark Cloud
         if((BullishOrBearish(ClosePrice, OpenPrice, Index + 1) == 1) && ((LowPrice[Index] > LowPrice[Index + 1]) && (ClosePrice[Index] <= c)))
           {
            return "DARK CLOUD";
           }
        }
     }
   return "FALSE";
  }
   
//+------------------------------------------------------------------+
//--- MORNING & NIGHT STARS
string Morning_Night_Stars(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index)                              
  {
   bool a = CandleAmplitude(ClosePrice, OpenPrice, Index + 2) > (CandleAmplitude_AVG(ClosePrice, OpenPrice, Index + 3) * 1.3);
   bool b = CandleAmplitude(ClosePrice, OpenPrice, Index)     > (CandleAmplitude_AVG(ClosePrice, OpenPrice, Index + 1) * 1.3);
   bool c = CandleAmplitude(ClosePrice, OpenPrice, Index + 1) < CandleAmplitude(ClosePrice, OpenPrice, Index);

   //--- Morning Star
   if(a && b && c)
     {
      if((BullishOrBearish(ClosePrice, OpenPrice, Index + 2) == 2) && (BullishOrBearish(ClosePrice, OpenPrice, Index) == 1))
        {
         if(((HighPrice[Index + 1] < ClosePrice[Index + 2]) && (HighPrice[Index + 1] < OpenPrice[Index])) && ((HighPrice[Index + 1] >= LowPrice[Index + 2]) || (HighPrice[Index + 1] >= LowPrice[Index])))
           {
            return "MORNING STAR";
           }
        }
      else
        {       
         if((BullishOrBearish(ClosePrice, OpenPrice, Index + 2) == 1) && (BullishOrBearish(ClosePrice, OpenPrice, Index) == 2))
           {
            if((((LowPrice[Index + 1] > ClosePrice[Index + 2]) && (LowPrice[Index + 1] > OpenPrice[Index])) && ((LowPrice[Index + 1] <= HighPrice[Index + 2]) || (LowPrice[Index + 1] <= HighPrice[Index]))))
              {
               return "NIGHT STAR";
              }
           }
        }    
     }
   return "FALSE";
  }
   
//+------------------------------------------------------------------+
//--- ABANDONED BABY     
bool AbandonedBaby(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index)   
  {    
   bool a = CandleAmplitude(ClosePrice, OpenPrice, Index + 1) < CandleAmplitude(ClosePrice, OpenPrice, Index);
                                     
   if((a) && (CandleAmplitude(ClosePrice, OpenPrice, Index + 2) > (CandleAmplitude_AVG(ClosePrice, OpenPrice, Index + 3) * 1.3)) && (CandleAmplitude(ClosePrice, OpenPrice, Index) > (CandleAmplitude_AVG(ClosePrice, OpenPrice, Index + 1) * 1.3)))
     {
      if((BullishOrBearish(ClosePrice, OpenPrice, Index + 2) == 1) && (BullishOrBearish(ClosePrice, OpenPrice, Index) == 2))
        {
         if((LowPrice[Index + 1] > HighPrice[Index + 2]) && (LowPrice[Index + 1] > HighPrice[Index]))
           {
            return true;            
           }
        }
      else
        {
         if((BullishOrBearish(ClosePrice, OpenPrice, Index + 2) == 2) && (BullishOrBearish(ClosePrice, OpenPrice, Index) == 1))
           {
            if((HighPrice[Index] < LowPrice[Index + 2]) && (HighPrice[Index + 1] < LowPrice[Index]))
              {
               return true;
              }
           }
        }
     }
   return false;
  }
      
//+------------------------------------------------------------------+
//--- GIFT       
bool Gift(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], int Index) 
  {  
   double CandleAmplitude2 = CandleAmplitude(ClosePrice, OpenPrice, Index + 1);     
   
   //--- Tails
   double ClHi = NormalizeDouble(HighPrice[Index]  - ClosePrice[Index], _Digits);
   double OpLo = NormalizeDouble(OpenPrice[Index]  - LowPrice[Index],   _Digits);
   double OpHi = NormalizeDouble(HighPrice[Index]  - OpenPrice[Index],  _Digits);
   double ClLo = NormalizeDouble(ClosePrice[Index] - LowPrice[Index],   _Digits);  
                                     
   if((CandleAmplitude2) > ((CandleAmplitude_AVG(ClosePrice, OpenPrice, Index + 2) * 1.3)))
     {
      if(CandleAmplitude(ClosePrice, OpenPrice, Index) < (70 * _Point))
        {
         if((BullishOrBearish(ClosePrice, OpenPrice, Index) == 1) && ((ClHi + OpLo) <= (CandleAmplitude2 / 2)))
           {
            return true;
           }
         else
           {
            if((BullishOrBearish(ClosePrice, OpenPrice, Index) == 2) && ((OpHi + ClLo) <= (CandleAmplitude2 / 2)))
              {
               return true;
              }
           }
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//--- MA RETURN
int MAReturn(const double &PinkMAPrice[], const double &GrayMAPrice[], 
             const double &OpenPrice[],   const double &HighPrice[], 
             const double &LowPrice[],    const double &ClosePrice[], 
             int          Index,          const double SymbolTickSize)
  {
   bool   BullishCandle    = BullishOrBearish(ClosePrice, OpenPrice, Index)                     ==    1;
   bool   BearishCandle    = BullishOrBearish(ClosePrice, OpenPrice, Index)                     ==    2;
   bool   BullishCandle2   = BullishOrBearish(ClosePrice, OpenPrice, Index + 1)                 ==    1;
   bool   BearishCandle2   = BullishOrBearish(ClosePrice, OpenPrice, Index + 1)                 ==    2;
   
   bool   Elephant_Bar     = ElephantBar(OpenPrice, HighPrice, LowPrice, ClosePrice, Index)     == true;
   bool   Elephant_Bar2    = ElephantBar(OpenPrice, HighPrice, LowPrice, ClosePrice, Index + 1) == true;
   
   double Amplitude        = CandleAmplitude(ClosePrice, OpenPrice, Index);
   double Amplitude2       = CandleAmplitude(ClosePrice, OpenPrice, Index + 1);
    
   double CandleMiddle     = HighPrice[Index] - (HighPrice[Index] - LowPrice[Index]);  
  
   //--- Tails
   double ClHi  = NormalizeDouble(HighPrice[Index]  - ClosePrice[Index], _Digits);
   double OpLo  = NormalizeDouble(OpenPrice[Index]  - LowPrice[Index],   _Digits);
   double OpHi  = NormalizeDouble(HighPrice[Index]  - OpenPrice[Index],  _Digits);
   double ClLo  = NormalizeDouble(ClosePrice[Index] - LowPrice[Index],   _Digits);
   
   double ClHi2 = NormalizeDouble(HighPrice[Index + 1]  - ClosePrice[Index + 1], _Digits);
   double OpLo2 = NormalizeDouble(OpenPrice[Index + 1]  - LowPrice[Index + 1],   _Digits);
   double OpHi2 = NormalizeDouble(HighPrice[Index + 1]  - OpenPrice[Index + 1],  _Digits);
   double ClLo2 = NormalizeDouble(ClosePrice[Index + 1] - LowPrice[Index + 1],   _Digits);
  
   if((LowPrice[Index + 1] > PinkMAPrice[Index + 1]) && (LowPrice[Index] <= PinkMAPrice[Index]) && (ClosePrice[Index] > PinkMAPrice[Index]))
     {
      if((Hammers(OpenPrice, HighPrice, LowPrice, ClosePrice, Index, SymbolTickSize) == "HAMMER") && (LowPrice[Index] < PinkMAPrice[Index]))
        {
         if(((BullishCandle) && ((PinkMAPrice[Index] - LowPrice[Index])) > (OpenPrice[Index] - PinkMAPrice[Index])))
           {
            return 1;
           }
         else
           {
            if(((BearishCandle) && ((PinkMAPrice[Index] - LowPrice[Index])) > (ClosePrice[Index] - PinkMAPrice[Index])))
              {
               return 1;
              }
           }
        }
      else
        {
         if(Dojis(OpenPrice, HighPrice, LowPrice, ClosePrice, Index, SymbolTickSize) == "DRAGONFLY")
           {
            return 2;
           }
         else
           {
            if(BullishCandle)
              {
               /*if((Elephant_Bar) && (ClosePrice[Index] > HighPrice[Index + 1]))
                 {
                  return 3;
                 }
               else
                 {*/
               /*if(HighPrice[WhereIsTop(HighPrice, Index + 2)] > ClosePrice[Index])
                 {
                  if((OpLo > (Amplitude * 0.3)) && ((MathAbs(OpenPrice[Index] - PinkMAPrice[Index])) <= (OpLo / 2)))
                    {
                     if((OpLo > ClHi) && (HighPrice[Index] < HighPrice[Index + 1]))
                       {
                        return 3;
                       }
                     else
                       {
                        if((OpLo > ClHi) && (ClosePrice[Index] > HighPrice[Index + 1]))
                          {
                           return 3;
                          }
                       }
                    }
                 }*/
                  
                 //}
              }
            else
              {
               /*if(HighPrice[WhereIsTop(HighPrice, Index + 2)] > ClosePrice[Index])
                 {
                  if((ClLo > (Amplitude * 0.5)) && ((ClosePrice[Index] - PinkMAPrice[Index]) <= (ClLo / 2)))
                    {
                     if((ClLo > OpHi) && (HighPrice[Index] < HighPrice[Index + 1]))
                       {
                        return 3;
                       }                                     
                    }
                 }*/
              }
           }
        }
     }
   else
     {
      if(((LowPrice[Index + 2] > PinkMAPrice[Index + 2]) && (LowPrice[Index + 1] <= PinkMAPrice[Index + 1])) && ((ClosePrice[Index] > PinkMAPrice[Index]) && (ClosePrice[Index + 1] > PinkMAPrice[Index + 1])))
        {
         if(BearishCandle2)
           {
            if((Elephant_Bar2) && (ClosePrice[Index] > HighPrice[Index + 1]))
              {
               return 4;
              }
            else
              {
               if(PiercingPattern_DarkCloud(OpenPrice, HighPrice, LowPrice, ClosePrice, Index) == "PIERCING PATTERN")
                 {
                  if(LowPrice[Index] <= CandleMiddle)
                    {
                     return 4;
                    }
                 }
              }
           }
        }
      else
        {
         if((HighPrice[Index + 1] < PinkMAPrice[Index + 1]) && (HighPrice[Index] >= PinkMAPrice[Index]) && (ClosePrice[Index] < PinkMAPrice[Index]))
           {
            if((Hammers(OpenPrice, HighPrice, LowPrice, ClosePrice, Index, SymbolTickSize) == "INVERTED HAMMER") && (HighPrice[Index] > PinkMAPrice[Index]))
              {
               if((BullishCandle) && ((HighPrice[Index] - PinkMAPrice[Index]) > (PinkMAPrice[Index] - ClosePrice[Index])))
                 {
                  return 11;
                 }
               else
                 {
                  if((BearishCandle) && ((HighPrice[Index] - PinkMAPrice[Index]) > (PinkMAPrice[Index] - OpenPrice[Index])))
                    {
                     return 11;
                    }
                 }
              }
            else
              {
               if(Dojis(OpenPrice, HighPrice, LowPrice, ClosePrice, Index, SymbolTickSize) == "GRAVESTONE")
                 {
                  return 22;
                 }
               else
                 {
                  if(BearishCandle)
                    { 
                     /*if((Elephant_Bar) && (ClosePrice[Index] < LowPrice[Index + 1]))
                       {
                        return 33;
                       }
                     else
                       {*/
                     /*if(LowPrice[WhereIsBottom(LowPrice, Index + 2)] < Close[Index])
                       {
                        if((OpHi > (Amplitude * 0.3)) && ((MathAbs(PinkMAPrice[Index] - OpenPrice[Index])) <= (OpHi / 2)))
                          {
                           if((OpHi > ClLo) && (LowPrice[Index] > LowPrice[Index + 1]))
                             {
                              return 33;
                             }
                           else
                             {
                              if((OpHi > ClLo) && (ClosePrice[Index] < LowPrice[Index + 1]))
                                {
                                 return 33;
                                }
                             }
                          }
                       }*/
                        
                       //}
                    }
                  else
                    {
                     /*if(LowPrice[WhereIsBottom(LowPrice, Index + 2)] < Close[Index])
                       {
                        if((ClHi > (Amplitude * 0.5)) && ((PinkMAPrice[Index] - ClosePrice[Index]) <= (ClHi / 2)))
                          {
                           if((ClHi > OpLo) && (LowPrice[Index] > LowPrice[Index + 1]))
                             {
                              return 33;
                             }                   
                          }
                       }*/
                       //}
                    }
                 }
              }
           }
         else
           {
            if(((HighPrice[Index + 2] < PinkMAPrice[Index + 2]) && (HighPrice[Index + 1] >= PinkMAPrice[Index + 1])) && ((ClosePrice[Index] < PinkMAPrice[Index]) && (ClosePrice[Index + 1] < PinkMAPrice[Index + 1])))
              {
               if(BullishCandle2)
                 {
                  if((Elephant_Bar2) && (ClosePrice[Index] < LowPrice[Index + 1]))
                    {
                     return 44;
                    }
                  else
                    {
                     if(PiercingPattern_DarkCloud(OpenPrice, HighPrice, LowPrice, ClosePrice, Index) == "DARK CLOUD")
                       {
                        if(HighPrice[Index] >= CandleMiddle)
                          {
                           return 44;
                          }
                       }
                    }
                 }
              }
           }
        }
     }
   
   if((BullishOrBearish(ClosePrice, OpenPrice, Index) == 1) && (HighPrice[Index] < PinkMAPrice[Index]))
     {
      if(HighPrice[Index - 1] >= PinkMAPrice[Index - 1])
        {
         return 7;
        }
     }
   else
     {
      if((BullishOrBearish(ClosePrice, OpenPrice, Index) == 2) && (LowPrice[Index] > PinkMAPrice[Index]))
        {
         if(LowPrice[Index - 1] <= PinkMAPrice[Index - 1])
           {
            return 8;
           }
        }
      else
        {
         if(BullishOrBearish(ClosePrice, OpenPrice, (Index)) == 0)
           {
            if((HighPrice[Index - 1] >= PinkMAPrice[Index - 1]) && (HighPrice[Index] < PinkMAPrice[Index]))
              {
               return 7;
              }
            else
              {
               if((LowPrice[Index - 1] <= PinkMAPrice[Index - 1]) && (LowPrice[Index] > PinkMAPrice[Index]))
                 {
                  return 8;
                 }
              }
           }
        }
     }
   return 0;
  }
  
//+------------------------------------------------------------------+
//--- TRADING                                                        |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+  
//--- What Is The Position Candle?
int WhatIsPositionCandle(MqlRates &rates_[], MqlDateTime &dt_position)
  {
   int PositionOpenMin  = (dt_position.min  / Timeframe) * Timeframe;
   int PositionOpenHour = dt_position.hour;
   
   for(int i = 0; i <= 100; i++)
     {
      TimeToStruct(rates_[i].time, dt_rates);
                     
      if((dt_rates.min == PositionOpenMin) && (dt_rates.hour == PositionOpenHour))
        {
         return i;        
        }
     }
   return -1;
  }
  
//+------------------------------------------------------------------+
//--- CANCEL PENDING ORDERS
void CancelOrders(const int OrdersToDelete = NULL, const int OrderToBeDelete = NULL)
  {
   if((OrdersToDelete == NULL) && (OrderToBeDelete == NULL))
     {
      for(int i = 0; i < Orders(_Symbol); i++)
        {
         string symbol      = OrderGetString(ORDER_SYMBOL);
         ulong  magic       = OrderGetInteger(ORDER_MAGIC);
         ulong  OrderTicket = OrderGetTicket(i);
      
         if((OrderSelect(OrderTicket)) && (symbol == _Symbol && magic == EAMagicNumber))
           {
            if(trade.OrderDelete(OrderTicket))
              {
               Print("Order Delete - Success. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Order Delete - Fail. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
              }  
           }
        }
     }
   else
     {
      if((OrdersToDelete != NULL) && (OrderToBeDelete == NULL))
        {
         for(int i = 0; i < OrdersToDelete; i++)
           {
            string symbol      = OrderGetString(ORDER_SYMBOL);
            ulong  magic       = OrderGetInteger(ORDER_MAGIC);
            ulong  OrderTicket = OrderGetTicket(i);
      
            if((OrderSelect(OrderTicket)) && (symbol == _Symbol && magic == EAMagicNumber))
              {
               if(trade.OrderDelete(OrderTicket))
                 {
                  Print("Order Delete - Success. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                  }
                else
                 {
                  Print("Order Delete - Fail. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }  
              }    
           }
        }
      else
        {
         if((OrdersToDelete == NULL) && (OrderToBeDelete != NULL))
           {
            for(int i = 0; i <= OrderToBeDelete; i++)
              {
               string symbol      = OrderGetString(ORDER_SYMBOL);
               ulong  magic       = OrderGetInteger(ORDER_MAGIC);
               ulong  OrderTicket = OrderGetTicket(i);
      
               if((OrderSelect(OrderTicket)) && (symbol == _Symbol && magic == EAMagicNumber) && (i == OrderToBeDelete))
                 {
                  if(trade.OrderDelete(OrderTicket))
                    {
                     Print("Order Delete - Success. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                     }
                   else
                    {
                     Print("Order Delete - Fail. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }  
                 }    
              }
           }
        }
     }
  }
  
//+------------------------------------------------------------------+
//--- CLOSE POSITIONS
void ClosePositions(double PriceAsk, double PriceBid, const double SymbolTickSize)
  {
   for(int i = 0; i < Positions(_Symbol); i++)
     {
      //--- Round Prices
      double RPriceAsk  = NormalizeDouble((MathRound(PriceAsk / SymbolTickSize) * SymbolTickSize), _Digits);
      double RPriceBid  = NormalizeDouble((MathRound(PriceBid / SymbolTickSize) * SymbolTickSize), _Digits);

      string symbol = PositionGetSymbol(i);
      ulong  magic  = PositionGetInteger(POSITION_MAGIC);
      
      if(symbol == _Symbol && magic == EAMagicNumber)
        {
         ulong  PositionTicket = PositionGetTicket(i);
         double PositionVolume = PositionGetDouble(POSITION_VOLUME);
         
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            if(trade.Sell(PositionVolume, _Symbol, RPriceBid, 0.00, 0.00, NULL))
              {
               Print("Position Close - Success. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Position Close - Fail. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
              }
           }
         else
           {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               if(trade.Buy(PositionVolume, _Symbol, RPriceAsk, 0.00, 0.00, NULL))
                 {
                  Print("Position Close - Success. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }
               else
                 {
                  Print("Position Close - Fail. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }
              }
           }
         /*if(trade.PositionClose(PositionTicket, Deviation))
           {
            Print("Position Close - Success. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
           }
         else
           {
            Print("Position Close - Fail. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
           }*/
        } 
     }
  }
  
//+------------------------------------------------------------------+
//--- IS THERE ORDER IN THE PRICE?
bool OrderInPrice(const double Price, const int Index = NULL)
  {
   if(Index == NULL)
     {
      for(int i = 0; i < Orders(_Symbol); i++)
        {  
         ulong OrderTicket = OrderGetTicket(i);
      
         if(OrderSelect(OrderTicket))
           {
            if(OrderGetDouble(ORDER_PRICE_OPEN) == Price)
              {
               return true;
              }
            else
              {
               if(i == Orders(_Symbol))
                 {
                  return false;
                 }
              }
           }
        }
     }
   else
     {
      for(int i = 0; i <= Index; i++)
        {  
         ulong OrderTicket = OrderGetTicket(i);
      
         if(OrderSelect(OrderTicket))
           {
            if((i == Index) && (OrderGetDouble(ORDER_PRICE_OPEN) == Price))
              {
               return true;
              }
           }
        }
     }
   return false;
  }
  
//+------------------------------------------------------------------+
//--- POSITION TYPE
bool PositionType(const ENUM_POSITION_TYPE Type)
  {
   if(PositionSelect(_Symbol) && Positions(_Symbol) > 0)
     {
      if(PositionGetInteger(POSITION_TYPE) == Type)
        {
         return true;
        }
      else
        {
         return false;
        }
     }
   return false;
  }
  
//+------------------------------------------------------------------+
//--- ORDER TYPE  
bool OrderType(const ENUM_ORDER_TYPE Type, const string symbol, const int Index = NULL)
  {
   if(Index == NULL)
     {
      for(int i = 0; i < Orders(symbol); i++)
        {
         ulong Ticket = OrderGetTicket(i);
      
         if(OrderSelect(Ticket))
           {
            if(OrderGetInteger(ORDER_TYPE) == Type)
              {
               return true;
              }
           }
        }
     }
   else
     {
      for(int i = 0; i <= Index; i++)
        {
         ulong Ticket = OrderGetTicket(i);
      
         if((i == Index) && (OrderSelect(Ticket)))
           {
            if(OrderGetInteger(ORDER_TYPE) == Type)
              {
               return true;
              }
           }
        }
     }
   
   return false;
  }
    
  
//+------------------------------------------------------------------+
//--- POSITION VOLUME
double PositionVolume(const string symbol)
  { 
   if(PositionSelect(symbol))
     {
      return PositionGetDouble(POSITION_VOLUME);
     }
   return 0.0;
  }
  
//+------------------------------------------------------------------+
//--- POSITION TIME
long PositionTime(const string symbol)
  {
   for(int i = 0; i < Positions(symbol); i++)
     {
      if(PositionSelect(symbol))
        {
         return PositionGetInteger(POSITION_TIME);
        }
     }
   long x = TimeTradeServer();
   return x;
  }  
  
//+------------------------------------------------------------------+
//--- POSITIONS TOTAL
int Positions(const string symbol)
  {
   int a = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     { 
      if(PositionGetSymbol(i) == symbol)
        {
         a += 1;
        } 
        
      if(i == (PositionsTotal() - 1))
        {
         return a;  
        }
     }
   return a;
  }  

//+------------------------------------------------------------------+
//--- ORDERS TOTAL
int Orders(const string symbol)
  {
   int a = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      ulong Ticket = OrderGetTicket(i);
      
      if(OrderSelect(Ticket))
        {
         if(OrderGetString(ORDER_SYMBOL) == symbol)
           {
            a += 1;
           }
        }
      
      if(i == OrdersTotal()-1)
        {
         return a;
        }
     }
   return a;
  }


//+------------------------------------------------------------------+
//--- BREAKEVEN CONDITION
bool BreakevenCondition(const double AskPrice,     const double BidPrice, 
                        const double &HighPrice[], const double &LowPrice[], 
                        const double Fibo,         const double SymbolTickSize,
                        int Index)
  {
   if((ArraySize(HighPrice) >= (Index + 2)) && (ArraySize(LowPrice) >= (Index + 2)) && (Index >= 0))
     {
      double PositionPrOp = PositionGetDouble(POSITION_PRICE_OPEN);
      double PositionSL   = PositionGetDouble(POSITION_SL);
   
      if(PositionType(POSITION_TYPE_BUY))
        {
         bool AllowBreakeven = AskPrice >= (NormalizeDouble(PositionPrOp + ((MathRound(((HighPrice[Index + 1] - LowPrice[Index + 1]) * Fibo) / SymbolTickSize) * SymbolTickSize)), _Digits));
      
         if(AllowBreakeven)
           {
            return true;
           }
        }
      else
        {
         if(PositionType(POSITION_TYPE_SELL))
           {
            bool AllowBreakeven = BidPrice <= (NormalizeDouble(PositionPrOp - ((MathRound(((HighPrice[Index + 1] - LowPrice[Index + 1]) * Fibo) / SymbolTickSize) * SymbolTickSize)), _Digits));
         
            if(AllowBreakeven)
              {
               return true;
              }
           }
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//--- BREAKEVEN
void Breakeven(const string symbol, const double SymbolTickSize)
  {
   for(int i = 0; i < Positions(symbol); i++)
     {
      ulong Magic  = PositionGetInteger(POSITION_MAGIC);
      ulong Ticket = PositionGetTicket(i);
       
      if(Magic == EAMagicNumber)
        {
         bool AllowBreakeven = (PositionGetDouble(POSITION_SL) != (PositionGetDouble(POSITION_PRICE_OPEN) - SymbolTickSize)) && (PositionGetDouble(POSITION_SL) != (PositionGetDouble(POSITION_PRICE_OPEN) + SymbolTickSize));
         
         if(AllowBreakeven && PositionType(POSITION_TYPE_BUY))
           {
            if(trade.PositionModify(Ticket, PositionGetDouble(POSITION_PRICE_OPEN) - SymbolTickSize, PositionGetDouble(POSITION_TP)))
              {
               Print("Breakeven - Success. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Breakeven - Fail. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
              }
           }
         else
           {
            if(AllowBreakeven && PositionType(POSITION_TYPE_SELL))
              {
               if(trade.PositionModify(Ticket, PositionGetDouble(POSITION_PRICE_OPEN) + SymbolTickSize, PositionGetDouble(POSITION_TP)))
                 {
                  Print("Breakeven - Success. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }
               else
                 {
                  Print("Breakeven - Fail. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }
              }
           }
        }
     }
  } 
  
//+------------------------------------------------------------------+
//--- ROUND AND NORMALIZE PRICE
double NormalRoundPrice(const double Price, const double SymbolTickSize)
  {
   double x = NormalizeDouble((MathRound(Price / SymbolTickSize)) * SymbolTickSize, _Digits);
   
   return x;
  }
  
//+------------------------------------------------------------------+
//--- FIBONACCI VALUE
double Fibonacci(const double Value, const double Fibo, const double SymbolTickSize)
  {
   double x = NormalizeDouble((MathRound((Value * Fibo) / SymbolTickSize) * SymbolTickSize), _Digits);
   
   return x;
  }
  
//+------------------------------------------------------------------+  
//--- FIBONNACCI RETRACEMENT
double FiboRetracement(const double Price100, const double Price0, const double RetracementLevel)
  {
   if(Price100 > Price0)
     {
      double x = Price100 - Price0;
      double y = x * RetracementLevel;
      return(Price0 + y);
     }
   else
     {
      if(Price100 < Price0)
        {
         double x = Price0 - Price100;
         double y = x * RetracementLevel;
         return(Price0 - y);
        }
     }
   
   Print("ERROR! - 100% Price Must Be != Than 0% Price - Fibo Retracement.");
   return 0;
  }  
  
//+------------------------------------------------------------------+
//--- STOP LOSS MODIFY
void SLModify(const double SL)
  {
   for(int i = 0; i < Positions(_Symbol); i++)
     {
      string symbol          = PositionGetSymbol(i);
      ulong  magic           = PositionGetInteger(POSITION_MAGIC);
      
      bool   AllowSLModify   = PositionGetDouble(POSITION_SL) != SL;
      double PositionPriceOp = PositionGetDouble(POSITION_PRICE_OPEN);
      
      if(symbol == _Symbol && magic == EAMagicNumber)
        {
         ulong PositionTicket = PositionGetTicket(i);
         
         if(PositionType(POSITION_TYPE_BUY))
           {
            if((AllowSLModify) && (SL < PositionPriceOp))
              {
               if(trade.PositionModify(PositionTicket, SL, PositionGetDouble(POSITION_TP)))
                 {
                  Print("Stop Loss Modify - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }
               else
                 {
                  Print("Stop Loss Modify - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }
              }
           }
         else
           {
            if(PositionType(POSITION_TYPE_SELL))
              {
               if((AllowSLModify) && (SL > PositionPriceOp))
                 {
                  if(trade.PositionModify(PositionTicket, SL, PositionGetDouble(POSITION_TP)))
                    {
                     Print("Stop Loss Modify - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                  else
                    {
                     Print("Stop Loss Modify - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                 }
              }
           }
        }
     }
  }
  
//+------------------------------------------------------------------+
//--- TAKE PROFIT MODIFY
void TPModify(const double TP)
  {
   for(int i = 0; i < Positions(_Symbol); i++)
     {
      string symbol          = PositionGetSymbol(i);
      ulong  magic           = PositionGetInteger(POSITION_MAGIC);
      
      bool   AllowTPModify   = PositionGetDouble(POSITION_TP) != TP;
      double PositionPriceOp = PositionGetDouble(POSITION_PRICE_OPEN);
      
      if(symbol == _Symbol && magic == EAMagicNumber)
        {
         ulong PositionTicket = PositionGetTicket(i);
         
         if(PositionType(POSITION_TYPE_BUY))
           {
            if((AllowTPModify) && (TP > PositionPriceOp))
              {
               if(trade.PositionModify(PositionTicket, PositionGetDouble(POSITION_SL), TP))
                 {
                  Print("Take Profit Modify - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }
               else
                 {
                  Print("Take Profit Modify - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }
              }
           }
         else
           {
            if(PositionType(POSITION_TYPE_SELL))
              {
               if((AllowTPModify) && (TP < PositionPriceOp))
                 {
                  if(trade.PositionModify(PositionTicket, PositionGetDouble(POSITION_SL), TP))
                    {
                     Print("Take Profit Modify - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                  else
                    {
                     Print("Take Profit Modify - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                 }
              }
           }
        }
     }
  }
  
//--- ORDER MODIFY
void OrderModify(const double Price, int Index)
  {
   for(int i = 0; i < Orders(_Symbol); i++)
     { 
      ulong Magic       = OrderGetInteger(ORDER_MAGIC);
      ulong OrderTicket = OrderGetTicket(i);
      
      if(OrderSelect(OrderTicket) && i == Index)
        {
         bool AllowOrderModify = OrderGetDouble(ORDER_PRICE_OPEN) != Price;
      
         if(Magic == EAMagicNumber && AllowOrderModify)
           {
            if(trade.OrderModify(OrderTicket, Price, OrderGetDouble(ORDER_SL), OrderGetDouble(ORDER_TP), ORDER_TIME_DAY, 0, 0.000))
              {
               Print("Order Modify - SUCCESS. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Order Modify - FAIL. Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
              }
           }
        }
     }
  }
