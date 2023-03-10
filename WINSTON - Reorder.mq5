//+------------------------------------------------------------------+
//|                                            WINSTON - Reorder.mq5 |
//|                                            Copyright 2022, FABIO |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, FABIO"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade trade;

#include <WINSTON - Library.mqh>
ParamethersControl Dis_Allow;

//+------------------------------------------------------------------+
//--- ENUMERATORS                                                    |------------------------------------------------------------------+
//+------------------------------------------------------------------+
enum ENUM_ACCOUNT_NAME
  {
   FABIO_ORIONE_DA_SILVA_NETTO = 0, //FABIO ORIONE DA SILVA NETTO
   MARIA_CAROLINA_DA_SILVA     = 1, //MARIA CAROLINA DA SILVA
   Tester                      = 2  //TESTER
  };
  
enum ENUM_ACCOUNT_NUMBER
  {
   Login_1601657 = 0 //1601657
  };
  
enum ENUM_TRADE_MODE
  {
   Day_Trade,  //DAY TRADE
   Swing_Trade //SWING TRADE
  };



//+------------------------------------------------------------------+
//--- INPUTS                                                         |------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//--- Account Info
input group "ACCOUNT INFO"

sinput ENUM_ACCOUNT_NAME   AccountName   = Tester;        //Account Name
sinput ENUM_ACCOUNT_NUMBER AccountNumber = Login_1601657; //Account Number

//+------------------------------------------------------------------+
//--- Volume
input group  "VOLUME" 

sinput double FullVolume    = 6.0; //Full Volume
sinput double HalfVolume    = 3.0; //Light Volume
sinput double PartialVolume = 2.0; //Parcial Volume

//+------------------------------------------------------------------+
//--- Trend
input group "TREND"

input bool AllowMACDTrend = true; //Allow MACD on Trend
input bool AllowTrendLVL1 = true; //Allow Trend LVL 1
input bool AllowTrendLVL2 = true; //Allow Trend LVL 2
input bool AllowTrendLVL3 = true; //Allow Trend LVL 3
input bool AllowSideTrend = true; //Allow Side Trend

//+------------------------------------------------------------------+
//--- MA Return
input group "MA RETURN"

input bool AllowMARETURN     = true; //Allow MA Return
input bool AllowMAReturn_1   = true; //Allow MA Return 1
input bool AllowMAReturn_11  = true; //Allow MA Return 11
input bool AllowMAReturn_2   = true; //Allow MA Return 2
input bool AllowMAReturn_22  = true; //Allow MA Return 22
input bool AllowMAReturn_3   = true; //Allow MA Return 3
input bool AllowMAReturn_33  = true; //Allow MA Return 33
input bool AllowMAReturn_301 = true; //Allow MA Return 301
input bool AllowMAReturn_331 = true; //Allow MA Return 331
input bool AllowMAReturn_302 = true; //Allow MA Return 302
input bool AllowMAReturn_332 = true; //Allow MA Return 332
input bool AllowMAReturn_303 = true; //Allow MA Return 303
input bool AllowMAReturn_333 = true; //Allow MA Return 333

//+------------------------------------------------------------------+
//--- CANDLESTICKS
input group "CANDLESTICKS"

input bool AllowBlendedCandle   = true; //Allow Blended Candles

input bool AllowHammer          = true; //Allow Hammer
input bool AllowInvertedHammer  = true; //Allow Inverted Hammer
input bool AllowStandardDoji    = true; //Allow Standard Doji
input bool AllowDragonfly       = true; //Allow Dragonfly
input bool AllowGravestone      = true; //Allow Gravestone
input bool AllowLongLegsDoji    = true; //Allow Long Legs Doji
input bool AllowBullElephantBar = true; //Allow Bullish Elephant Bar
input bool AllowBearElephantBar = true; //Allow Bearish Elephant Bar
input bool AllowBullGift        = true; //Allow Bullsih Gift
input bool AllowBearGift        = true; //Allow Bearish Gift 

//+------------------------------------------------------------------+
//--- SUPPORTS & RESISTANCES
input group "SUPPORTS & RESISTANCES"

sinput double Price1 = 0.0; //Price 1
sinput double Price2 = 0.0; //Price 2
sinput double Price3 = 0.0; //Price 3
sinput double Price4 = 0.0; //Price 4

//+------------------------------------------------------------------+
//--- Times
input group "TIMES"

input ENUM_TIMEFRAMES Timeframe  = PERIOD_M5; //Timeframe
input int             StartHour  =         9; //Begin Hour
input int             StartMinut =        10; //Begin Minut
input int             EndHour    =        17; //End Hour - To Close Positions and Orders (DT Mode Active)
input int             EndMinut   =        30; //End Minut - To Close Positions and Orders (DT Mode Active)
input int             EndHour_2  =        17; //End Hour - To Not Open Positions
input int             EndMinut_2 =         1; //End Minut - To Not Open Positions

//+------------------------------------------------------------------+
//--- Moving Averages
input group "MOVING AVERAGES"

input int                GrayMAMPeriod       =           9; //Gray MA Period     
input int                PinkMAMPeriod       =          15; //Pink MA Period
input int                RedMAMPeriod        =          33; //Red MA Period
input int                WhiteMAPeriod       =         240; //White MA Period
input ENUM_MA_METHOD     GrayMAMethod        =    MODE_EMA; //Gray MA Method
input ENUM_MA_METHOD     PinkMAMethod        =    MODE_EMA; //Pink MA Method
input ENUM_MA_METHOD     RedMAMethod         =    MODE_SMA; //Red MA Method
input ENUM_MA_METHOD     WhiteMAMethod       =    MODE_SMA; //White MA Method
input ENUM_APPLIED_PRICE GrayMAAppliedPrice  = PRICE_CLOSE; //Gray MA Applied Price
input ENUM_APPLIED_PRICE PinkMAAppliedPrice  = PRICE_CLOSE; //Pink MA Applied Price
input ENUM_APPLIED_PRICE RedMAAppliedPrice   = PRICE_CLOSE; //Red MA Applied Price
input ENUM_APPLIED_PRICE WhiteMAAppliedPrice = PRICE_CLOSE; //White MA Applied Price

//+------------------------------------------------------------------+
//--- MACD
input group "MACD"

input int                MACDFastEMA      =            17; //MACD Fast EMA
input int                MACDSlowEMA      =           100; //MACD Slow EMA
input int                MACDSignalP      =             9; //MACD Signal
input ENUM_APPLIED_PRICE MACDAppliedPrice = PRICE_TYPICAL; //MACD Applied Price

//+------------------------------------------------------------------+
//--- Trading
input group "TRADING"

input ENUM_TRADE_MODE         TradeMode        =            Day_Trade; //Trade Mode
input bool                    AllowBREAKEVEN   =                 true; //Allow Breakeven
input bool                    AllowTRAILING    =                 true; //Allow Trailing Stop
input ulong                   EAMagicNumber    =               314159; //EA Magic Number
input ENUM_ORDER_TYPE_FILLING OrderTypeFilling = ORDER_FILLING_RETURN; //Order Type Filling
input ulong                   OrderDeviation   =                   15; //Order Deviation - Points
input bool                    AutoTrading      =                 true; //Auto Trading



//+------------------------------------------------------------------+
//--- GLOBAL VARIABLES                                               |------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//--- PRICES - Common 
MqlRates rates[]; //Struct to Rates Values
double Open[];    //Open Prices
double High[];    //High Prices
double Low[];     //Low Prices
double Close[];   //Close Prices
double Ask;       //Ask Price
double Bid;       //Bid Price

//+------------------------------------------------------------------+
//--- TICK SIZE
double TickSize; //Symbol Tick Size

//+------------------------------------------------------------------+
//--- TIMES
MqlDateTime dt;       //Struct to Time Current
MqlDateTime dt_;      //Struct to Position Open Time 
MqlDateTime dt_rates; //Struct to Rates Time

//+------------------------------------------------------------------+
//--- MOVING AVERAGES
double GrayMA[];      //Gray MA Prices
double PinkMA[];      //Pink MA Prices
double RedMA[];       //Red MA Prices
double WhiteMA[];     //White MA Prices
int    GrayMAHandle;  //Gray MA Handle
int    PinkMAHandle;  //Pink MA Handle
int    RedMAHandle;   //Red MA Handle
int    WhiteMAHandle; //White MA Handle

