#! /usr/bin/perl

# This perl script collates results from part 2 runs of every case (i.e. cases 1, 2, and 3).
# The template PDB with lowest RMS for a query PDB together with the percentage sequence
# identity in each case (sequence identity over the loop in case 1, sequence identity over
# the key residues in case 2 and sequence identity over the key framework residues and loop
# sequence in case 3).

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

# Set the control sequence for CTRL-C keystrokes.

$SIG{INT} = \&ctrlC;

my $line = "";

my $loop = "";
my $case1Part2Filename = "";
my $case2Part2Filename = "";
my $case3Part2Filename = "";

my @case1QueryPDBs = ();
my @case2QueryPDBs = ();
my @case3QueryPDBs = ();

my %bestMatchCase1 = "";
my %bestMatchCase2 = "";
my %bestMatchCase3 = "";

my $bestMatchPDBCase1 = "";
my $bestMatchPDBCase2 = "";
my $bestMatchPDBCase3 = "";

my $queryPDB = "";
my $targetPDB = "";

my $queryCanonicalClass = "";
my $targetCanonicalClass = "";

my $sequenceIdentity = 0;
my $rmsd = 0;


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


sub process_case_files
{
   # &process_case_files($case3Part2Filename, \@case3QueryPDBs, \%bestMatchCase3,
   #                     1, 2, 3, 4, 5, 6);

   my ($caseFilename, $queryPDBs, $hash,
       $queryPDBFieldNumber, $queryCanFieldNumber,
       $targetPDBFieldNumber, $targetCanFieldNumber,
       $sequenceIdentityFieldNumber, $rmsdFieldNumber) = @_;

   my @parts = ();

   my $queryPDB = "";
   my $queryCanonicalClass = "";

   my $targetPDB = "";
   my $targetCanonicalClass = "";

   my $sequenceIdentity = 0;
   my $rmsd = 0;

   my %bestRMSD = ();

   # Open the file or report an error.

   open(HD, $caseFilename) || die "\nUnable to open file \"$caseFilename\".\n\n";

   # Gather the required information.

   while($line = <HD>)
   {
      # Remove newline.

      chomp($line);

      # Skip the line if it does not contain a loop name.

      if($line !~ /[0-9]$/)
      {
         next;
      }

      # Parse the contents.

      @parts = split(/,/, $line);

      # Get the required field numbers.

      $queryPDB = $parts[$queryPDBFieldNumber - 1];
      $queryCanonicalClass = $parts[$queryCanFieldNumber - 1];

      $targetPDB = $parts[$targetPDBFieldNumber - 1];
      $targetCanonicalClass = $parts[$targetCanFieldNumber - 1];

      $sequenceIdentity = $parts[$sequenceIdentityFieldNumber - 1];;
      $rmsd = $parts[$rmsdFieldNumber - 1];

      # In cases where loop residues are missing in the structure,
      # move to the next case.

      if( grep(/$queryPDB/, @$queryPDBs) )
      {
         # A taget PDB has already been found for the query.

         if($bestRMSD{$queryPDB} > $rmsd)
         {
            $bestRMSD{$queryPDB} = $rmsd;
            $$hash{$queryPDB} = "$queryCanonicalClass:$targetPDB:$targetCanonicalClass:$sequenceIdentity:$rmsd";
         }
      }
      else
      {
         # No taget PDB has been found for the query yet.

         push(@$queryPDBs, $queryPDB);

         $bestRMSD{$queryPDB} = $rmsd;
         $$hash{$queryPDB} = "$queryCanonicalClass:$targetPDB:$targetCanonicalClass:$sequenceIdentity:$rmsd";
      }

   } # End of while loop.


   # Close the file handle.

   close(HD);

} # End of sub-routine "process_case_files".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

# Check for command line parameters.

