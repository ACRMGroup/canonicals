#! /usr/bin/perl

use strict 'vars';
use Env;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

# Set the control sequence for CTRL-C keystrokes.

$SIG{INT} = \&ctrlC;

my $HOME = $ENV{"HOME"};

my $pdbCode = "";
my $FvPDBFilename = "";
my $fullPDBFilename = "";
my $loop = "";
my $loopDef = "";

my $line = "";
my @parts = ();
my @bfactors = ();
my $totalBFactor = 0;
my $mean = 0;
my $sd = 0;

my $loopStart = "";
my $loopEnd = "";
my $BF_upper_threshold = 0;
my $sd_limit = 3;

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# --------------- SUB - ROUTINES SECTION ---------------

sub ctrlC
{
   # Exit from the program.

   exit(0);

} # End of sub-routine "ctrlC".


sub get_mean_and_sd
{
   # ($mean, $sd) = &get_mean_and_sd($totalBFactor, \@bfactors);

   my ($totalBFactors, $bfactors) = @_;

   my $mean = 0;
   my $sd = 0;
   my $i = 0;
   my $totalSquare = 0;

   # Calculate the mean.

   $mean = $totalBFactors/($#$bfactors + 1);

   # Calculate the SD.

   for($i = 0 ; $i <= $#$bfactors ; $i++)
   {
      $totalSquare += ( ($mean - $$bfactors[$i]) * ($mean - $$bfactors[$i]) );
   }

   $sd = sqrt($totalSquare/($#$bfactors + 1));

   # Return the mean and the standard deviation.

   return ($mean, $sd);

} # End of sub-routine "get_mean_and_sd".


sub check_for_threshold
{
   # if( &check_for_threshold($FvPDBFilename, $loopStart, $loopEnd, $BF_upper_threshold) )

   my ($FvPDBFilename, $loopStart, $loopEnd, $BF_upper_threshold) = @_;

   my @loopBFactors = ();
   my $BF = 0;

   # Get the B-factors in the loop.

   @loopBFactors = `getpdb $loopStart $loopEnd $FvPDBFilename | cut -c 61-66 | sed 's/ //g'`;

   # Check if any of the loop B-factors are greater than the threshold.
   #
   # If yes, then return 1 to the calling function.

   foreach $BF (@loopBFactors)
   {
      # Remove newlines.

      chomp($BF);

      # Check if the B-factor is empty.

      if($BF eq "")
      {
         next;
      }

      # Return 1 if the B-factor is <= 0.

      if($BF == 0)
      {
         return 1;
      }

      # Return 1 if the B-factor is greater than the threshold.

      if( ($BF > $BF_upper_threshold) && ($BF > 45) )
      {
         return 1;
      }
   }

   # Return 0 to the calling function.

   return 0;

} # End of sub-routine "check_for_threshold".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 2)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. PDB Code";
   print STDERR "\n2. Full path of Fv region PDB file";
   print STDERR "\n3. Full path of original PDB file";
   print STDERR "\n3. Loop";
   print STDERR "\n4. Loop definition (e.g. L24-L34)";
   print STDERR "\n\n";

   exit(0);
}

$pdbCode = $ARGV[0];
$FvPDBFilename = $ARGV[1];
$fullPDBFilename = $ARGV[2];
$loop = $ARGV[3];
$loopDef = $ARGV[4];

# Open the full PDB file.

open(HD, $fullPDBFilename) || die "\nUnable to open file \"$fullPDBFilename\".\n\n";

# Sift through the file's contents.

while($line = <HD>)
{
   # Remove newlines.

   chomp($line);

   # If line does not start with ATOM, skip to the next one.

   if($line !~ /^ATOM/)
   {
      next;
   }

   # Extract the B-factor from the line.

   $line =~s/ +/ /g; # Substitute multiple occurrences of space with a single one.

   # Clear @parts.

   @parts = ();

   # Get the B-factor and add it to the sum.

   @parts = split(/ /, $line);
   push(@bfactors, $parts[10]);
   $totalBFactor += $parts[10];

} # End of while loop.

# Close the file handle.

close(HD);

# Get the mean and SD.

($mean, $sd) = &get_mean_and_sd($totalBFactor, \@bfactors);

# Check the loop definition string.

($loopStart, $loopEnd) = split(/\-/, $loopDef);

if( ($loopStart !~ /^[LH][1-9]/) ||
    ($loopEnd !~ /^[LH][1-9]/) )
{
   print STDERR "\nUnable to parse loop definition string \"$loopDef\".\n\n";
   exit(0);
}

# Set the threshold for B-factors.

$BF_upper_threshold = $mean + ($sd_limit * $sd);

# For every PDB, see if the loop region should be flagged for high B-factors.

$FvPDBFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/$pdbCode.pdb";

if( &check_for_threshold($FvPDBFilename, $loopStart, $loopEnd, $BF_upper_threshold) )
{
   print "$pdbCode,$loop,$loopDef\n";
}

# End of program.
