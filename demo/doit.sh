# Setup
makeclan=./scripts/makeclan.pl
clan=../src/clan
findsdrs=../src/findsdrs

# Uncomment this line for testing on a small set:
#limit='-limit=10'   

# Grab and unpack the non-redundant Chothia-numbered PDB files of antibodies
wget www.bioinf.org.uk/abs/abdb/Data/NR_CombinedAb_Chothia.tar.bz2
tar jxvf NR_CombinedAb_Chothia.tar.bz2
rm NR_CombinedAb_Chothia.tar.bz2

# Create the Clan files
$makeclan $limit NR_CombinedAb_Chothia L1
$makeclan $limit NR_CombinedAb_Chothia L2
$makeclan $limit NR_CombinedAb_Chothia L3
$makeclan $limit NR_CombinedAb_Chothia H1
$makeclan $limit NR_CombinedAb_Chothia H2

# Make a results directory
mkdir -p results

# Run CLAN
for loop in L1 L2 L3 H1 H2
do
   echo "Analyzing clusters for CDR $loop"
   $clan $loop.clan
done

# Run findsdrs
for loop in L1 L2 L3 H1 H2
do
   echo -n "Finding key residues for CDR $loop..."
   $findsdrs -k results/${loop}_clan.out results/${loop}.sdrs 2>results/${loop}.log
   echo "done"
done

# Remove the solvent accessibility files
\rm *.sa

echo " "
echo " "

echo "Final results are in results/??.sdrs"
echo "Log files are in results/??.log"

