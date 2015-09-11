#! /bin/sh

# Needed: Reference PDB file, Mobile PDB file.

if [ $# -lt 2 ]
then
   echo
   echo "Usage: $0 <Reference structure> <File with list of PDB codes>"
   echo
   exit 0
fi

referencePDBFilename=$1
pdbCodesFilename=$2

# Assign a temporary ProFit script file.

ProFitScriptFilename=/tmp/$$.prf

# For every PDB code in the file.

for pdbCode in `cat $pdbCodesFilename`
do
   # Get the light chain of the mobile structure.

   fullPDBFilename=~/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$pdbCode".pdb"
   mobilePDBFilename=$pdbCode"_L.pdb"

   getchain L $fullPDBFilename $mobilePDBFilename

   # Write the ProFit script file.

   echo "reference $referencePDBFilename" > $ProFitScriptFilename
   echo "mobile $mobilePDBFilename" >> $ProFitScriptFilename
   echo "zone 24-34" >> $ProFitScriptFilename
   echo "ignoremissing" >> $ProFitScriptFilename
   echo "fit" >> $ProFitScriptFilename

   # Run the ProFit script.

   RMS=`profit -f $ProFitScriptFilename | grep RMS | awk -F': ' '{print $2}'`

   # Print the RMS.

   echo "$referencePDBFilename,$mobilePDBFilename,$RMS"

   # Remove the mobile PDB file.

   rm -f $mobilePDBFilename

done

# Remove the ProFit script file.

rm -f $
