if [ $# -lt 6 ]
then
   echo
   echo "Usage: $0 <Arguments>"
   echo
   echo "Arguments are:"
   echo
   echo "1. Loop"
   echo "2. File with list of PDB codes and their canonical classes for a specific loop"
   echo "3. Canonical definitions file for the loop"
   echo "4. Directory with numbering files for every PDB"
   echo "5. Extension of the numbering files (e.g.: out, num etc)"
   echo "6. Output directory for the files"
   echo

   exit 0
fi

loop=$1
pdbCodesListFilename=$2
canonicalDefinitionsFilename=$3
numberingDirectory=$4
numberingFileExtension=$5
outputDirectory=$6

# Check for the PDB codes list file.

if [ ! -r $pdbCodesListFilename ]
then
   echo
   echo "Unable to read file \"$pdbCodesListFilename\""
   echo
fi

# Assign standard filenames.

loopFASTAFilename=$loop"_SDR.fasta"

# Process every pair of canonical classes.

for class1 in `grep "^>" $loopFASTAFilename | awk -F'-' '{print $2}' | sort -u`
do
   len1=`echo $class1 | sed 's/[A-Z]//'`

   for class2 in `grep "^>" $loopFASTAFilename | awk -F'-' '{print $2}' | sort -u`
   do
      len2=`echo $class2 | sed 's/[A-Z]//'`

      # Check if the lengths are the same.

      if [ $len1 -ne $len2 ]
      then
         continue
      fi

      # Check if the classes are the same.

      if [ "$class1" == "$class2" ]
      then
         continue
      fi

      # Check if the combination of canonical classes has already been examined.

      outputFilename=$outputDirectory"/"$loop"-"$class2"_"$class1".fasta"

      # if [ -e $outputFilename ]
      # then
      #    echo "Already examined combination of $class1 and $class2 for loop CDR-"$loop
      #    continue
      # fi

      # Assign standard files.

      outputFilename=$outputDirectory"/"$loop"-"$class1"_"$class2".fasta"

      # Write the status message.

      echo "Comparing $class1 and $class2 of CDR-"$loop

      # The perl program is invoked in the following way:
      #
      # perl get_alternative_SDR_residues_FASTA_format.pl pdb_codes_L2.out ../../canonical_L2 ../../../NEW_DATASET/NUMBERED_FILES/ out 7A 7C temp.out

      command="perl get_alternative_SDR_residues_FASTA_format.pl $pdbCodesListFilename $canonicalDefinitionsFilename $numberingDirectory $numberingFileExtension $class1 $class2 $outputFilename"

      $command
   done

done
