#! /usr/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $canonicalsFilename = "";
my $outputFilename = "";
my $ignore = "";
my $loop = "";
my $canonicalClass = "";
my $chothiaClass = "";
my $acrmClass = "";
my $flag = 0;
my $criticalPosition = "";
my $criticalPositionsString = "";
my $residues = "";
my $sequenceString = "";

my $line = "";
my $criticalPositionsString = "";
my $sequenceString = "";
my $length = "";

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

if($#ARGV < 1)
{
   print STDERR "\nUsage: $0 <Canonical definitions file> <Output file>\n\n";
   exit(0);
}

$canonicalsFilename = $ARGV[0];
$outputFilename = $ARGV[1];

# Open the canonicals file in read mode.

open(HD, $canonicalsFilename) || die "\nUnable to open file \"$canonicalsFilename\" in read mode.\n\n";
open(WHD, ">$outputFilename") || die "\nUnable to open file \"$outputFilename\" in write mode.\n\n";

# Parse through the contents of the file.

while($line = <HD>)
{
   # Remove newlines.

   chomp($line);

   # Parse the contents.

   if($line =~ /LOOP/)
   {
      # If a flag definition has already been encountered, write it to the
      # output file.

      if($flag == 1)
      {
         print WHD ">$chothiaClass/$acrmClass", "::::", $criticalPositionsString, "\n";
         print WHD $sequenceString, "\n";
      }

      # If the line contains the name of a loop and canonical class, store them.
      #
      # LOOP H1 ?/10E 10

      ($ignore, $loop, $canonicalClass, $length) = split(/ /, $line);
      ($chothiaClass, $acrmClass) = split(/\//, $canonicalClass);

      # Set the flag to indicate that at least one loop definition
      # has been encountered so far.

      $criticalPositionsString = "";
      $sequenceString = "";
      $flag = 1;
   }
   elsif($line =~ /^[LH][0-9]/)
   {
      # Line contains a critical residue. Line is of the form:
      #
      # H24     A
      # H50     NGR

      $line =~s/\s+/ /g;
      ($criticalPosition, $residues) = split(/ /, $line);

      # Store the critical position.

      $criticalPositionsString .= "$criticalPosition:";

      # Store the residue(s).

      if(length($residues) > 1)
      {
         $sequenceString .= "[$residues]";
      }
      else
      {
         $sequenceString .= $residues;
      }
   }

} # End of "while($line = <HD>)".


# Close the input and output file handles.

close(HD);
close(WHD);

# End of program.
