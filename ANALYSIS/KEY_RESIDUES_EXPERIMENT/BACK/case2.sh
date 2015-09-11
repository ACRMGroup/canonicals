#! /bin/sh

# Case II:
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
# NOTE: x' is another PDB with the same loop length as $pdbCode1
#
# a) Calculate the sequence identity of x,x' over k + f.
#
# b) Record the best PDB b.
#
# c) Calculate the RMS over the the loop between b and x.


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
   echo "3. File with list of bad PDB codes for the loop concerned"
   echo "4. File with list of canonical class mapping to PDB codes"
   echo "5. File with key positions for canonical classes of the loop in FASTA format"
   echo
   exit 0
fi

loop=$1
loopDefinition=$2
prohibitedPDBsListFilename=$3
mappingsFilename=$4
keyPositionsFilename=$5

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

for pdbCode1 in `grep "^>" Fv_unique.pir | sed 's/>P1;//'`
do
   # Step 1: Identify another structure whose loop sequence matches
   #         best with the loop sequence of $pdbCode1.

   if [ `grep $pdbCode1 $prohibitedPDBsListFilename` ]
   then
      # Skip to the next PDB.

      continue
   fi

   # Get the canonical class information.

   canonicalClass1=`grep $pdbCode1 $mappingsFilename | awk -F',' '{print $3}'`

   # If the canonical class does not have any associated key positions, then
   # skip to the next PDB.

   if [ ! `grep "^>" $keyPositionsFilename | grep $canonicalClass1` ]
   then
      # Skip to the next PDB.

      echo "Skipping $pdbCode1 for $canonicalClass1"

      continue
   fi

   # Set the path for the PDB of Fv region.

   pdb1Filename=$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$pdbCode1.pdb

   # Get the loop sequence.

   loop1Sequence=`getpdb $loopStart $loopEnd $pdb1Filename | pdb2pir -C -s | grep -v "^>" | grep -v "Seque" | sed 's/\*//'`
   loop1Length=`echo "${#loop1Sequence}"`

   # Set the best match variables to default values.

   bestSequenceIdentity=-100000
   bestLoopSequence=""
   bestPDBCode=""
   bestPDBFilename=""

   # For every other pdb in the unique list, do the required comparisons.

   for pdbCode2 in `grep "^>" Fv_unique.pir | sed 's/>P1;//'`
   do
      # If the two PDB codes are the same, skip to the next one.

      if [ "$pdbCode1" == "$pdbCode2" ]
      then
         continue
      fi

      # Check if the PDB is in the list of prohibited PDBs for the loop.

      if [ `grep $pdbCode2 $prohibitedPDBsListFilename` ]
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

      if [ $loop1Length != $loop2Length ]
      then
         continue
      fi

      # Get the sequence identity over key residues in the loop and the framework.

      sequenceIdentityOverKeyResidues=0
      sequenceIdentityOverKeyResidues=`perl get_sequence_identity_over_key_residues.pl $pdbCode1 $pdbCode2 $mappingsFilename $keyPositionsFilename`

      # Check if the sequence identity is better than the best recorded
      # so far. If so, update the best sequence identity.

      out=`echo "$sequenceIdentityOverKeyResidues > $bestSequenceIdentity" | bc`

      if [ $out == 1 ]
      then
         bestLoopSequence=$loop2Sequence
         bestSequenceIdentity=$sequenceIdentityOverKeyResidues
         bestPDBCode=$pdbCode2
      fi

   done  # End of inner for loop.


   # Step 2: Carry out a structural fit of the loop of $pdbCode1 with $pdbCode2.

   profitScriptFilename=/tmp/$$.prf

   bestPDBFilename=$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$bestPDBCode.pdb

   echo "REFERENCE $pdb1Filename" > $profitScriptFilename
   echo "MOBILE $bestPDBFilename" >> $profitScriptFilename
   echo "ZONE $loopDefinition:$loopDefinition" >> $profitScriptFilename
   echo "IGNOREMISSING" >> $profitScriptFilename
   echo "FIT" >> $profitScriptFilename

   # Get the canonical class information for the best match.

   bestCanonicalClassMatch=`grep $bestPDBCode $mappingsFilename | awk -F',' '{print $3}'`

   # Run ProFit on the script.

   rms=`profit -f $profitScriptFilename | grep RMS | awk '{print $2}'`

   # Print the results.

   echo "$loop,$loopDefinition,$pdbCode1,$canonicalClass1,$loop1Sequence,$bestPDBCode,$bestCanonicalClassMatch,$bestLoopSequence,$bestSequenceIdentity,$rms"


done # End of outer for loop.


# Remove the ProFit script.

rm -f $profitScriptFilename

# End of script.
