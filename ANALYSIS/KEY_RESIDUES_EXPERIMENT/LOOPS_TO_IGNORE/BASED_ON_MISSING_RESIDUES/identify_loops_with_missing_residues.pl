#! /usr/bin/perl

use strict 'vars';
use Env;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $HOME = $ENV{"HOME"};

my $pdbListFilename = "";
my $loopDefinition = "";
my $loopStart = "";
my $loopEnd = "";
my $requiredChain = "";
my $pdbCode = "";
my $numberingFilename = "";

# Set the control sequence for CTRL-C keystrokes.

$SIG{INT} = \&ctrlC;

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# --------------- SUB - ROUTINES SECTION ---------------


###########################################################
# sub ctrlC: Sub-routine that exits from the program when a
# CTRL-C keystroke is encountered.
###########################################################

sub ctrlC
{
   # Exit from the program.

   exit(0);

} # End of sub-routine "ctrlC".


sub check_for_missing_residues
{
   # if( &check_for_missing_residues($numberingFilename,
   #                                 $loopStart, $loopEnd,
   #                                 $requiredChain) )

   my ($numberingFilename,
       $loopStart, $loopEnd,
       $requiredChain) = @_;

   my $line = "";
   my $position = "";
   my $residue = "";
   my $positionNumber = "";

   my $loopStartNumber = $loopStart;
   my $loopEndNumber = $loopEnd;

   # Remove the alphabets from the start and end numbers.

   $loopStartNumber =~s/[A-Z]//g;
   $loopEndNumber =~s/[A-Z]//g;

   # Open the numbering file.

   open(NUM, $numberingFilename);

   # Sift through the contents.

   while($line = <NUM>)
   {
      # Remove newlines.

      chomp($line);

      # See if the line contains a position.

      if($line !~ /[LH][1-9]/)
      {
         # Skip to the next line.

         next;
      }

      # See if the chain is the right type. If not, skip the line.

      if(! ($line =~ /^$requiredChain/) )
      {
         # Skip to the next line.

         next;
      }

      # Get the number of the line.

      ($position, $residue) = split(/ /, $line);

      $positionNumber = $position;
      $positionNumber =~s/[A-Z]//g;

      # If the position number is outside the bounds of the loop,
      # skip to the next line.

      if($positionNumber < $loopStartNumber)
      {
         next;
      }

      if($positionNumber > $loopEndNumber)
      {
         return 0;
      }

      # If the residue is in lower case (i.e. a missing residue),
      # return 1 to the calling function.

      if($residue =~ /[a-z]/)
      {
         return 1;
      }

   } # End of while loop.

   # Close the numbering file handle.

   close(NUM);

   # Return a value of zero to the calling routine.

   return 0;

} # End of sub-routine "check_for_missing_residues".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

# Check for command line parameters.

if($#ARGV < 1)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. File with list of PDBs that are unique in sequence";
   print STDERR "\n2. Loop definition (e.g. L24-L34)";
   print STDERR "\n\n";

   exit(0);
}

$pdbListFilename = $ARGV[0];
$loopDefinition = $ARGV[1];

# Open the PDB list file.

open(PDB, $pdbListFilename) || die "\nUnable to open file \"$pdbListFilename\".\n\n";

# Parse the loop definition for loop start and end.

($loopStart, $loopEnd) = split(/\-/, $loopDefinition);

if( ($loopStart !~ /^[LH][1-9]/) ||
    ($loopEnd !~ /^[LH][1-9]/) )
{
   print STDERR "\nUnable to parse loop definition string \"$loopDefinition\".\n\n";
   exit(0);
}
else
{
   # Set the chain type.

   if($loopStart =~ /^L/)
   {
      $requiredChain = "L";
   }
   else
   {
      $requiredChain = "H";
   }
}

# For each PDB, check if there are missing residues.

while($pdbCode = <PDB>)
{
   # Remove newlines.

   chomp($pdbCode);

   # Set the numbering file.

   $numberingFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_FILES/".$pdbCode.".out";

   if(! -r $numberingFilename)
   {
      # Print error.

      print STDERR "\nUnable to read file \"$numberingFilename\".\n\n";
   }

   # Check for missing residues in the loop.

   if( &check_for_missing_residues($numberingFilename,
                                   $loopStart, $loopEnd,
                                   $requiredChain) )
   {
      print $pdbCode, "\n";
   }

} # End of while loop.


# Close the file handle.

close(PDB);

# End of program.
