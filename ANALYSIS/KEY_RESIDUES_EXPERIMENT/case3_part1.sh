#! /bin/sh

# Case III:
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
# 6) Performing the following steps:
#
# Given the best matches on the basis of sequence identity over (k + f):
#
# a) Calculate the sequence identity over (f + c) between every b (in B) and x.
#
# b) For the best b in step (c), calculate the RMSD with x over the loop.


# Check if the required command line parameters have been input.

if [ $# -lt 4 ]
then
   echo
   echo "Usage: $0 <Arguments>"
   echo
   echo "Arguments are:"
   echo
   echo "1. File with list of bad PDB codes for the loop concerned"
   echo "2. File with key positions for canonical classes of the loop in FASTA format"
   echo "3. File with results of case II (i.e. CSV file with best match in sequence identity over key residues)"
   echo "4. File with mappings between PDB codes and canonical classes"
   echo
   exit 0
fi

prohibitedPDBsListFilename=$1
keyPositionsFilename=$2
case2ResultsFilename=$3
mappingsFilename=$4

# Check if the file with list of bad PDB codes can be read.

if [ ! -r $prohibitedPDBsListFilename ]
then
   echo
   echo "Unable to read file \"$prohibitedPDBsListFilename\""
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

# Check if the file with case II results
# is present.

if [ ! -r $case2ResultsFilename ]
then
   echo
   echo "Unable to read file \"$case2ResultsFilename\""
   echo
   exit 0
fi

# Check if the file with mappings between PDB codes and canonical classes
# is present.

if [ ! -r $mappingsFilename ]
then
   echo
   echo "Unable to read file \"$case2ResultsFilename\""
   echo
   exit 0
fi

# For every line in the case II results file....

for line in `grep "^[LH][1-3]" $case2ResultsFilename`
do
   # Line is of the form:
   #
   # L3,L89-L97,2f5a,9A,QQLHFYPHT,1tjg,9A,QQLHFYPHT,85.0,0.756

   loop=`echo $line | awk -F',' '{print $1}'`
   loopDefinition=`echo $line | awk -F',' '{print $2}'`
   pdbCode1=`echo $line | awk -F',' '{print $3}'`
   can1=`echo $line | awk -F',' '{print $4}'`
   keyResidues1=`echo $line | awk -F',' '{print $5}'`
   pdbCode2=`echo $line | awk -F',' '{print $6}'`
   can2=`echo $line | awk -F',' '{print $7}'`
   keyResidues2=`echo $line | awk -F',' '{print $8}'`
   bestSequenceIdentity=`echo $line | awk -F',' '{print $9}'`

   # Get the loop start and loop end.

   loopStart=`echo $loopDefinition | awk -F'-' '{print $1}'`
   loopEnd=`echo $loopDefinition | awk -F'-' '{print $2}'`

   # Get loop length for $pdbCode1.

   loopSequence1=""
   FvPDBFilename1=$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$pdbCode1".pdb"
   loopSequence1=`getpdb $loopStart $loopEnd $FvPDBFilename1 | pdb2pir -C | grep -v "^>" | grep -v "Seq" | sed 's/\*//'`
   loopLength1=`echo "${#loopSequence1}"`

   # Print the header line.

   echo ">"$pdbCode1","$bestSequenceIdentity

   # Find all PDBs whose sequence identity over the key residues are
   # at least equal to $sequenceIdentity.

   for pdbCode in `grep "^>" Fv_unique.pir | sed 's/^>P1;//'`
   do
      # Check if $pdbCode is the same as $pdbCode1.

      if [ "$pdbCode" == "$pdbCode1" ]
      then
         # Skip to the next PDB.

         continue
      fi

      # If $pdbCode is in the list of prohibited PDBs for the loop, skip to
      # the next one.

      if [ `grep $pdbCode $prohibitedPDBsListFilename | head -1` ]
      then
         continue
      fi

      # Get the loop sequence.

      loopSequence=""
      FvPDBFilename=$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$pdbCode".pdb"
      loopSequence=`getpdb $loopStart $loopEnd $FvPDBFilename | pdb2pir -C | grep -v "^>" | grep -v "Seq" | sed 's/\*//'`

      # Get loop length for $pdbCode1.

      loopLength=`echo "${#loopSequence}"`

      # Check if the loop sequence is of the same length as that of $pdbCode1.
      # If not, skip to the next PDB.

      out=`echo "$loopLength1 != $loopLength" | bc`

      if [ $out == 1 ]
      then
         # Skip to the next PDB in the inner PDB loop.

         continue
      fi

      # Get the sequence identity over the key residues.

      sequenceIdentityOverKeyResidues=0
      sequenceIdentityOverKeyResidues=`perl get_sequence_identity_over_key_residues.pl $pdbCode1 $pdbCode $mappingsFilename $keyPositionsFilename`

      # Check if the sequence identity is equal to the bext sequence identity.
      # If it is, record the PDB.

      out=`echo "$bestSequenceIdentity == $sequenceIdentityOverKeyResidues" | bc`

      if [ $out == 1 ]
      then
         # Record the PDB code.

         echo $pdbCode","$loopSequence

      fi # End of if loop.

   done # End of "for pdbCode....."

done # End of "for line...."


# End of script.
