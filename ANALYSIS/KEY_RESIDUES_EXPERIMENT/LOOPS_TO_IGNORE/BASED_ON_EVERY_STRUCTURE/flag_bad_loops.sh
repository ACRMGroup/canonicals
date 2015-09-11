#! /bin/sh

if [ $# -lt 2 ]
then
   echo
   echo "Usage: $0 <Loop (e.g. L1)> <Loop definition (.e.g. L24-L34)>"
   echo
   exit 0
fi

loop=$1
loopDef=$2

for pdbCode in `cat unique_PDB_codes.lst`
do
   FvPDBFilename=/home/bsm2/abhi/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$pdbCode.pdb

   if [ `echo $pdbCode | grep _` ]
   then
      # PDB code is of the form 1cic_1.

      fullPDBCode=`echo $pdbCode | sed 's/_.*//g'`
      fullPDBFilename=/acrm/data/pdb/pdb$fullPDBCode.ent

   else
      fullPDBFilename=/acrm/data/pdb/pdb$pdbCode.ent
   fi

   # Run the perl script.

   perl flag_bad_loops.pl $pdbCode $FvPDBFilename $fullPDBFilename $loop $loopDef

   # Print the PDB code.

   echo $pdbCode

done
