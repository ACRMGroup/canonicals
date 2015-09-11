#! /bin/bash

# Check if the environment variable PROCESS has been set. If not, report error and exit script.

if [ ! `echo $PROCESS` ]
then
   echo
   echo "Please set environment variable PROCESS to point to the required processing directory"
   echo
   exit 0
fi

processingDirectory=$PROCESS

# Check if the PDB codes list file has been passed as command line parameter.
# If it hasn't, print message and exit.

if [ $# -lt 1 ]
then
   echo
   echo "Please pass the file containing PDB codes as parameter"
   echo
   exit 0
fi

# Check if file with PDB codes is present.

pdbCodesListFile=$1

if [ ! -e $pdbCodesListFile ]
then
   echo
   echo File $pdbCodesListFile does not exist
   echo
   exit 0
fi

# Step 1: Write PDB paths into a file.

perl create_pdb_file_list.pl $pdbCodesListFile > pdb_files.lst
echo "Completed create_pdb_file_list.pl" > completed.txt

# Step 2: Create PIR format sequence files out of the PDB files.

for file in `cat pdb_files.lst`
do
   pdbCode=`basename $file .ent | sed 's/pdb//'`
   # pdb2pir -c $file > $processingDirectory/PDB_SEQUENCES/ALL_SEQUENCES/$pdbCode.pir
   pdb2pir -C -s $file > $processingDirectory/PDB_SEQUENCES/ALL_SEQUENCES/$pdbCode.pir
done

echo "Completed creation of PDB files from PDB codes. Written into ALL_SEQUENCES" >> completed.txt

# Step 3: Remove sequences of antigens from the original PIR format sequence files.
#	  Before doing this, remove the files one.txt and many.txt.
#	  Also, the directory $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS
#	  needs to be created.

rm -f many.txt one.txt
mkdir $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS


for file in `ls -1 $processingDirectory/PDB_SEQUENCES/ALL_SEQUENCES/*.pir`
do
   pdbCode=`basename $file .pir`
   echo $file
   ./split_pdb_file_list.exe -in $file -out $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS/$pdbCode.pir -many many.txt -one one.txt
done

echo "Completed running split_pdb_file_list.exe" >> completed.txt

# Step 4: Move antibodies with more than one light and heavy chain into the appropriate directory.
#
# Source directory: $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS
# Destination directory: $processingDirectory/PDB_SEQUENCES/MANY_CHAINS/
#

for file in `grep File many.txt | awk '{print $2}'`
do
   pdbCode=`basename $file .pir`
   mv $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS/$pdbCode.pir $processingDirectory/PDB_SEQUENCES/MANY_CHAINS/
done

echo "Moved all sequences with more than one light and heavy chain (from many.txt) into directory MANY_CHAINS" >> completed.txt

# Step 5: Move antibodies with a single light and heavy chain into the final directory.
#
# Source directory: $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS
# Target/Final directory: $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS_AND_REDUNDANCY

for file in `grep File one.txt | awk '{print $2}'`
do
   pdbCode=`basename $file .pir`
   mv $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS/$pdbCode.pir $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS_AND_REDUNDANCY
done


echo "Moved all files with a single light and heavy chain (from one.txt) into directory WITHOUT_ANTIGENS_AND_REDUNDANCY" >> completed.txt

# Step 6: Eliminate redundancy in files with more than one light and heavy chain.

# Note: The sole purpose of running the program "remove_redundant_sequences.exe" is to find structures that
#       contain more than one unique antibody (Eg. Anti-idiotype antibodies). Once we know these, the program
#       "choose_correct_chain_combination.exe" must be used to select the appropriate combination of light and
#       heavy chains in the antibody.

for file in `ls -1 $processingDirectory/PDB_SEQUENCES/MANY_CHAINS/*.pir`
do
   pdbCode=`basename $file .pir`

   ./remove_redundant_sequences.exe -in $file -out $processingDirectory/PDB_SEQUENCES/WITHOUT_REDUNDANCY/$pdbCode.pir

done

# echo "Completed running remove_redundant_sequences on sequences in MANY_CHAINS" >> completed.txt

echo "Completed running remove_redundant_sequences.exe on sequences in MANY_CHAINS" >> completed.txt

# Step 7: Now, compile a list of all files that have only a single unique antibody in them.
#         Store the list of PDBs in the file "single_unique_antibody.lst".
#         Structures with more than one unique antibody are writted into a file called
#         "multiple_unique_antibodies.lst"

rm -f single_unique_antibody.lst multiple_unique_antibodies.lst

for file in `ls -1 $processingDirectory/PDB_SEQUENCES/WITHOUT_REDUNDANCY/*.pir`
do

   pdbCode=`basename $file .pir`
   frequency=`grep -c "^>" $file`

   if [ $frequency -lt 2 ]
   then
      echo "Faulty processing for $pdbCode. It has $frequency chains."
      read
   fi

   if [ "$frequency" -eq "2" ]
   then
      echo $pdbCode >> single_unique_antibody.lst
   fi

   if [ "$frequency" -eq "4" ]
   then
      echo $pdbCode >> multiple_unique_antibodies.lst
   fi

   if [ "$frequency" -eq "3" ]
   then
      echo "Faulty processing for $pdbCode. It has $frequency chains."
      read
   fi

   if [ $frequency -gt 4 ]
   then
      echo "Faulty processing for $pdbCode. It has $frequency chains."
      read
   fi

   echo $pdbCode

done

# Step 8: Run the program "choose_correct_chain_combination.exe" on the files containing a single
#         unique antibody. Write all the output PIR format files into the following directory:
#         WITHOUT_ANTIGENS_AND_REDUNDANCY.

for pdbCode in `cat single_unique_antibody.lst`
do

   inputFilename=$processingDirectory/PDB_SEQUENCES/MANY_CHAINS/$pdbCode.pir
   outputFilename=$processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS_AND_REDUNDANCY/$pdbCode.pir

   ./choose_correct_chain_combination.exe -i $inputFilename -o $outputFilename
   echo $pdbCode

done

# Step 9: Remove files that correspond to PDB entries in ignore.lst

for pdbCode in `cat ignore.lst`
do
   for file in `find $processingDirectory/PDB_SEQUENCES -iname "$pdbCode*"`
   do
      rm -f $file
   done
done

# Step 10: Remove the directory WITHOUT_ANTIGENS.

rm -rf $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS

echo "Completed erasing directory WITHOUT_ANTIGENS" >> completed.txt

# Step 11: Make final list of PDB Codes from the directory WITHOUT_ANTIGENS_AND_REDUNDANCY

mv Fv_Fab_pdb.lst Fv_Fab_pdb.lst.1

for file in `ls -1 $processingDirectory/PDB_SEQUENCES/WITHOUT_ANTIGENS_AND_REDUNDANCY/`
do
   pdbCode=`basename $file .pir`
   echo $pdbCode >> Fv_Fab_pdb.lst
done

echo "Completed creation of update list of PDB Codes for analysis" >> completed.txt

# Step 12: Run the numbering program.

for pdbCode in `cat Fv_Fab_pdb.lst`
do
   inputFilename=PDB_SEQUENCES/WITHOUT_ANTIGENS_AND_REDUNDANCY/$pdbCode.pir
   outputFilename=NUMBERED_FILES/$pdbCode.out

   perl $ABNUM/kabnum_wrapper_with_PC.pl $inputFilename -c -pc >> $outputFilename

done

# Step 13: Extract only the numbering from the .out files.

cd NUMBERED_FILES
cp ../SCRIPTS/get_only_numbering.sh .
sh get_only_numbering.sh
cd ..

# Step 14: Get only the Fv region of the antibody. Run the script
#
# Note: Look into file some.log to ensure that all the PDB files have been created without errors.
# At the end of the process, do an 'ls -1 CHAIN_PDBS | wc -l' and see how many files are found in
# the directory CHAIN_PDBS. If this does not match the number of PDB codes in the file "Fv_Fab_pdb.lst"
# then it means there was an error in processing.

sh create_Fv_pdb.sh >& some.log

# Step 15: Patch the numbering into the PDB files. Write the resulting patched PDB files into the
#          directory PATCHED_PDBS.
#
# Note: Look into file some.log to ensure that all the PDB files have been created without errors.
# At the end of the process, do an 'ls -1 PATCHED_PDBS | wc -l' and see how many files are found in
# the directory PATCHED_PDBS. If this does not match the number of PDB codes in the file "Fv_Fab_pdb.lst"
# then it means there was an error in processing.

sh patch_pdb.sh >& some.log

# Step 16: Run the program to get the individual light and heavy chains from the patched PDB files.

sh split_patched_pdbs.sh >& some.log

# Step 17: Copy 'standard.data' to the following directories:
#
# 1. PATCHED_PDBS/
# 2. SPLIT_PATCHED_PDBS/

cp /home/bsm/martin/acrm/sa/standard.data PATCHED_PDBS
cp /home/bsm/martin/acrm/sa/standard.data SPLIT_PATCHED_PDBS

# Step 18: Run the asurf program on all PDB files in the directories PATCHED_PDBS and SPLIT_PATCHED_PDBS.

sh asurf.sh

# Step 19: Erase the following files in these directories after the execution of asurf on ALL files is complete.
#
# 1. asurf.sh.e*
# 2. asurf.sh.o*
# 3. *.log
# 4. *.asa
#
# Also, remove the shell script grid_asurf.sh from the individual directories.

find PATCHED_PDBS -name "*.asa" | xargs rm -f
find PATCHED_PDBS -name "*.log" | xargs rm -f
find PATCHED_PDBS -name "*.sh.e*" | xargs rm -f
find PATCHED_PDBS -name "*.sh.o*" | xargs rm -f

find SPLIT_PATCHED_PDBS -name "*.asa" | xargs rm -f
find SPLIT_PATCHED_PDBS -name "*.log" | xargs rm -f
find SPLIT_PATCHED_PDBS -name "*.sh.e*" | xargs rm -f
find SPLIT_PATCHED_PDBS -name "*.sh.o*" | xargs rm -f

rm -f PATCHED_PDBS/grid_asurf.sh
rm -f SPLIT_PATCHED_PDBS/grid_asurf.sh

# Step 20: Find the positions that form the VH-VL interface.

for pdbCode in `cat Fv_Fab_pdb.lst`
do

   lightFile="SPLIT_PATCHED_PDBS/$pdbCode"_L.rsa

   heavyFile="SPLIT_PATCHED_PDBS/$pdbCode"_H.rsa

   complexFile="PATCHED_PDBS/$pdbCode".rsa

   outputFilename=INTERFACE_POSITIONS_AND_RESIDUES/$pdbCode.lst

   overallInterfaceResidueListFile=overall_interface_residues.lst_"$changeFraction"

   ./find_interface_residues.exe -l $lightFile -h $heavyFile -c $complexFile -o $outputFilename -f $changeFraction -overall $overallInterfaceResidueListFile -rel 10

   echo $pdbCode
done


# Step 21: Find the interface angle and write PDB files for the best fit lines.
#
# Note: Examine the file "some.log" after calculation of all the interface angles to ensure
#       that the program worked properly!

sh calculate_torsion_angle.sh >& some.log
