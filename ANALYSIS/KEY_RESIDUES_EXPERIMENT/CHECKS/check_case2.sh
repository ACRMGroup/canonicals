#! /bin/sh

if [ $# -lt 3 ]
then
   echo
   echo "Usage: $0 <Arguments>"
   echo
   echo "1. CSV file with Case 2, part 1 results>"
   echo "2. File with list of canonical class mapping to PDB codes"
   echo "3. File with key positions for canonical classes of the loop in FASTA format"
   echo
   exit 0
fi

inputFilename=$1
mappingsFilename=$2
keyPositionsFilename=$3

# Check if the input file can be read.

if [ ! -r $inputFilename ]
then
   echo
   echo "Unable to read \"$inputFilename\""
   echo
   exit 0
fi

# Check if the mappings file can be read.

if [ ! -r $mappingsFilename ]
then
   echo
   echo "Unable to read \"$mappingsFilename\""
   echo
   exit 0
fi

# Check if the key positions file can be read.

if [ ! -r $keyPositionsFilename ]
then
   echo
   echo "Unable to read \"$keyPositionsFilename\""
   echo
   exit 0
fi

# Read the file.

for line in `cat $inputFilename | grep -vi Skip`
do
   # Skip the line if required.

   if [ ! `echo $line | grep "^[LH][1-3]"` ]
   then
      continue
   fi

   # Line is of the form:
   #
   # L1,L24-L34,2f5a,11A,RASQGVTSALA,1tjg,11A,RASQGVTSALA,100.0,0.962

   loopDefinition=`echo $line | awk -F',' '{print \$2}'`
   queryPDB=`echo $line | awk -F',' '{print \$3}'`
   targetPDB=`echo $line | awk -F',' '{print \$6}'`
   bestSequenceIdentity=`echo $line | awk -F',' '{print \$9}'`

   # Run the program.

   sequenceIdentity=`perl $HOME/CANONICALS/acaca/ANALYSIS/ANDREW_KEY_RESIDUES_EXPERIMENT/get_sequence_identity_over_key_residues.pl $queryPDB $targetPDB $mappingsFilename $keyPositionsFilename`

   # Run the check.

   out=`echo "$sequenceIdentity != $bestSequenceIdentity" | bc`

   if [ $out == 1 ]
   then
      echo $line" ### In Result file: "$bestSequenceIdentity" ### Calculated : "$sequenceIdentity
   fi

done # End of for loop.


# End of script.
