#! /bin/sh

# CDR-L1

echo L1
perl tabulate_old_new_canonical_classes.pl $HOME/CANONICALS/NEW_DATASET/Fv_Fab_pdb.lst $HOME/CANONICALS/acaca/results/acaca_2007/l1_clan.out $HOME/CANONICALS/acaca//results/L1_clan.out L1 L1_old_new_comparison.csv
perl check_old_new_equality.pl L1_old_new_comparison.csv > all_comparison.txt

# CDR-L2

echo L2
perl tabulate_old_new_canonical_classes.pl $HOME/CANONICALS/NEW_DATASET/Fv_Fab_pdb.lst $HOME/CANONICALS/acaca/results/acaca_2007/l2_clan.out $HOME/CANONICALS/acaca//results/L2_clan.out L2 L2_old_new_comparison.csv
perl check_old_new_equality.pl L2_old_new_comparison.csv >> all_comparison.txt

# CDR-L3

echo L3
perl tabulate_old_new_canonical_classes.pl $HOME/CANONICALS/NEW_DATASET/Fv_Fab_pdb.lst $HOME/CANONICALS/acaca/results/acaca_2007/l3_clan.out $HOME/CANONICALS/acaca//results/L3_clan.out L3 L3_old_new_comparison.csv
perl check_old_new_equality.pl L3_old_new_comparison.csv >> all_comparison.txt

# CDR-H1

echo H1
perl tabulate_old_new_canonical_classes.pl $HOME/CANONICALS/NEW_DATASET/Fv_Fab_pdb.lst $HOME/CANONICALS/acaca/results/acaca_2007/h1_clan.out $HOME/CANONICALS/acaca//results/H1_clan.out H1 H1_old_new_comparison.csv
perl check_old_new_equality.pl H1_old_new_comparison.csv >> all_comparison.txt

# CDR-H2

echo H2
perl tabulate_old_new_canonical_classes.pl $HOME/CANONICALS/NEW_DATASET/Fv_Fab_pdb.lst $HOME/CANONICALS/acaca/results/acaca_2007/h2_clan.out $HOME/CANONICALS/acaca//results/H2_clan.out H2 H2_old_new_comparison.csv
perl check_old_new_equality.pl H2_old_new_comparison.csv >> all_comparison.txt

# CDR-H3

echo H3
perl tabulate_old_new_canonical_classes.pl $HOME/CANONICALS/NEW_DATASET/Fv_Fab_pdb.lst $HOME/CANONICALS/acaca/results/acaca_2007/h3_clan.out $HOME/CANONICALS/acaca//results/H3_clan.out H3 H3_old_new_comparison.csv

# Sort the output in the file all_comparson.txt

sort -ur all_comparison.txt > 1.txt
mv 1.txt all_comparison.txt
