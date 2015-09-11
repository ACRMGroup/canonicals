#! /usr/bin/perl

use strict 'vars';

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $element1 = "";
my $element2 = "";
my $overlapFlag = 1;


# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# --------------- SUB - ROUTINES SECTION ---------------

sub overlap
{
   # &overlap($criticalResidues1, $criticalResidues2)

   my ($criticalResidues1, $criticalResidues2) = @_;

   print "\nHere to compare \"$criticalResidues1\" and \"$criticalResidues2\".\n";
   <STDIN>;

   my $found = 0;
   my $temp = "";
   my @shorterSet = ();
   my $residue = "";

   # Transfer the shorter set of residues to $criticalResidues1.

   if( length($criticalResidues1) > length($criticalResidues2) )
   {
      $temp = $criticalResidues1;
      $criticalResidues1 = $criticalResidues2;
      $criticalResidues2 = $temp;
   }

   # Check if the length of $criticalResidues1 is 1.
   # If yes, check if $criticalResidues1 is a substring
   # of $criticalResidues2.

   if(length($criticalResidues1) == 1)
   {
      if($criticalResidues2 =~ /$criticalResidues1/i)
      {
         return 1; # Return 1 to indicate overlap in critical residues.
      }
      else
      {
         return 0; # Return 0 to indicate no overlap in critical residues.
      }
   }

   # There are a set of critical residues in both canonical classes.
   # Compare the shorter set against the longer set.

   $criticalResidues1 =~s/\[//g;
   $criticalResidues1 =~s/\]//g;

   @shorterSet = split(//, $criticalResidues1);

   $found = 0; # Set found to 0 (default) to indicate no overlap in critical residues.

   foreach $residue (@shorterSet)
   {
      if($criticalResidues2 =~ /$residue/)
      {
         $found = 1; # Set found to 1 to indicate overlap in critical residues.
         last;
      }
   }

   # Return the result of the finding.

   return $found;

} # End of sub-routine "overlap".


my @string1 = ("A", "[BC]", "D", "[EF]");
my @string2 = ("[AB]", "B", "[CD]", "[FGH]");


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

for(my $i = 0 ; $i < 4 ; $i++)
{
   $element1 = $string1[$i];
   $element2 = $string2[$i];

   if(! &overlap($element1, $element2) )
   {
      $overlapFlag = 0;
   }

}

print "\nOverlap flag: $overlapFlag\n\n";

# End of program.
