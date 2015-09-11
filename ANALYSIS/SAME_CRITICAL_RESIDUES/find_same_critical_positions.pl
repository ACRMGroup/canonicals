#! /usr/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $loop = "";
my $criticalPositionsFilename = "";
my $outputFilename = "";
my $formattedOutputFilename = "";
my $canonicalClassesString = "";
my %canonicalClassesHash = ();
my @sameCriticalPositions = ();
my %criticalResiduesHash = ();
my $canonicalClass1 = "";
my $canonicalClass2 = "";
my $line = "";
my $canonicalClass = "";
my $criticalPositions = "";
my %criticalPositionsHash = ();
my @writtenCanonicalClasses = ();
my $tempCan1 = "";
my $tempCan2 = "";
my $canonicalDefinitionsFilename = "";
my %canonicalDefinitions = ();

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# ---------------- SUB-ROUTINES SECTION ----------------

sub read_canonical_definitions_file
{
   # if(! &read_canonical_definitions_file($canonicalDefinitionsFilename,
   #                                       \%canonicalDefinitions) )

   my ($canonicalDefinitionsFilename,
       $canonicalDefinitions) = @_;

   my $line = "";
   my $ignore = "";
   my $canonicalClass = "";
   my $label = "";
   my $residues = "";
   my $hashKey = "";

   # Read the file.

   open(HD, $canonicalDefinitionsFilename) || die "\nUnable to open file \"$canonicalDefinitionsFilename\".\n\n";

   # Parse the contents.

   while($line = <HD>)
   {
      # Remove newlines.

      chomp($line);

      # If the line contains a canonical class name.

      if($line =~ /LOOP/)
      {
         # LOOP L1 ?/16B 16

         ($ignore, $ignore, $canonicalClass, $ignore) = split(/ /, $line);
         next;
      }

      # If the line contains a critical resiude.

      if($line =~ /^[LH][1-9]/)
      {
         # L4      M

         $line =~s/\t+/\t/g;
         $line =~s/ //g;
         ($label, $residues) = split(/\t/, $line);

         # Remove brackets if required.

         $residues =~s/\[//g;
         $residues =~s/\]//g;

         $hashKey = $canonicalClass.":".$label;
         $$canonicalDefinitions{$hashKey} = $residues;

         next;
      }

   } # End of while($line =....)

   # Close the file handle.

   close(HD);

} # End of sub-routine "read_canonical_definitions_file".
 

sub compare_canonical_classes
{
   # &compare_canonical_classes($canonicalClass1,
   #                            $canonicalClass2,
   #                            $canonicalDefinitions,
   #                            $criticalPositionsHash);

   my ($canonicalClass1,
       $canonicalClass2,
       $canonicalDefinitions,
       $criticalPositionsHash) = @_;

   my $criticalPositionsString = "";
   my @criticalPositions = ();
   my $criticalPosition = "";

   my $criticalResidues1 = "";
   my $criticalResidues2 = "";
   my $overlapFlag = 1;
   my $hashKey = "";

   # Gather the critical positions.

   $criticalPositionsString = $$criticalPositionsHash{$canonicalClass1};
   @criticalPositions = split(/:/, $criticalPositionsString);

   # Compare the residues in the critical positions.

   foreach $criticalPosition (@criticalPositions)
   {
      $hashKey = $canonicalClass1.":".$criticalPosition;
      $criticalResidues1 = $$canonicalDefinitions{$hashKey};

      $hashKey = $canonicalClass2.":".$criticalPosition;
      $criticalResidues2 = $$canonicalDefinitions{$hashKey};

      if(! &overlap($criticalResidues1, $criticalResidues2) )
      {
         $overlapFlag = 0;
      }
   }

   # Return the overlap flag.

   return $overlapFlag;

} # End of sub-routine "compare_canonical_classes".