//+------------------------------------------------------------------+
//--- MACD
double MACDMain[];   //MACD Main
double MACDSignal[]; //MACD Signal
int    MACDHandle;   //MACD Handle

//+------------------------------------------------------------------+
//--- TREND
bool BullishTrendLVL1[]; //Array to Indicate Trend
bool BullishTrendLVL2[]; //Array to Indicate Trend
bool BullishTrendLVL3[]; //Array to Indicate Trend

bool BearishTrendLVL1[]; //Array to Indicate Trend
bool BearishTrendLVL2[]; //Array to Indicate Trend
bool BearishTrendLVL3[]; //Array to Indicate Trend

//+------------------------------------------------------------------+
//--- TOPS & BOTTOMS
double LastTop;    //Last Top Price
double LastBottom; //Last Bottom Price

//+------------------------------------------------------------------+
//--- MA RETURN
bool MAReturn_1[];   //Array to MA Return
bool MAReturn_11[];  //Array to MA Return
bool MAReturn_2[];   //Array to MA Return
bool MAReturn_22[];  //Array to MA Return
bool MAReturn_3[];   //Array to MA Return
bool MAReturn_33[];  //Array to MA Return
bool MAReturn_301[]; //Array to MA Return
bool MAReturn_331[]; //Array to MA Return

//+------------------------------------------------------------------+
//--- FIBONACCI
double Fibo50P;   //Fibo 50% Projection
double Fibo618P;  //Fibo 61,8% Projection
double Fibo100P;  //Fibo 100% Projection
double Fibo1618P; //Fibo 161,8% Projection

double Fibo382R;  //Fibo 38,2% Retraction
double Fibo50R;   //Fibo 50% Retraction
double Fibo618R;  //Fibo 61,8% Retraction
double Fibo100R;  //Fibo 100% Retraction
double Fibo1618R; //Fibo 161,8% Retraction


