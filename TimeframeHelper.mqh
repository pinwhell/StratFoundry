string GetTimeFrame(int lPeriod)
{
   switch(lPeriod)
   {
   case 1: return("M1");
   case 5: return("M5");
   case 15: return("M15"); 
   case 30: return("M30");
   case 60: return("H1");
   case 240: return("H4");
   case 1440: return("D1");
   case 10080: return("W1"); 
   case 43200: return("MN1"); 
   }
return  "";
}