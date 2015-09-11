#! /bin/sh

if [ $# -lt 2 ]
then
   echo
   echo "Usage: $0 <Arguments>"
   echo
   echo "Arguments are:"
   echo
   echo "1. File with amino acids of SDRs belonging for all the canonical classes of the loop"
   echo "2. Output file"
   echo
   exit 0
fi

overallFASTAFilename=$1
outputFilename=$2

# Check if the overall FASTA file can be read.

if [ ! -r $overallFASTAFilename ]
then
   echo
   echo "File \"$overallFASTAFilename\" cannot be read."
   echo
   exit 0
fi

# For every FASTA format file, check.

for file in `ls -1 *.fasta`;
do
   loop=`echo $file | awk -F'-' '{print $1}'`
   class1=`echo $file | awk -F'-' '{print $2}' | awk -F'_' '{print $1}'`
   class2=`echo $file | awk -F'-' '{print $2}' | awk -F'_' '{print $2}' | sed 's/\.fasta//'`

   # Set the file to scan.

   class1SDRResiduesFASTAFilename=$loop"-"$class1"_"$class2".fasta"

   if [ ! -r $class1SDRResiduesFASTAFilename ]
   then
      echo
      echo "File \"$class1SDRResiduesFASTAFilename\" cannot be read."
      echo
      exit 0
   fi

   # For sequences of PDBs corresponding to SDRs (of class2) belonging to class1,
   # do a string search against the FASTA file with all the sequences.

   echo "Comparing $class1 and $class2 for loop $loop" >> $outputFilename

   for seq in `grep -v "^>" $class1SDRResiduesFASTAFilename`
   do
      command="grep -B 1 $seq $overallFASTAFilename"
      $command >> $outputFilename

   done

   echo "#####################" >> $outputFilename

done
