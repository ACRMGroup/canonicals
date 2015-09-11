#! /bin/sh

# Get a unique set of Fv sequences in FASTA format.
#
# Unique sequences are stored in the file Fv_unique.pir

sh get_unique_Fv_sequences.sh

# Get the canonical definition files in FASTA format.

perl convert_candef_to_FASTA.pl L1 ~/CANONICALS/acaca/canonical_L1 canonical_L1.fasta
perl convert_candef_to_FASTA.pl L2 ~/CANONICALS/acaca/canonical_L2 canonical_L2.fasta
perl convert_candef_to_FASTA.pl L3 ~/CANONICALS/acaca/canonical_L3 canonical_L3.fasta
perl convert_candef_to_FASTA.pl H1 ~/CANONICALS/acaca/canonical_H1 canonical_H1.fasta
perl convert_candef_to_FASTA.pl H2 ~/CANONICALS/acaca/canonical_H2 canonical_H2.fasta

# Case 1, part 2:

nohup sh case1_part2.sh L1 L24-L34 L1_case1_part1.csv LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_L1.csv ../SUMMARIES/pdb_codes_L1.out > & L1_case1_part2.csv &
nohup sh case1_part2.sh L2 L50-L56 L2_case1_part1.csv LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_L2.csv ../SUMMARIES/pdb_codes_L2.out > & L2_case1_part2.csv &
nohup sh case1_part2.sh L3 L89-L97 L3_case1_part1.csv LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_L3.csv ../SUMMARIES/pdb_codes_L3.out > & L3_case1_part2.csv &
nohup sh case1_part2.sh H1 H26-H35 H1_case1_part1.csv LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_H1.csv ../SUMMARIES/pdb_codes_H1.out > & H1_case1_part2.csv &
nohup sh case1_part2.sh H2 H50-H58 H2_case1_part1.csv LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_H2.csv ../SUMMARIES/pdb_codes_H2.out > & H2_case1_part2.csv &

# Case 2, part 2.

nohup sh case2_part2.sh L1 L24-L34 L1_case2_part1.csv LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_L1.csv ../SUMMARIES/pdb_codes_L1.out canonical_L1.fasta >& L1_case2_part2.csv &
nohup sh case2_part2.sh L2 L50-L56 L2_case2_part1.csv LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_L2.csv ../SUMMARIES/pdb_codes_L2.out canonical_L2.fasta > & L2_case2_part2.csv &
nohup sh case2_part2.sh L3 L89-L97 L3_case2_part1.csv LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_L3.csv ../SUMMARIES/pdb_codes_L3.out canonical_L3.fasta >& L3_case2_part2.csv &
nohup sh case2_part2.sh H1 H26-H35 H1_case2_part1.csv LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_H1.csv ../SUMMARIES/pdb_codes_H1.out canonical_H1.fasta >& H1_case2_part2.csv &
nohup sh case2_part2.sh H2 H50-H58 H2_case2_part1.csv LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_H2.csv ../SUMMARIES/pdb_codes_H2.out canonical_H2.fasta >& H2_case2_part2.csv &



# Case 3, part 1:

nohup sh case3.sh LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_L1.csv canonical_L1.fasta L1_case2_part1.csv ../SUMMARIES/pdb_codes_L1.out > & L1_case3_part1.csv &
nohup sh case3.sh LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_L2.csv canonical_L2.fasta L2_case2_part1.csv ../SUMMARIES/pdb_codes_L2.out > & L2_case3_part1.csv &
nohup sh case3.sh LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_L3.csv canonical_L3.fasta L3_case2_part1.csv ../SUMMARIES/pdb_codes_L3.out > & L3_case3_part1.csv &
nohup sh case3.sh LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_H1.csv canonical_H1.fasta H1_case2_part1.csv ../SUMMARIES/pdb_codes_H1.out > & H1_case3_part1.csv &
nohup sh case3.sh LOOPS_TO_IGNORE/BASED_ON_ALL_STRUCTURES/bad_loops_H2.csv canonical_H2.fasta H2_case2_part1.csv ../SUMMARIES/pdb_codes_H2.out > & H2_case3_part1.csv &

# Case 3, part 2:

