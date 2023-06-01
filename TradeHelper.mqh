#include <StratFoundry\TradeBatchDesc.mqh>
#include <StratFoundry\LotHelper.mqh>
#include <StratFoundry\ContextHelper.mqh>

enum TradeOp {
   NONE,
   LONG,
   SHORT
};

double GetPerTradeRiskAmount(double riskPerc)
{
   return AccountBalance() * (riskPerc / 100.f);
}

int LongAbs(double entryPrice, double slAbs, double tpAbs, double lotSz, int magic = 0)
{   
   #ifdef PRINT_SL_TP_INF
   printf("Long SL[%f], TP[%f]", slAbs, tpAbs);
   #endif
   
   return OrderSend(Symbol(), OP_BUY, lotSz, entryPrice, 10, slAbs , tpAbs , NULL, magic);
}

int Long(double entryPrice, double slAmmount, double tpAmmount, double lotSz, int magic = 0)
{   
   return LongAbs(entryPrice, entryPrice - slAmmount, entryPrice + tpAmmount, lotSz, magic);
}

int ShortAbs(double entryPrice, double slAbs, double tpAbs, double lotSz, int magic = 0)
{  
   #ifdef PRINT_SL_TP_INF
   printf("Short SL[%f], TP[%f]", slAbs, tpAbs);
   #endif
   
   return OrderSend(Symbol(), OP_SELL, lotSz, entryPrice, 10,slAbs ,tpAbs, NULL, magic);
}

int Short(double entryPrice, double slAmmount, double tpAmmount, double lotSz, int magic = 0)
{     
   return ShortAbs(entryPrice, entryPrice + slAmmount, entryPrice - tpAmmount, lotSz, magic);
}

int MarketLongAbs(double slAbs, double tpAbs, double lotSz, int magic = 0)
{
   return LongAbs(Ask, slAbs, tpAbs, lotSz, magic);
}

int MarketShortAbs(double slAbs, double tpAbs, double lotSz, int magic = 0)
{
   return ShortAbs(Bid, slAbs, tpAbs, lotSz, magic);
}

int MarketLong(double slAmmount, double tpAmmount, double lotSz, int magic = 0)
{
   return Long(Ask, slAmmount, tpAmmount, lotSz, magic);
}

int MarketShort(double slAmmount, double tpAmmount, double lotSz, int magic = 0)
{
   return Short(Bid, slAmmount, tpAmmount, lotSz, magic);
}

int getTradesRunning(int contextUid)
{
   int tradesRunning = 0;
   
   for( int i = 0 ; i < OrdersTotal() ; i++ ) { 
          // We select the order of index i selecting by position and from the pool of market/pending trades.
          if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false)
            continue; 
          // If the pair of the order is equal to the pair where the EA is running.
          if (OrderMagicNumber() == contextUid) tradesRunning++; 
   } 
   
   return tradesRunning; 
}

bool StrategyOp(TradeOp tOp, int slPips, int tpPips, double riskAmmount, TradeBatchDesc& tradeBatchDesc)
{
   double lotSz = GetLotSize(Symbol(), riskAmmount, slPips);
   
   tradeBatchDesc.Reset();
   
   if(lotSz < 0)
      return false;
   
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   
   double slAmmount = Pip2Ammount(Symbol(), slPips);
   double tpAmmount = Pip2Ammount(Symbol(), tpPips);
   int contextUid = getContextUID();
   
   if(lotSz > maxLot)
   {
      printf("Splitting Lot Size");
      
      do {
         
         int tradeTicketId = 
            (tOp == TradeOp::LONG) ? MarketLong(slAmmount, tpAmmount, maxLot, contextUid) :
            (tOp == TradeOp::SHORT) ? MarketShort(slAmmount, tpAmmount, maxLot, contextUid) : -1;
            
         
         if(tradeTicketId > -1)
            tradeBatchDesc.AddTicket(tradeTicketId);
         
         lotSz = lotSz - maxLot;
      } while(lotSz > maxLot);
   }
   
   if(lotSz < minLot)
   {  
      printf("Warning, %f Remaining unable to Trade", lotSz);
      return true;
   }
   
   if(lotSz > minLot)
   {  
      int _tradeTicketId = 
            (tOp == TradeOp::LONG) ? MarketLong(slAmmount, tpAmmount, lotSz, contextUid) :
            (tOp == TradeOp::SHORT) ? MarketShort(slAmmount, tpAmmount, lotSz, contextUid) : -1;
            
      if(_tradeTicketId > -1)
         tradeBatchDesc.AddTicket(_tradeTicketId);
   }
   
   return true;
}

bool StrategyOpAbs(TradeOp tOp, int absSl, int absTp, double lotAmmount, TradeBatchDesc& tradeBatchDesc)
{
   double lotSz = lotAmmount;
   
   if(lotSz < 0)
      return false;
   
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);

   int contextUid = getContextUID();
   
   if(lotSz > maxLot)
   {
      printf("Splitting Lot Size");
      
      do {
         
         int tradeTicketId = 
            (tOp == TradeOp::LONG) ? MarketLongAbs(absSl, absTp, maxLot, contextUid) :
            (tOp == TradeOp::SHORT) ? MarketShortAbs(absSl, absTp, maxLot, contextUid) : -1;
            
         
         if(tradeTicketId > -1)
            tradeBatchDesc.AddTicket(tradeTicketId);
         
         lotSz = lotSz - maxLot;
      } while(lotSz > maxLot);
   }
   
   if(lotSz < minLot)
   {  
      printf("Warning, %f Remaining unable to Trade", lotSz);
      return true;
   }
   
   if(lotSz > minLot)
   {  
      int _tradeTicketId = 
            (tOp == TradeOp::LONG) ? MarketLongAbs(absSl, absTp, lotSz, contextUid) :
            (tOp == TradeOp::SHORT) ? MarketShortAbs(absSl, absTp, lotSz, contextUid) : -1;
            
      if(_tradeTicketId > -1)
         tradeBatchDesc.AddTicket(_tradeTicketId);
   }
   
   return true;
}

bool CloseAllTrades(int magic = 0)
{
   bool bAllClosed = true;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderMagicNumber() != magic)
            continue;
            
         if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, CLR_NONE))
            bAllClosed = false;
      }
   }
   
   return bAllClosed;
}