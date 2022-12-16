//+------------------------------------------------------------------+
//|                                      1 TREND - Old Indicator.mq5 |
//|                                           Copyright 2021, FABIO. |
//|                              https://instagram.com/fabio.orione/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, FABIO."
#property link      "https://instagram.com/fabio.orione/"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2

//--- PLOT MOVING AVERAGE
#property indicator_label1  "MOVING AVERAGE"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrRed, clrGreen, clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- PLOT COLOR CANDLES
#property indicator_label2  "CANDLES"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrRed, clrFireBrick, clrTomato, clrGreen, clrDarkOliveGreen, clrPaleGreen, clrDarkGray, clrWhite
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- INPUTS
input int            MAPeriod = 15;
input ENUM_MA_METHOD MAType   = MODE_EMA;

input int WhiteMAPeriod = 200;
input int BrownMAPeriod =  27;
input int RedMAPeriod   =  27;
input int PinkMAPeriod  =  15;
input int GrayMAPeriod  =  15;
input int MACDFastEMA   =  20;
input int MACDSlowEMA   = 100;
input int MACDSignalP   =   9;
input ENUM_APPLIED_PRICE MACDPriceType = PRICE_TYPICAL;

//--- HANDLERS
//--- PLOT
int MAHandler;

//--- MACD
int MACDHandler;

//--- MOVING AVERAGES
int WhiteHandler;
int BrownHandler;
int RedHandler;
int PinkHandler;
int GrayHandler;

//--- ARRAYS
//--- PLOTS
double MovingAverage[];
double MAColor[];

double CandleOpen[];
double CandleHigh[];
double CandleLow[];
double CandleClose[];
double CandleColor[];

//--- MACD
double MACDMain[];
double MACDSignal[];

//--- MOVING AVERAGES
double WhiteMA[];
double BrownMA[];
double RedMA[];
double PinkMA[];
double GrayMA[];

