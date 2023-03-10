//+------------------------------------------------------------------+
//|                                             WINSTON - Ranges.mq5 |
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


input ENUM_TIMEFRAMES Timeframe  = PERIOD_M5; //Timeframe

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

int OnInit()
  {
   //+------------------------------------------------------------------+
   //--- ARRAY SET AS SERIES
   if(ArrayIsNotSeries(rates,      "rates"     ) ||
      ArrayIsNotSeries(Open,       "Open"      ) ||
      ArrayIsNotSeries(High,       "High"      ) ||
      ArrayIsNotSeries(Low,        "Low"       ) ||
      ArrayIsNotSeries(Close,      "Close"     )   )
     {
      return(INIT_FAILED);
     }
     
   //+------------------------------------------------------------------+
   //--- OBJECTS
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

void OnDeinit(const int reason)
  {

  }

void OnTick()
  {
   CopyRates(_Symbol, Timeframe, 0, 1000, rates);
   CopyOpen (_Symbol, Timeframe, 0, 1000, Open );
   CopyHigh (_Symbol, Timeframe, 0, 1000, High );
   CopyLow  (_Symbol, Timeframe, 0, 1000, Low  );
   CopyClose(_Symbol, Timeframe, 0, 1000, Close);
   
   
   Ask      = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Bid      = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   if(isNewCandle(rates))
     {
      int a = 6;
      int b = 6;
     
      for(int i = 0; i < 5; i++)
        {
         int TopIndexVar = TopIndex(High, a); // Top Index Variable
         int BottomIndexVar = BottomIndex(Low, b); // Bottom Index Variable
         
        
         if(AmplitudeTop(TopIndexVar, Open, High, Low, Close, rates))
           {
            string ArrowName = (string) rates[TopIndexVar].time + "T";
       
            if(ObjectFind(0, ArrowName) < 0)
              {
               ObjectCreate(0, ArrowName, OBJ_ARROW_DOWN, 0, rates[TopIndexVar].time, High[TopIndexVar] + (50*_Point));
              }
           }
         else
           {
            string ArrowName = (string) rates[TopIndexVar].time + "T";
       
            if(ObjectFind(0, ArrowName) >= 0)
              {
               ObjectDelete(0, ArrowName);
              }
           }   
         
           
           
         if(AmplitudeBottom(BottomIndexVar, Open, High, Low, Close, rates))
           {
            string ArrowName = (string) rates[BottomIndexVar].time + "B";
       
            if(ObjectFind(0, ArrowName) < 0)
              {
               ObjectCreate(0, ArrowName, OBJ_ARROW_UP, 0, rates[BottomIndexVar].time, Low[BottomIndexVar] - (50*_Point));
              }
           }
         else
           {
            string ArrowName = (string) rates[BottomIndexVar].time + "B";
       
            if(ObjectFind(0, ArrowName) >= 0)
              {
               ObjectDelete(0, ArrowName);
              }
           }
           
           
         a = TopIndexVar + 1;
         b = BottomIndexVar + 1;
        }   
        
      Range(Open, High, Low, Close, rates);
     }
  }


//+------------------------------------------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//--- Amplitude Top

bool AmplitudeTop(const int TopIndexVar, const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], const MqlRates &rates_[])
  {
   if(TopIndexVar < 6)
     {
      return false;
     }
     
   double SymbolTickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
   //+--- 1 Step ---------------------------------------------------------------+
   //--- Forward from Top
   bool FirstStepCondition1 = true;
   bool FirstStepCondition2 = false;
   bool FirstStepCondition3 = false;
   int x = BottomIndex(LowPrice, TopIndexVar-1, false);//Candle to stop analysis 
   if((x == 0) || (x > (TopIndexVar - 5))) {x = TopIndexVar-5;}
   
   for(int i = TopIndexVar-2; i >= x; i--)
     {
      if(HighPrice[i] >= HighPrice[TopIndexVar])
        {
         return false;
        }
     }
     
   
   if(FirstStepCondition1)
     {
      int LowestBottom = LowerBottom(LowPrice, 2);
      if(LowestBottom > TopIndexVar-2) {LowestBottom = 1;}
      
      if(Candlesticks(Inverted_Hammer,   true, OpenPrice, HighPrice, LowPrice, ClosePrice, TopIndexVar, SymbolTickSize, Dis_Allow)   ||
         Candlesticks(Inverted_Hammer,   true, OpenPrice, HighPrice, LowPrice, ClosePrice, TopIndexVar-1, SymbolTickSize, Dis_Allow) ||
         Candlesticks(Gravestone,        true, OpenPrice, HighPrice, LowPrice, ClosePrice, TopIndexVar, SymbolTickSize, Dis_Allow) //||
         /*Candlesticks(Bearish_Engulfing, true, OpenPrice, HighPrice, LowPrice, ClosePrice, TopIndexVar, SymbolTickSize, Dis_Allow) ||
         Candlesticks(Dark_Cloud,        true, OpenPrice, HighPrice, LowPrice, ClosePrice, TopIndexVar, SymbolTickSize, Dis_Allow)*/   )
        {
         FirstStepCondition2 = true;
        }
      else
        {
         for(int i = TopIndexVar-1; i >= LowestBottom; i--)
           {
            if(Candlesticks(Bearish_Elephant_Bar, false, OpenPrice, HighPrice, LowPrice, ClosePrice, i, SymbolTickSize, Dis_Allow))
              {  
               FirstStepCondition3 = true;
               break;
              }
           }
        }      
     }  
   
   
   //+--- 2 Step ---------------------------------------------------------------+
   //--- Backward from Top
   if(FirstStepCondition2 || FirstStepCondition3)
     {
      int LowestBottom = LowerBottom(LowPrice, TopIndexVar+2);
      if(LowestBottom < TopIndexVar+2) {LowestBottom = TopIndexVar+4;}
      
      
      for(int i = TopIndexVar+2; i <= LowestBottom; i++)
        {
         if(HighPrice[i] >= HighPrice[TopIndexVar])
           {
            string CandleDate1 = StringSubstr((string) rates_[i].time,        0, 10); //Candle Date to 'i' Candle
            string CandleDate2 = StringSubstr((string) rates_[TopIndexVar].time, 0, 10); //Candle Date to 'TopIndexVar' Candle


            if(CandleDate1 == CandleDate2)
              {
               return false;
              }
              
            break;
           }
        }
        
      if(FirstStepCondition2)
        {
         return true;
        }  
        
      bool SecondStepCondition1 = true;  
      
      for(int i = TopIndexVar+2; i <= TopIndexVar+10; i++)
        {
         if(HighPrice[i] >= HighPrice[TopIndexVar])
           {
            SecondStepCondition1 = false;
           }
        }
        
      if(SecondStepCondition1)
        {
         return true;
        }  
        
      for(int i = TopIndexVar+1; i <= LowestBottom; i++)
        {
         if(Candlesticks(Bullish_Elephant_Bar, false, OpenPrice, HighPrice, LowPrice, ClosePrice, i, SymbolTickSize, Dis_Allow))
           {
            return true;
           }
        }
     }
     
     
   if(TopIndexVar >= 11)
     {
      for(int i = TopIndexVar-1; i >= TopIndexVar-9; i--)
        {
         if(HighPrice[i] >= HighPrice[TopIndexVar])
           {
            if(HighPrice[i-1] > HighPrice[i])
              {
               return false;
              }
           }
        }
        
      for(int i = TopIndexVar+1; i <= TopIndexVar+9; i++)
        {
         if(HighPrice[i] >= HighPrice[TopIndexVar])
           {
            if(HighPrice[i+1] > HighPrice[i])
              {
               return false;
              }
           }
        }
        
      return true;
     }  
   
   
   
   return false;
  }
  




