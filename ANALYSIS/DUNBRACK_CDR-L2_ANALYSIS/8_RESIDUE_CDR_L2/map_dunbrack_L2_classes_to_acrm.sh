#! /bin/sh

echo "PDB,DUN_CLASS,ACRM_CLASS" > dunbrack_acrm_L2_map.out

for line in `cat dunbrack_8_residue_L2_pdb_codes_and_classes.out`
do
   if [ `echo $line | grep -v "^[0-9]"` ]
   then
      continue
   fi

   # Line is of the form:
   #
   # 1A0Q,L2-8-1

   dunPDBCode=`echo $line | awk -F',' '{print $1}'`
   dunClass=`echo $line | awk -F',' '{print $2}'`

   acrmCanonicalClass=`grep -i $dunPDBCode pdb_codes_L2.out | awk -F',' '{print \$3}'`

   echo "$dunPDBCode,$dunClass,$acrmCanonicalClass" >> dunbrack_acrm_L2_map.out
done
