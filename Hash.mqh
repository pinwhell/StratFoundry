int djb2(string key){
   int i, h = 0, k = 0;
   for (i=0; i<StringLen(key); i++){
      k = StringGetChar(key, i);
      h = (h << 5) + h + k;
   }
   return(h);
}
