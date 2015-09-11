#! /bin/bash

# This script is to extract only numbering (.pro files) from the output of the numbering program kabnum_wrapper.pl

for file in `ls -1 *.out`
do
   pdbCode=`basename $file .out`
   grep "^[LH][0-9]*[A-Z]* " $file > $pdbCode.pro
   echo $pdbCode
done
