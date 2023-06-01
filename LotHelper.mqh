double PipSize(string symbol)
{
   return MarketInfo(symbol, MODE_TICKVALUE);
}

double Pip2Ammount(string symbol, double pips)
{
   if(pips < 1)
      return 0;

   return pips * PipSize(symbol);
}

double Ammount2Pips(string symbol, double ammount)
{
   return ammount / PipSize(symbol);
}

double NormalizeLot(string symbol, double size)
{
   double lotStep = MarketInfo(symbol, MODE_LOTSTEP);
   return NormalizeDouble(MathCeil(size / lotStep) * lotStep, MarketInfo(symbol, MODE_DIGITS));
}

double GetLotSizeRel(string symbol, double tradeRiskAmmount, double slRelAmmount)
{
   double minLot = MarketInfo(symbol, MODE_MINLOT);
   double lotSz = tradeRiskAmmount / slRelAmmount;
   
   if(lotSz < minLot)
   {
      printf("Lot Size is Less than Min Lote");
      return -1;
   }
   
   return NormalizeLot(symbol, lotSz);
}

double GetLotSize(string symbol, double tradeRiskAmmount, double slPips)
{
   return GetLotSizeRel(symbol, tradeRiskAmmount, Pip2Ammount(symbol, slPips));
}