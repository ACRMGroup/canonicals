#! /usr/bin/perl

use strict 'vars';

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $sequence1 = "";
my $sequence2 = "";

my @parts1 = ();
my @parts2 = ();

my $numberOfIdenticalResidues = 0;
my $percentageIdentity = 0;

my $i = 0;

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# Main code of the program starts here.

if($#ARGV < 1)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. Sequence 1";
   print STDERR "\n2. Sequence 2";
   print STDERR "\n\n";
   exit(0);
}

$sequence1 = $ARGV[0];
$sequence2 = $ARGV[1];

# Check if their lengths are equal.

if( length($sequence1) != length($sequence2) )
{
   print STDERR "\nLengths of the two sequences are not equal.\nAborting program.\n\n";
   exit(0);
}

# Split the sequences into arrays.

@parts1 = split(//, $sequence1);
@parts2 = split(//, $sequence2);

# Find number of identical residues.

for($i = 0 ; $i <= $#parts1 ; $i++)
{
   if($parts1[$i] eq $parts2[$i])
   {
      $numberOfIdenticalResidues++;
   }
}

# Calculate identity.

$percentageIdentity = $numberOfIdenticalResidues/length($sequence1);

# Print the percentage identity.

$percentageIdentity = printf("%2.1f", $percentageIdentity * 100);

print $percentageIdentity;

# End of program.
