#! /bin/sh

# A script that extracts unique Fv sequences from the set of Fv PDBs in the following directory:
#
# ~abhi/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/

temporaryPIRFilename=./$$.pir
outputFilename=Fv_unique.pir

rm -f $temporaryPIRFilename

for pdbFilename in `find ~/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/ -name "*.pdb"`
do
   pdbCode=`basename $pdbFilename .pdb`

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

   echo ">P1;"$pdbCode >> $temporaryPIRFilename
   echo "SequenceX" >> $temporaryPIRFilename
   echo $seq"*" >> $temporaryPIRFilename

   echo $pdbCode

done

# Run the command to remove redundant sequences.

for line in `grep -v "^>" $temporaryPIRFilename | grep -v "Sequence" | sort -u`
do
   grep -B 2 $line $temporaryPIRFilename | head -3 >> $outputFilename
done

# Remove the temporary PIR file.

# rm -f $temporaryPIRFilename

# End of script.
