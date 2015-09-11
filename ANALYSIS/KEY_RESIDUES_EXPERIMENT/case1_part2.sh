#! /bin/sh

# Case I:
#
#
# 1) Let's assume a set of 100 unique abs - X.
#
# 2) Let's say for CDR-L1 (using CDR-L1 as an example), the following definitions apply:
#
#    a) c is CDR-L1 sequence.
#    b) k is the set of key residues in the CDR for the specific class of CDR-L1.
#    c) f is the set of key residues in the framework for the class of CDR-L1.
#
# 3) For each x in X, do the following steps:
#
# 4) Define X' as (X - x).
#
# 5) For each x' in X':
#
# 6) If the length of the CDR of x' is not the same as x, go to the next sequence.
#
# 7) Performing the following steps:
#
# NOTE: x' is another PDB with the same loop length as $queryPDBCode
#
# a) Calculate the sequence identity of x,x' over c
#
# b) Record the best PDB b.
#
# c) Calculate the RMS over the the loop between b and x.


# -------------------------- SUB-ROUTINES SECTION ----------------------

Find_RMS()
{
   # Find the RMS with the hit PDB and print it. The sub-routine is invoked in the
   # following way:
   #
   # Find_RMS $loop $loopDefinition $queryPDBCode $queryCanonicalClass $pdbCode2 $canonicalClass2 $bestSequenceIdentity

   loop=$1
   loopDefinition=$2
   queryPDBCode=$3
   queryCanonicalClass=$4
   targetPDBCode=$5
   targetCanonicalClass=$6
   bestSequenceIdentity=$7

   # Set all the filenames.

   queryPDBFilename="$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/"$queryPDBCode".pdb"
   targetPDBFilename="$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/"$targetPDBCode".pdb"

   profitScriptFilename="/tmp/"$queryPDBCode"_"$targetPDBCode"_"$loopDefinition".prf"

   # Write the ProFit script.

   echo "REFERENCE $queryPDBFilename " > $profitScriptFilename
   echo "MOBILE $targetPDBFilename" >> $profitScriptFilename
   echo "ZONE $loopDefinition:$loopDefinition" >> $profitScriptFilename
   echo "IGNOREMISSING" >> $profitScriptFilename
   echo "FIT" >> $profitScriptFilename

   # Run ProFit on the script.

   rms=`profit -f $profitScriptFilename | grep RMS | awk '{print $2}'`

   # Print the results.

   echo "$loop,$loopDefinition,$queryPDBCode,$queryCanonicalClass,$targetPDBCode,$targetCanonicalClass,$bestSequenceIdentity,$rms"

   # Remove the temporary ProFit script file.

   unlink $profitScriptFilename

} # End of sub-routine "Find_RMS".


# --------------------- END OF SUB-ROUTINES SECTION -----------------





# Check if the required command line parameters have been input.

if [ $# -lt 5 ]
then
   echo
   echo "Usage: $0 <Arguments>"
   echo
   echo "Arguments are:"
   echo
   echo "1. Loop"
   echo "2. Loop definition (e.g. L24-L34)"
   echo "3. CSV file with results of the Case 1, part 1 run"
   echo "4. File with list of bad PDB codes for the loop concerned"
   echo "5. File with list of canonical class mapping to PDB codes"
   echo
   exit 0
fi

loop=$1
loopDefinition=$2
case1Part1Filename=$3
prohibitedPDBsListFilename=$4
mappingsFilename=$5

# Check if the file with results of the case 1, part 1 is readable.

if [ ! -r $case1Part1Filename ]
then
   echo
   echo "Unable to read file \"$case1Part1Filename\""
   echo
   exit 0
fi

# Check if the file with list of bad PDB codes can be read.

if [ ! -r $prohibitedPDBsListFilename ]
then
   echo
   echo "Unable to read file \"$prohibitedPDBsListFilename\""
   echo
   exit 0
fi

# Check if the file with mappings between PDB codes and canonical classes
# is present.

if [ ! -r $mappingsFilename ]
then
   echo
   echo "Unable to read file \"$mappingsFilename\""
   echo
   exit 0
fi

# Parse the loop definition for the loop start and loop end.

loopStart=`echo $loopDefinition | awk -F'-' '{print $1}'`
loopEnd=`echo $loopDefinition | awk -F'-' '{print $2}'`

if [ ! `echo $loopStart | grep "^[LH][1-9]"` ]
then
   echo
   echo "Invalid loop definition string \"$loopDefinition\""
   echo
   exit 0
fi

if [ ! `echo $loopEnd | grep "^[LH][1-9]"` ]
then
   echo
   echo "Invalid loop definition string \"$loopDefinition\""
   echo
   exit 0
fi

# For every unique PDB....

for line in `cat $case1Part1Filename`
do
   # Check if the line needs skipping.

   if [ ! `echo $line | grep "^[LH][1-3]"` ]
   then
      # Skip to the next line.

      continue
   fi

   # Get the query PDB Code and other information.
   #
   # Line is of the form:
   #
   # L2,L50-L56,2f5a,7A,DASSLES,1tjg,7A,DASSLES,100.01,0.699

   queryPDBCode=`echo $line | awk -F',' '{print \$3}'`
   queryCanonicalClass=`echo $line | awk -F',' '{print \$4}'`
   bestSequenceIdentity=`echo $line | awk -F',' '{print \$9}'`

   queryPDBFilename="$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/"$queryPDBCode".pdb"

   # Get the loop sequence.

   queryLoopSequence=`getpdb $loopStart $loopEnd $queryPDBFilename | pdb2pir -C -s | grep -v "^>" | grep -v "Seque" | sed 's/\*//'`
   queryLoopLength=`echo "${#queryLoopSequence}"`

   # For every other pdb in the unique list, do the required comparisons.

   for pdbCode2 in `grep "^>" Fv_unique.pir | sed 's/>P1;//'`
   do
      # If the two PDB codes are the same, skip to the next one.

      if [ "$queryPDBCode" == "$pdbCode2" ]
      then
         continue
      fi

      # Check if the PDB is in the list of prohibited PDBs for the loop.

      if [ `grep $pdbCode2 $prohibitedPDBsListFilename | head -1` ]
      then
         # Skip to the next PDB.

         continue
      fi

      # Get the loop sequence.

      pdb2Filename=$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$pdbCode2.pdb

      loop2Sequence=`getpdb $loopStart $loopEnd $pdb2Filename | pdb2pir -C -s | grep -v "^>" | grep -v "Seque" | sed 's/\*//'`
      loop2Length=`echo "${#loop2Sequence}"`

      # Skip to the next PDB in the inner loop if the two loops
      # are not of equal length.

      if [ $queryLoopLength != $loop2Length ]
      then
         continue
      fi

      # Get the sequence identity between the two loops.

      sequenceIdentity=`perl get_sequence_identity.pl $queryLoopSequence $loop2Sequence`

      # Check if the sequence identity is better than the best recorded
      # so far. If so, update the best sequence identity.

      out=`echo "$sequenceIdentity == $bestSequenceIdentity" | bc`

      if [ $out == 1 ]
      then
         # Get the canonical class for $pdbCode2

         canonicalClass2=`grep $pdbCode2 $mappingsFilename | awk -F',' '{print $3}'`

         # Calculate the RMSD over the loops of the two PDBs.

         Find_RMS $loop $loopDefinition $queryPDBCode $queryCanonicalClass $pdbCode2 $canonicalClass2 $bestSequenceIdentity
      fi

   done  # End of inner for loop.

done # End of outer for loop.

# End of script.
