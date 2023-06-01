#include<Arrays\List.mqh>
#include<StratFoundry\TradeBatchDesc.mqh>
#include<StratFoundry\ContextHelper.mqh>
#include<StratFoundry\TradeHelper.mqh>
#include<StratFoundry\TimeframeHelper.mqh>
#include<StratFoundry\LotHelper.mqh>

input float LEVERAGE = 1;

#ifndef MAX_TRADES_RUNNING
#define MAX_TRADES_RUNNING 1
#endif

enum EventType {
   EV_NONE,
   EV_TICK,
   EV_CLOSE_CANDLE
};

class BaseStrategy {
private:

   static void ProxyOnTradeOpCallback(TradeBatchDesc& thiz, TradeState top)
   {
      gStrategy.onTradeOpCallback(thiz, top);
   }
   
   datetime mLastCandleTime;
   bool bInTrade;
   int lastClosedTradeIdx;
   CList trades;
   TradeBatchDesc* lastTrade;
   TradeBatchDesc lastTradeDesc;
   EventType updateSignalEvent;
   double mTpPips;
   double mSlPips;
   double perTradeRiskPerc;
   
public:


BaseStrategy()
{
   bInTrade = false;
   mLastCandleTime = 0;
   lastTrade = NULL;
   lastTradeDesc.Reset();
   updateSignalEvent = EV_NONE;
   perTradeRiskPerc = 1;
   mTpPips = 0;
   mSlPips = 0;
}

void setUpdateSignalsAt(EventType eventType)
{
   updateSignalEvent = eventType;
}

void setTpPips(double _tpPips)
{
   mTpPips = _tpPips;
}

void setSlPips(double _slPips)
{
   mSlPips = _slPips;
}

void setPerTradeRiskPerc(double _riskPerc)
{
   perTradeRiskPerc = _riskPerc;
}

virtual ~BaseStrategy(){}

virtual void onTradeOpCallback(TradeBatchDesc& thiz, TradeState state)
{
   switch(state)
   {
      case TradeState::OPEN:
         printf("Trade Opened");
      break;
      
      case TradeState::CLOSED:
         printf("Trade Closed with %f Profit", thiz.getProfits());
      break;
   }
      
}

virtual void OnShortSignal()
{
   StrategyOp(TradeOp::SHORT, mSlPips, mTpPips, GetPerTradeRiskAmount(perTradeRiskPerc));
}

virtual void OnLongSignal()
{
   StrategyOp(TradeOp::LONG, mSlPips, mTpPips, GetPerTradeRiskAmount(perTradeRiskPerc));
}

void UpdateCandleEvents()
{
   if (mLastCandleTime != Time[0])
   {
      OnCandleClosed();
      mLastCandleTime = Time[0];
   }
}

virtual void Update() {
   if(updateSignalEvent == EV_TICK)
      UpdateSignals();
}

virtual void OnTick()
{
   Comment("Spread = ", MarketInfo(_Symbol,MODE_SPREAD));
   
   lastTradeDesc.Update();
   UpdateCandleEvents();   
   lastTradeDesc.Update();
   Update();
}

virtual void OnInit()
{
   EventSetTimer(60);
}

virtual void OnDeinit()
{
   EventKillTimer();
}

bool StrategyOp(TradeOp tOp, int _slPips, int _tpPips, double riskAmmount)
{
   //TradeBatchDesc* tbd = new TradeBatchDesc();
   
   /*if(trades.Add(tbd) > COMPOUND_STAGES)
   {
      trades.GetFirstNode();
      trades.DeleteCurrent();
   }*/
   
   //trades.Add(tbd);
   
   lastTradeDesc.Reset();
   lastTradeDesc.setCallback(ProxyOnTradeOpCallback);
   
   return StrategyOp(tOp, _slPips, _tpPips, riskAmmount, /*tbd*/lastTradeDesc);
}

bool StrategyOpAbs(TradeOp tOp, int absSl, int absTp, double riskAmmount)
{
   //TradeBatchDesc* tbd = new TradeBatchDesc();
   
   /*if(trades.Add(tbd) > COMPOUND_STAGES)
   {
      trades.GetFirstNode();
      trades.DeleteCurrent();
   }*/
   
   //trades.Add(tbd);
   
   lastTradeDesc.Reset();
   lastTradeDesc.setCallback(ProxyOnTradeOpCallback);
   
   return StrategyOpAbs(tOp, absSl, absTp, GetLotSizeRel(Symbol(), riskAmmount, Close[0] / LEVERAGE), /*tbd*/lastTradeDesc);
}

void UpdateTrades()
{
   TradeBatchDesc* curr = trades.GetFirstNode();
   
   if(curr)
   {
      do {
         curr.Update();
      }while((curr = trades.Next()) != NULL);
   }
}

virtual void UpdateSignals() {}

virtual void OnCandleClosed() {
   if(updateSignalEvent == EV_CLOSE_CANDLE)
      UpdateSignals();
}

virtual bool CanPlaceTrades()
{
   return getTradesRunning(getContextUID()) < MAX_TRADES_RUNNING;
}

};

BaseStrategy* gStrategy;

template<typename T>
void InitStrategy()
{
   gStrategy = new T();
   
   gStrategy.OnInit();
}

void DeinitStrategy()
  {
   gStrategy.OnDeinit();
   
   delete gStrategy;
  }
  
void StrategyOnTick()
  {
   gStrategy.OnTick();
  }