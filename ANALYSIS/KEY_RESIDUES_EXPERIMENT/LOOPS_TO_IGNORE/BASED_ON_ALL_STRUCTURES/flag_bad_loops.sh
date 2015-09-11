#! /bin/sh

if [ $# -lt 3 ]
then
   echo
   echo "Usage: $0 <Arguments>"
   echo
   echo "Arguments are:"
   echo
   echo "1. Loop (e.g. L1)"
   echo "2. Loop definition (e.g. L24-L34)"
   echo "3. File with list of all B-factors"
   echo
   exit 0
fi

loop=$1
loopDef=$2
BFsFilename=$3

# Gather the mean and standard deviation.

out=`~/BASIC_UTILITIES/get_mean_and_standard_deviation.pl $BFsFilename`

# $out is of the form:
#
# Mean: 33.5599702736305 Standard Deviation: 22.202645204936

mean=`echo $out | awk '{print $2}'`
sd=`echo $out | awk '{print $5}'`

for pdbCode in `cat unique_PDB_codes.lst`
do
   FvPDBFilename=/home/bsm2/abhi/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$pdbCode.pdb

   # Run the perl script.
   #
   # perl flag_bad_loops.pl 12e8 ~/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/12e8.pdb L1 L24-L34 33.5599702736305 22.202645204936

   perl flag_bad_loops.pl $pdbCode $FvPDBFilename $loop $loopDef $mean $sd

   # Print the PDB code.

   echo $pdbCode

done
