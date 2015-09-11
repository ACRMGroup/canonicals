#! /bin/sh

for str in `awk -F',' '{print $4}' supplementalData_mod_new.csv`
do
   pdbCode=`echo \${str:0:4} | tr '[A-Z]' '[a-z]'`

   echo $pdbCode
done
   
