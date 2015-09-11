# include <stdio.h>

int process(char current, char **before,
            int flag, int *numberOfElements)
{
   int len = (*length);
   int i = 0;

   if(flag == 1)
   {
      /* For every element in before, concatenate the
         current character.
      */

      for(i = 0 ; i < numberOfElements ; i++)
      {
         

int main(int argc, char **argv)
{
   char string[] = "[HY]P[ST][DF]";

   char currentChar;

   char **before = NULL,
        **after = NULL;

   int i = 0;

   for(i = 0 ; i < strlen(string) ; i++)
   {
      currentChar = string[i];

      if(currentChar == '[')
      {
         flag = 1;
         continue;
      }

      if(currentChar == ']')
      {
         flag = 0;
         continue;
      }

      if( isalpha(currentChar) )
      {
         process(currentChar, before, flag, &numberOfElements);
      }
   }

   return 0;

} /* End of program. */
