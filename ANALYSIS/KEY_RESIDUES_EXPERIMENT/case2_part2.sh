#! /bin/sh

# Given a query PDB, this script finds the RMS over a loop with another PDB that
# shares the highest sequence identity over key residues of the query PDB.


# --------------- SUB-ROUTINES SECTION --------------------


Find_RMS()
{
   # Find the RMS with the hit PDB and print it. The sub-routine is invoked in the
   # following way:
   #
   # Find_RMS $loop $loopDefinition $queryPDBCode $queryCanonicalClass $pdbCode2 $pdb2CanonicalClass $bestSequenceIdentity


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


# ------------ END OF SUB-ROUTINES SECTION ----------------




# Check if the required command line parameters have been input.

if [ $# -lt 6 ]
then
   echo
   echo "Usage: $0 <Arguments>"
   echo
   echo "Arguments are:"
   echo
   echo "1. Loop"
   echo "2. Loop definition (e.g. L24-L34)"
   echo "3. CSV file with results of Case 2, part 1 run"
   echo "4. File with list of prohibited PDBs for the loop"
   echo "5. File with list of canonical class mapping to PDB codes"
   echo "6. File with key positions for canonical classes of the loop in FASTA format"
   echo
   exit 0
fi

loop=$1
loopDefinition=$2
case2Part1Filename=$3
prohibitedPDBsListFilename=$4
mappingsFilename=$5
keyPositionsFilename=$6

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

# Check if the file with key positions for canonical classes of the loop
# is present.

if [ ! -r $keyPositionsFilename ]
then
   echo
   echo "Unable to read file \"$keyPositionsFilename\""
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

# For every unique PDB....

for line in `grep -vi Skip $case2Part1Filename`
do
   # Skip the line if it does not have a template PDB like this one
   # for CDR-H2 (taken from the file H2_case2_part1.csv):
   #
   # H2,H50-H58,3h0t,11A,RTYYRSKWFND,,,,-100000,

   if [ `echo $line | grep ",,,"` ]
   then
      # Skip to the next line.

      continue
   fi

   # Get the query PDB code.

   queryPDBCode=`echo "$line" | awk -F',' '{print \$3}'`

   # Identify another structure whose loop sequence matches
   # best with the loop sequence of $queryPDBCode.

   if [ `grep $queryPDBCode $prohibitedPDBsListFilename | head -1` ]
   then
      # Skip to the next PDB.

      continue
   fi

   # Get the canonical class information.

   queryCanonicalClass=`grep $queryPDBCode $mappingsFilename | awk -F',' '{print $3}'`

   # If the canonical class does not have any associated key positions, then
   # skip to the next PDB.

   if [ ! `grep "^>" $keyPositionsFilename | grep $queryCanonicalClass` ]
   then
      # Skip to the next PDB.

      echo "Skipping $queryPDBCode for $queryCanonicalClass"

      continue
   fi

   # Set the path for the PDB of Fv region.

   queryPDBFilename=$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$queryPDBCode.pdb

   # Get the loop sequence.

   queryLoopSequence=`getpdb $loopStart $loopEnd $queryPDBFilename | pdb2pir -C -s | grep -v "^>" | grep -v "Seque" | sed 's/\*//'`
   queryLoopLength=`echo "${#queryLoopSequence}"`

   # Get the best sequence identity over key residues.
   # Line is of the form:
   #
   # L1,L24-L34,2f5a,11A,RASQGVTSALA,1tjg,11A,RASQGVTSALA,100.0,0.962

   bestSequenceIdentity=`echo $line | awk -F',' '{print \$9}'`

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

      # Get the sequence identity over key residues in the loop and the framework.

      sequenceIdentityOverKeyResidues=0
      sequenceIdentityOverKeyResidues=`perl get_sequence_identity_over_key_residues.pl $queryPDBCode $pdbCode2 $mappingsFilename $keyPositionsFilename`

      # Check if the sequence identity is better than the best recorded
      # so far. If so, update the best sequence identity.

      out=`echo "$sequenceIdentityOverKeyResidues == $bestSequenceIdentity" | bc`

      if [ $out == 1 ]
      then
         # Get the canonical class information for the best match.

         pdb2CanonicalClass=`grep $pdbCode2 $mappingsFilename | awk -F',' '{print \$3}'`

         # Find the RMS with the hit PDB and print it.

         Find_RMS $loop $loopDefinition $queryPDBCode $queryCanonicalClass $pdbCode2 $pdb2CanonicalClass $bestSequenceIdentity

      fi

   done  # End of inner for loop.


done # End of outer for loop.


# Remove the ProFit script.

rm -f $profitScriptFilename

# End of script.
