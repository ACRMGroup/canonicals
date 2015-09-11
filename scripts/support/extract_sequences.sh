#! /bin/sh

if [ $# -lt 2 ]
then
   echo
   echo "Usage: $0 <Arguments>"
   echo
   echo "Arguments are:"
   echo
   echo "1. File with list of PDB codes"
   echo "2. Directory where sequences must be written"
   echo
   exit 0
fi

pdbCodesFilename=$1
outputDirectory=$2

# For every PDB code in the PDB codes file, extract the sequences.

for pdbCode in `cat $pdbCodesFilename`
do
   inputFilename="/acrm/data/pdb/pdb"$pdbCode".ent"
   outputFilename=$outputDirectory"/"$pdbCode".pir"
   pdb2pir -C -s $inputFilename $outputFilename
   echo $pdbCode
done

# End of script.
