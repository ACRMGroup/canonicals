#! /bin/sh

# Set the required file names.

pdbCodesFilename=unique_PDB_codes.lst
outputFilename=Fv_unique.pir

# Remove the output file on the first instance.

rm -f $outputFilename

# Check if the PDB codes file can be read.

if [ ! -r $pdbCodesFilename ]
then
   echo
   echo "Unable to read file \"$pdbCodesFilename\"."
   echo
   exit 0
fi

# For every PDB, extract the Fv region sequence.

for pdbCode in `cat $pdbCodesFilename`
do
   pdbFilename=$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$pdbCode.pdb

   seq=""

   for line in `getchain L $pdbFilename | pdb2pir -C -s | grep -v "^>" | grep -v "Sequence" | sed 's/\*//'`
   do
      seq=$seq$line
   done

   for line in `getchain H $pdbFilename | pdb2pir -C -s | grep -v "^>" | grep -v "Sequence" | sed 's/\*//'`
   do
      seq=$seq$line
   done

   # Print the PDB code and the sequence.

   echo ">P1;"$pdbCode >> $outputFilename
   echo "SequenceX" >> $outputFilename
   echo $seq"*" >> $outputFilename

   echo $pdbCode

done
