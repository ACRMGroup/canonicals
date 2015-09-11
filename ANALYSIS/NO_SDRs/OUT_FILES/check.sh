#! /bin/sh

# Checks have to be performed for the following classes:
#
# CDR-L2: 7A, 7D, 7E
# CDR-H2: 10F

outputFilename=comparison.txt

# Remove the output file.

rm -f $outputFilename

# Case 1: CDR-L2, class 7A

loop=L2
class1=7A

originalFASTAFile="../"$loop"_SDR.fasta"
searchString=$class1"_"

for newFASTAFilename in `find ./ -maxdepth 1 -name "*.fasta" | grep $searchString`
do
   class2=`echo $newFASTAFilename | awk -F'_' '{print $2}' | sed 's/.fasta//'`

   echo "Checking PDBs of $class1 for residues at SDRs of $class2 for loop CDR-"$loop >> $outputFilename
   perl check.pl $originalFASTAFile $newFASTAFilename $class1 $class2 >> $outputFilename
   echo "-----------" >> $outputFilename

   echo "Checking PDBs of $class1 for residues at SDRs of $class2 for loop CDR-"$loop
done


# Case 2: CDR-L2, class 7D

loop=L2
class1=7D

originalFASTAFile="../"$loop"_SDR.fasta"
searchString=$class1"_"

for newFASTAFilename in `find ./ -maxdepth 1 -name "*.fasta" | grep $searchString`
do
   class2=`echo $newFASTAFilename | awk -F'_' '{print $2}' | sed 's/.fasta//'`

   echo "Checking PDBs of $class1 for residues at SDRs of $class2 for loop CDR-"$loop >> $outputFilename
   perl check.pl $originalFASTAFile $newFASTAFilename $class1 $class2 >> $outputFilename
   echo "-----------" >> $outputFilename

   echo "Checking PDBs of $class1 for residues at SDRs of $class2"
done


# Case 3: CDR-L2, class 7E

loop=L2
class1=7E

originalFASTAFile="../"$loop"_SDR.fasta"
searchString=$class1"_"

for newFASTAFilename in `find ./ -maxdepth 1 -name "*.fasta" | grep $searchString`
do
   class2=`echo $newFASTAFilename | awk -F'_' '{print $2}' | sed 's/.fasta//'`

   echo "Checking PDBs of $class1 for residues at SDRs of $class2 for loop CDR-"$loop >> $outputFilename
   perl check.pl $originalFASTAFile $newFASTAFilename $class1 $class2 >> $outputFilename
   echo "-----------" >> $outputFilename

   echo "Checking PDBs of $class1 for residues at SDRs of $class2"
done


# Case 4: CDR-H2, class 10F

loop=H2
class1=10F

originalFASTAFile="../"$loop"_SDR.fasta"
searchString=$class1"_"

for newFASTAFilename in `find ./ -maxdepth 1 -name "*.fasta" | grep $searchString`
do
   class2=`echo $newFASTAFilename | awk -F'_' '{print $2}' | sed 's/.fasta//'`

   echo "Checking PDBs of $class1 for residues at SDRs of $class2 for loop CDR-"$loop >> $outputFilename
   perl check.pl $originalFASTAFile $newFASTAFilename $class1 $class2 >> $outputFilename
   echo "-----------" >> $outputFilename

   echo "Checking PDBs of $class1 for residues at SDRs of $class2"
done


