#! /usr/bin/perl

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

# Set the control sequence for CTRL-C keystrokes.

$SIG{INT} = \&ctrlC;

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# --------------- SUB - ROUTINES SECTION ---------------

sub ctrlC
{
   # Exit from the program.

   exit(0);

} # End of sub-routine "ctrlC".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 2)
{
   print STDERR "\nUsage: $0 <Loop> <Canonical definitions file> <Output file (FASTA format)>";
   print STDERR "\n\n";
   exit(0);
}

$loop = $ARGV[0];
$inputFilename = $ARGV[1];
$outputFilename = $ARGV[2];

# Open the files.

open(HD, $inputFilename) || die "\nUnable to open file \"$inputFilename\" in read mode.\n\n";
open(WHD, ">$outputFilename") || die "\nUnable to open file \"$outputFilename\" in write mode.\n\n";

# Go through the file.

$positions = "";

while($line = <HD>)
{
   chomp($line);

   # If line contains a class name.

   if($line =~ /LOOP/)
   {
      # Write the previous canonical class.

      if($positions ne "")
      {
         print WHD ">$loop:$acrmClass\n";
         print WHD $positions, "\n";
      }

      $positions = "";

      # LOOP L1 ?/16B 16

      ($ignore, $ignore, $canonicalClass, $ignore) = split(/ /, $line);

      # Split the canonical class into chothia and acrm components.

      ($ignore, $acrmClass) = split(/\//, $canonicalClass);

   }
   elsif($line =~ /^[LH][1-9]/)
   {
      ($position, $ignore) = split(/ /, $line);

      $positions .= "$position:";
   }
}

# Write the last position.

print WHD ">$loop:$acrmClass\n";
print WHD $positions, "\n";

# Close the file handles.

close(HD);
close(WHD);

# End of program.
