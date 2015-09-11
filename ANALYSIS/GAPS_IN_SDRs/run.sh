echo "--------"
echo "Loop: L1"
perl get_SDRs_FASTA_format.pl pdb_codes_L1.out ../../canonical_L1 ../../../NEW_DATASET/NUMBERED_FILES/ out L1_SDR.fasta
echo "--------"
echo "Loop: L2"
perl get_SDRs_FASTA_format.pl pdb_codes_L2.out ../../canonical_L2 ../../../NEW_DATASET/NUMBERED_FILES/ out L2_SDR.fasta
echo "--------"
echo "Loop: L3"
perl get_SDRs_FASTA_format.pl pdb_codes_L3.out ../../canonical_L3 ../../../NEW_DATASET/NUMBERED_FILES/ out L3_SDR.fasta
echo "--------"
echo "Loop: H1"
perl get_SDRs_FASTA_format.pl pdb_codes_H1.out ../../canonical_H1 ../../../NEW_DATASET/NUMBERED_FILES/ out H1_SDR.fasta
echo "--------"
echo "Loop: H2"
perl get_SDRs_FASTA_format.pl pdb_codes_H2.out ../../canonical_H2 ../../../NEW_DATASET/NUMBERED_FILES/ out H2_SDR.fasta
