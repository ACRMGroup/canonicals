#! /bin/sh

# Choose all lines in the RMS files with RMS > 1.5A

egrep '2.[0-9][0-9][0-9]' [LH][1-3]_rms.txt | awk -F':' '{print $2}' | sed 's/\t\t/,/g' > high_ca_rms.txt
egrep '1.[5-9][0-9][0-9]' [LH][1-3]_rms.txt | awk -F':' '{print $2}' | sed 's/\t\t/,/g' >> high_ca_rms.txt
