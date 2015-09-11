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
my $sd_limit = 2;

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# --------------- SUB - ROUTINES SECTION ---------------

sub ctrlC
{
   # Exit from the program.

   exit(0);

} # End of sub-routine "ctrlC".


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

      # Check if the B-factor is empty. If yes, skip to the next value.

      if($BF eq "")
      {
         next;
      }

      # Return 1 if the B-factor is 0.

      if($BF == 0)
      {
         return 1;
      }

      # Return 1 if the B-factor is greater than the threshold.

      if($BF > $BF_upper_threshold)
      {
         return 1;
      }
   }

   # Return 0 to the calling function.

   return 0;

} # End of sub-routine "check_for_threshold".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 5)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. PDB Code";
   print STDERR "\n2. Full path of Fv region PDB file";
   print STDERR "\n3. Loop";
   print STDERR "\n4. Loop definition (e.g. L24-L34)";
   print STDERR "\n5. Mean of the distribution";
   print STDERR "\n6. SD of the distribution";
   print STDERR "\n\n";

   exit(0);
}

$pdbCode = $ARGV[0];
$FvPDBFilename = $ARGV[1];
$loop = $ARGV[2];
$loopDef = $ARGV[3];
$mean = $ARGV[4];
$sd = $ARGV[5];

# Check the loop definition string.

($loopStart, $loopEnd) = split(/\-/, $loopDef);

if( ($loopStart !~ /^[LH][1-9]/) ||
    ($loopEnd !~ /^[LH][1-9]/) )
{
   print STDERR "\nUnable to parse loop definition string \"$loopDef\".\n\n";
   exit(0);
}

# Check if the Fv file is readable.

if(! -r $FvPDBFilename)
{
   print STDERR "\nUnable to read file \"$FvPDBFilename\".\n\n";
   exit(0);
}

# Set the upper B-factor threshold.

$BF_upper_threshold = $mean + ($sd_limit * $sd);

if( &check_for_threshold($FvPDBFilename, $loopStart, $loopEnd, $BF_upper_threshold) )
{
   print "$pdbCode,$loop,$loopDef\n";
}

# End of program.