//+------------------------------------------------------------------+
//--- Amplitude Bottom
bool AmplitudeBottom(const int BottomIndexVar, const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], const MqlRates &rates_[])
  {
   if(BottomIndexVar < 6)
     {
      return false;
     }
     
   double SymbolTickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
   //+--- 1 Step ---------------------------------------------------------------+
   //--- Forward from Bottom
   bool FirstStepCondition1 = true;
   bool FirstStepCondition2 = false;
   bool FirstStepCondition3 = false;
   int x = TopIndex(HighPrice, BottomIndexVar-1, false);//Candle to stop analysis 
   if((x == 0) || (x > (BottomIndexVar - 5))) {x = BottomIndexVar-5;}
   
   for(int i = BottomIndexVar-2; i >= x; i--)
     {
      if(LowPrice[i] <= LowPrice[BottomIndexVar])
        {
         return false;
        }
     }
     
   
   if(FirstStepCondition1)
     {
      int HighestTop = BiggestTop(HighPrice, 2);
      if(HighestTop > BottomIndexVar-2) {HighestTop = 1;}
      
      if(Candlesticks(Hammer,            true, OpenPrice, HighPrice, LowPrice, ClosePrice, BottomIndexVar, SymbolTickSize, Dis_Allow)   ||
         Candlesticks(Hammer,            true, OpenPrice, HighPrice, LowPrice, ClosePrice, BottomIndexVar-1, SymbolTickSize, Dis_Allow) ||
         Candlesticks(Dragonfly,         true, OpenPrice, HighPrice, LowPrice, ClosePrice, BottomIndexVar, SymbolTickSize, Dis_Allow) //||
         /*Candlesticks(Bullish_Engulfing, true, OpenPrice, HighPrice, LowPrice, ClosePrice, BottomIndexVar, SymbolTickSize, Dis_Allow) ||
         Candlesticks(Piercing_Line,     true, OpenPrice, HighPrice, LowPrice, ClosePrice, BottomIndexVar, SymbolTickSize, Dis_Allow)*/   )
        {
         FirstStepCondition2 = true;
        }
      else
        {
         for(int i = BottomIndexVar-1; i >= HighestTop; i--)
           {
            if(Candlesticks(Bullish_Elephant_Bar, false, OpenPrice, HighPrice, LowPrice, ClosePrice, i, SymbolTickSize, Dis_Allow))
              {  
               FirstStepCondition3 = true;
               break;
              }
           }
        }      
     }  
   
   
   //+--- 2 Step ---------------------------------------------------------------+
   //--- Backward from Top
   if(FirstStepCondition2 || FirstStepCondition3)
     {
      int HighestTop = BiggestTop(HighPrice, BottomIndexVar+2);
      if(HighestTop < BottomIndexVar+2) {HighestTop = BottomIndexVar+4;}
      
      for(int i = BottomIndexVar+2; i <= HighestTop; i++)
        {
         if(LowPrice[i] <= LowPrice[BottomIndexVar])
           {
            string CandleDate1 = StringSubstr((string) rates_[i].time,           0, 10); //Candle Date to 'i' Candle
            string CandleDate2 = StringSubstr((string) rates_[BottomIndexVar].time, 0, 10); //Candle Date to 'BottomIndexVar' Candle

           
            if(CandleDate1 == CandleDate2)
              {
               return false;
              }
              
            break;
           }
        }
        
      if(FirstStepCondition2)
        {
         return true;
        }
        
      bool SecondStepCondition1 = true;  
      
      for(int i = BottomIndexVar+2; i <= BottomIndexVar+10; i++)
        {
         if(LowPrice[i] <= LowPrice[BottomIndexVar])
           {
            SecondStepCondition1 = false;
           }
        }
        
      if(SecondStepCondition1)
        {
         return true;
        }  
        
      for(int i = BottomIndexVar+1; i <= HighestTop; i++)
        {
         if(Candlesticks(Bearish_Elephant_Bar, false, OpenPrice, HighPrice, LowPrice, ClosePrice, i, SymbolTickSize, Dis_Allow))
           {
            return true;
           }
        }
     }
     
     
   if(BottomIndexVar >= 11)
     {
      for(int i = BottomIndexVar-1; i >= BottomIndexVar-9; i--)
        {
         if(LowPrice[i] <= LowPrice[BottomIndexVar])
           {
            if(LowPrice[i-1] < LowPrice[i])
              {
               return false;
              }
           }
        }
        
      for(int i = BottomIndexVar+1; i <= BottomIndexVar+9; i++)
        {
         if(LowPrice[i] <= LowPrice[BottomIndexVar])
           {
            if(LowPrice[i+1] < LowPrice[i])
              {
               return false;
              }
           }
        }
        
      return true;
     }  
   
   
   
   return false;
  }
  



