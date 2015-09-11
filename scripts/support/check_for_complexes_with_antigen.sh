#! /bin/sh

# Check for the command line arguments.

if [ $# -lt 2 ]
then
   echo
   echo "Usage: $0 <Arguments>"
   echo
   echo "Arguments are:"
   echo
   echo "1. File with the list of Fv/Fab PDB Codes"
   echo "2. File with the list of dimer PDB Codes"
   echo
   exit 0
fi

fvPDBCodesFilename=$1
dimerPDBCodesFilename=$2

# Check for the files.

if [ ! -r $fvPDBCodesFilename ]
then
   echo
   echo "Unable to read file \"$fvPDBCodesFilename\""
   echo
   exit 0
fi

if [ ! -r $dimerPDBCodesFilename ]
then
   echo
   echo "Unable to read file \"$dimerPDBCodesFilename\""
   echo
   exit 0
fi

# For the Fv/Fab PDBs, check for complex with the antigen.

for pdbCode in `cat $fvPDBCodesFilename`
do
   pirFilename="Fv_Fab_SEQUENCES/"$pdbCode".pir"
   numberingFilename="NUMBERED_FILES/"$pdbCode".out"

   numberOfSequencesInPIRFile=`grep -c "^>" $pirFilename`
   numberOfNumberedSequences=`grep -B 3 "^[LH][12] " $numberingFilename | grep -c "Chain: "`

   if [ "$numberOfNumberedSequences" == "0" ]
   then
      echo "Fv/Fab $pdbCode: Problem"
      continue
   fi

   # Check if the file is complexed with an antigen or not.

   # If the number of sequences in the PIR file IS MORE than the number of
   # sequences numbered, report that the PDB is complexed with the antigen.

   if [ $numberOfSequencesInPIRFile -gt $numberOfNumberedSequences ]
   then
      echo "Fv/Fab $pdbCode: Complexed"
   else
      if [ $numberOfSequencesInPIRFile -eq $numberOfNumberedSequences ]
      then
         echo "Fv/Fab $pdbCode: Uncomplexed"
      else
         echo "Fv/Fab $pdbCode: Mismatch"
      fi
   fi

done

# For the dimer PDBs, check for complex with the antigen.

for pdbCode in `cat $dimerPDBCodesFilename`
do
   pirFilename="DIMER_SEQUENCES/"$pdbCode".pir"
   numberingFilename="NUMBERED_FILES/"$pdbCode".out"

   numberOfSequencesInPIRFile=`grep -c "^>" $pirFilename`
   numberOfNumberedSequences=`grep -B 3 "^[LH][12] " $numberingFilename | grep -c "Chain: "`

   if [ "$numberOfNumberedSequences" == "0" ]
   then
      echo "Dimer $pdbCode: Problem"
      continue
   fi

   # Check if the file is complexed with an antigen or not.

   # If the number of sequences in the PIR file IS MORE than the number of
   # sequences numbered, report that the PDB is complexed with the antigen.

   if [ $numberOfSequencesInPIRFile -gt $numberOfNumberedSequences ]
   then
      echo "Dimer $pdbCode: Complexed"
   else
      if [ $numberOfSequencesInPIRFile -eq $numberOfNumberedSequences ]
      then
         echo "Dimer $pdbCode: Uncomplexed"
      else
         echo "Dimer $pdbCode: Mismatch"
      fi
   fi

done
