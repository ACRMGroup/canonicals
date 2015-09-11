#! /bin/sh

# Add blank lines to the lists (ALL_STRUCTURES and EVERY_STRUCTURE).

perl identify_loops_with_missing_residues.pl unique_PDB_codes.lst L24-L34 > bad_loops_L1.csv
perl identify_loops_with_missing_residues.pl unique_PDB_codes.lst L50-L56 > bad_loops_L2.csv
perl identify_loops_with_missing_residues.pl unique_PDB_codes.lst L89-L97 > bad_loops_L3.csv
perl identify_loops_with_missing_residues.pl unique_PDB_codes.lst H26-H35 > bad_loops_H1.csv
perl identify_loops_with_missing_residues.pl unique_PDB_codes.lst H50-H58 > bad_loops_H2.csv

# Concatenate with the list of bad loops by evaluating B-factors of all structures.

cat bad_loops_L1.csv ../BASED_ON_ALL_STRUCTURES//bad_loops_L1.csv > ../all_struc_bad_loops_L1.csv
cat bad_loops_L2.csv ../BASED_ON_ALL_STRUCTURES//bad_loops_L2.csv > ../all_struc_bad_loops_L2.csv
cat bad_loops_L3.csv ../BASED_ON_ALL_STRUCTURES//bad_loops_L3.csv > ../all_struc_bad_loops_L3.csv
cat bad_loops_H1.csv ../BASED_ON_ALL_STRUCTURES//bad_loops_H1.csv > ../all_struc_bad_loops_H1.csv
cat bad_loops_H2.csv ../BASED_ON_ALL_STRUCTURES//bad_loops_H2.csv > ../all_struc_bad_loops_H2.csv

# Concatenate with the list of bad loops by evaluating B-factors of every structure.

cat bad_loops_L1.csv ../BASED_ON_EVERY_STRUCTURE//bad_loops_L1.csv > ../every_struc_bad_loops_L1.csv
cat bad_loops_L2.csv ../BASED_ON_EVERY_STRUCTURE//bad_loops_L2.csv > ../every_struc_bad_loops_L2.csv
cat bad_loops_L3.csv ../BASED_ON_EVERY_STRUCTURE//bad_loops_L3.csv > ../every_struc_bad_loops_L3.csv
cat bad_loops_H1.csv ../BASED_ON_EVERY_STRUCTURE//bad_loops_H1.csv > ../every_struc_bad_loops_H1.csv
cat bad_loops_H2.csv ../BASED_ON_EVERY_STRUCTURE//bad_loops_H2.csv > ../every_struc_bad_loops_H2.csv