//+------------------------------------------------------------------+
//--- Range Function
void Range(const double &OpenPrice[], const double &HighPrice[], const double &LowPrice[], const double &ClosePrice[], const MqlRates &rates_[])
  {
   struct range_info
     {
      string name;//Range Name
      int    candle1;//Oldest Candle
      int    candle2;//Newest Candle
      double sup_price;//Support Price
      double res_price;//Resistance Price
      bool   alone;//Range don't touch other ranges
      bool   active;//Define if range is active or not
      color  color_;//Range color (hierarchy)
      
      
      void AssociateToArrayOBJ(range_info &obj[], int index, string _name, int _candle1, int _candle2, double _sup_price, double _res_price, bool _alone, bool _active, color _color_)
        {
         obj[index].name      = _name;
         obj[index].candle1   = _candle1;
         obj[index].candle2   = _candle2;
         obj[index].sup_price = _sup_price;
         obj[index].res_price = _res_price;
         obj[index].alone     = _alone;
         obj[index].active    = _active;
         obj[index].color_    = _color_;
        }
     };
    range_info ranges[20];
    range_info existRange[];
    
   //---------------------------------------------------------------------------------
   //--- 1 - FIND PRICES
   double PriceCandle[2][25] = {};//y = 0: Prices; y = 1: Indexes 
   int arr_TopIndexes[20]     = {};
   int arr_BottomIndexes[20]  = {};
   
   int a = 6;
   int b = 6;
     
   int jt = 0;  
   int jb = 0;
   for(int i = 0; i < 1000; i++)
     {
      int TopIndexVar    = TopIndex(HighPrice,   a); // Top Index Variable
      int BottomIndexVar = BottomIndex(LowPrice, b); // Bottom Index Variable
      
      if((jt == 20) && (jb == 20)){break;}
      
      if(AmplitudeTop(TopIndexVar, OpenPrice, HighPrice, LowPrice, ClosePrice, rates_) && (jt < 20))
        {
         arr_TopIndexes[jt] = TopIndexVar; 
         jt++;
        }
           
           
      if((AmplitudeBottom(BottomIndexVar, OpenPrice, HighPrice, LowPrice, ClosePrice, rates_)) && (jb < 20))
        {
         arr_BottomIndexes[jb] = BottomIndexVar;
         jb++;
        }
        
      a = TopIndexVar + 1;
      b = BottomIndexVar + 1;
     }
     
   int j1 = 0;  
   for(int i = 0; i < 5; i++)
     {
      int previndex = 0;
      
      for(int i2=0;i2<5;i2++)
        {
         if((MathAbs(arr_TopIndexes[i]-arr_BottomIndexes[i2])) < (MathAbs(arr_TopIndexes[i]-arr_BottomIndexes[previndex])))
           {
            previndex = i2;
           }
         else if(i2!=0)
           {
            break;
           }
        }
        
      PriceCandle[0][j1]   = HighPrice[arr_TopIndexes[i]];
      PriceCandle[0][j1+1] = LowPrice[arr_BottomIndexes[previndex]];
      PriceCandle[1][j1]   = arr_TopIndexes[i];
      PriceCandle[1][j1+1] = arr_BottomIndexes[previndex];
      
      j1 = j1+2;
     }
     
   j1 = 10;  
   for(int i = 0; i < 5; i++)
     {
      int previndex = 0;
      
      for(int i2=0;i2<5;i2++)
        {
         if((MathAbs(arr_BottomIndexes[i]-arr_TopIndexes[i2])) < (MathAbs(arr_BottomIndexes[i]-arr_TopIndexes[previndex])))
           {
            previndex = i2;
           }
         else if(i2!=0)
           {
            break;
           }
        }
        
      PriceCandle[0][j1+1] = LowPrice[arr_BottomIndexes[i]];
      PriceCandle[0][j1]   = HighPrice[arr_TopIndexes[previndex]];
      PriceCandle[1][j1+1] = arr_BottomIndexes[i];
      PriceCandle[1][j1]   = arr_TopIndexes[previndex];
      
      j1 = j1+2;
     }
     
   
   //---------------------------------------------------------------------------------
   //--- 1.1 - RANGE STILL EXISTS
   int iExistent = 0;
   for(int it = 5; it < 20; it++)
     {
      for(int ib = 0; ib < 20; ib++)
        {
         string RangeName = "["+(string)rates_[arr_TopIndexes[it]].time+"] "+(string)HighPrice[arr_TopIndexes[it]]+" --- ["+(string)rates_[arr_BottomIndexes[ib]].time+"] "+(string)LowPrice[arr_BottomIndexes[ib]];       
        
         if(ObjectFind(0, RangeName) >= 0)
           {
            if(ObjectGetInteger(0, RangeName, OBJPROP_COLOR) != clrGray)
              {
               ArrayResize(existRange, iExistent+1, iExistent+1);
               existRange[iExistent].AssociateToArrayOBJ(existRange, iExistent, RangeName, MathMax(arr_BottomIndexes[ib], arr_TopIndexes[it]), MathMin(arr_BottomIndexes[ib], arr_TopIndexes[it]), LowPrice[arr_BottomIndexes[ib]], HighPrice[arr_TopIndexes[it]], false, false, (color)ObjectGetInteger(0, RangeName, OBJPROP_COLOR));
               iExistent += 1;
              }
           }
        }
     }
     
   for(int ib = 5; ib < 20; ib++)
     {
      for(int it = 0; it < 20; it++)
        {
         string RangeName = "["+(string)rates_[arr_TopIndexes[it]].time+"] "+(string)HighPrice[arr_TopIndexes[it]]+" --- ["+(string)rates_[arr_BottomIndexes[ib]].time+"] "+(string)LowPrice[arr_BottomIndexes[ib]];        
        
         if(ObjectFind(0, RangeName) >= 0)
           {
            if(ObjectGetInteger(0, RangeName, OBJPROP_COLOR) != clrGray)
              {
               ArrayResize(existRange, iExistent+1, iExistent+1);
               existRange[iExistent].AssociateToArrayOBJ(existRange, iExistent, RangeName, MathMax(arr_BottomIndexes[ib], arr_TopIndexes[it]), MathMin(arr_BottomIndexes[ib], arr_TopIndexes[it]), LowPrice[arr_BottomIndexes[ib]], HighPrice[arr_TopIndexes[it]], false, false, (color)ObjectGetInteger(0, RangeName, OBJPROP_COLOR));
               iExistent += 1;
              }
           }
        }
     }
   
   //---------------------------------------------------------------------------------
   //--- (*) - Forward Existing Range Verification
   for(int i = 0; i < ArraySize(existRange);i++)
     {
      int aNewestCandle = existRange[i].candle2;
      int aCandlesOutRange = 0;
      int aIndexMinToRange = 0; 
      int aTopIndexVar2 = 0;
      int aBottomIndexVar2 = 0;
      bool aPriceOutRange = false;
      bool aResistanceBreak = false;
      bool aSupportBreak = false;

      int z = aNewestCandle - 2;  
      for(int z1 = 0; z1 < 5; z1++)
        {
         if(z<2) {break;}
           
         int z2 = TopIndex(HighPrice, z, false);
      
         if(HighPrice[z2] > existRange[i].res_price)
           {
            aResistanceBreak = true;

            aTopIndexVar2 = z2;
            break;
           }
      
         z = z2 - 1;  
        }
        
        
      //---------------------------
      z = aNewestCandle - 2;  
      for(int z1 = 0; z1 < 5; z1++)
        {
         if(z<2) {break;}
        
         int z2 = BottomIndex(LowPrice, z, false);
      
         if(LowPrice[z2] < existRange[i].sup_price)
           {
            aSupportBreak = true;
            Print("Support Break: ", z2);
            
            aBottomIndexVar2 = z2;
            break;
           }
      
         z = z2 - 1;  
        }
     
      
      for(int i3 = aNewestCandle-1; i3 > 0; i3--)
        {
         if(((1.618 * (existRange[i].res_price - existRange[i].sup_price)) <= (HighPrice[i3] - existRange[i].res_price)) ||
            ((1.618 * (existRange[i].res_price - existRange[i].sup_price)) <= (existRange[i].sup_price - LowPrice[i3])))
           {
            aPriceOutRange = true;
           }
   
         if((ClosePrice[i3] > existRange[i].res_price) || (ClosePrice[i3] < existRange[i].sup_price))
           {
            aCandlesOutRange += 1;
            if(aPriceOutRange)
              {
               aIndexMinToRange = i3;
               break;
              }
           }
           
         if(aPriceOutRange || (aCandlesOutRange > ((aNewestCandle-1)/2)))
           {
            if((aTopIndexVar2 < aBottomIndexVar2) && (aResistanceBreak))
              {
               for(int i4 = aTopIndexVar2-1; i4 > 0; i4--)
                 {
                  if(ClosePrice[i4] > HighPrice[aTopIndexVar2])
                    {
                     aIndexMinToRange = i4;
                     break;
                    }
                 }
              }  
              
            if((aBottomIndexVar2 < aTopIndexVar2) && (aSupportBreak))
              {
               for(int i4 = aBottomIndexVar2-1; i4 > 0; i4--)
                 {
                  if(ClosePrice[i4] < LowPrice[aBottomIndexVar2])
                    {
                     aIndexMinToRange = i4;
                     break;
                    }
                 }
              }
              
            break;
           }
        }
        
      
      //---------------------------------------------------------------------------------
      //--- 4.2 - Backward
      int aOldestCandle            = existRange[i].candle1;
      int aIndexMaxToRange         = aOldestCandle;
      int aBack161Target           = -1; //Var to Candle that Reaches 161.8% Range Target (Backward)
      bool aInsideRange            = false; //Bool Var to First Oldest Candle Inside Range
      int aarr_CandlesOutRange[];
      double aRangeSize = existRange[i].res_price - existRange[i].sup_price;
      double aResistanceRange[2][1] = {{existRange[i].res_price + (aRangeSize*0.33)}, {existRange[i].res_price - (aRangeSize*0.33)}};
      double aSupportRange[2][1]    = {{existRange[i].sup_price - (aRangeSize*0.33)}, {existRange[i].sup_price + (aRangeSize*0.33)}};

      for(int i3 = aOldestCandle+1; i3 < 500; i3++)
        {
         if(((1.618 * (existRange[i].res_price - existRange[i].sup_price)) <= (HighPrice[i3] - existRange[i].res_price)) ||
            ((1.618 * (existRange[i].res_price - existRange[i].sup_price)) <= (existRange[i].sup_price - LowPrice[i3])))
           {
            aBack161Target = i3;
            break;
           }
           
         if((aBack161Target == -1) && (i3 == 499))
           {
            aBack161Target = 500;
           }
        }
        
        
      int ac1 = aOldestCandle+1;
      int ad1 = aOldestCandle+1;  
      bool aRangeExistsBackwards = false;
        
      for(int i22 = 0; i22 < 15; i22++)
        {
         int aTopIndexVar1     = TopIndex(HighPrice,   ac1, false, 2);//Var to Tops Backward OldestCandle
         int aBottomIndexVar1  = BottomIndex(LowPrice, ad1, false, 2);//Var to Bottoms Backward OldestCandle 
         
         if((HighPrice[aTopIndexVar1] < aResistanceRange[0][0]) && (HighPrice[aTopIndexVar1] > aResistanceRange[1][0]))
           {
            aRangeExistsBackwards = true;
           } 
       
         if((LowPrice[aBottomIndexVar1] > aSupportRange[0][0]) && (LowPrice[aBottomIndexVar1] < aSupportRange[1][0]))
           {
            aRangeExistsBackwards = true;
           }  
         
         if(aRangeExistsBackwards)
           {
            break;
           }
         
         ac1 = aTopIndexVar1    + 1;
         ad1 = aBottomIndexVar1 + 1;
         
         if((ac1 > aBack161Target) || (ad1 > aBack161Target))
           {
            break;
           }
        }
         
         
      if(aRangeExistsBackwards)
        {
         int ay3 = 0; //Index to Fill arr_CandlesOutRanges
         
         for(int i3 = aBack161Target; i3 > aOldestCandle; i3--)
           {
            if((!aInsideRange) && ((ClosePrice[i3] <= existRange[i].res_price) && (ClosePrice[i3] >= existRange[i].sup_price)))
              {
               aInsideRange = true;
              }  
            
            if((aInsideRange) && ((ClosePrice[i3] > existRange[i].res_price) || (ClosePrice[i3] < existRange[i].sup_price)))
              {
               ArrayResize(aarr_CandlesOutRange, ay3+1, ay3+1);
               aarr_CandlesOutRange[ay3] = i3;
               ay3++;
              }
           }  
        
         
         if(ay3 != 1)
           {
            if((ay3) > ((aBack161Target - aOldestCandle)/2))
              {
               for(int i4 = ay3-1; i4 >= 1; i4--)
                 {
                  if(i4+1 < ((aarr_CandlesOutRange[i4] - aOldestCandle)*0.1))
                    {
                     for(int i5 = aarr_CandlesOutRange[ay3-i4]; i5 > aOldestCandle; i5--)
                       {
                        if((ClosePrice[i5] <= existRange[i].res_price) && (ClosePrice[i5] >= existRange[i].sup_price))
                          {
                           aIndexMaxToRange = i5;
                           break;
                          }
                        }
                     break;
                    }
                 }
              }
            else
              {
               for(int i4 = aBack161Target; i4 > aOldestCandle; i4--)
                 {
                  if((ClosePrice[i4] <= existRange[i].res_price) && (ClosePrice[i4] >= existRange[i].sup_price))
                    {
                     aIndexMaxToRange = i4;
                     break;
                    }
                 }
              } 
           }
         else
           {
            if(ay3 == 0)
              {
               aIndexMaxToRange = aBack161Target;   
              }
           }
        }
        
        
      
      Print("TIME 1: ", ObjectGetInteger(0, existRange[i].name, OBJPROP_DATE_SCALE, 1), " --- TIME 2: ", ObjectGetInteger(0, existRange[i].name, OBJPROP_LEVELWIDTH));
      
      ObjectMove(0, existRange[i].name, 0, rates_[aIndexMaxToRange].time, existRange[i].res_price);
      ObjectMove(0, existRange[i].name, 1, rates_[aIndexMinToRange].time, existRange[i].sup_price);
      
      if(aIndexMinToRange > 0){ObjectSetInteger(0, existRange[i].name, OBJPROP_COLOR, clrGray);}
     }
   //---------------------------------------------------------------------------------  
     
   ArrayPrint(PriceCandle);
   ArrayPrint(arr_TopIndexes);
   ArrayPrint(arr_BottomIndexes);
   ArrayPrint(existRange);
   
   for(int i = 0; i < 24; i++)
     {
      if(((PriceCandle[1][i] == 0) || (PriceCandle[1][i+1] == 0)))
        {
         break;
        }
        
      int Top          = (((double) ((double) i/2) - ((int) i/2)) == 0)? i   : i+1;
      int Bottom       = (((double) ((double) i/2) - ((int) i/2)) == 0)? i+1 : i;
      int CandlesRange = (int) MathAbs(PriceCandle[1][i] - PriceCandle[1][i+1]); //Range Between 2 Candles
      int NewestCandle = (int) MathMin(PriceCandle[1][i], PriceCandle[1][i+1]);  //Newest Between 2 Candles
      int OldestCandle = (int) MathMax(PriceCandle[1][i], PriceCandle[1][i+1]);  //Oldest Between 2 Candles
      
      
      //---------------------------------------------------------------------------------
      //--- 2 - VERIFY LOSS OF STRENGH
      bool LossOfStrengh = false;
      
      if((PriceCandle[0][i] != 0) && (PriceCandle[0][i+1] != 0) && (PriceCandle[0][Top] > PriceCandle[0][Bottom]))
        {
         if((NewestCandle - CandlesRange) > 0)
           {
            /*Print("Candle 1: ", PriceCandle[1][i], " - Candle 2: ", PriceCandle[1][i+1],
                  "\nCandles Range: ", CandlesRange, " - Newest Candle: ", NewestCandle);*/
           
            int CandlesINRange = 0; //Candles Into Range
            int NewestRange    = 0; //Candles After 'CandlesRange'
                  
            for(int y = NewestCandle - CandlesRange; y < NewestCandle; y++)
              {
               if((ClosePrice[y] <= PriceCandle[0][Top]) && (ClosePrice[y] >= PriceCandle[0][Bottom]))
                 {
                  CandlesINRange += 1;
                 }
                 
               if(CandlesINRange > (CandlesRange/2))
                 {
                  Print("~50% Candles Into Range!");
                 
                  double x  = PriceCandle[0][Top] - PriceCandle[0][Bottom];
                  double x1 = ClosePrice[NewestCandle] - ClosePrice[NewestCandle - CandlesRange];
                  double x2 = PriceCandle[1][Top] - PriceCandle[1][Bottom];
               
                  if((x2 > 0 && x1 < 0) || (x2 < 0 && x1 > 0)) //--- Condition Yet to Be Verified
                    {
                     if(MathAbs(x1) < (x*1.328))
                       {
                        Print("LOSS OF STRENGH!", "\nResistance: ", PriceCandle[0][Top], "\nSupport: ", PriceCandle[0][Bottom]);
                        LossOfStrengh = true;
                       }
                    } 
                    
                  break;
                 }
              }
           }
        }
      //---------------------------------------------------------------------------------  
        
        
      //---------------------------------------------------------------------------------
      //--- 3 - CONFIRM SUPPORTS AND RESISTANCES
      if(LossOfStrengh)
        {
         int c = NewestCandle - 2;
         int d = NewestCandle - 2;
         
         bool ResistanceExist = false;
         bool SupportExist    = false;
         bool ResistanceBreak = false;
         bool SupportBreak    = false;
         
         
         for(int i2 = 0; i2 < 15; i2++)
           {
            int TopIndexVar     = TopIndex(HighPrice,   c, false, 2);//Var to Tops Forward 
            int BottomIndexVar  = BottomIndex(LowPrice, d, false, 2); 
            int TopIndexVar2    = 0;//Var to Resistance Break Top
            int BottomIndexVar2 = 0;//Var to Support Break Bottom
            
            double RangeSize             = PriceCandle[0][Top] - PriceCandle[0][Bottom];
            double ResistanceRange[2][1] = {{PriceCandle[0][Top]    + (RangeSize*0.33)}, {PriceCandle[0][Top]    - (RangeSize*0.33)}};
            double SupportRange[2][1]    = {{PriceCandle[0][Bottom] - (RangeSize*0.33)}, {PriceCandle[0][Bottom] + (RangeSize*0.33)}};
            
            
            if((HighPrice[TopIndexVar] < ResistanceRange[0][0]) && (HighPrice[TopIndexVar] > ResistanceRange[1][0]))
              {
               ResistanceExist = true;
              } 
            if((LowPrice[BottomIndexVar] > SupportRange[0][0]) && (LowPrice[BottomIndexVar] < SupportRange[1][0]))
              {
               SupportExist = true;
              }  
            
            if(i2 == 0)
              {
               int z = NewestCandle - 2;  
               for(int z1 = 0; z1 < 5; z1++)
                 {
                  if(z<2) {break;}
                    
                  int z2 = TopIndex(HighPrice, z, false);
               
                  if(HighPrice[z2] > PriceCandle[0][Top])
                    {
                     ResistanceBreak = true;
                     Print("Resistance Break: ", z2);
                  
                     TopIndexVar2 = z2;
                     break;
                    }
               
                  z = z2 - 1;  
                 }
                 
               //---------------------------
               z = NewestCandle - 2;  
               for(int z1 = 0; z1 < 5; z1++)
                 {
                  if(z<2) {break;}
                 
                  int z2 = BottomIndex(LowPrice, z, false);
               
                  if(LowPrice[z2] < PriceCandle[0][Bottom])
                    {
                     SupportBreak = true;
                     Print("Support Break: ", z2);
                     
                     BottomIndexVar2 = z2;
                     break;
                    }
               
                  z = z2 - 1;  
                 }
              }  
            
            //---------------------------------------------------------------------------------
               
            
            //---------------------------------------------------------------------------------
            //--- 4 - DEFINE TIME RANGE TO DRAW OBJ
            int CandlesOutRange = 0;
            int IndexMinToRange = 0;
            
            bool PriceOutRange = false;
            
            //---------------------------------------------------------------------------------
            //--- 4.1 - Forward
            for(int i3 = NewestCandle-1; i3 > 0; i3--)
              {
               if(((1.618 * (PriceCandle[0][Top] - PriceCandle[0][Bottom])) <= (HighPrice[i3] - PriceCandle[0][Top])) ||
                  ((1.618 * (PriceCandle[0][Top] - PriceCandle[0][Bottom])) <= (PriceCandle[0][Bottom] - LowPrice[i3])))
                 {
                  PriceOutRange = true;
                 }

               //Print("RESISTANCE: ", PriceCandle[0][Top], " --- SUPPORT: ", PriceCandle[0][Bottom]);
               if((ClosePrice[i3] > PriceCandle[0][Top]) || (ClosePrice[i3] < PriceCandle[0][Bottom]))
                 {
                  CandlesOutRange += 1;
                  //Print("I3: ", i3); 
                  if(PriceOutRange)
                    {
                     IndexMinToRange = i3;
                     break;
                    }
                 }
                 
               if(PriceOutRange || (CandlesOutRange > ((NewestCandle-1)/2)))
                 {
                  if((TopIndexVar2 < BottomIndexVar2) && (ResistanceBreak))
                    {
                     for(int i4 = TopIndexVar2-1; i4 > 0; i4--)
                       {
                        if(ClosePrice[i4] > HighPrice[TopIndexVar2])
                          {
                           IndexMinToRange = i4;
                           Print("Break Confirmed: ", i4);
                           break;
                          }
                       }
                    }  
                    
                  if((BottomIndexVar2 < TopIndexVar2) && (SupportBreak))
                    {
                     for(int i4 = BottomIndexVar2-1; i4 > 0; i4--)
                       {
                        if(ClosePrice[i4] < LowPrice[BottomIndexVar2])
                          {
                           IndexMinToRange = i4;
                           Print("Break Confirmed: ", i4);
                           break;
                          }
                       }
                    }
                    
                  break;
                 }
              }  
              
             
            //---------------------------------------------------------------------------------
            //--- 4.2 - Backward
            int IndexMaxToRange         = OldestCandle;
            int Back161Target           = -1; //Var to Candle that Reaches 161.8% Range Target (Backward)
            bool InsideRange            = false; //Bool Var to First Oldest Candle Inside Range
            int arr_CandlesOutRange[];


            for(int i3 = OldestCandle+1; i3 < 500; i3++)
              {
               if(((1.618 * (PriceCandle[0][Top] - PriceCandle[0][Bottom])) <= (HighPrice[i3] - PriceCandle[0][Top])) ||
                  ((1.618 * (PriceCandle[0][Top] - PriceCandle[0][Bottom])) <= (PriceCandle[0][Bottom] - LowPrice[i3])))
                 {
                  Back161Target = i3;
                  break;
                 }
                 
               if((Back161Target == -1) && (i3 == 499))
                 {
                  Back161Target = 500;
                 }
              }
              
              
            int c1 = OldestCandle+1;
            int d1 = OldestCandle+1;  
            bool RangeExistsBackwards = false;
              
            for(int i22 = 0; i22 < 15; i22++)
              {
               int TopIndexVar1     = TopIndex(HighPrice,   c1, false, 2);//Var to Tops Backward OldestCandle
               int BottomIndexVar1  = BottomIndex(LowPrice, d1, false, 2);//Var to Bottoms Backward OldestCandle 
               
               if((HighPrice[TopIndexVar1] < ResistanceRange[0][0]) && (HighPrice[TopIndexVar1] > ResistanceRange[1][0]))
                 {
                  RangeExistsBackwards = true;
                 } 
             
               if((LowPrice[BottomIndexVar1] > SupportRange[0][0]) && (LowPrice[BottomIndexVar1] < SupportRange[1][0]))
                 {
                  RangeExistsBackwards = true;
                 }  
               
               if(RangeExistsBackwards)
                 {
                  break;
                 }
               
               c1 = TopIndexVar1    + 1;
               d1 = BottomIndexVar1 + 1;
               
               if((c1 > Back161Target) || (d1 > Back161Target))
                 {
                  break;
                 }
              }
               
               
            if(RangeExistsBackwards)
              {
               int y3 = 0; //Index to Fill arr_CandlesOutRanges
               
               for(int i3 = Back161Target; i3 > OldestCandle; i3--)
                 {
                  if((!InsideRange) && ((ClosePrice[i3] <= PriceCandle[0][Top]) && (ClosePrice[i3] >= PriceCandle[0][Bottom])))
                    {
                     InsideRange = true;
                    }  
                  
                  if((InsideRange) && ((ClosePrice[i3] > PriceCandle[0][Top]) || (ClosePrice[i3] < PriceCandle[0][Bottom])))
                    {
                     ArrayResize(arr_CandlesOutRange, y3+1, y3+1);
                     arr_CandlesOutRange[y3] = i3;
                     y3++;
                    }
                 }  
              
               
               if(y3 != 1)
                 {
                  if((y3) > ((Back161Target - OldestCandle)/2))
                    {
                     for(int i4 = y3-1; i4 >= 1; i4--)
                       {
                        if(i4+1 < ((arr_CandlesOutRange[i4] - OldestCandle)*0.1))
                          {
                           for(int i5 = arr_CandlesOutRange[y3-i4]; i5 > OldestCandle; i5--)
                             {
                              if((ClosePrice[i5] <= PriceCandle[0][Top]) && (ClosePrice[i5] >= PriceCandle[0][Bottom]))
                                {
                                 IndexMaxToRange = i5;
                                 break;
                                }
                              }
                           break;
                          }
                       }
                    }
                  else
                    {
                     for(int i4 = Back161Target; i4 > OldestCandle; i4--)
                       {
                        if((ClosePrice[i4] <= PriceCandle[0][Top]) && (ClosePrice[i4] >= PriceCandle[0][Bottom]))
                          {
                           IndexMaxToRange = i4;
                           break;
                          }
                       }
                    } 
                 }
               else
                 {
                  if(y3 == 0)
                    {
                     IndexMaxToRange = Back161Target;   
                    }
                 }
              }
            
            //---------------------------------------------------------------------------------  
            
                    
            //---------------------------------------------------------------------------------
            //--- 5 - DRAW OBJ  
            if(ResistanceExist && SupportExist)
              {
               string RangeName = "["+(string)rates_[(int)PriceCandle[1][Top]].time+"] "+(string)PriceCandle[0][Top]+" --- ["+(string)rates_[(int)PriceCandle[1][Bottom]].time+"] "+(string)PriceCandle[0][Bottom];
               Print(RangeName); 
               
               if(ObjectFind(0, RangeName) < 0)
                 {
                  ranges[i].AssociateToArrayOBJ(ranges, i, RangeName, IndexMaxToRange, IndexMinToRange, PriceCandle[0][Bottom], PriceCandle[0][Top], false, false, clrViolet);
                 }
               else
                 {
                  ranges[i].AssociateToArrayOBJ(ranges, i, RangeName, IndexMaxToRange, IndexMinToRange, PriceCandle[0][Bottom], PriceCandle[0][Top], false, false, (color) ObjectGetInteger(0, RangeName, OBJPROP_COLOR));
                 }
             
               /*Print("res: ", PriceCandle[1][Top], " --- supp: ", PriceCandle[1][Bottom]);
               Print("obj_test --- res: ", ranges[i].res_price, " --- supp: ", ranges[i].sup_price);*/
              
               
               for(int i5 = 0; i5 < 20; i5++)
                 {
                  if(ranges[i].candle2 != 0){ranges[i].color_ = clrGray; break;} 
                  
                 
                  if(((ranges[i].candle2 <= ranges[i5].candle1) || (ranges[i].candle1 >= ranges[i5].candle2)) ||
                     ((ranges[i].res_price >= ranges[i5].res_price) || (ranges[i].sup_price <= ranges[i5].sup_price)))
                    {
                     ranges[i].alone  = true;
                     ranges[i].color_ = clrDarkRed; 
                    }
                  else
                    {
                     ranges[i].alone = false;
                     
                     if((ranges[i].res_price <= ranges[i5].res_price) && (ranges[i].sup_price >= ranges[i5].sup_price))
                       {
                        if((ranges[i].res_price - ranges[i].sup_price) <= ((ranges[i5].res_price - ranges[i5].sup_price) * 0.33))
                          {
                           (ranges[i5].color_ != clrDarkOrange)? ranges[i].color_ = clrDarkOrange : ranges[i].color_ = clrDarkBlue; 
                          }
                       }
                     else
                       {
                        if(ranges[i].res_price > ranges[i5].res_price)
                          {
                           if((((ranges[i].res_price - ranges[i].sup_price)*2) >= (ranges[i5].res_price - ranges[i].sup_price)) &&
                              ((ranges[i5].res_price - ranges[i].sup_price) <= ((ranges[i5].res_price - ranges[i5].sup_price) * 0.33)))
                             {
                              if((ranges[i].res_price - ranges[i].sup_price) < (ranges[i5].res_price - ranges[i5].sup_price))
                                {
                                 ranges[i].color_ = clrDarkRed;
                                }
                              else
                                {
                                 ranges[i].color_ = clrDarkOrange;
                                }
                             }
                          }
                        else
                          {
                           if((((ranges[i].res_price - ranges[i].sup_price)*2) >= (ranges[i].res_price - ranges[i5].sup_price)) &&
                              ((ranges[i].res_price - ranges[i5].sup_price) <= ((ranges[i5].res_price - ranges[i5].sup_price) * 0.33)))
                             {
                              if((ranges[i].res_price - ranges[i].sup_price) < (ranges[i5].res_price - ranges[i5].sup_price))
                                {
                                 ranges[i].color_ = clrDarkRed;
                                }
                              else
                                {
                                 ranges[i].color_ = clrDarkOrange;
                                }
                             }
                          }
                       }
                       
                     break;
                    }
                 }  
                 
               /*
                only draw if
                
                  range dont touch on each others
                else
                  contained case
                     takes at max 33% of another range (price range)
                     do not touch the sup or res ranges and dont take more than 50% of time range
                  
                  not contained case
                     dont take more than 33% of range and the price range is 2x greater that is taked
               */

               
               
               if(ranges[i].color_ != clrViolet)
                 {
                  if(ObjectFind(0, RangeName) < 0)
                    {
                     if(!ObjectCreate(0, RangeName, OBJ_RECTANGLE, 0, rates_[IndexMaxToRange].time, PriceCandle[0][Bottom], rates_[IndexMinToRange].time, PriceCandle[0][Top]))
                       {
                        Print("Cannot Create Object: ", RangeName, "Error: ", GetLastError());
                       }
                    
                     ObjectSetInteger(0, RangeName, OBJPROP_FILL, true);
                     ObjectSetInteger(0, RangeName, OBJPROP_COLOR, ranges[i].color_);
                     ObjectSetInteger(0, RangeName, OBJPROP_BACK, true);
                     
                     ChartRedraw();
                    } 
                  else if(ObjectFind(0, RangeName) >= 0)
                    {
                     ObjectMove(0, RangeName, 0, rates_[IndexMinToRange].time, PriceCandle[0][Bottom]);
                     ObjectMove(0, RangeName, 1, rates_[IndexMaxToRange].time,    PriceCandle[0][Top]);
                     ObjectSetInteger(0, RangeName, OBJPROP_COLOR, ranges[i].color_);
                    
                     ChartRedraw();
                    } 
                 }
               
              }      
              
            
            c = TopIndexVar     - 1;
            d = BottomIndexVar  - 1;
            
            if((c < 2) || (d < 2))
              {
               break;
              }
           }
        }
     }
  }