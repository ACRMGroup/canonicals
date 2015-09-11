#! /bin/sh

if [ $# -lt 1 ]
then
   echo
   echo "Usage: $0 <CSV file with Case 1, part 1 results>"
   echo
   exit 0
fi

inputFilename=$1

if [ ! -r $inputFilename ]
then
   echo
   echo "Unable to read \"$inputFilename\""
   echo
   exit 0
fi

# Read the file.

for line in `cat $inputFilename`
do
   # Line is of the form:
   #
   # L1,L24-L34,2f5a,11A,RASQGVTSALA,1tjg,11A,RASQGVTSALA,100.01,0.962

   loopDefinition=`echo $line | awk =F',' '{print \$2}'`
   queryPDB=`echo $line | awk =F',' '{print \$3}'`
   targetPDB=`echo $line | awk =F',' '{print \$6}'`
   bestSequenceIdentity=`echo $line | awk =F',' '{print \$9}'`

   # Get the loop start and end.

   loopStart=`echo $loopDefinition | awk -F'-' '{print \$1}'`
   loopEnd=`echo $loopDefinition | awk -F'-' '{print \$2}'`

   # Get the loop sequences.

   queryPDBFilename=$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$queryPDB.pdb
   targetPDBFilename=$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$targetPDB.pdb

   queryLoop=`getpdb $loopStart $loopEnd $queryPDBFilename | pdb2pir -C -s | grep -v ^> | grep -v Seq | | sed 's/\*//'`
   targetLoop=`getpdb $loopStart $loopEnd $targetPDBFilename | pdb2pir -C -s | grep -v ^> | grep -v Seq | | sed 's/\*//'`

   # Run the program.

   sequenceIdentity=`perl get_sequence_identity.pl $queryLoop $targetLoop`

   # Run the check.

   out=`echo "$sequenceIdentity != $bestSequenceIdentity" | bc`

   if [ $out == 1 ]
   then
      echo $queryPDB" "$targetPDB
   fi

done # End of for loop.


# End of script.
