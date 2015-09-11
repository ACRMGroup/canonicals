#! /usr/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $pdbCodesListFilename = "";
my $loopNumberingString = "";
my $numberingDirectory = "";
my $numberingExtension = "";
my $outputFilename = "";

my $loopStart = "";
my $loopEnd = "";

my $pdbCode = "";
my %loopResiduesHash = ();
my $position = "";

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


######################################################################################
# sub parse_numbering_string: Sub-routine that parses the numbering string for a loop.
######################################################################################

sub parse_numbering_string
{
   # if(! ($loopStart, $loopEnd) = &parse_numbering_string($loopNumberingString) )

   my $loopNumberingString = $_[0];

   my $loopStart = "";
   my $loopEnd = "";

   # The string looks like "L50-L56". This should be split into L50 and L56.

   ($loopStart, $loopEnd) = split(/\-/, $loopNumberingString);

   # Check if the loop start and loop end string are in the correct format.

   if( ($loopStart !~ /^[LH][0-9]/) || ($loopEnd !~ /^[LH][0-9]/) )
   {
      $loopStart = -1;
      $loopEnd = -1;
   }

   # Return the loop start and ending strings.

   return ($loopStart, $loopEnd);

} # End of sub-routine "parse_numbering_string".


sub get_residues_in_loop
{
   # &get_residues_in_loop($pdbCode,
   #                       $numberingDirectory,
   #                       $numberingExtension,
   #                       $loopStart,
   #                       $loopEnd,
   #                       \%loopResiduesHash);

   my ($pdbCode,
       $numberingDirectory,
       $numberingExtension,
       $loopStart,
       $loopEnd,
       $loopResiduesHash) = @_;

   my $numberingFilename = "";

   my $loopStartNumber = $loopStart;
   my $loopEndNumber = $loopEnd;

   my $chainPrefix = $&;

   my $line = "";

   my $currentPosition = "";
   my $currentResidue = "";
   my $currentChainPrefix = "";
   my $currentPositionNumber = -1;

   # Establish the start and end numbers of the loop and the chain prefix.

   $chainPrefix = $loopStart;
   $chainPrefix =~s/[0-9]//g;

   $loopStartNumber = $loopStart;
   $loopStartNumber =~s/[A-Z]//g;

   $loopEndNumber = $loopEnd;
   $loopEndNumber =~s/[A-Z]//g;

   # Assign the numbering file name.

   $numberingFilename = $numberingDirectory."/".$pdbCode.".".$numberingExtension;

   # Read the numbering file.

   if(! -r $numberingFilename)
   {
      print STDERR "\nUnable to open file \"$numberingFilename\".\n\n";
      return 0;
   }

   # Open the numbering file.

   open(HD, $numberingFilename);

   # Read the contents and pick the required sections.

   while($line = <HD>)
   {
      # Remove the newline.

      chomp($line);

      # Move to the next line if the line does not contain a numbering record
      # of the form:
      #
      # L38 Q

      if($line !~ /^[LH][0-9]+ [A-Z]/)
      {
         next;
      }

      # Parse the line for the position and the residue.

      ($currentPosition, $currentResidue) = split(/ /, $line);

      # Split the position into chain prefix and number.

      $currentChainPrefix = $currentPosition;
      $currentPositionNumber = $currentPosition;

      $currentChainPrefix =~s/[0-9]//g;
      $currentPositionNumber =~s/[A-Z]//g;

      # Move to the next line if the current chain prefix does not match
      # the loop.

      if($currentChainPrefix ne $chainPrefix)
      {
         next;
      }

      # Check if the current position number is within the loop.

      if( ($currentPositionNumber >= $loopStartNumber) &&
          ($currentPositionNumber <= $loopEndNumber) )
      {
         # If the residue at the current position is already in the hash,
         # then move to the next line.

         if($$loopResiduesHash{$currentPosition} =~ /$currentResidue/)
         {
            next;
         }

         # Add the residue to the hash.

         print "\nFound residue $currentResidue in $pdbCode for position $currentPosition";

         $$loopResiduesHash{$currentPosition} .= $currentResidue;
      }

   } # End of "while($line = <HD>)".


   # Close the numbering file handle.

   close(HD);

} # End of sub-routine "get_residues_in_loop".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 4)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. File with list of PDB codes for the specific class without SDRs";
   print STDERR "\n2. String representing the numbering zones for the loop (E.g. L50-L56 for CDR-L2)";
   print STDERR "\n3. Directory with numbered files for the PDBs";
   print STDERR "\n4. Extension for the numbered files";
   print STDERR "\n5. Output file with listing of residues for every position in the CDR";
   print STDERR "\n\n";
   exit(0);
}

$pdbCodesListFilename = $ARGV[0];
$loopNumberingString = $ARGV[1];
$numberingDirectory = $ARGV[2];
$numberingExtension = $ARGV[3];
$outputFilename = $ARGV[4];

# Check if the pdb codes list file is present.

if(! -r $pdbCodesListFilename)
{
   print STDERR "\nFile \"$pdbCodesListFilename\" cannot be read.\nAborting program.\n\n";
   exit(0);
}

# Parse the numbering string for the loop.

($loopStart, $loopEnd) = &parse_numbering_string($loopNumberingString);

if( ($loopStart == -1) || ($loopEnd == -1) )
{
   print STDERR "\nUnable to parse numbering string \"$loopNumberingString\" for the loop.";
   print STDERR "\nAborting program.\n\n";
   exit(0);
}

# Open the file with PDB codes.

open(PDB, $pdbCodesListFilename) || die "\nUnable to open file \"$pdbCodesListFilename\".\n\n";

# For every PDB code, extract the residues in the loop and store them in a hash.

while($pdbCode = <PDB>)
{
   # Remove newline.

   chomp($pdbCode);

   # Get the residues in the loop.

   if(! &get_residues_in_loop($pdbCode,
                              $numberingDirectory,
                              $numberingExtension,
                              $loopStart,
                              $loopEnd,
                              \%loopResiduesHash) )
   {
      print STDERR "\nUnable to read numbering for PDB code: $pdbCode";
      next;
   }

} # End of while loop.

# Close the PDB codes list file handle.

close(PDB);

# Open the output file in write mode.

open(WHD, ">$outputFilename");

# Print the residue usage in every position in the loop.

foreach $position (keys %loopResiduesHash)
{
   print WHD "Position: $position, Residues: ", $loopResiduesHash{$position}, "\n";
}

# Close the output file handle.

close(WHD);

# End of program.
