#include <Arrays/List.mqh>

enum TradeState{
   IDDLE = 0,
   OPEN,
   CLOSED
};

class TradeBatchDesc;

typedef void (*tOnTradeBatchOp)(TradeBatchDesc& thiz, TradeState top);

/*

This class describes a Batch of trades,
becouse, some time, when trying to place big trades,
the limits doesnt allow us, so to overpass this limits
we allocate, the big trade, as a serie of smaller trades
and we keep track of this smallers trade representing a big trade, 
with this class

*/
class TradeBatchDesc : public CObject
{
   public:
   int mTickets[];
   int mTicketsCount;
   tOnTradeBatchOp onTradeStatusCallback;
   TradeState lastState;
   
   void AddTicket(int ticket)
   {
      ArrayResize(mTickets, mTicketsCount + 1);
      mTickets[mTicketsCount++] = ticket;
   }
   
   void Reset()
   {
      mTicketsCount = 0;
      onTradeStatusCallback = (tOnTradeBatchOp)dummyCallback;
      lastState = TradeState::IDDLE;
   }
   
   static void dummyCallback(TradeBatchDesc& thiz, TradeState top)
   {
      
   }
   
   TradeBatchDesc()
   {
      Reset();
   }
   
   void setCallback(tOnTradeBatchOp callback)
   {
      onTradeStatusCallback = callback;
   }
   
   bool AreAllClosed()
   {
      bool bAllClosed = true;
   
      for(int i = 0; i < mTicketsCount; i++)
      {
         if(OrderSelect(mTickets[i], MODE_HISTORY) == false)
            return false;
            
         if((bAllClosed = OrderCloseTime() != 0) == false)
            break;
      }
      
      return bAllClosed;
   }
   
   double getProfits()
   {
      double profits = 0.f;
   
      for(int i = 0; i < mTicketsCount; i++)
      {
         if(OrderSelect(mTickets[i], SELECT_BY_TICKET) == false)
            return -1.f;
            
         profits += OrderProfit();
      }
      
      return profits;
   }
   
   bool IsWinner()
   {
      return getProfits() > 0;
   }
   
   void UpdateState(TradeState state)
   {
      if(state != lastState)
      {
         onTradeStatusCallback(this, state);
         
         lastState = state;
      }
   }

   void Update()
   {
      TradeState currState = AreAllClosed() ? TradeState::CLOSED :
                              TradeState::OPEN;
                              
      UpdateState(currState);
   }
};