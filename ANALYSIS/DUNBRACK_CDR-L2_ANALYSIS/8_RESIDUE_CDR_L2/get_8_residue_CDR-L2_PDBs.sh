#! /bin/sh

echo "PDB,DUN_CLASS" > dunbrack_8_residue_L2_pdb_codes_and_classes.out

for line in `cat supplementalData_mod.csv | grep "L2-8"`
do
   classInfo=`echo $line | awk -F',' '{print $3}'`
   pdbInfo=`echo $line | awk -F',' '{print $4}'`

   if [ `echo $pdbInfo | grep _` ]
   then
      pdbCode=`echo "${pdbInfo:0:6}"`
   else
      pdbCode=`echo "${pdbInfo:0:4}"`
   fi


   echo $pdbCode","$classInfo >> dunbrack_8_residue_L2_pdb_codes_and_classes.out
done
