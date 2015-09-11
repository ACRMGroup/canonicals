#! /bin/sh

# Usage: flag_bad_loops.sh <Loop (e.g. L1)> <Loop definition (.e.g. L24-L34)>

echo L1
sh flag_bad_loops.sh L1 L24-L34 | grep "," > bad_loops_L1.csv
echo L2
sh flag_bad_loops.sh L2 L50-L56 | grep "," > bad_loops_L2.csv
echo L3
sh flag_bad_loops.sh L3 L89-L97 | grep "," > bad_loops_L3.csv
echo H1
sh flag_bad_loops.sh H1 H26-H35 | grep "," > bad_loops_H1.csv
echo H2
sh flag_bad_loops.sh H2 H50-H58 | grep "," > bad_loops_H2.csv