//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
  {
   //+------------------------------------------------------------------+
   //--- SET HANDLE VALUES
   GrayMAHandle  = iMA(  _Symbol, Timeframe, GrayMAMPeriod, 0, GrayMAMethod,  GrayMAAppliedPrice);
   PinkMAHandle  = iMA(  _Symbol, Timeframe, PinkMAMPeriod, 0, PinkMAMethod,  PinkMAAppliedPrice);
   RedMAHandle   = iMA(  _Symbol, Timeframe, RedMAMPeriod,  0, RedMAMethod,   RedMAAppliedPrice);
   WhiteMAHandle = iMA(  _Symbol, Timeframe, WhiteMAPeriod, 0, WhiteMAMethod, WhiteMAAppliedPrice);
   MACDHandle    = iMACD(_Symbol, Timeframe, MACDFastEMA, MACDSlowEMA, MACDSignalP, MACDAppliedPrice);
  
   //--- Handlers Errors
   if(InvalidHandle(GrayMAHandle,  "Gray MA Handle" ) ||
      InvalidHandle(PinkMAHandle,  "Pink MA Handle" ) ||
      InvalidHandle(RedMAHandle,   "Red MA Handle"  ) ||
      InvalidHandle(WhiteMAHandle, "White MA Handle") ||
      InvalidHandle(MACDHandle,    "MACD MA Handle" )   )
     {
      return(INIT_FAILED);
     }

   
   //+------------------------------------------------------------------+
   //--- ARRAY SET AS SERIES
   if(ArrayIsNotSeries(rates,      "rates"     ) ||
      ArrayIsNotSeries(Open,       "Open"      ) ||
      ArrayIsNotSeries(High,       "High"      ) ||
      ArrayIsNotSeries(Low,        "Low"       ) ||
      ArrayIsNotSeries(Close,      "Close"     ) ||
      ArrayIsNotSeries(GrayMA,     "GrayMA"    ) ||
      ArrayIsNotSeries(PinkMA,     "PinkMA"    ) ||
      ArrayIsNotSeries(RedMA,      "RedMA"     ) ||
      ArrayIsNotSeries(WhiteMA,    "WhiteMA"   ) ||
      ArrayIsNotSeries(MACDMain,   "MACDMain"  ) ||
      ArrayIsNotSeries(MACDSignal, "MACDSignal")   )
     {
      return(INIT_FAILED);
     }

   //+------------------------------------------------------------------+
   //--- ACCOUNT VERIFY
   switch(AccountName)
     {
      case 0 : if(AccountInfoString(ACCOUNT_NAME) != "FABIO ORIONE DA SILVA NETTO") {return(INIT_FAILED);} break;
      case 1 : if(AccountInfoString(ACCOUNT_NAME) != "MARIA CAROLINA DA SILVA")     {return(INIT_FAILED);} break;  
      case 2 : if(AccountInfoString(ACCOUNT_NAME) != "Tester")                      {return(INIT_FAILED);} break; 
     }
   switch(AccountNumber)
     {
      case 0 : if(AccountInfoInteger(ACCOUNT_LOGIN) != 1601657) {return(INIT_FAILED);} break;
     }
   
   //+------------------------------------------------------------------+
   //--- INPUT ERRORS
   if(StartHour > EndHour)
     {
      Print("ERROR! 'Begin Hour' is Greater than 'End Hour'. ");
      return(INIT_FAILED);
     }
   if(EAMagicNumber != 314159)
     {
      Print("ERROR! 'EA Magic Number' Must Be Greater than Zero. ");
      return(INIT_FAILED);
     }
   if(PartialVolume != (FullVolume/3))
     {
      Print("ERROR! 'Partial Volume' Must Be 1/3 of 'Full Volume'. ");
      return(INIT_FAILED);
     }
   if(HalfVolume != (FullVolume/2))
     { 
      Print("ERROR! 'Half Volume' Must Be a Half 'Full Volume'. ");
      return(INIT_FAILED);
     }


   //+------------------------------------------------------------------+
   //--- OBJECTS
   trade.SetExpertMagicNumber(EAMagicNumber);
   trade.SetTypeFilling(OrderTypeFilling);
   trade.SetDeviationInPoints(OrderDeviation);
   
  
   Dis_Allow.MACDTrend       = AllowMACDTrend; 
   Dis_Allow.TrendLVL1       = AllowTrendLVL1;
   Dis_Allow.TrendLVL2       = AllowTrendLVL2;
   Dis_Allow.TrendLVL3       = AllowTrendLVL3;
   Dis_Allow.SideTrend       = AllowSideTrend;
  
   Dis_Allow.MARETURN        = AllowMARETURN;     
   Dis_Allow.MAReturn_1      = AllowMAReturn_1;   
   Dis_Allow.MAReturn_11     = AllowMAReturn_11; 
   Dis_Allow.MAReturn_2      = AllowMAReturn_2;  
   Dis_Allow.MAReturn_22     = AllowMAReturn_22; 
   Dis_Allow.MAReturn_3      = AllowMAReturn_3;   
   Dis_Allow.MAReturn_33     = AllowMAReturn_33;  
   Dis_Allow.MAReturn_301    = AllowMAReturn_301;
   Dis_Allow.MAReturn_331    = AllowMAReturn_331;
   Dis_Allow.MAReturn_302    = AllowMAReturn_302;
   Dis_Allow.MAReturn_332    = AllowMAReturn_332; 
   Dis_Allow.MAReturn_303    = AllowMAReturn_303; 
   Dis_Allow.MAReturn_333    = AllowMAReturn_333;
   
   Dis_Allow.BlendedCandle   = AllowBlendedCandle;  
   Dis_Allow.Hammer          = AllowHammer;         
   Dis_Allow.InvertedHammer  = AllowHammer;  
   Dis_Allow.StandardDoji    = AllowStandardDoji;   
   Dis_Allow.Dragonfly       = AllowDragonfly;       
   Dis_Allow.Gravestone      = AllowGravestone;      
   Dis_Allow.LongLegsDoji    = AllowLongLegsDoji;   
   Dis_Allow.BullElephantBar = AllowBullElephantBar; 
   Dis_Allow.BearElephantBar = AllowBearElephantBar; 
   Dis_Allow.BullGift        = AllowBullGift;        
   Dis_Allow.BearGift        = AllowBearGift;
   //+------------------------------------------------------------------+

   Print("EA INITIALIZED.");
   return(INIT_SUCCEEDED);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+  
  
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
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
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnTick()
  {
   Comment("");
   
   //+------------------------------------------------------------------+
   TimeToStruct(TimeTradeServer(), dt);
   TimeToStruct(PositionTime(), dt_);

   CopyRates(_Symbol, Timeframe, 0, 200, rates);
   CopyOpen (_Symbol, Timeframe, 0, 200, Open );
   CopyHigh (_Symbol, Timeframe, 0, 200, High );
   CopyLow  (_Symbol, Timeframe, 0, 200, Low  );
   CopyClose(_Symbol, Timeframe, 0, 200, Close);
   
   Ask      = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Bid      = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   TickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   CopyBuffer(GrayMAHandle,  0, 0, 100, GrayMA    );
   CopyBuffer(PinkMAHandle,  0, 0, 100, PinkMA    );
   CopyBuffer(RedMAHandle,   0, 0, 100, RedMA     );
   CopyBuffer(WhiteMAHandle, 0, 0, 100, WhiteMA   );
   CopyBuffer(MACDHandle,    0, 0, 100, MACDMain  );
   CopyBuffer(MACDHandle,    1, 0, 100, MACDSignal);
   
   //+------------------------------------------------------------------+
   
   
   
   //+------------------------------------------------------------------+
//-//--- TRADING LOGIC/INFORMATION                                      |------------------------------------------------------------------+
   //+------------------------------------------------------------------+
   //+--- TRENDS -----------------------------------------------------------------------------------------------------------------------+
   //+--- TREND --------------------------------------------------------+
   CopyTrend(BullishTrendLVL1, Dis_Allow, Bullish_LVL1, AllowMACDTrend, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   CopyTrend(BullishTrendLVL2, Dis_Allow, Bullish_LVL2, AllowMACDTrend, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   CopyTrend(BullishTrendLVL3, Dis_Allow, Bullish_LVL3, AllowMACDTrend, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   
   CopyTrend(BearishTrendLVL1, Dis_Allow, Bearish_LVL1, AllowMACDTrend, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   CopyTrend(BearishTrendLVL2, Dis_Allow, Bearish_LVL2, AllowMACDTrend, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   CopyTrend(BearishTrendLVL3, Dis_Allow, Bearish_LVL3, AllowMACDTrend, MACDMain, MACDSignal, GrayMA, PinkMA, RedMA, WhiteMA, Close, High, Low);
   
   //+--- TOPS & BOTTOMS -----------------------------------------------+
   LastTop    = High[TopIndex(High)];
   LastBottom = Low[BottomIndex(Low)];
   
   //+--- MA RETURN ----------------------------------------------------+
   CopyMAReturn(MAReturn_1,   Type_1,   PinkMA, Open, High, Low, Close, TickSize, Dis_Allow, 1, 3);
   CopyMAReturn(MAReturn_11,  Type_11,  PinkMA, Open, High, Low, Close, TickSize, Dis_Allow, 1, 3);
   CopyMAReturn(MAReturn_2,   Type_2,   PinkMA, Open, High, Low, Close, TickSize, Dis_Allow, 1, 3);
   CopyMAReturn(MAReturn_22,  Type_22,  PinkMA, Open, High, Low, Close, TickSize, Dis_Allow, 1, 3);
   CopyMAReturn(MAReturn_3,   Type_3,   PinkMA, Open, High, Low, Close, TickSize, Dis_Allow, 1, 3);
   CopyMAReturn(MAReturn_33,  Type_33,  PinkMA, Open, High, Low, Close, TickSize, Dis_Allow, 1, 3);
   CopyMAReturn(MAReturn_301, Type_301, PinkMA, Open, High, Low, Close, TickSize, Dis_Allow, 1, 3);
   CopyMAReturn(MAReturn_331, Type_331, PinkMA, Open, High, Low, Close, TickSize, Dis_Allow, 1, 3);

   //+---  --------------------------------------------------------+
   
   //+--- REVERSALS --------------------------------------------------------------------------------------------------------------------+
   
   
   //+--- RANGES -----------------------------------------------------------------------------------------------------------------------+
     
     
     
   if(TimeCondition(dt, StartHour, StartMinut, EndHour_2, EndMinut_2))
     {
      bool BullishTrend = BullishTrendLVL1[0] || BullishTrendLVL2[0] || BullishTrendLVL3[0];
      bool BearishTrend = BearishTrendLVL1[0] || BearishTrendLVL2[0] || BearishTrendLVL3[0];
      
      
      //+------------------------------------------------------------------+
//----//--- NOT POSITIONED                                                 |------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      if(Positions() == 0)
        {
         //+--- CANCELING ORDERS --------------------------------------------------------------------------------------------------------------+
         if(Orders() > 0)
           {
            for(int i = 0; i < Orders(_Symbol, Highest_Index); i++)
              {
               ulong OrderTicket = OrderGetTicket(i);
               
               if(OrderSelect(OrderTicket))
                 {
                  string OrderSymbol = OrderGetString(ORDER_SYMBOL);
                  
                  if(OrderSymbol == _Symbol)
                    {
                    //+---------------------
                     string Order_Comment    = OrderGetString(ORDER_COMMENT);
                     string OrderTypeComment = StringSubstr(Order_Comment, 0, 1);
                     string OperationComment = Order_Comment;
                     int    OBComm           = StringReplace(OperationComment, "OB.", "O.");
                     if(OBComm == 0) {StringReplace(OperationComment, "OS.", "O.");}
                     int    Order_Candle     = OrderCandle(rates, Timeframe, i);
                     double Order_Price      = OrderGetDouble(ORDER_PRICE_OPEN);
                     double Candle_Middle2   = Low[2] + ((High[2] - Low[2]) / 2);    
                     
                         
                     //+---------------------
                     if(OrderTypeComment == "O")
                       {
                        if((OperationComment == "O. T,3 MAR. 3") || (OperationComment == "O. T,2 MAR. 3") || (OperationComment == "O. T,1 MAR. 3"))
                          {
                           if(Order_Candle < 2)
                             {
                              if(Order_Candle == 0)
                                {
                                 if((!OrderInPrice(High[1] + (2*TickSize), _Symbol, i)) || 
                                    (!OrderType(ORDER_TYPE_BUY,            _Symbol, i)  && 
                                     !OrderType(ORDER_TYPE_BUY_LIMIT,      _Symbol, i)  && 
                                     !OrderType(ORDER_TYPE_BUY_STOP,       _Symbol, i))   )
                                   {
                                    CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                   }
                                }
                              else if(Order_Candle == 1)
                                {
                                 if((Low[1] > PinkMA[1]) && (Close[1] > Candle_Middle2))
                                   {
                                    if((!OrderInPrice(High[2] + (2*TickSize), _Symbol, i)) || 
                                       (!OrderType(ORDER_TYPE_BUY,            _Symbol, i)  && 
                                        !OrderType(ORDER_TYPE_BUY_LIMIT,      _Symbol, i)  && 
                                        !OrderType(ORDER_TYPE_BUY_STOP,       _Symbol, i))   )
                                      {
                                       CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                      }
                                   }
                                 else
                                   {
                                    CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                   }
                                }
                             }
                           else
                             {
                              CancelOrders(EAMagicNumber, -1, i, _Symbol);
                             }
                          }
                        //+---------------------
                        else
                          {
                           if((OperationComment == "O. T'3 MAR. 33") || (OperationComment == "O. T'2 MAR. 33") || (OperationComment == "O. T'1 MAR. 33"))
                             {
                              if(Order_Candle < 2)
                                {
                                 if(Order_Candle == 0)
                                   {
                                    if((!OrderInPrice(Low[1] - (2*TickSize), _Symbol, i)) || 
                                       (!OrderType(ORDER_TYPE_SELL,          _Symbol, i)  && 
                                        !OrderType(ORDER_TYPE_SELL_LIMIT,    _Symbol, i)  && 
                                        !OrderType(ORDER_TYPE_SELL_STOP,     _Symbol, i))   )
                                      {
                                       CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                      }
                                   }
                                 else if(Order_Candle == 1)
                                   {
                                    if((High[1] < PinkMA[1]) && (Close[1] < Candle_Middle2))
                                      {
                                       if((!OrderInPrice(Low[2] - (2*TickSize), _Symbol, i)) || 
                                          (!OrderType(ORDER_TYPE_SELL,          _Symbol, i)  && 
                                           !OrderType(ORDER_TYPE_SELL_LIMIT,    _Symbol, i)  && 
                                           !OrderType(ORDER_TYPE_SELL_STOP,     _Symbol, i))   )
                                         {
                                          CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                         }
                                      }
                                    else
                                      {
                                       CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                      }
                                   }
                                }
                              else
                                {
                                 CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                }
                             }
                           //+---------------------
                           else
                             {
                              if((OperationComment == "O. T,3 MAR. 301") || (OperationComment == "O. T,2 MAR. 301") || (OperationComment == "O. T,1 MAR. 301"))
                                {
                                 if(Order_Candle < 1)
                                   {
                                    if(Order_Candle == 0)
                                      {
                                       if((!OrderInPrice(High[1] + (2*TickSize), _Symbol, i)) || 
                                          (!OrderType(ORDER_TYPE_BUY,            _Symbol, i)  && 
                                           !OrderType(ORDER_TYPE_BUY_LIMIT,      _Symbol, i)  && 
                                           !OrderType(ORDER_TYPE_BUY_STOP,       _Symbol, i))   )
                                         {
                                          CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                         }
                                      }
                                   }
                                 else
                                   {
                                    CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                   }
                                }
                              //+---------------------
                              else
                                {
                                 if((OperationComment == "O. T'3 MAR. 331") || (OperationComment == "O. T'2 MAR. 331") || (OperationComment == "O. T'1 MAR. 331"))
                                   {
                                    if(Order_Candle < 1)
                                      {
                                       if(Order_Candle == 0)
                                         {
                                          if((!OrderInPrice(Low[1] - (2*TickSize), _Symbol, i)) || 
                                             (!OrderType(ORDER_TYPE_SELL,          _Symbol, i)  && 
                                              !OrderType(ORDER_TYPE_SELL_LIMIT,    _Symbol, i)  && 
                                              !OrderType(ORDER_TYPE_SELL_STOP,     _Symbol, i))   )
                                            {
                                             CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                            }
                                         }
                                      }
                                    else
                                      {
                                       CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                      }
                                   }
                                 //+---------------------
                                 else
                                   {
                                    if((OperationComment == "O. T,3 MAR. 1") || (OperationComment == "O. T,2 MAR. 1") || (OperationComment == "O. T,1 MAR. 1"))
                                      {
                                       if(Order_Candle < 1)
                                         {
                                          if(Order_Candle == 0)
                                            {
                                             if((!OrderInPrice(High[1] + (2*TickSize), _Symbol, i)) || 
                                                (!OrderType(ORDER_TYPE_BUY,            _Symbol, i)  && 
                                                 !OrderType(ORDER_TYPE_BUY_LIMIT,      _Symbol, i)  && 
                                                 !OrderType(ORDER_TYPE_BUY_STOP,       _Symbol, i))   )
                                               {
                                                CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                               }
                                            }
                                         }
                                       else
                                         {
                                          CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                         }
                                      }
                                    //+---------------------
                                    else
                                      {
                                       if((OperationComment == "O. T'3 MAR. 11") || (OperationComment == "O. T'2 MAR. 11") || (OperationComment == "O. T'1 MAR. 11"))
                                         {
                                          if(Order_Candle < 1)
                                            {
                                             if(Order_Candle == 0)
                                               {
                                                if((!OrderInPrice(Low[1] - (2*TickSize), _Symbol, i)) || 
                                                   (!OrderType(ORDER_TYPE_SELL,          _Symbol, i)  && 
                                                    !OrderType(ORDER_TYPE_SELL_LIMIT,    _Symbol, i)  && 
                                                    !OrderType(ORDER_TYPE_SELL_STOP,     _Symbol, i))   )
                                                  {
                                                   CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                                  }
                                               }
                                            }
                                          else
                                            {
                                             CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                            }
                                         }
                                       //+---------------------
                                       else if(Order_Comment != "ERROR")
                                         {
                                          CancelOrders(EAMagicNumber, -1, i, _Symbol);
                                         }  
                                      }
                                   }
                                }
                             }
                          }
                       }
                     //+---------------------
                     else
                       {
                        CancelOrders(EAMagicNumber, -1, i, _Symbol);
                       }
                     
                     
                    }
                 }
               else
                 {
                  Alert("ERROR Selecting Order - OnTick (Alert 1)");
                 }
              }
           }
           
           
           
         //+--- BULLISH TREND ------------------------------------------------------------------------------------------------------------------+
         if(BullishTrend)
           {
            //+--- LVL 3 --------------------------------------------------------+
            if(BullishTrendLVL3[0])
              {
               if(MAReturn_1[0])
                 {
                  if(!OrderInPrice(High[1] + (2*TickSize)))
                    {
                     SendOrder(BUY, FullVolume, High[1] + (2*TickSize), _Symbol, Low[1] - (3*TickSize), 0.0, 15, "OB. T,3 MAR. 1");
                    } 
                 }
                 
               //+--------------------- 
               if(MAReturn_3[0])
                 {
                  if(!OrderInPrice(High[1] + (2*TickSize)))
                    {
                     SendOrder(BUY, FullVolume, High[1] + (2*TickSize), _Symbol, Low[1] - (3*TickSize), 0.0, 15, "OB. T,3 MAR. 3");
                    } 
                 }
               //+--------------------- 
               else if(MAReturn_301[0])
                 {
                  if(!OrderInPrice(High[1] + (2*TickSize)))
                    {
                     SendOrder(BUY, FullVolume, High[1] + (2*TickSize), _Symbol, Low[1] - (3*TickSize), 0.0, 15, "OB. T,3 MAR. 301");
                    } 
                 }
               
              }
            else
              {
              //+--- LVL 2 --------------------------------------------------------+
               if(BullishTrendLVL2[0])
                 {
                  if(MAReturn_1[0])
                    {
                     if(!OrderInPrice(High[1] + (2*TickSize)))
                       {
                        SendOrder(BUY, FullVolume, High[1] + (2*TickSize), _Symbol, Low[1] - (3*TickSize), 0.0, 15, "OB. T,2 MAR. 1");
                       } 
                    }
                  
                  //+--------------------- 
                  if(MAReturn_3[0])
                    {
                     if(!OrderInPrice(High[1] + (2*TickSize)))
                       {
                        SendOrder(BUY, FullVolume, High[1] + (2*TickSize), _Symbol, Low[1] - (3*TickSize), 0.0, 15, "OB. T,2 MAR. 3");
                       } 
                    }
                  //+--------------------- 
                  else if(MAReturn_301[0])
                    {
                     if(!OrderInPrice(High[1] + (2*TickSize)))
                       {
                        SendOrder(BUY, FullVolume, High[1] + (2*TickSize), _Symbol, Low[1] - (3*TickSize), 0.0, 15, "OB. T,2 MAR. 301");
                       } 
                    }
                    
                  
                 }
               else
                 {
                  //+--- LVL 1 --------------------------------------------------------+
                  if(BullishTrendLVL1[0])
                    {
                     if(MAReturn_1[0])
                       {
                        if(!OrderInPrice(High[1] + (2*TickSize)))
                          {
                           SendOrder(BUY, FullVolume, High[1] + (2*TickSize), _Symbol, Low[1] - (3*TickSize), 0.0, 15, "OB. T,1 MAR. 1");
                          } 
                       }
                    
                     //+--------------------- 
                     if(MAReturn_3[0])
                       {
                        if(!OrderInPrice(High[1] + (2*TickSize)))
                          {
                           SendOrder(BUY, FullVolume, High[1] + (2*TickSize), _Symbol, Low[1] - (3*TickSize), 0.0, 15, "OB. T,1 MAR. 3");
                          } 
                       }
                     //+--------------------- 
                     else if(MAReturn_301[0])
                       {
                        if(!OrderInPrice(High[1] + (2*TickSize)))
                          {
                           SendOrder(BUY, FullVolume, High[1] + (2*TickSize), _Symbol, Low[1] - (3*TickSize), 0.0, 15, "OB. T,1 MAR. 301");
                          } 
                       }
                       
                     
                    }
                 }
              }
              
              
           }
         //+--- BEARISH TREND ------------------------------------------------------------------------------------------------------------------+
         else
           {
            if(BearishTrend)
              {
               //+--- LVL 3 --------------------------------------------------------+
               if(BearishTrendLVL3[0])
                 {
                  if(MAReturn_11[0])
                    {
                     if(!OrderInPrice(Low[1] - (2*TickSize)))
                       {
                        SendOrder(SELL, FullVolume, Low[1] - (2*TickSize), _Symbol, High[1] + (3*TickSize), 0.0, 15, "OS. T'3 MAR. 11");
                       } 
                    } 
                 
                  //+--------------------- 
                  if(MAReturn_33[0])
                    {
                     if(!OrderInPrice(Low[1] - (2*TickSize)))
                       {
                        SendOrder(SELL, FullVolume, Low[1] - (2*TickSize), _Symbol, High[1] + (3*TickSize), 0.0, 15, "OS. T'3 MAR. 33");
                       } 
                    } 
                  //+---------------------                                 
                  else if(MAReturn_331[0])
                    {
                     if(!OrderInPrice(Low[1] - (2*TickSize)))
                       {
                        SendOrder(SELL, FullVolume, Low[1] - (2*TickSize), _Symbol, High[1] + (3*TickSize), 0.0, 15, "OS. T'3 MAR. 331");
                       } 
                    }
                 
                 }
               else
                 {
                  //+--- LVL 2 --------------------------------------------------------+
                  if(BearishTrendLVL2[0])
                    {
                     if(MAReturn_11[0])
                       {
                        if(!OrderInPrice(Low[1] - (2*TickSize)))
                          {
                           SendOrder(SELL, FullVolume, Low[1] - (2*TickSize), _Symbol, High[1] + (3*TickSize), 0.0, 15, "OS. T'2 MAR. 11");
                          } 
                       } 
                    
                     //+--------------------- 
                     if(MAReturn_33[0])
                       {
                        if(!OrderInPrice(Low[1] - (2*TickSize)))
                          {
                           SendOrder(SELL, FullVolume, Low[1] - (2*TickSize), _Symbol, High[1] + (3*TickSize), 0.0, 15, "OS. T'2 MAR. 33");
                          } 
                       } 
                     //+---------------------                                 
                     else if(MAReturn_331[0])
                       {
                        if(!OrderInPrice(Low[1] - (2*TickSize)))
                          {
                           SendOrder(SELL, FullVolume, Low[1] - (2*TickSize), _Symbol, High[1] + (3*TickSize), 0.0, 15, "OS. T'2 MAR. 331");
                          } 
                       }
                    
                    
                    }
                  else
                    {
                     //+--- LVL 1 --------------------------------------------------------+
                     if(BearishTrendLVL1[0])
                       {
                        if(MAReturn_11[0])
                          {
                           if(!OrderInPrice(Low[1] - (2*TickSize)))
                             {
                              SendOrder(SELL, FullVolume, Low[1] - (2*TickSize), _Symbol, High[1] + (3*TickSize), 0.0, 15, "OS. T'1 MAR. 11");
                             } 
                          }
                       
                        //+--------------------- 
                        if(MAReturn_33[0])
                          {
                           if(!OrderInPrice(Low[1] - (2*TickSize)))
                             {
                              SendOrder(SELL, FullVolume, Low[1] - (2*TickSize), _Symbol, High[1] + (3*TickSize), 0.0, 15, "OS. T'1 MAR. 33");
                             } 
                          } 
                        //+---------------------                                 
                        else if(MAReturn_331[0])
                          {
                           if(!OrderInPrice(Low[1] - (2*TickSize)))
                             {
                              SendOrder(SELL, FullVolume, Low[1] - (2*TickSize), _Symbol, High[1] + (3*TickSize), 0.0, 15, "OS. T'1 MAR. 331");
                             } 
                          }
                    
                    
                       }
                    }
                 }
                 
                 
              }
           }
         
          
        }       
      
                                                                                                                                   
      //+------------------------------------------------------------------+
//----//--- POSITIONED                                                     |------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      if(Positions() == 1)
        {
         int    Position_Candle      = PositionCandle(rates, dt_, Timeframe);
         string Position_Comment     = PositionComment(); 
         double Position_Price       = PositionPrice();
         
         //+--- POSITION TYPE BUY ------------------------------------------------------------------------------------------------------------+
         if(PositionType(POSITION_TYPE_BUY))
           {
            string NewComment = Position_Comment;
            StringReplace(NewComment, "OB.", "CS.");
            int RefCandle     = Position_Candle + 1;
            (Low[RefCandle] <= (PinkMA[RefCandle] + TickSize))? RefCandle = RefCandle : RefCandle = RefCandle + 1;
            
            //+--- FIBO ---------------------------------------------------------+
            Fibo50P   = FiboProjection(High[RefCandle], Low[RefCandle], LVL_50,   TickSize);
            Fibo618P  = FiboProjection(High[RefCandle], Low[RefCandle], LVL_618,  TickSize);
            Fibo100P  = FiboProjection(High[RefCandle], Low[RefCandle], LVL_100,  TickSize);
            Fibo1618P = FiboProjection(High[RefCandle], Low[RefCandle], LVL_1618, TickSize);
            


            //+--- PARTIAL ORDERS -----------------------------------------------------------------------------------------------------------------+
            //+--- MAR 1 --------------------------------------------------------+
            if((Position_Comment == "OB. T,3 MAR. 1") || (Position_Comment == "OB. T,2 MAR. 1") || (Position_Comment == "OB. T,1 MAR. 1"))
              {
               if((!OrderInPrice(Fibo100P)) && (PositionVolume() >= FullVolume))
                 {
                  SendOrder(SELL, PartialVolume, Fibo100P, _Symbol, 0, 0, 0, NewComment, false);
                 }
                 
               if((!OrderInPrice(Fibo1618P)) && (PositionVolume() >= FullVolume))
                 {
                  SendOrder(SELL, HalfVolume, Fibo1618P, _Symbol, 0, 0, 0, NewComment, false);
                 }
              }
            //+--- MAR 3 --------------------------------------------------------+
            if((Position_Comment == "OB. T,3 MAR. 3") || (Position_Comment == "OB. T,2 MAR. 3") || (Position_Comment == "OB. T,1 MAR. 3"))
              {
               if((!OrderInPrice(Fibo100P)) && (PositionVolume() >= FullVolume))
                 {
                  SendOrder(SELL, PartialVolume, Fibo100P, _Symbol, 0, 0, 0, NewComment, false);
                 }
                 
               if((!OrderInPrice(Fibo1618P)) && (PositionVolume() >= FullVolume))
                 {
                  SendOrder(SELL, HalfVolume, Fibo1618P, _Symbol, 0, 0, 0, NewComment, false);
                 }
              }
            //+--- MAR 301 ------------------------------------------------------+
            else
              {
               if((Position_Comment == "OB. T,3 MAR. 301") || (Position_Comment == "OB. T,2 MAR. 301") || (Position_Comment == "OB. T,1 MAR. 301"))
                 {
                  if((!OrderInPrice(Fibo100P)) && (PositionVolume() >= FullVolume))
                    {
                     SendOrder(SELL, PartialVolume, Fibo100P, _Symbol, 0, 0, 0, NewComment, false);
                    }
                 
                  if((!OrderInPrice(Fibo1618P)) && (PositionVolume() >= FullVolume))
                    {
                     SendOrder(SELL, HalfVolume, Fibo1618P, _Symbol, 0, 0, 0, NewComment, false);
                    }
                 }
              }
            
            
            //+--- BREAKEVEN / TRAILING STOP ----------------------------------------------------------------------------------------------------+
            if(isNewCandle(rates))
              {
               if((Position_Candle > BottomIndex(Low)) && (LastBottom > Position_Price))
                 {
                  Breakeven(TickSize);
                  TrailingStop(LastBottom - (3*TickSize), PartialVolume/2, EAMagicNumber, BOUGHT, rates, Position_Candle);
                 }
                 
               if((Position_Candle > TopIndex(High)) && (Low[1] > Position_Price))
                 {
                  for(int i = 1; i <= TopIndex(High) - 1; i++)
                    {
                     if(High[i] > LastTop)
                       {
                        TrailingStop(Low[1] - (3*TickSize), PartialVolume/2, EAMagicNumber, BOUGHT, rates, Position_Candle);
                        break;
                       }
                    }
                 }
              }
            
           }
         //+--- POSITION TYPE SELL -----------------------------------------------------------------------------------------------------------+
         else if(PositionType(POSITION_TYPE_SELL))
           {
            string NewComment = Position_Comment;
            StringReplace(NewComment, "OS.", "CB.");
            int RefCandle     = Position_Candle + 1;
            (High[RefCandle] >= (PinkMA[RefCandle] - TickSize))? RefCandle = RefCandle : RefCandle = RefCandle + 1;
            
            //+--- FIBO ---------------------------------------------------------+
            Fibo50P   = FiboProjection(Low[RefCandle], High[RefCandle], LVL_50,   TickSize);
            Fibo618P  = FiboProjection(Low[RefCandle], High[RefCandle], LVL_618,  TickSize);
            Fibo100P  = FiboProjection(Low[RefCandle], High[RefCandle], LVL_100,  TickSize);
            Fibo1618P = FiboProjection(Low[RefCandle], High[RefCandle], LVL_1618, TickSize);
            
            
            
            //+--- PARTIAL ORDERS -----------------------------------------------------------------------------------------------------------------+
            //+--- MAR 11 -------------------------------------------------------+
            if((Position_Comment == "OS. T'3 MAR. 11") || (Position_Comment == "OS. T'2 MAR. 11") || (Position_Comment == "OS. T'1 MAR. 11"))
              {
               if((!OrderInPrice(Fibo100P)) && (PositionVolume() >= FullVolume))
                 {
                  SendOrder(BUY, PartialVolume, Fibo100P, _Symbol, 0, 0, 0, NewComment, false);
                 }
                 
               if((!OrderInPrice(Fibo1618P)) && (PositionVolume() >= FullVolume))
                 {
                  SendOrder(BUY, HalfVolume, Fibo1618P, _Symbol, 0, 0, 0, NewComment, false);
                 }
              }
            //+--- MAR 33 -------------------------------------------------------+
            if((Position_Comment == "OS. T'3 MAR. 33") || (Position_Comment == "OS. T'2 MAR. 33") || (Position_Comment == "OS. T'1 MAR. 33"))
              {
               if((!OrderInPrice(Fibo100P)) && (PositionVolume() >= FullVolume))
                 {
                  SendOrder(BUY, PartialVolume, Fibo100P, _Symbol, 0, 0, 0, NewComment, false);
                 }
                 
               if((!OrderInPrice(Fibo1618P)) && (PositionVolume() >= FullVolume))
                 {
                  SendOrder(BUY, HalfVolume, Fibo1618P, _Symbol, 0, 0, 0, "C. MAR: 33", false);
                 }
              }
             //+--- MAR 331 ------------------------------------------------------+
             else
              {
               if((Position_Comment == "OS. T'3 MAR. 331") || (Position_Comment == "OS. T'2 MAR. 331") || (Position_Comment == "OS. T'1 MAR. 331"))
                 {
                  if((!OrderInPrice(Fibo100P)) && (PositionVolume() >= FullVolume))
                    {
                     SendOrder(BUY, PartialVolume, Fibo100P, _Symbol, 0, 0, 0, NewComment, false);
                    }
                 
                  if((!OrderInPrice(Fibo1618P)) && (PositionVolume() >= FullVolume))
                    {
                     SendOrder(BUY, HalfVolume, Fibo1618P, _Symbol, 0, 0, 0, NewComment, false);
                    }
                 }
              }
            
            
            //+--- BREAKEVEN / TRAILING STOP -------------------------------------------------------------------------------------------------------+
            if(isNewCandle(rates))
              {
               if((Position_Candle > TopIndex(High)) && (LastTop < Position_Price))
                 {
                  Breakeven(TickSize);
                  TrailingStop(LastTop + (3*TickSize), PartialVolume/2, EAMagicNumber, SOLD, rates, Position_Candle);
                 }
                 
               if((Position_Candle > BottomIndex(Low)) && (High[1] < Position_Price))
                 {
                  for(int i = 1; i <= BottomIndex(Low) - 1; i++)
                    {
                     if(Low[i] < LastBottom)
                       {
                        TrailingStop(High[1] + (3*TickSize), PartialVolume/2, EAMagicNumber, SOLD, rates, Position_Candle);
                       }
                    }
                 }
              }

           }
         
         
         
         
         
         /*//+--- BULLISH TREND ------------------------------------------------------------------------------------------------------------------+
         if(BullishTrend)
           {
            //+------------------------------------------------------------------+
            if(BullishTrendLVL3[0])
              {
            
              }
            else
              {
              //+------------------------------------------------------------------+
               if(BullishTrendLVL2[0])
                 {
               
                 }
               else
                 {
                  //+------------------------------------------------------------------+
                  if(BullishTrendLVL1[0])
                    {
                  
                    }
                 }
              }
              
              
           }
         //+--- BEARISH TREND ------------------------------------------------------------------------------------------------------------------+
         else
           {
            if(BearishTrend)
              {
               //+------------------------------------------------------------------+
               if(BearishTrendLVL3[0])
                 {
                 
                 }
               else
                 {
                  //+------------------------------------------------------------------+
                  if(BearishTrendLVL2[0])
                    {
                       
                    }
                  else
                    {
                     //+------------------------------------------------------------------+
                     if(BearishTrendLVL1[0])
                       {
                        
                       }
                    }
                 }
                 
                 
              }
           }*/
        }
        
        
      Security(TickSize);
     }
   //+---------------------------------------------------------------------------------------------------------------------------------------+
   else if(!TimeCondition(dt, StartHour, StartMinut, EndHour, EndMinut))
     {
      if(TradeMode == Day_Trade)
        {
         if(Positions() > 0)
           {
            ClosePositions(Ask, Bid, TickSize);
           }
          
         if(Orders() > 0)
           {
            CancelOrders(EAMagicNumber);
           }
        }
         
           
      Comment("TIME OUT!");
     }
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


//+------------------------------------------------------------------+
//--- Send Order
enum ENUM_TYPE_ORDER
  {
   BUY,
   SELL
  };
  
void SendOrder(const ENUM_TYPE_ORDER Type, 
               const double          volume,    double       price,     const string symbol, 
               const double          SL = 0.0,  const double TP = 0.0,  double deviation_pts = 15, 
               const string          Comm = "", const bool   AllowMKTOrder = true)
  {
   MqlTick tick_;
   SymbolInfoTick(symbol, tick_);
   
   double SymbolTickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   deviation_pts = deviation_pts * _Point;
   
   if(Type == BUY)
     {
      if(tick_.ask < price)
        {
         if(trade.BuyStop(volume, price, symbol, SL, TP, ORDER_TIME_DAY, 0, Comm))
           {
            Print("[", symbol, "] BUY STOP ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Sent).", 
                  "\nSUCCESS! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription(),
                  "\nREASON: ", Comm);
           }
         else
           {
            Alert("[", symbol, "] BUY AT MARKET ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Not Sent).", 
                  "\nFAIL! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
           }
        }
      else
        {
         if(tick_.ask > price)
           {
            if(tick_.ask > (price+deviation_pts))
              {
               if(trade.BuyLimit(volume, price, symbol, SL, TP, ORDER_TIME_DAY, 0, Comm))
                 {
                  Print("[", symbol, "] BUY LIMIT ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Sent).", 
                        "\nSUCCESS! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription(),
                        "\nREASON: ", Comm);
                 }
               else
                 {
                  Alert("[", symbol, "] BUY AT MARKET ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Not Sent).", 
                        "\nFAIL! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }
              }
            else
              {
               if((tick_.ask <= (price+deviation_pts)) && (AllowMKTOrder))
                 {
                  price = NormalRoundPrice(tick_.ask, SymbolTickSize);
                 
                  if(trade.Buy(volume, symbol, price, SL, TP, Comm))
                    {
                     Print("[", symbol, "] BUY AT MARKET ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Sent).", 
                           "\nSUCCESS! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription(),
                           "\nREASON: ", Comm);
                    }
                  else
                    {
                     Alert("[", symbol, "] BUY AT MARKET ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Not Sent).", 
                           "\nFAIL! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                 }
              }
           }
         else
           {
            if((tick_.ask == price) && (AllowMKTOrder))
              {
               price = NormalRoundPrice(tick_.ask, SymbolTickSize);
                 
               if(trade.Buy(volume, symbol, price, SL, TP, Comm))
                 {
                  Print("[", symbol, "] BUY AT MARKET ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Sent).", 
                        "\nSUCCESS! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription(),
                        "\nREASON: ", Comm);
                 }
               else
                 {
                  Alert("[", symbol, "] BUY AT MARKET ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Not Sent).", 
                        "\nFAIL! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                 }
              }
           }
        }
     }
   else
     {
      if(Type == SELL)
        {
         if(tick_.bid > price)
           {
            if(trade.SellStop(volume, price, symbol, SL, TP, ORDER_TIME_DAY, 0, Comm))
              {
               Print("[", symbol, "] SELL STOP ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Sent).", 
                     "\nSUCCESS! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription(),
                     "\nREASON: ", Comm);
              }
            else
              {
               Alert("[", symbol, "] SELL STOP", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Not Sent).", 
                     "\nFAIL! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
              }
           }
         else
           {
            if(tick_.bid < price)
              {
               if(tick_.bid < (price-deviation_pts))
                 {
                  if(trade.SellLimit(volume, price, symbol, SL, TP, ORDER_TIME_DAY, 0, Comm))
                    {
                     Print("[", symbol, "] SELL LIMIT ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Sent).", 
                           "\nSUCCESS! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription(),
                           "\nREASON: ", Comm);
                    }
                  else
                    {
                     Alert("[", symbol, "] SELL LIMIT ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Not Sent).", 
                           "\nFAIL! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                 }
               else
                 {
                  if((tick_.bid >= (price-deviation_pts)) && (AllowMKTOrder))
                    {
                     price = NormalRoundPrice(tick_.bid, SymbolTickSize);
                 
                     if(trade.Sell(volume, symbol, price, SL, TP, Comm))
                       {
                        Print("[", symbol, "] SELL AT MARKET ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Sent).", 
                              "\nSUCCESS! Result Retcode: ", tradeclass.ResultRetcode(), " Retcode Description: ", tradeclass.ResultRetcodeDescription(),
                              "\nREASON: ", Comm);
                       }
                     else
                       {
                        Alert("[", symbol, "] SELL AT MARKET ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Not Sent).", 
                              "\nFAIL! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                       }
                    }
                 }
              }
            else
              {
               if((tick_.bid == price) && (AllowMKTOrder))
                 {
                  price = NormalRoundPrice(tick_.bid, SymbolTickSize);
                 
                  if(trade.Sell(volume, symbol, price, SL, TP, Comm))
                    {
                     Print("[", symbol, "] SELL AT MARKET ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Sent).", 
                           "\nSUCCESS! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription(),
                           "\nREASON: ", Comm);
                    }
                  else
                    {
                     Alert("[", symbol, "] SELL AT MARKET ", volume, " at ", price, "; SL: ", SL, " - TP: ", TP, " (Order Not Sent).", 
                           "\nFAIL! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                    }
                 }
              }
           }
        }
      else
        {
         Alert("ERROR! 'Type' Must Be 'BUY' or 'SELL' - Send Order Function.");
         ExpertRemove();
        }
     }
  }
  

//+------------------------------------------------------------------+
//--- Trailing Stop
enum ENUM_TYPE_POSITION
  {
   BOUGHT,
   SOLD
  };

void TrailingStop(const double Price,        const double volume,     const ulong EA_Magic_Number, const ENUM_TYPE_POSITION Pos_Type, 
                  MqlRates     &rates_str[], const int    pos_candle, string      symbol = "_Symbol")
  {
   if(symbol == "_Symbol")
     {
      symbol = _Symbol;
     }
   
   if(Orders(symbol) > 0)
     {
      bool isFirstTrailing = true;
     
      for(int i = 0; i < Orders(symbol, Highest_Index); i++)
        {
         ulong OrderTicket = OrderGetTicket(i);
         
         if(OrderSelect(OrderTicket))
           {
            string OrderSymbol   = OrderGetString(ORDER_SYMBOL);
            string Order_Comment = OrderGetString(ORDER_COMMENT);
            
            if((OrderSymbol == symbol) && ((Order_Comment == "CS. TRAILING STOP") || (Order_Comment == "CB. TRAILING STOP")))
              {
               isFirstTrailing   = false;
               double OrderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
               
               if((Pos_Type == BOUGHT) && (OrderPrice < Price))
                 {
                  OrderModify(Price, i, EA_Magic_Number, symbol);
                 }
               else if((Pos_Type == SOLD) && (OrderPrice > Price))
                 {
                  OrderModify(Price, i, EA_Magic_Number, symbol);
                 }
              }
           }
         else
           {
            Alert("ERROR Selecting Order - Trailing Stop Function.");
           }
        }
      
      
      if(isFirstTrailing)
        {   
         HistorySelect(rates_str[pos_candle].time, TimeTradeServer());
         
         for(int i = 0; i < HistoryDealsTotal(); i++)
           {
            ulong  DealTicket = HistoryDealGetTicket(i);
            string DealSymbol = HistoryDealGetString(DealTicket, DEAL_SYMBOL);
            
            if((HistoryDealSelect(DealTicket)) && (DealSymbol == symbol))
              {
               string DealComment = HistoryDealGetString(DealTicket, DEAL_COMMENT);
               
               if((DealComment == "CS. TRAILING STOP") || (DealComment == "CB. TRAILING STOP"))
                 {
                  isFirstTrailing = false;
                 }
              }
           }
         
         if(isFirstTrailing)
           {
            if(Pos_Type == BOUGHT)
              {
               SendOrder(SELL, volume, Price, symbol, 0, 0, 0, "CS. TRAILING STOP", false);
              }
            else if(Pos_Type == SOLD)
              {
               SendOrder(BUY, volume, Price, symbol, 0, 0, 0, "CB. TRAILING STOP", false);
              }
           }  
         
        }
     }  
   else
     {
      bool isFirstTrailing = true;
        
      HistorySelect(rates_str[pos_candle].time, TimeTradeServer());         
     
      for(int i = 0; i < HistoryDealsTotal(); i++)
        {
         ulong  DealTicket = HistoryDealGetTicket(i);
         string DealSymbol = HistoryDealGetString(DealTicket, DEAL_SYMBOL);
          
         if((HistoryDealSelect(DealTicket)) && (DealSymbol == symbol))
           {
            string DealComment = HistoryDealGetString(DealTicket, DEAL_COMMENT);
            
            if((DealComment == "CS. TRAILING STOP") || (DealComment == "CB. TRAILING STOP"))
              {
               isFirstTrailing = false;
              }
           }
        }
         
      if(isFirstTrailing)
        {
         if(Pos_Type == BOUGHT)
           {
            SendOrder(SELL, volume, Price, symbol, 0, 0, 0, "CS. TRAILING STOP", false);
           }
         else if(Pos_Type == SOLD)
           {
            SendOrder(BUY, volume, Price, symbol, 0, 0, 0, "CB. TRAILING STOP", false);
           }
        }
     }
  }
  
//+------------------------------------------------------------------+
//--- Security System
void Security(const double SymbolTickSize)
 {
  MqlTick tick_;
  SymbolInfoTick(_Symbol, tick_);
 
  if(Positions() == 1)
    {
     double Position_Price   = PositionPrice();
     double Position_Volume  = PositionVolume();
     string Position_Comment = PositionComment();
     string Pos_Comment_Type = StringSubstr(Position_Comment, 0, 3);
     int    Position_Candle  = PositionCandle(rates, dt_, Timeframe);
         
     double COrdersVolumeT = 0;
      
     //+--------------------- 
     for(int i = 0; i < Orders(_Symbol, Highest_Index); i++)
       {
        ulong OrderTicket = OrderGetTicket(i);
         
        //+---------------------   
        if(OrderSelect(OrderTicket))
          {
           string OrderSymbol      = OrderGetString(ORDER_SYMBOL);
           string OrderCommentType = StringSubstr(OrderGetString(ORDER_COMMENT), 0, 1);
            
           //+---------------------    
           if((OrderSymbol == _Symbol) && (OrderCommentType == "C"))
             {
              double Order_Volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
              COrdersVolumeT     += Order_Volume;
                 
              //+--- C. Volume Exceeds Position -----------------------------------+   
              if(COrdersVolumeT > Position_Volume)
                {
                 double NewVolume   = Order_Volume - (COrdersVolumeT - Position_Volume);
                 double Order_Price = OrderGetDouble(ORDER_PRICE_OPEN);
                 
                 if(NewVolume > 0)
                   {
                    COrdersVolumeT = (COrdersVolumeT - Order_Volume) + NewVolume;
                   
                    if(PositionType(POSITION_TYPE_BUY))
                      {
                       SendOrder(SELL, NewVolume, Order_Price, _Symbol, 0, 0, 0, "CS. S.S.", false);
                      }
                    else if(PositionType(POSITION_TYPE_SELL))
                      {
                       SendOrder(BUY, NewVolume, Order_Price, _Symbol, 0, 0, 0, "CB. S.S.", false);
                      } 
                   }
                 else
                   {
                    COrdersVolumeT = COrdersVolumeT - Order_Volume;
                   }
                  
                 CancelOrders(EAMagicNumber, -1, i);
                }
                
              //+--- Insufficient C. Volume ---------------------------------------+   
              if(i == (Orders(_Symbol, Highest_Index) - 1))
                {
                 if((Position_Candle >= 2) && (COrdersVolumeT <= (Position_Volume/2)))
                   {
                    if(PositionType(POSITION_TYPE_BUY))
                      {
                       double SSOrderVolume = Position_Volume;
                       double SSOrderPrice  = Position_Price + (High[Position_Candle - 1] - Low[Position_Candle - 1]);
                       
                       SendOrder(SELL, SSOrderVolume, SSOrderPrice,_Symbol, 0, 0, 0, "CS. S.S.", false);
                      }
                    else if(PositionType(POSITION_TYPE_SELL))
                      {
                       double SSOrderVolume = Position_Volume;
                       double SSOrderPrice  = Position_Price - (High[Position_Candle - 1] - Low[Position_Candle - 1]);
                        
                       SendOrder(BUY, SSOrderVolume, SSOrderPrice,_Symbol, 0, 0, 0, "CB. S.S.", false);
                      }
                   }
                } 
                   
              //+--- C. Order Incorret --------------------------------------------+   
              if(PositionType(POSITION_TYPE_BUY))
                {
                 if((!OrderType(ORDER_TYPE_SELL, _Symbol, i)) && (!OrderType(ORDER_TYPE_SELL_LIMIT, _Symbol, i)) && (!OrderType(ORDER_TYPE_SELL_STOP, _Symbol, i)))
                   {
                    CancelOrders(EAMagicNumber, -1, i);
                   }
                }
              else 
                {
                 if(PositionType(POSITION_TYPE_SELL))
                   {
                    if((!OrderType(ORDER_TYPE_BUY, _Symbol, i)) && (!OrderType(ORDER_TYPE_BUY_LIMIT, _Symbol, i)) && (!OrderType(ORDER_TYPE_BUY_STOP, _Symbol, i)))
                      {
                       CancelOrders(EAMagicNumber, -1, i);
                      }
                   }
                }
             }
           else
             {
              if((OrderSymbol == _Symbol) && (OrderCommentType == "O"))
                {
                 double Order_Volume      = OrderGetDouble(ORDER_VOLUME_CURRENT);
                 double Init_Order_Volume = OrderGetDouble(ORDER_VOLUME_INITIAL);
                 double Order_Price       = OrderGetDouble(ORDER_PRICE_OPEN);
                 double OrderSL           = OrderGetDouble(ORDER_SL);
                 double OrderTP           = OrderGetDouble(ORDER_TP);
                 string Order_Comment     = OrderGetString(ORDER_COMMENT);
                 
                 
                 //+--- Partial Execution - Type O. Order ----------------------------+
                 if(Order_Volume != Init_Order_Volume)
                   {
                    //+---------------------
                    if(OrderType(ORDER_TYPE_BUY_STOP, _Symbol, i) || OrderType(ORDER_TYPE_BUY_LIMIT, _Symbol, i))
                      {
                       if(tick_.ask < Order_Price)
                         {
                          CancelOrders(EAMagicNumber, -1, i);
                          if(trade.Buy(Order_Volume, _Symbol, Order_Price, OrderSL, OrderTP, Order_Comment))
                            {
                             Print("[", _Symbol, "] BUY AT MARKET ", Order_Volume, " at ", Order_Price, "; SL: ", OrderSL, " - TP: ", OrderTP, " (Order Sent).", 
                                   "\nSUCCESS! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription(),
                                   "\nREASON: ", Order_Comment);
                            }
                          else
                            {
                             Alert("[", _Symbol, "] BUY AT MARKET ", Order_Volume, " at ", Order_Price, "; SL: ", OrderSL, " - TP: ", OrderTP, " (Order Not Sent).", 
                                   "\nFAIL! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                            }
                         }
                       else
                         {
                          if(tick_.ask > Order_Price)
                            {
                             CancelOrders(EAMagicNumber, -1, i);
                             SendOrder(BUY, Order_Volume, Order_Price, _Symbol, OrderSL, OrderTP, 15*_Point, Order_Comment, true);
                            }
                         }
                      }
                    //+---------------------
                    else
                      {
                       if(OrderType(ORDER_TYPE_SELL_STOP, _Symbol, i) || OrderType(ORDER_TYPE_SELL_LIMIT, _Symbol, i))
                         {
                          if(tick_.bid > Order_Price)
                            {
                             CancelOrders(EAMagicNumber, -1, i);
                             if(trade.Sell(Order_Volume, _Symbol, Order_Price, OrderSL, OrderTP, Order_Comment))
                               {
                                Print("[", _Symbol, "] SELL AT MARKET ", Order_Volume, " at ", Order_Price, "; SL: ", OrderSL, " - TP: ", OrderTP, " (Order Sent).", 
                                      "\nSUCCESS! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription(),
                                      "\nREASON: ", Order_Comment);
                               }
                             else
                               {
                                Alert("[", _Symbol, "] SELL AT MARKET ", Order_Volume, " at ", Order_Price, "; SL: ", OrderSL, " - TP: ", OrderTP, " (Order Not Sent).", 
                                      "\nFAIL! Result Retcode: ", trade.ResultRetcode(), " Retcode Description: ", trade.ResultRetcodeDescription());
                               }
                            }
                          else
                            {
                             if(tick_.bid < Order_Price)
                               {
                                CancelOrders(EAMagicNumber, -1, i);
                                SendOrder(SELL, Order_Volume, Order_Price, _Symbol, OrderSL, OrderTP, 15*_Point, Order_Comment, true);
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
           Alert("ERROR Selecting Order - Security Function.");
          }
       }
         
     //+--- Type C. Position ---------------------------------------------+
     if(Pos_Comment_Type == "CB.")
       {
        if(PositionType(POSITION_TYPE_BUY))
          {
           ClosePositions(Ask, Bid, TickSize);
          }
       }   
     else
       {
        if(Pos_Comment_Type == "CS.")
          {
           if(PositionType(POSITION_TYPE_SELL))
             {
              ClosePositions(Ask, Bid, TickSize);
             }
          }
       }
       
     
     //+--- Operation Protection -----------------------------------------+   
     for(int i = 0; i < Positions(_Symbol, Highest_Index); i++)
       {
        if(PositionSelect(_Symbol))
          {
           ulong PositionTicket = PositionGetTicket(i);
           
           if(PositionSelectByTicket(PositionTicket))
             {
              double PositionSL = PositionGetDouble(POSITION_SL);
              
              //+---------------------
              if(PositionType(POSITION_TYPE_BUY, i))
                {
                 if(tick_.bid < PositionSL)
                   {
                    ClosePositions(tick_.ask, tick_.bid, SymbolTickSize, _Symbol);
                   }
                }
              //+---------------------
              else
                {
                 if(PositionType(POSITION_TYPE_SELL, i))
                   {
                    if(tick_.ask > PositionSL)
                      {
                       ClosePositions(tick_.ask, tick_.bid, SymbolTickSize, _Symbol);
                      }
                   }
                }
             }
           else
             {
              Alert("ERROR Selecting Position - Security Function.");
             }
          }
        else
          {
           Alert("ERROR Selecting Position - Security Function.");
          }
       }
    }
       
       
   /*if(Orders() > 0)
     {
      //--- Orders at Same Place and Big Volume 
     }*/
  }