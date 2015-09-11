#! /bin/sh

# Print the header line.

echo "LOOP   LOOPDEF"\
     "PDB1   CLASS1   RESOL1   LOWBF1   HIGHBF1"\
     "PDB2   CLASS2   RESOL2   LOWBF2   HIGHBF2"\
     "CA-RMS"
     
for line in `cat high_ca_rms.txt`
do
   # Line is of the form:
   #
   # H1,1rzg,10C,2jb5,10Y,H26-H35,2.810

   loop=`echo $line | awk -F',' '{print $1}'`
   pdb1=`echo $line | awk -F',' '{print $2}'`
   class1=`echo $line | awk -F',' '{print $3}'`
   pdb2=`echo $line | awk -F',' '{print $4}'`
   class2=`echo $line | awk -F',' '{print $5}'`
   loopBoundary=`echo $line | awk -F',' '{print $6}'`
   ca_rms=`echo $line | awk -F',' '{print $7}'`

   # Set the filenames for the full PDB files.

   if [ `echo $pdb1 | grep "_"` ]
   then
      newPDBCode=`echo $pdb1 | sed 's/_[1-2]//'`
      fullPDB1Filename="/acrm/data/pdb/pdb"$newPDBCode".ent"
   else
      fullPDB1Filename="/acrm/data/pdb/pdb"$pdb1".ent"
   fi

   if [ `echo $pdb2 | grep "_"` ]
   then
      newPDBCode=`echo $pdb2 | sed 's/_[1-2]//'`
      fullPDB2Filename="/acrm/data/pdb/pdb"$newPDBCode".ent"
   else
      fullPDB2Filename="/acrm/data/pdb/pdb"$pdb2".ent"
   fi

   # Set the file names for only the light and heavy chains.

   LH_PDB1="$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/"$pdb1".pdb"
   LH_PDB2="$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/"$pdb2".pdb"

   # Get the resolutions and R-factors.

   resol1=`getresol $fullPDB1Filename`
   resol2=`getresol $fullPDB2Filename`

   # Get the start and end positions of the loop.

   startPosition=`echo $loopBoundary | awk -F'-' '{print $1}'`
   endPosition=`echo $loopBoundary | awk -F'-' '{print $2}'`

   # Find the lowest and highest B-factors for the CA atoms in PDB1.

   lowestBF1=10000
   highestBF1=-10000

   for BF in `getpdb $startPosition $endPosition $LH_PDB1 | grep CA | awk '{print $11}'`
   do
      # Check for the lowest CA B-factors.

      res=`echo "$BF > $lowestBF1" | bc`

      if [ $res -eq 0 ]
      then
         lowestBF1=$BF
      fi

      # Check for the highest CA B-factors.

      res=`echo "$BF < $highestBF1" | bc`

      if [ $res -eq 0 ]
      then
         highestBF1=$BF
      fi

   done # End of for loop.

   # Find the lowest and highest B-factors for the CA atoms in PDB2.

   lowestBF2=10000
   highestBF2=-10000

   for BF in `getpdb $startPosition $endPosition $LH_PDB2 | grep CA | awk '{print $11}'`
   do
      # Check for the lowest CA B-factors.

      res=`echo "$BF > $lowestBF2" | bc`

      if [ $res -eq 0 ]
      then
         lowestBF2=$BF
      fi

      # Check for the highest CA B-factors.

      res=`echo "$BF < $highestBF2" | bc`

      if [ $res -eq 0 ]
      then
         highestBF2=$BF
      fi

   done # End of for loop.

   # Print the loop, PDBs, canonical classes, resolutions, lowest and highest B-factors.

   echo $loop"   "$loopBoundary"   "\
        $pdb1"   "$class1"   "$resol1"   "$lowestBF1"   "$highestBF1"   "\
        $pdb2"   "$class2"   "$resol2"   "$lowestBF2"   "$highestBF2"   "\
        $ca_rms
done
