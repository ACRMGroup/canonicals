#! /usr/bin/perl

use strict 'vars';
use Env;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $HOME = $ENV{"HOME"};

my $pdbCode1 = "";
my $pdbCode2 = "";
my $mappingsFilename = "";
my $keyPositionsFilename = "";

my $can1 = "";
my $can2 = "";
my @keyPositions = ();

my $numberingFilename1 = "";
my $numberingFilename2 = "";

my $sequence1 = "";
my $sequence2 = "";

my %numbering1 = ();
my %numbering2 = ();

my $position = "";
my @keyPositionsCon = ();
my @keyPositions = ();

my @residues1 = ();
my @residues2 = ();

my $i = 0;
my $numberOfIdenticalResidues = 0;
my $sequenceIdentity = 0;


# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# ---------------- SUB - ROUTINES SECTION --------------


sub get_canonical_classes
{
   # ($can1, $can2) = &get_canonical_classes($pdbCode1, $pdbCode2, $mappingsFilename);

   my ($pdbCode1, $pdbCode2, $mappingsFilename) = @_;

   my @con = ();
   my @found1 = ();
   my @found2 = ();

   my $ignore = "";
   my $can1 = "";
   my $can2 = "";

   # Open the mappings file.

   open(HD, $mappingsFilename) || die "\nUnable to open file \"$mappingsFilename\".\n\n";
   @con = <HD>;
   close(HD);

   # Gather the canonical classes.

   @found1 = grep(/$pdbCode1/, @con);
   @found2 = grep(/$pdbCode2/, @con);

   # @found1 and @found2 will be of the form:
   #
   # 12e8,L1,11A

   ($ignore, $ignore, $can1) = split(/,/, $found1[0]);
   ($ignore, $ignore, $can2) = split(/,/, $found2[0]);

   # Remove newline characters.

   chomp($can1);
   chomp($can2);

   # Return the canonical classes.

   return ($can1, $can2);

} # End of sub-routine "get_canonical_classes".


sub get_key_positions
{
   # &get_key_positions($can1, \@keyPositionsCon, \@keyPositions);

   my ($can, $keyPositionsCon, $keyPositions) = @_;
   my $line = "";
   my $flag = 0;

   # Gather the required information.

   foreach $line (@$keyPositionsCon)
   {
      chomp($line);

      # Look for the canonical class.

      if( ($line =~ /$can/) && ($line =~ /^>/) )
      {
         $flag = 1;

         next;
      }

      # Check if $flag is 1 and extract the required information.

      if($flag == 1)
      {
         # Reset $flag.

         $flag = 0;

         # Get the positions.
         # Line is of the form:
         #
         # L2:L3:L4:L23:L25:L26:L27:L29:L31:L33:L34:L35:L49:L51:L66:L69:L70:L71:L88:L90:L91:L92:L93:

         @$keyPositions = split(/:/, $line);
      }
   }

} # End of sub-routine "get_key_positions".



sub read_numbering
{
   # &read_numbering($numberingFilename1, \%numbering1);

   my ($numberingFilename, $numbering) = @_;

   my $line = "";
   my $position = "";
   my $residue = "";

   # Open the numbering file.

   open(HD, $numberingFilename) || die "\nUnable to open file \"$numberingFilename\".\n\n";

   # Gather the required contents.

   while($line = <HD>)
   {
      # Remove newlines.

      chomp($line);

      # Skip line if required.

      if($line !~ /^[LH][1-9]/)
      {
         next;
      }

      # Parse the line.
      #
      # Line is of the form:
      #
      # L2 I

      ($position, $residue) = split(/ /, $line);

      # Store the numbering in the hash.

      $$numbering{$position} = $residue;

   } # End of while loop.


   # Close the file handle.

   close(HD);

} # End of sub-routine "read_numbering".



# ------------- END OF SUB-ROUTINES SECTION ---------------


# Main code of the program starts here.

if($#ARGV < 3)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. PDB Code 1";
   print STDERR "\n2. PDB Code 2";
   print STDERR "\n4. File with mappings of PDB codes to canonical classes";
   print STDERR "\n5. File with key positions for canonical classes of the loop in FASTA format";
   print STDERR "\n\n";
   exit(0);
}

$pdbCode1 = $ARGV[0];
$pdbCode2 = $ARGV[1];
$mappingsFilename = $ARGV[2];
$keyPositionsFilename = $ARGV[3];

# Step 1: Get the canonical classes for the two PDB codes.

($can1, $can2) = &get_canonical_classes($pdbCode1, $pdbCode2, $mappingsFilename);

# Step 2: Get the key positions for the canonical class $can1.

open(KEY, $keyPositionsFilename) || die "\nUnable to read file \"$keyPositionsFilename\".\n\n";
@keyPositionsCon = <KEY>;
close(KEY);

&get_key_positions($can1, \@keyPositionsCon, \@keyPositions);

# Check if the canonical class $can1 has associated key positions.
# If not, then print -1 as the pairwise sequence identity.

if($#keyPositions == -1)
{
   print "-1";
   exit(0);
}

# if($#keyPositions == -1)
# {
#    # Get the key positions for canonical class $can2.
# 
#    &get_key_positions($can2, \@keyPositionsCon, \@keyPositions);
# 
#    if($#keyPositions == -1)
#    {
#       # $can2 does not have any key positions either.
#       # Print a sequence identity of -1 and exit the program.
# 
#       print "NA:-1";
#    }
#    else
#    {
#       $keyPositionsClass = $can2;
#    }
# }
# else
# {
#    # $can1 has been used for the key positions.
# 
#    $keyPositionsClass = $can1;
# }

# Read the numbering of the two files.

$numberingFilename1 = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_FILES/".$pdbCode1.".out";
$numberingFilename2 = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_FILES/".$pdbCode2.".out";

&read_numbering($numberingFilename1, \%numbering1);
&read_numbering($numberingFilename2, \%numbering2);

# For every key position, gather the residue in the position
# for $pdbCode1 and $pdbCode2.

foreach $position (@keyPositions)
{
   push(@residues1, $numbering1{$position});
   push(@residues2, $numbering2{$position});
}

# Calculate the identity between the two sequences.

$numberOfIdenticalResidues = 0;

for($i = 0 ; $i <= $#keyPositions ; $i++)
{
   if( uc($residues1[$i]) eq uc($residues2[$i]) )
   {
      $numberOfIdenticalResidues++;
   }
}

$sequenceIdentity = sprintf("%2.1f", ($numberOfIdenticalResidues * 100)/($#keyPositions + 1));

# Print the sequence identity.

print "$sequenceIdentity";

# End of program.