sub overlap
{
   # &overlap($criticalResidues1, $criticalResidues2)

   my ($criticalResidues1, $criticalResidues2) = @_;

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


sub write_formatted_output
{
   # &write_formatted_output($loop,
   #                         $canonicalClass1,
   #                         $canonicalClass2,
   #                         $criticalPositionsHash{$canonicalClass1},
   #                         \%canonicalDefinitions);

   my ($loop,
       $canonicalClass1,
       $canonicalClass2,
       $criticalPositions,
       $canonicalDefinitions) = @_;

   my @positions = ();
   my $position = "";
   my $hashKey = "";
   my $criticalResidues1 = "";
   my $criticalResidues2 = "";
   my $i = 0;

   # Write the header line.

   print FORMAT "LOOP\t",
                "POSITION\t",
                "$canonicalClass1\t",
                "$canonicalClass2\n";

   # Write the residues.

   @positions = split(/:/, $criticalPositions);

   for($i = 0 ; $i <= $#positions ; $i++)
   {
      $position = $positions[$i];

      $hashKey = $canonicalClass1.":".$position;
      $criticalResidues1 = $$canonicalDefinitions{$hashKey};

      print FORMAT $loop, "\t",
                   $position, "\t",
                   $criticalResidues1, "\t";

      $hashKey = $canonicalClass2.":".$position;
      $criticalResidues2 = $$canonicalDefinitions{$hashKey};

      print FORMAT $criticalResidues2, "\n";
   }

} # End of sub-routine "write_formatted_output".




# ------------- END OF SUB-ROUTINES SECTION ------------

# Main code of the program starts here.

if($#ARGV < 3)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. Loop";
   print STDERR "\n2. File with canonical classes that have the same set of critical positions";
   print STDERR "\n   (In FASTA format)";
   print STDERR "\n3. Canonical definitions file";
   print STDERR "\n4. Output filename";
   print STDERR "\n5. Formatted output filename";
   print STDERR "\n\n";
   exit(0);
}

$loop = $ARGV[0];
$criticalPositionsFilename = $ARGV[1];
$canonicalDefinitionsFilename = $ARGV[2];
$outputFilename = $ARGV[3];
$formattedOutputFilename = $ARGV[4];

# Read and store the contents of the canonicals definitions file in a hash.

if(! &read_canonical_definitions_file($canonicalDefinitionsFilename,
                                       \%canonicalDefinitions) )
{
   print STDERR "\nUnable to read canonical definitions file \"$canonicalDefinitionsFilename\".\n\n";
   exit(0);
}

# Open the input file.

open(HD, $criticalPositionsFilename) || die "\nUnable to open file \"$criticalPositionsFilename\".\n\n";

# Parse the contents of the input file.

while($line = <HD>)
{
   # Remove newlines.

   chomp($line);

   # If the line starts with >, get the set of critical positions.

   if($line =~ /^>/)
   {
      ($canonicalClass, $criticalPositions) = split(/::::/, $line);
      $canonicalClass =~s/^>//;

      # Record the correspondence between canonical class and critical positions.

      $criticalPositionsHash{$canonicalClass} = $criticalPositions;

      # Check if there is already another canonical class with the same set
      # of critical positions.

      if($canonicalClassesHash{$criticalPositions} ne "")
      {
         # If there are other canonical class with the same set of critical positions,
         # record this.

         $canonicalClassesString = $canonicalClassesHash{$criticalPositions}.":".$canonicalClass;

         push(@sameCriticalPositions, $canonicalClassesString);

         print "\nLoop: ", $loop;
         print "\nCanonical class 1: ", $canonicalClassesHash{$criticalPositions};
         print "\nCanonical class 2: ", $canonicalClass;
         print "\nCritical positions: ", $criticalPositions;
         print "\n-----------------------\n";
      }
      else
      {
         $canonicalClassesHash{$criticalPositions} = $canonicalClass;
      }
   }
   else
   {
      # Line contains a list of residues at the critical positions.
      #
      # [PWS][FYG][WV][DSG][FY][YF][IV][RSY][YW][GSN][GD][GSA][TK][YR]YI[RK]

      $criticalResiduesHash{$canonicalClass} = $line;
   }

} # End of while loop.

# Close the input file handle.

close(HD);

# Open the output file in write mode.

open(WHD, ">$outputFilename");
open(FORMAT, ">>$formattedOutputFilename");

# For every pair of canonical classes that have the same set of critical positions,
# write the canonical class and corresponding critical residues to a file.

foreach $canonicalClassesString (@sameCriticalPositions)
{
   ($canonicalClass1, $canonicalClass2) = split(/:/, $canonicalClassesString);

   if( &compare_canonical_classes($canonicalClass1,
                                  $canonicalClass2,
                                  \%canonicalDefinitions,
                                  \%criticalPositionsHash) )
   {
      # Print to the regular output file.

      print WHD "$canonicalClass1\t",
                "$canonicalClass2\t",
                "Possible\t",
                $criticalPositionsHash{$canonicalClass1}, "\t",
                $criticalResiduesHash{$canonicalClass1}, "\t",
                $criticalResiduesHash{$canonicalClass2};

      # Print to the formatted output file.

      &write_formatted_output($loop,
                              $canonicalClass1,
                              $canonicalClass2,
                              $criticalPositionsHash{$canonicalClass1},
                              \%canonicalDefinitions);
   }
   else
   {
      # Print to the regular output file.

      print WHD "$canonicalClass1\t",
                "$canonicalClass2\t",
                "Not possible\t",
                $criticalPositionsHash{$canonicalClass1}, "\t",
                $criticalResiduesHash{$canonicalClass1}, "\t",
                $criticalResiduesHash{$canonicalClass2};

      # Print to the formatted output file.

   }

   print WHD "\n";

} # End of foreach loop.

# Close the output file handle.

close(WHD);
close(FORMAT);

# End of program.
