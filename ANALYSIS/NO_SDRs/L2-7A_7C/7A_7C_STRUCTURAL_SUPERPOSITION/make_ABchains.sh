#! /bin/sh

if [ $# -lt 1 ]
then
   echo
   echo "Usage: $0 <PDB file>"
   echo
   exit 0
fi

pdbFilename=$1

pdbCode=`basename $pdbFilename .pdb`
outputPDBFilename=$pdbCode"_AB.pdb"

lightChainPDBFilename=$pdbCode"_A.pdb"
heavyChainPDBFilename=$pdbCode"_B.pdb"


getchain L $pdbFilename | chainpdb -c A > $lightChainPDBFilename
getchain H $pdbFilename | chainpdb -c B > $heavyChainPDBFilename

cat $lightChainPDBFilename $heavyChainPDBFilename > $outputPDBFilename

# Remove the light and heavy chain files.

rm -f $lightChainPDBFilename $heavyChainPDBFilename
