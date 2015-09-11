#! /acrm/usr/local/bin/perl

use strict 'vars';

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $numberingDirectory = "";
my $pdbCodesFilename = "";
my $outputFilename = "";
my $numberingExtension = "";

my %canonicalClassHash = ();
my $loopSequence = "";
my $identicalLoopPDBCode = "";
my $line = "";
my $pdbCode = "";
my %loopSequenceHash = ();
my $loopStart = "";
my $loopEnd = "";
my $chainPrefix = "";
my $loopBoundaryString = "";
my $loop = "";
my $canonicalClass = "";



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



sub get_loop_info
{
   # ($loopStart, $loopEnd, $chainPrefix) = &get_loop_info($loopBoundaryString);

   my $loopBoundaryString = $_[0];

   # The loop boundary string is of the form:
   #
   # L24-L34

   if($loopBoundaryString !~ /^[LH][0-9]+\-[LH][0-9]+/)
   {
      return (-1, -1, -1);
   }

   # Parse the loop boundary string.

   ($loopStart, $loopEnd) = split(/\-/, $loopBoundaryString);

   # Get the chain prefix.

   $loopStart =~s/[LH]//g;
   $loopEnd =~s/[LH]//g;

   $chainPrefix = $&;

   # Return the loop start, loop end and the chain prefix to the calling function.

   return ($loopStart, $loopEnd, $chainPrefix);

} # End of sub-routine "get_loop_info".


sub get_loop_sequence
{
   # $loopSequence = &get_loop_sequence($pdbCode,
   #                                    $loopStart, $loopEnd, $chainPrefix,
   #                                    $numberingDirectory,
   #                                    $numberingExtension);

   my ($pdbCode,
      $loopStart, $loopEnd, $chainPrefix,
      $numberingDirectory,
      $numberingExtension) = @_;

   my $numberingFilename = "";
   my $line = "";
   my $position = "";
   my $residue = "";
   my $positionNumber = -1;
   my $loopSequence = "";

   # Set the numbering file.

   $numberingFilename = $numberingDirectory."/".$pdbCode.".".$numberingExtension;

   # Read the numbering file.

   open(NUM, $numberingFilename) || die "\nUnable to open numbering file \"$numberingFilename\".\n\n";

   # Read through the file.

   while($line = <NUM>)
   {
      # Remove newline.

      chomp($line);

      # Check for the chain prefix.

      if($line !~ /^$chainPrefix/)
      {
         next;
      }

      # Parse the line into the position and residue.

      ($position, $residue) = split(/ /, $line);

      # Check if the number in the position (e.g. 52 in L52 or 63 in H63) 
      # falls in the loop region.

      $positionNumber = $position;
      $positionNumber =~s/^[LH]//;

      if( ($positionNumber >= $loopStart) &&
          ($positionNumber <= $loopEnd) )
      {
         if($residue ne "-")
         {
            $loopSequence .= $residue;
         }
      }
      elsif($positionNumber > $loopEnd)
      {
         last;
      }

   } # End of while loop.

   # Close the numbering file handle.

   close(NUM);

   # Return the loop sequence.

   return $loopSequence;

} # End of sub-routine "get_loop_sequence".



# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 3)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. File with list of PDB codes and canonical classes";
   print STDERR "\n2. String representing the loop boundaries (E.g. L24-L34 for CDR-L1)";
   print STDERR "\n3. Directory with list of numbered files for the PDBs";
   print STDERR "\n4. Extension for numbering files (e.g. out)";
   print STDERR "\n5. Output file for results of the comparison";
   print STDERR "\n\n";
   exit(0);
}

$pdbCodesFilename = $ARGV[0];
$loopBoundaryString = $ARGV[1];
$numberingDirectory = $ARGV[2];
$numberingExtension = $ARGV[3];
$outputFilename = $ARGV[4];

# Get the start, end of the loop and the chain prefix.

($loopStart, $loopEnd, $chainPrefix) = &get_loop_info($loopBoundaryString);

if($loopStart == -1)
{
   print STDERR "\nUnable to parse loop boundary string \"$loopBoundaryString\".\n\n";
   exit(0);
}

# Open the PDB codes list file.

open(HD, $pdbCodesFilename) || die "\nUnable to open file \"$pdbCodesFilename\" in read mode.\n\n";

# Open the output file in write mode.

open(WHD, ">$outputFilename");

# For every PDB file, extract the loop sequence.

while($line = <HD>)
{
   # Remove the newline character.

   chomp($line);

   # If line does not start with a digit, then skip to the next line.

   if($line !~ /^[0-9]/)
   {
      next;
   }

   # Line is of the form:
   #
   # 1bm3,L1,11A

   ($pdbCode, $loop, $canonicalClass) = split(/,/, $line);

   # Store the canonical class info in a hash.

   $canonicalClassHash{$pdbCode} = $canonicalClass;

   # Get the loop sequence.

   $loopSequence = "";
   $loopSequence = &get_loop_sequence($pdbCode,
                                      $loopStart, $loopEnd, $chainPrefix,
                                      $numberingDirectory,
                                      $numberingExtension);

   # Report an identical loop sequence if required.

   if($loopSequenceHash{$loopSequence} eq "")
   {
      $loopSequenceHash{$loopSequence} = $pdbCode;
   }
   else
   {
      $identicalLoopPDBCode = $loopSequenceHash{$loopSequence};

      print WHD "PDB Codes: $pdbCode, $identicalLoopPDBCode\n";
      print WHD "\nCanonical classes: ", $canonicalClassHash{$pdbCode}, ", ", $canonicalClassHash{$identicalLoopPDBCode}, "\n";
      print WHD "\nLoop sequence: $loopSequence\n";

      if($canonicalClassHash{$pdbCode} ne $canonicalClassHash{$identicalLoopPDBCode})
      {
         print WHD "\nOf interest.....\n";
      }

      print WHD "---------\n";

      # Concatenate the identical loop PDB code to the loop sequence hash.

      # $loopSequenceHash{$loopSequence} .= ":".$pdbCode;
   }

} # End of while loop.

# Close the file handles.

close(HD);
close(WHD);

# End of program.
