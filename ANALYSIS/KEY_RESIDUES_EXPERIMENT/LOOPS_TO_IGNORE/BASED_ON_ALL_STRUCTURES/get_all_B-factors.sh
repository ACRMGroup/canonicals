#! /bin/sh

if [ $# -lt 2 ]
then
   echo
   echo "Usage: $0 <File with list of unique PDB codes> <Output file>"
   echo
   exit 0
fi

uniquePDBCodesFilename=$1
outputFilename=$2

# Get the B-factors of all ATOM records in the PDB files.

for pdbCode in `cat $uniquePDBCodesFilename`
do
   if [ `echo $pdbCode | grep _` ]
   then
      continue
   fi

   # Gather the ATOM records.

   fullPDBFilename=/acrm/data/pdb/pdb$pdbCode.ent

   grep \"^ATOM\" $fullPDBFilename | cut -c 61-66 | sed 's/ //g' >> $outputFilename

done

# Get the B-factors of the anti-idiotype antibodies.

grep "^ATOM" /acrm/data/pdb/pdb1iai.ent | cut -c 61-66 | sed 's/ //g' >> $outputFilename
grep "^ATOM" /acrm/data/pdb/pdb1cic.ent | cut -c 61-66 | sed 's/ //g' >> $outputFilename
grep "^ATOM" /acrm/data/pdb/pdb1pg7.ent | cut -c 61-66 | sed 's/ //g' >> $outputFilename
grep "^ATOM" /acrm/data/pdb/pdb3bqu.ent | cut -c 61-66 | sed 's/ //g' >> $outputFilename
grep "^ATOM" /acrm/data/pdb/pdb1qfw.ent | cut -c 61-66 | sed 's/ //g' >> $outputFilename
grep "^ATOM" /acrm/data/pdb/pdb1dvf.ent | cut -c 61-66 | sed 's/ //g' >> $outputFilename

# End of script.
