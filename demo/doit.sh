# Setup
makeclan=./scripts/makeclan.pl
clan=../src/clan

# Grab and unpack the non-redundant Chothia-numbered PDB files of antibodies
wget www.bioinf.org.uk/abs/abdb/Data/NR_CombinedAb_Chothia.tar.bz2
tar jxvf NR_CombinedAb_Chothia.tar.bz2
rm NR_CombinedAb_Chothia.tar.bz2

# Create the Clan files
$makeclan -limit=10 NR_CombinedAb_Chothia L1
#$makeclan -limit=10 NR_CombinedAb_Chothia L2
#$makeclan -limit=10 NR_CombinedAb_Chothia L3
#$makeclan -limit=10 NR_CombinedAb_Chothia H1
#$makeclan -limit=10 NR_CombinedAb_Chothia H2

# Make a results directory
mkdir -p results

# Run CLAN
$clan L1.clan
$clan L2.clan
$clan L3.clan
$clan H1.clan
$clan H2.clan


