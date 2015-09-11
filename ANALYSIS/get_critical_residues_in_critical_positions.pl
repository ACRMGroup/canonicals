#! /usr/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $criticalPositionsFilename = "";
my $pdbCodesFilename = "";
my $numberingDirectory = "";
my $numberingFileExtension = "";
my $outputFilename = "";

my @criticalPositions = ();
my @pdbCodes = ();
my $pdbCode = "";
my $numberingFilename = "";
my %numbering = ();
my $criticalPosition = "";
my $criticalResidues = "";

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# --------------- SUB - ROUTINES SECTION ---------------


sub get_numbering
{
   my ($numberingFilename, $numbering) = @_;
   my @numberingCon = ();
   my $line = "";
   my $label = "";
   my $residue = "";

   # Open the numbering file.

   open(NUM, $numberingFilename);
   @numberingCon = <NUM>;
   close(NUM);

   # Return 0 if file is empty.

   if($#numberingCon == -1)
   {
      return 0;
   }

   # Gather the numbering.

   foreach $line (@numberingCon)
   {
      if($line =~ /^[LH][0-9]/)
      {
         chomp($line);

         ($label, $residue) = split(/ /, $line);

         $$numbering{$label} = $residue;
      }
   }

   # Return 1 to the calling function.

   return 1;

} # End of sub-routine "get_numbering".

# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.


# Connect to the database and report error attempt to connect fails.

if($#ARGV < 2)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. File with list critical positions";
   print STDERR "\n2. File with list of PDB Codes";
   print STDERR "\n3. Directory with list of numbered files (for PDBs)";
   print STDERR "\n4. Numbering files extension";
   print STDERR "\n5. Output file (FASTA format)";
   print STDERR "\n\n";

   exit(0);
}

$criticalPositionsFilename = $ARGV[0];
$pdbCodesFilename = $ARGV[1];
$numberingDirectory = $ARGV[2];
$numberingFileExtension = $ARGV[3];
$outputFilename = $ARGV[4];

# Get the list of critical positions.

open(HD, $criticalPositionsFilename) || die "\nUnable to open file \"$criticalPositionsFilename\".\n\n";
@criticalPositions = <HD>;
close(HD);

chomp(@criticalPositions);

# Get the PDB codes.

open(HD, $pdbCodesFilename) || die "\nUnable to open file \"$pdbCodesFilename\".\n\n";
@pdbCodes = <HD>;
close(HD);

chomp(@pdbCodes);

# Open the output file in write mode.

open(WHD, ">$outputFilename");

# Gather the numbering data.

foreach $pdbCode (@pdbCodes)
{
   $numberingFilename = $numberingDirectory."/".$pdbCode.$numberingFileExtension;

   if(! &get_numbering($numberingFilename,
                       \%numbering) )
   {
      print STDERR "\nUnable to open file \"$numberingFilename\".\n";
   }

   # Write the critical residues in FASTA format.

   print WHD ">", $pdbCode, ":::";

   foreach $criticalPosition (@criticalPositions)
   {
      print WHD "$criticalPosition:";

      $criticalResidues .= $numbering{$criticalPosition};
   }

   chomp($criticalResidues);

   print WHD "\n";
   print WHD $criticalResidues, "\n";

   # Reset the critical residues string and the numbering hash.

   $criticalResidues = "";
   %numbering = ();

} # End of "foreach $pdbCode (@pdbCodes)".


# Close the output file handle.

close(WHD);

# End of program.
