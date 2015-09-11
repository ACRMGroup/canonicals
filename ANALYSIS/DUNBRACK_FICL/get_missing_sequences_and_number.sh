#! /bin/sh

# Get the missing sequences.

for pdbCode in `cat missing_PDB_codes.lst`
do

   originalPDBFilename="/acrm/data/pdb/pdb"$pdbCode".ent"
   pirFilename=~/CANONICALS/NEW_DATASET/OUR_MISSING_PDB_SEQUENCES/$pdbCode.pir

   pdb2pir -C -s $originalPDBFilename $pirFilename
   echo $pdbCode

done

# Get numbering.

# Set the substitution matrix path.

export SUBSTITUTION_MATRIX_PATH=/home/bsm2/abhi/ABNUM/CONFIG_FILES/MDM.mat
export ABNUM=/home/bsm2/abhi/ABNUM/

for file in `ls -1 ~/CANONICALS/NEW_DATASET/OUR_MISSING_PDB_SEQUENCES/*.pir`
do
   pdbCode=`basename $file .pir`
   numberingOutputFilename=~/CANONICALS/NEW_DATASET/OUR_MISSING_PDB_NUMBERING/$pdbCode.out

   /home/bsm2/abhi/ABNUM/kabnum_wrapper_with_PC.pl $file -c -pc > $numberingOutputFilename

   echo $file
done

# Get the Fv region PDBs from the numbering and the original PDB files.

for numberingFilename in `find ~/CANONICALS/NEW_DATASET/OUR_MISSING_PDB_NUMBERING/ -name "*.out"`
do
   pdbCode=`basename $numberingFilename .out`
   originalPDBFilename=/acrm/data/pdb/pdb$pdbCode".ent"
   outputFvPDBFilename=~/CANONICALS/NEW_DATASET/OUR_MISSING_PDB_FILES/$pdbCode".pdb"

   ./get_Fv_pdb.o -num $numberingFilename -pdb $originalPDBFilename -out $outputFvPDBFilename

   echo $numberingFilename

done
