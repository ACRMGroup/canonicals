#! /usr/bin/sh

for pdbCode in `cat Fv_Fab_pdb.lst`
do
   lightChainPDB=$pdbCode"_L.pdb"
   heavyChainPDB=$pdbCode"_H.pdb"
   getchain L PATCHED_PDBS/$pdbCode.pdb > SPLIT_PATCHED_PDBS/$lightChainPDB
   getchain H PATCHED_PDBS/$pdbCode.pdb > SPLIT_PATCHED_PDBS/$heavyChainPDB

   echo $pdbCode
done
