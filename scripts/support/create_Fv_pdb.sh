#! /usr/bin/sh

# ./get_Fv_pdb.exe -num NUMBERED_FILES/12e8.out -pdb /acrm/data/pdb/pdb12e8.ent -out 12e8_Fv.pdb

for pdbCode in `cat Fv_Fab_pdb.lst`
do
   numberedFile=NUMBERED_FILES/$pdbCode.out
   outputFilename=CHAIN_PDBS/$pdbCode.pdb

   echo $pdbCode

   if [ `echo $pdbCode | grep "_"` ]
   then

      # 1cic_1

      pdbCode=`echo $pdbCode | awk -F'_' '{print $1}'`
   fi

   pdbFilename=/acrm/data/pdb/pdb$pdbCode.ent

   ./get_Fv_pdb.exe -num $numberedFile -pdb $pdbFilename -out $outputFilename

done
