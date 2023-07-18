double HeikenAshiOpen(uint candId)
{
    return (Open[candId + 1] + Close[candId + 1]) / 2;
} 

double HeikenAshiClose(uint candId)
{
    return (Open[candId] + High[candId] + Low[candId] + Close[candId]) / 4;
} 

double HeikenAshiHigh(uint candId)
{
    double high = High[candId];

    high = Open[candId] > high ? Open[candId] : high;
    high = Close[candId] > high ? Close[candId] : high;

    return high;
} 

double HeikenAshiLow(uint candId)
{
    double low = Low[candId];

    low = Open[candId] < low ? Open[candId] : low;
    low = Close[candId] < low ? Close[candId] : low;

    return low;
}

bool HeikenAshiCandleBullish(uint candId)
{
    return HeikenAshiClose(candId) > HeikenAshiOpen(candId);
}

bool HeikenAshiCandleBearish(uint candId)
{
    return HeikenAshiClose(candId) < HeikenAshiOpen(candId);
}

bool PastNHACandlesBullish(int n)
{
   for(int i = 1; i <=  1 + n; i++)
   {
      if(HeikenAshiCandleBullish(i) == false)
         return false;
   } 
   
   return true;
}

bool PastNHACandlesBearish(int n)
{
   for(int i = 1; i <= 1 + n; i++)
   {
      if(HeikenAshiCandleBearish(i) == false)
         return false;
   } 
   
   return true;
}