nohup perl process_case3_files.pl L1 L24-L34 L1_case3_part1.csv ../SUMMARIES/pdb_codes_L1.out canonical_L1.fasta > & L1_case3_part2.csv &
nohup perl process_case3_files.pl L2 L50-L56 L2_case3_part1.csv ../SUMMARIES/pdb_codes_L2.out canonical_L2.fasta > & L2_case3_part2.csv &
nohup perl process_case3_files.pl L3 L89-L97 L3_case3_part1.csv ../SUMMARIES/pdb_codes_L3.out canonical_L3.fasta > & L3_case3_part2.csv &
nohup perl process_case3_files.pl H1 H26-H35 H1_case3_part1.csv ../SUMMARIES/pdb_codes_H1.out canonical_H1.fasta > & H1_case3_part2.csv &
nohup perl process_case3_files.pl H2 H50-H58 H2_case3_part1.csv ../SUMMARIES/pdb_codes_H2.out canonical_H2.fasta > & H2_case3_part2.csv &

# Evaluate correlation coefficients between the sequence identity and RMS in all 3 cases.
#
# Case 1: Lines are of the form:
#
# L1,L24-L34,2f5a,11A,RASQGVTSALA,1tjg,11A,RASQGVTSALA,100.01,0.962
#
# NOTE: Before running the for loop, ensure that there are no lines that correspond to missing
#       residues in loops of some PDBs. These are identified by "-100000" in the case1 result files.
#
#       E.g. L1_case1_part1.csv has a line that corresponds to missing residues in the loop of the PDB 3c08.
#
#       L1,L24-L34,3c08,8A,SASVTYMY,,,,-100000,

for file in `ls -1 *_case1_part1.csv`
do

   prefix=`basename $file .csv`
   outputFilename=$prefix"_seqid_rms.txt"

   echo $file

   for line in `cat $file`
   do
      if [ `echo $line | egrep -v '[0-9]$'` ]
      then
         continue
      fi

      seqid=`echo $line | awk -F',' '{print \$9}'`
      rms=`echo $line | awk -F',' '{print \$10}'`

      echo $seqid" "$rms >> $outputFilename

   done # End of inner for loop.

done # End of outer for loop.

# Calculate the correlation coefficients.

echo "CASE 1:"
echo "-------"

for file in `ls -1 *_case1_seqid_rms.txt`
do
   cor=`correlation $file`
   echo $file": "$cor
done

echo "-------"

# Case 2: Lines are of the form (in files *_case2_part1.csv):
#
# L2,L50-L56,1i8i,7C,EGNTLRP,1ind,7A,GTNNRAP,100.0,1.612
#
# NOTE: Before running the for loop, ensure that there are no lines that correspond to missing
#       residues in loops of some PDBs. Examples of such lines include:
#
# Skipping 2jb6 for 10F
# H1,H26-H35,2jb6,,NYAIN,1mj7,,SSWIN,51.6,

for file in `ls -1 *_case2_part1.csv`
do

   prefix=`basename $file .csv`
   outputFilename=$prefix"_seqid_rms.txt"

   echo $file

   for line in `grep -v Skip $file`
   do
      if [ `echo $line | egrep -v '[0-9]$'` ]
      then
         continue
      fi

      seqid=`echo $line | awk -F',' '{print \$9}'`
      rms=`echo $line | awk -F',' '{print \$10}'`

      echo $seqid" "$rms >> $outputFilename

   done # End of inner for loop.

done # End of outer for loop.

# Calculate the correlation coefficients.

echo "CASE 2:"
echo "-------"

for file in `ls -1 *_case2_seqid_rms.txt`
do
   cor=`correlation $file`
   echo $file": "$cor
done

echo "-------"

# Case 3: Lines are of the form (in files *_case2_part1.csv):
#
# 2f5a,9A,1tjg,9A,0.9,0.756
#
# NOTE: Before running the for loop, ensure that there are no lines that correspond to missing
#       residues in loops of some PDBs. Examples of such lines include:
#
# 2jb6,,1mj7,,0.4,

for file in `ls -1 *_case3_part2.csv`
do

   prefix=`basename $file .csv`
   outputFilename=$prefix"_seqid_rms.txt"

   echo $file

   for line in `cat $file`
   do
      if [ `echo $line | egrep -v '[0-9]$'` ]
      then
         continue
      fi

      seqid=`echo $line | awk -F',' '{print \$5}'`
      rms=`echo $line | awk -F',' '{print \$6}'`

      echo $seqid" "$rms >> $outputFilename

   done # End of inner for loop.

done # End of outer for loop.

# Calculate the correlation coefficients.

echo "CASE 3:"
echo "-------"

for file in `ls -1 *_case3_part2_seqid_rms.txt`
do
   cor=`correlation $file`
   echo $file": "$cor
done

echo "-------"

# End of script.
