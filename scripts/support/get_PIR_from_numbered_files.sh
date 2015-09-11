#! /bin/sh

for file in `grep File one.txt | awk '{print $2}'`
do
   pdbCode=`basename $file .pir`
   numberingFilename=$processingDirectory/NUMBERED_FILES/$pdbCode.out
   outputPIRFilename=$processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS_AND_REDUNDANCY/$pdbCode.pir

   for chain in `grep Chain $numberingFilename | awk '{print $2}'`
   do
      pdbFilename="/acrm/data/pdb/pdb"$pdbCode".ent"
      getchain $chain $pdbFilename | pdb2pir -C >> $outputPIRFilename 
   done

  echo "$pdbCode: $outputPIRFilename"
done
