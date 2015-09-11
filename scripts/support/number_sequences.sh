#! /bin/sh

# Check for the command line arguments.

if [ $# -lt 2 ]
then
   echo
   echo "Usage: $0 <Arguments>"
   echo
   echo "Arguments are:"
   echo
   echo "1. File with the list of Fv/Fab PDB codes"
   echo "2. File with the list of dimer PDB codes"
   echo
   exit 0
fi

fvPDBCodesFilename=$1
dimerPDBCodesFilename=$2

# Check if the Fv and dimer PDB codes files exist.

if [ ! -r $fvPDBCodesFilename ]
then
   echo
   echo "Cannot read file \"$fvPDBCodesFilename\""
   echo
   exit 0
fi

if [ ! -r $dimerPDBCodesFilename ]
then
   echo
   echo "Cannot read file \"$dimerPDBCodesFilename\""
   echo
   exit 0
fi


# Export the environment variable ABNUM to point to the directory
# containing the numbering program "abnum.o".

export ABNUM=$HOME/ABNUM

# For every Fv or Fab fragment, run the numbering program with the
# print chain option (-pc).

for pdbCode in `cat $fvPDBCodesFilename`
do
   inputPIRFilename=Fv_Fab_SEQUENCES/$pdbCode.pir
   numberingFilename=NUMBERED_FILES/$pdbCode.out

   $ABNUM/kabnum_wrapper_with_PC.pl $inputPIRFilename -c -pc > $numberingFilename
   echo "Fv: $pdbCode"
done

# For every dimer, run the numbering program with the
# print chain option (-pc).

for pdbCode in `cat $dimerPDBCodesFilename`
do
   inputPIRFilename=DIMER_SEQUENCES/$pdbCode.pir
   numberingFilename=NUMBERED_FILES/$pdbCode.out

   $ABNUM/kabnum_wrapper_with_PC.pl $inputPIRFilename -c -pc > $numberingFilename
   echo "Dimer: $pdbCode"
done

# End of shell script.
