#! /bin/sh

for file in `grep File one.txt | awk '{print $2}'`
do
   pdbCode=`basename $file .pir`

   numberingFilename=$processingDirectory/NUMBERED_FILES/$pdbCode.out

   $ABNUM/kabnum_wrapper_with_PC.pl $file -c -pc > $numberingFilename
   echo "$pdbCode : $inputPIRFile : $numberingFilename"
done
