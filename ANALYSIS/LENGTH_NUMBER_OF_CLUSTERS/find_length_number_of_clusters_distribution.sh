#! /bin/sh

for file in `ls -1 ~/CANONICALS/acaca/results/*_clan.out`
do
   # For every loop length, find the number of canonical classes.

   loop=`basename $file _clan.out`
   outputFilename=$loop.length.txt

   perl find_length_number_of_clusters_distribution.pl $file $outputFilename
   echo $file
done
