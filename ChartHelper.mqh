bool CandleIsBullish(int candId)
{
   return Close[candId] > Open[candId];
}

void CalcMomentum(const double& src[], double& result[], int lenght)
{
   for(int i = 0; i < lenght; i++)
   {
      result[i] = src[i] - src[0];
   }
}
