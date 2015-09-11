#! /bin/sh

if [ $# -lt 1 ]
then
   echo
   echo "Usage: $0 <File with list of all B-factors>"
   echo
   exit 0
fi

allBFsFilename=$1

# Invoke the shell script that does what is required.

echo L1
sh flag_bad_loops.sh L1 L24-L34 $allBFsFilename | grep "," > bad_loops_L1.csv
echo L2
sh flag_bad_loops.sh L2 L50-L56 $allBFsFilename | grep "," > bad_loops_L2.csv
echo L3
sh flag_bad_loops.sh L3 L89-L97 $allBFsFilename | grep "," > bad_loops_L3.csv
echo H1
sh flag_bad_loops.sh H1 H26-H35 $allBFsFilename | grep "," > bad_loops_H1.csv
echo H2
sh flag_bad_loops.sh H2 H50-H58 $allBFsFilename | grep "," > bad_loops_H2.csv

# End of script.
