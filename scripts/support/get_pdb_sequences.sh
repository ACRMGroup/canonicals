#! /bin/sh

if [ $# -lt 1 ]
then
   echo
   echo "Usage: $0 <File with list of PDB codes>"
   echo
   exit 0
fi

pdbCodesFilename=$1

for pdbCode in `cat $pdbCodesFilename`
do
   inputFilename="/acrm/data/pdb/pdb"$pdbCode".ent"
   outputFilename=PDB_SEQUENCES/ALL/$pdbCode.pir

   pdb2pir -C -s $inputFilename $outputFilename
   echo $pdbCode
done

# End of script.
