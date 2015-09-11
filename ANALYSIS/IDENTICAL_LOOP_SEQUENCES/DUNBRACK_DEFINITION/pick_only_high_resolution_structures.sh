#! /bin/sh

if [ $# -lt 1 ]
then
   echo
   echo "Usage: $0 <Input CSV file (e.g. high_ca_rms_resolutions_B-factor_data.csv)"
   echo
   exit 0
fi

inputFilename=$1

# Check if the input file is present.

if [ ! -r $inputFilename ]
then
   echo
   echo "Unable to read $inputFilename"
   echo
   exit 0
fi

# Write the header line.

echo "LOOP,LOOPDEF,"\
     "PDB1,CLASS1,METHOD1,RESOL1,RFAC1,LOWBF1,HIGHBF1,"\
     "PDB2,CLASS2,METHOD2,RESOL2,RFAC2,LOWBF2,HIGHBF2,"\
     "CA-RMS"
     
# Parse the file.

for line in `cat $inputFilename`
do
   if [ ! `echo $line | grep "^[LH][1-3]"` ]
   then
      continue
   fi

   # Line is of the form:
   #
   # H1,H23-H35,1nca,10A,crystal,2.50A,19.10%,10.41,31.55,1a4j,10L,crystal,2.10A,22.90%,21.81,71.93,2.031

   res1=`echo $line | awk -F',' '{print $6}' | sed 's/[A-Z]//g'`
   res2=`echo $line | awk -F',' '{print $13}' | sed 's/[A-Z]//g'`

   # Check resolution 1.

   c=`echo "$res1 > 2.6" | bc`

   if [ $c -eq 1 ]
   then
      continue
   fi

   # Check resolution 2.

   c=`echo "$res2 >= 2.6" | bc`

   if [ $c -eq 1 ]
   then
      continue
   fi

   # Print the line.

   echo "$line"
done
