#include <StratFoundry/Hash.mqh>
#include <StratFoundry/TimeframeHelper.mqh>

uint getContextUID(string symbol, int period)
{
   return djb2(symbol + GetTimeFrame(period));
}

uint getContextUID()
{
   return getContextUID(Symbol(), Period());
}