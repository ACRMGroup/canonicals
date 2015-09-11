#! /bin/sh

perl find_same_critical_positions.pl L1 L1_same_critical_positions.fasta ../../WITH_REFERENCE_STRUCTURES/L1_with_ref.out L1_results.out formatted.out
perl find_same_critical_positions.pl L2 L2_same_critical_positions.fasta ../../WITH_REFERENCE_STRUCTURES/L2_with_ref.out L2_results.out formatted.out
perl find_same_critical_positions.pl L3 L3_same_critical_positions.fasta ../../WITH_REFERENCE_STRUCTURES/L3_with_ref.out L3_results.out formatted.out
perl find_same_critical_positions.pl H1 H1_same_critical_positions.fasta ../../WITH_REFERENCE_STRUCTURES/H1_with_ref.out H1_results.out formatted.out
perl find_same_critical_positions.pl H2 H2_same_critical_positions.fasta ../../WITH_REFERENCE_STRUCTURES/H2_with_ref.out H2_results.out formatted.out
perl find_same_critical_positions.pl H3 H3_same_critical_positions.fasta ../../WITH_REFERENCE_STRUCTURES/H3_with_ref.out H3_results.out formatted.out

# Concatenate all the results into one tab separated.

rm -f all_loop_results.out

# Loop L1.

temp=`grep "Possible" L1_results.out`

if [ "$temp" != "" ]
then
   echo "L1" >> all_loop_results.out
   grep "Possible" L1_results.out >> all_loop_results.out
fi

# Loop L2.

temp=`grep "Possible" L2_results.out`

if [ "$temp" != "" ]
then
   echo "L2" >> all_loop_results.out
   grep "Possible" L2_results.out >> all_loop_results.out
fi

# Loop L3.

temp=`grep "Possible" L3_results.out`

if [ "$temp" != "" ]
then
   echo "L3" >> all_loop_results.out
   grep "Possible" L3_results.out >> all_loop_results.out
fi

# Loop H1.

temp=`grep "Possible" H1_results.out`

if [ "$temp" != "" ]
then
   echo "H1" >> all_loop_results.out
   grep "Possible" H1_results.out >> all_loop_results.out
fi

# Loop H2.

temp=`grep "Possible" H2_results.out`

if [ "$temp" != "" ]
then
   echo "H2" >> all_loop_results.out
   grep "Possible" H2_results.out >> all_loop_results.out
fi

# Loop H3.

temp=`grep "Possible" H3_results.out`

if [ "$temp" != "" ]
then
   echo "H3" >> all_loop_results.out
   grep "Possible" H3_results.out >> all_loop_results.out
fi

# End of script.
