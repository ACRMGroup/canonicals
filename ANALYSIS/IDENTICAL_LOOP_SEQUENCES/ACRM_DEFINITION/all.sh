#! /bin/sh

# Run the scripts in order.

# Step 1: Compare the loop sequences.

sh compare_loop_sequences.sh

# Step 2: Get the RMSD over CA atoms in the loop.

sh get_rmsd_over_loops.sh

# Step 3: Compile a list of high RMS deviations.

sh get_high_ca_rms.sh

# Step 4: Get details of resolution and B-factors in the loop.

sh process_high_ca_rms.sh > high_ca_rms_resolutions_B-factor_data.txt
