#! /usr/bin/sh

rm -f PATCHED_PDBS/*

for pdbCode in `cat Fv_Fab_pdb.lst`
do
   echo $pdbCode
   patchpdbnum NUMBERED_FILES/$pdbCode.pro CHAIN_PDBS/$pdbCode.pdb PATCHED_PDBS/$pdbCode.pdb
done
