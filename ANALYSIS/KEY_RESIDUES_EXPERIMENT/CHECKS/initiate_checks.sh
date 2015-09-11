#! /bin/sh

# It appears that some results for the calculation of
# pairwise sequence identity do not match those from
# previous runs (i.e. when the perl program to calculate
# pairwise identity over just the loop or framework key
# residues and loop sequence on two different occasions,
# the results differ). To check whether this is indeed the
# case, this script calls other shell scripts to check the
# results of the following:
#
# 1. Case 1, part 1 results.
#
# 2. Case 2, part 1 results.

outputFilename=checks_case1.txt

# Initiate Case 1 checks.

echo "Case 1:" > $outputFilename
echo >> $outputFilename
echo "L1" >> $outputFilename
sh check_case1.sh ../L1_case1_part1.csv >> $outputFilename
echo "----------" >> $outputFilename

echo >> $outputFilename
echo "L2" >> $outputFilename
sh check_case1.sh ../L2_case1_part1.csv >> $outputFilename
echo "----------" >> $outputFilename

echo >> $outputFilename
echo "L3" >> $outputFilename
sh check_case1.sh ../L3_case1_part1.csv >> $outputFilename
echo "----------" >> $outputFilename

echo >> $outputFilename
echo "H1" >> $outputFilename
sh check_case1.sh ../H1_case1_part1.csv >> $outputFilename
echo "----------" >> $outputFilename

echo >> $outputFilename
echo "H2" >> $outputFilename
sh check_case1.sh ../H2_case1_part1.csv >> $outputFilename
echo "----------" >> $outputFilename

# Initiate Case 2, part 1 checks.

outputFilename=checks_case2.txt

echo "Case 2:" > $outputFilename

echo >> $outputFilename
echo "L1" >> $outputFilename
echo >> $outputFilename
sh check_case2.sh ../L1_case2_part1.csv ../../SUMMARIES/pdb_codes_L1.out ../canonical_L1.fasta >> $outputFilename
echo "----------" >> $outputFilename

echo >> $outputFilename
echo "L2" >> $outputFilename
echo >> $outputFilename
sh check_case2.sh ../L2_case2_part1.csv ../../SUMMARIES/pdb_codes_L2.out ../canonical_L2.fasta >> $outputFilename
echo "----------" >> $outputFilename

echo >> $outputFilename
echo "L3" >> $outputFilename
echo >> $outputFilename
sh check_case2.sh ../L3_case2_part1.csv ../../SUMMARIES/pdb_codes_L3.out ../canonical_L3.fasta >> $outputFilename
echo "----------" >> $outputFilename

echo >> $outputFilename
echo "H1" >> $outputFilename
echo >> $outputFilename
sh check_case2.sh ../H1_case2_part1.csv ../../SUMMARIES/pdb_codes_H1.out ../canonical_H1.fasta >> $outputFilename
echo "----------" >> $outputFilename

echo >> $outputFilename
echo "H2" >> $outputFilename
echo >> $outputFilename
sh check_case2.sh ../H2_case2_part1.csv ../../SUMMARIES/pdb_codes_H2.out ../canonical_H2.fasta >> $outputFilename
echo "----------" >> $outputFilename