if($#ARGV < 2)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. Loop";
   print STDERR "\n2. CSV file - Results of Case I, part 2 analysis (highest identity on loop sequence alone)";
   print STDERR "\n3. CSV file - Results of Case II analysis, part 2 analysis (highest identity on key residues)";
   print STDERR "\n4. CSV file - Results of Case III analysis, part 2 analysis (highest identity on key framework residues + loop sequence)";
   print STDERR "\n\n";
   exit(0);
}

$loop = $ARGV[0];
$case1Part2Filename = $ARGV[1];
$case2Part2Filename = $ARGV[2];
$case3Part2Filename = $ARGV[3];

# Store the Case 1 results in a hash.
#
# File format:
#
# L1,L24-L34,2f5a,11A,1tjg,11A,100.01,0.962

&process_case_files($case1Part2Filename, \@case1QueryPDBs, \%bestMatchCase1,
                    3, 4, 5, 6, 7, 8); # Field numbers of the query, query canonical class
                                       # template, template canonical class, percentage
                                       # sequence identity over the loop and RMS.

# Store the Case 2 results in a hash.
#
# File format:
#
# L1,L24-L34,2f5a,11A,1tjg,11A,100.0,0.962

&process_case_files($case2Part2Filename, \@case2QueryPDBs, \%bestMatchCase2,
                    3, 4, 5, 6, 7, 8); # Field numbers of the query, query canonical class
                                       # template, template canonical class, percentage sequence
                                       # identity over key residues, and RMS.

# Store the Case 3 results in a hash.
#
# File format:
#
# 2f5a,11A,1tjg,11A,1.0,0.962

&process_case_files($case3Part2Filename, \@case3QueryPDBs, \%bestMatchCase3,
                    1, 2, 3, 4, 5, 6); # Field numbers of the query, query canonical class
                                       # template, template canonical class, percentage sequence
                                       # identity over key framework residues + loop sequence, and RMS.


# Print all the information in the following format:
#
# -- Query PDB
#
# -- Closest target PDB on the basis of loop sequence and
#    with the lowest RMSD over the loop, sequence identity
#    and RMSD (results from Part 1 analysis).
#
# -- Closest target PDB on the basis of key residues and
#    with the lowest RMSD over the loop, sequence identity
#    and RMSD (results from Part 2 analysis).
#
# -- Closest target PDB on the basis of key framework residues +
#    loop sequence and lowest RMSD over the loop, sequence identity
#    and RMSD (results from part 3 analysis).

foreach $queryPDB (@case1QueryPDBs)
{
   print $queryPDB, ",";

   # Extract the required information for the different cases from the hash.
   # Format for the hash:
   #
   # $$hash{$queryPDB} = "$queryCanonicalClass:$targetPDB:$targetCanonicalClass:$sequenceIdentity:$rmsd";

   # Best target in Case 1.

   ($queryCanonicalClass,
    $targetPDB, $targetCanonicalClass,
    $sequenceIdentity, $rmsd) = split(/:/, $bestMatchCase1{$queryPDB});

   # Print the query PDB's canonical class for the first time.

   print $queryCanonicalClass, ",";

   print $targetPDB, ",",
         $targetCanonicalClass, ",",
         $sequenceIdentity, ",",
         $rmsd, ",";

   # Best target in Case 2.

   ($queryCanonicalClass,
    $targetPDB, $targetCanonicalClass,
    $sequenceIdentity, $rmsd) = split(/:/, $bestMatchCase2{$queryPDB});

   print $targetPDB, ",",
         $targetCanonicalClass, ",",
         $sequenceIdentity, ",",
         $rmsd, ",";

   # Best target in Case 3.

   ($queryCanonicalClass,
    $targetPDB, $targetCanonicalClass,
    $sequenceIdentity, $rmsd) = split(/:/, $bestMatchCase3{$queryPDB});

   print $targetPDB, ",",
         $targetCanonicalClass, ",",
         $sequenceIdentity, ",",
         $rmsd;

   print "\n";

} # End of foreach loop.


# End of program.
