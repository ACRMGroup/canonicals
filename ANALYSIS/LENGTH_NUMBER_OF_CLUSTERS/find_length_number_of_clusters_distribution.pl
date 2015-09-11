#! /acrm/usr/local/bin/perl


if($#ARGV < 1)
{
   print STDERR "\nUsage: $0 <CLAN file> <Output file name>\n\n";
   exit(0);
}

$clanFilename = $ARGV[0];
$outputFilename = $ARGV[1];

if(! -r $clanFilename)
{
   print STDERR "\nUnable to open file \"$clanFilename\" in read mode.\n\n";
   exit(0);
}

# Open the CLAN file in read mode.

open(CLAN, $clanFilename);

# Read the contents of the CLAN file.

while($line = <CLAN>)
{
   chomp($line);

   # Set a flag when the BEGIN_LABELS line is encountered.

   if($line =~ /BEGIN_LABELS/)
   {
      $flag = 1;
   }

   # If flag is 1 and the line begins with a digit, parse the
   # line into cluster number and canonical class label.

   if( ($flag == 1) && ($line =~ /^[0-9]/) )
   {
      # Line is of the form:
      # 
      # 24      16B

      ($clusterNumber, $canonicalClassLabel) = split(/\t/, $line);

      # Get the loop length and increment the counter for number of classes
      # corresponding to the loop length.

      $canonicalClassLength = $canonicalClassLabel;
      $canonicalClassLength =~s/[A-Z]//;

      $numberOfClasses{$canonicalClassLength} += 1;
   }
   else
   {
      next;
   }

} # End of while loop.

# Close the CLAN file handle.

close(CLAN);

# Open the output file in write mode.

open(OUT, ">$outputFilename");

# Write the header line.

print OUT "LOOPLEN\tNO_CLASSES\n";

# Write the data.

foreach $loopLen (keys %numberOfClasses)
{
   print OUT $loopLen, "\t", $numberOfClasses{$loopLen}, "\n";
}

# Close the file handle.

close(OUT);

# End of program.
