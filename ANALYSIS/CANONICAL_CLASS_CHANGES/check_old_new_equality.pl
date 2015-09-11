#! /usr/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $inputFilename = "";
my $line = "";
my $pdbCode = "";
my $loop = "";
my $oldCan = "";
my $newCan = "";
my $type = "";

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# --------------- SUB - ROUTINES SECTION ---------------


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 0)
{
   print STDERR "\nUsage: $0 <File with comparison (CSV format)>\n\n";
   exit(0);
}

$inputFilename = $ARGV[0];

# Open the input file in read mode.

open(HD, $inputFilename) || die "\nUnable to open file \"$inputFilename\" in read mode.\n\n";

# Parse through the contents of the file.

while($line = <HD>)
{
   # Remove newline characters.

   chomp($line);

   # Split the line into constituent parts.
   # Line is of the form:
   #
   # 1gig,L1,14B,14B,FAB
   # 1a7n,L1,,11A,FV

   ($pdbCode, $loop, $oldCan, $newCan, $type) = split(/,/, $line);

   # If the old canonical class is empty, go to the next line.

   if($oldCan eq "")
   {
      next;
   }

   # Check if the old and new canonical class are the same.
   # If they are, then go to the next line.
   # Else report the case.

   if($oldCan eq $newCan)
   {
      next;
   }
   else
   {
      print $pdbCode, ",",
            $loop, ",",
            $oldCan, ",",
            $newCan, ",",
            $type, "\n";
   }

} # End of while loop.

# Close the input file handle.

close(HD);

# End of program.