int OnInit()
  {
   //--- SET BUFFERS
   SetIndexBuffer(0,MovingAverage,INDICATOR_DATA);
   SetIndexBuffer(1,MAColor,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,CandleOpen,INDICATOR_DATA);
   SetIndexBuffer(3,CandleHigh,INDICATOR_DATA);
   SetIndexBuffer(4,CandleLow,INDICATOR_DATA);
   SetIndexBuffer(5,CandleClose,INDICATOR_DATA);
   SetIndexBuffer(6,CandleColor,INDICATOR_COLOR_INDEX);
   
   //---
   MAHandler     = iMA(_Symbol, _Period, MAPeriod, 0, MAType, PRICE_CLOSE);
   
   MACDHandler   = iMACD(_Symbol, _Period, MACDFastEMA, MACDSlowEMA, MACDSignalP, MACDPriceType);

   WhiteHandler  = iMA(_Symbol, _Period, WhiteMAPeriod, 0, MODE_SMA,  PRICE_CLOSE);
   BrownHandler  = iMA(_Symbol, _Period, BrownMAPeriod, 0, MODE_SMMA, PRICE_OPEN);
   RedHandler    = iMA(_Symbol, _Period, RedMAPeriod,   0, MODE_SMA,  PRICE_OPEN);
   PinkHandler   = iMA(_Symbol, _Period, PinkMAPeriod,  0, MODE_EMA,  PRICE_CLOSE);
   GrayHandler   = iMA(_Symbol, _Period, GrayMAPeriod,  0, MODE_LWMA, PRICE_CLOSE);
   //---
   
   ChartIndicatorAdd(0, 1, MACDHandler);
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   IndicatorRelease(MACDHandler);
   for(int i = 0; i < 1; i++)
     {
      ChartIndicatorDelete(0, 1, ChartIndicatorName(0, 1, i)); 
     }
   
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   //---
   CopyBuffer(MAHandler, 0, 0, rates_total, MovingAverage);
   //---
   CopyBuffer(MACDHandler, 0, 0, rates_total, MACDMain);
   CopyBuffer(MACDHandler, 1, 0, rates_total, MACDSignal);
   
   CopyBuffer(WhiteHandler, 0, 0, rates_total, WhiteMA);
   CopyBuffer(BrownHandler, 0, 0, rates_total, BrownMA);
   CopyBuffer(RedHandler, 0, 0, rates_total, RedMA);
   CopyBuffer(PinkHandler, 0, 0, rates_total, PinkMA);
   CopyBuffer(GrayHandler, 0, 0, rates_total, GrayMA);
   //---
   
   int iStart;
   
   if(prev_calculated <= 2)
     {
      iStart = 2;
     }
   else
     {
      iStart = prev_calculated - 1;
     }
   
   //---
   for(int i = iStart; i < rates_total; i++)
     {
      if(MovingAverage[i] > MovingAverage[i - 1])
        {
         SetMAColor(MAColor, i, 1);
        }
      else
        {
         if(MovingAverage[i] < MovingAverage[i - 1])
           {
            SetMAColor(MAColor, i, 0); 
           }
         else
           {
            SetMAColor(MAColor, i, 2);
           }
        }
        
      //--- SIDE TREND
      bool SideTrend  = false;
      
      bool SideTrend1 = (MACDMain[i - 1] > 0) && (MACDSignal[i - 1] > 0);
      bool SideTrend2 = (MACDMain[i - 1] < 0) && (MACDSignal[i - 1] < 0);
      bool SideTrend3 = (MACDMain[i - 1] > MACDMain[i - 2]) && (MACDSignal[i - 1] > MACDSignal[i - 2]);
      bool SideTrend4 = (MACDMain[i - 1] < MACDMain[i - 2]) && (MACDSignal[i - 1] < MACDSignal[i - 2]);
     
      if(SideTrend1)
        {
         if(MACDMain[i - 1] < MACDSignal[i - 1])
           {
            SideTrend = true;
            SetCandleColor(CandleColor, i, 6, close, open, high, low);
           }
        }
      else
        {
         if(SideTrend2)
           {
            if(MACDMain[i - 1] > MACDSignal[i - 1])
              {
               SideTrend = true;
               SetCandleColor(CandleColor, i, 6, close, open, high, low);
              }
           }
        }
      
      if(!SideTrend1 && !SideTrend2)
        {
         if(SideTrend3 && MACDSignal[i - 1] > 0 && MACDMain[i - 1] < 0)
           {
            SideTrend = true;
            SetCandleColor(CandleColor, i, 6, close, open, high, low);
           }
         else
           {
            if(SideTrend4 && MACDSignal[i - 1] < 0 && MACDMain[i - 1] > 0)
              {
               SideTrend = true;
               SetCandleColor(CandleColor, i, 6, close, open, high, low);
              }
           }
        }  
        
      //--- BULLISH TREND
      if(!SideTrend)
        {
         bool PrimaryBullishTrend1   = false;
         bool PrimaryBullishTrend2   = false;
         
         bool SecondaryBullishTrend1 = false;
         bool SecondaryBullishTrend2 = false;

         //--- Primary Bullish Trend
         if((close[i - 1] > WhiteMA[i - 1]) && (PinkMA[i - 1] > WhiteMA[i - 1]))
           {
            PrimaryBullishTrend1 = true;
           }
      
         if(PrimaryBullishTrend1)
           {
            if(WhiteMA[i] > WhiteMA[i - 1])
              {
               PrimaryBullishTrend2 = true;
              }
           }
            
         //--- Secondary Bullish Trend
         if((PinkMA[i] > PinkMA[i - 1]) && (close[i] > PinkMA[i] || close[i - 1] > PinkMA[i - 1])) 
           {
            SecondaryBullishTrend1 = true;
           } 
             
         if(SecondaryBullishTrend1)
           { 
            if(GrayMA[i - 1] > BrownMA[i - 1])
              {
               SecondaryBullishTrend2 = true;
              }
           }
          
         bool BullishTrendLvl3 = PrimaryBullishTrend2 && SecondaryBullishTrend2;
         bool BullishTrendLvl1 = ((!PrimaryBullishTrend2 && !SecondaryBullishTrend2) && (PrimaryBullishTrend1 && SecondaryBullishTrend1));
         bool BullishTrendLvl2 = ((!BullishTrendLvl1 && !BullishTrendLvl3) && ((PrimaryBullishTrend1 && SecondaryBullishTrend2) && (!PrimaryBullishTrend2)));
         
         if(close[i] > open[i])
           {
            if(BullishTrendLvl3)
              {
               SetCandleColor(CandleColor, i, 3, close, open, high, low);
              }
            else
              {
               if(BullishTrendLvl1)
                 {
                  SetCandleColor(CandleColor, i, 4, close, open, high, low);
                 }
               else
                 {
                  if(BullishTrendLvl2)
                    {
                     SetCandleColor(CandleColor, i, 5, close, open, high, low);
                    }
                 }
              }
           }
         else
           {
            if((close[i] < open[i]) && (BullishTrendLvl3 || BullishTrendLvl1 || BullishTrendLvl2))
              {
               SetCandleColor(CandleColor, i, 7, close, open, high, low);
              }
           }
         
         //--- BEARISH TREND
         if(!BullishTrendLvl1 && !BullishTrendLvl2 && !BullishTrendLvl3)
           {
            bool PrimaryBearishTrend1   = false;
            bool PrimaryBearishTrend2   = false;
   
            bool SecondaryBearishTrend1 = false;
            bool SecondaryBearishTrend2 = false; 
          
            //--- Primary Bearish Trend
            if((close[i - 1] < WhiteMA[i - 1]) && (PinkMA[i - 1] < WhiteMA[i - 1]))
              {
               PrimaryBearishTrend1 = true;
              }
           
            if(PrimaryBearishTrend1)
              {
               if(WhiteMA[i] < WhiteMA[i - 1])
                 {
                  PrimaryBearishTrend2 = true;
                 }
              }
           
            //--- Secondary Bearish Trend
            if((PinkMA[i] < PinkMA[i - 1]) && (close[i] < PinkMA[i] || close[i - 1] < PinkMA[i - 1]))
              {
               SecondaryBearishTrend1 = true;
              }
           
            if(SecondaryBearishTrend1)
              {
               if(GrayMA[i - 1] < BrownMA[i - 1])
                 {
                  SecondaryBearishTrend2 = true;
                 }
              }
     
            bool BearishTrendLvl3 = PrimaryBearishTrend2 && SecondaryBearishTrend2;
            bool BearishTrendLvl1 = ((!PrimaryBearishTrend2 && !SecondaryBearishTrend2) && (PrimaryBearishTrend1 && SecondaryBearishTrend1));
            bool BearishTrendLvl2 = ((!BearishTrendLvl1 && !BearishTrendLvl3) && ((PrimaryBearishTrend1 && SecondaryBearishTrend2) && (!PrimaryBearishTrend2)));

            if(close[i] < open[i])
              {
               if(BearishTrendLvl3)
                 {
                  SetCandleColor(CandleColor, i, 0, close, open, high, low);
                 }
               else
                 {
                  if(BearishTrendLvl1)
                    {
                     SetCandleColor(CandleColor, i, 2, close, open, high, low);
                    }
                  else
                    {
                     if(BearishTrendLvl2)
                       {
                        SetCandleColor(CandleColor, i, 1, close, open, high, low);
                       }
                    }
                 }
              }
            else
              {
               if((close[i] > open[i]) && (BearishTrendLvl3 || BearishTrendLvl1 || BearishTrendLvl2))
                 {
                  SetCandleColor(CandleColor, i, 7, close, open, high, low);
                 }
              }
           }
        } 
     }
     
   return(rates_total);
  }

//+------------------------------------------------------------------+
void SetMAColor(double &MAColor[], int Index, int Color)
  {
   MAColor[Index] = Color;
  }

void SetCandleColor(double &CandleColor[], int Index, int Color, const double &close[], const double &open[], const double &high[], const double &low[])
  {
   SetCandleBuffers(Index, close, open, high, low);
   CandleColor[Index] = Color;
  }
  
/*void DontSetCandleColor(double &CandleColor[], int Index, const double &close[], const double &open[], const double &high[], const double &low[])
  {
   SetCandleBuffers(Index, close, open, high, low);
   CandleColor[Index] = EMPTY_VALUE;
  }*/

void SetCandleBuffers(int Index, const double &close[], const double &open[], const double &high[], const double &low[])
  {
   CandleOpen[Index]  = open[Index];
   CandleHigh[Index]  = high[Index];
   CandleLow[Index]   = low[Index];
   CandleClose[Index] = close[Index];
  }
//+------------------------------------------------------------------+
