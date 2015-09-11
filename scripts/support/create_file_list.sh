#! /bin/sh

if [ $# -lt 2 ]
then
   echo
   echo "Usage: $0 <List of Fv/Fab PDB codes> <List of dimer PDB Codes>"
   echo
   exit 0
fi

fvfabPDBCodesFilename=$1
dimerPDBCodesFilename=$2

for pdbCode in `cat $fvfabPDBCodesFilename`
do
   if [ `echo $pdbCode | grep _` ]
   then
      # E.g. 1cic_1

      pdbCode=`echo $pdbCode | sed 's/_.//'`
   fi

   file=/acrm/data/pdb/pdb$pdbCode.ent
   echo $file
done


for pdbCode in `cat $dimerPDBCodesFilename`
do
   if [ `echo $pdbCode | grep _` ]
   then
      # E.g. 1cic_1

      pdbCode=`echo $pdbCode | sed 's/_.//'`
   fi

   file=/acrm/data/pdb/pdb$pdbCode.ent
   echo $file
done
