#! /usr/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $loop = "";
my $inputFilename = "";
my $outputFilename = "";
my $canonicalClassesString = "";
my %canonicalClassesHash = ();
my @sameCriticalPositions = ();
my %criticalResiduesHash = ();
my $canonicalClass1 = "";
my $canonicalClass2 = "";
my $line = "";
my $canonicalClass = "";
my $criticalPositions = "";
my %criticalPositionsHash = ();

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# Main code of the program starts here.

if($#ARGV < 2)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. Loop";
   print STDERR "\n2. File with critical positions in FASTA format";
   print STDERR "\n3. Output filename";
   print STDERR "\n\n";
   exit(0);
}

$loop = $ARGV[0];
$inputFilename = $ARGV[1];
$outputFilename = $ARGV[2];

# Open the input file.

open(HD, $inputFilename) || die "\nUnable to open file \"$inputFilename\".\n\n";

# Parse the contents of the input file.

while($line = <HD>)
{
   # Remove newlines.

   chomp($line);

   # If the line starts with >, get the set of critical positions.

   if($line =~ /^>/)
   {
      ($canonicalClass, $criticalPositions) = split(/::::/, $line);
      $canonicalClass =~s/^>//;

      # Record the correspondence between canonical class and critical positions.

      $criticalPositionsHash{$canonicalClass} = $criticalPositions;

      # Check if there is already another canonical class with the same set
      # of critical positions.

      if($canonicalClassesHash{$criticalPositions} ne "")
      {
         # If there are other canonical class with the same set of critical positions,
         # record this.

         $canonicalClassesString = $canonicalClassesHash{$criticalPositions}.":".$canonicalClass;

         push(@sameCriticalPositions, $canonicalClassesString);

         print "\nLoop: ", $loop;
         print "\nCanonical class 1: ", $criticalPositionsHash{$criticalPositions};
         print "\nCanonical class 2: ", $canonicalClass;
         print "\nCritical positions: ", $criticalPositions;
         print "\n-----------------------\n";
      }
      else
      {
         $canonicalClassesHash{$criticalPositions} = $canonicalClass;
      }
   }
   else
   {
      # Line contains a list of residues at the critical positions.
      #
      # [PWS][FYG][WV][DSG][FY][YF][IV][RSY][YW][GSN][GD][GSA][TK][YR]YI[RK]

      $criticalResiduesHash{$canonicalClass} = $line;
   }

} # End of while loop.

# Close the input file handle.

close(HD);

# Open the output file in write mode.

open(WHD, ">$outputFilename");

# For every pair of canonical classes that have the same set of critical positions,
# write the canonical class and corresponding critical residues to a file.

foreach $canonicalClassesString (@sameCriticalPositions)
{
   ($canonicalClass1, $canonicalClass2) = split(/:/, $canonicalClassesString);

   # Write the canonical classes, their corresponding critical positions and residues.

   print WHD ">", $canonicalClass1, "::::", $criticalPositionsHash{$canonicalClass1}, "\n";
   print WHD $criticalResiduesHash{$canonicalClass1}, "\n";

   print WHD ">", $canonicalClass2, "::::", $criticalPositionsHash{$canonicalClass2}, "\n";
   print WHD $criticalResiduesHash{$canonicalClass2}, "\n";

} # End of foreach loop.

# Close the output file handle.

close(WHD);

# End of program.
