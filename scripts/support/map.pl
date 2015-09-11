#! /usr/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my @canonicalClassNames = ();

my $canonicalsFilename = "";
my $clanFilename = "";
my $outputFilename = "";
my $loop = "";

my @canonicalClassNames = ();
my %criticalResidueLines = ();
my %chothiaClassNames = ();
my %pdbCodesMappingHash = ();
my %clusterNumberNameMapping = ();

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# --------------- SUB - ROUTINES SECTION ---------------


##################################################################
# sub get_canonical_class_info: Sub-routine that creates a hash of
# canonical classes and critical residues that define it.
##################################################################

sub get_canonical_class_info
{
   # &get_canonical_class_info(\@canonicalClassNames,
   #                           \%criticalResidueLines,
   #                           \%chothiaClassNames);

   my ($canonicalClassNames,
       $criticalResidueLines,
       $chothiaClassNames) = @_;

   my $line = "";
   my @parts = ();
   my $ignore = "";
   my $canonicalClassName = "";
   my $chothiaClassName = "";

   # The canonical definitions file is of the form:
   #
   # LOOP L1 ?/16B 16
   # SOURCE [b]
   # L2      V
   # L3      V
   # L4      M
   #
   # All the canonical class names (e.g. 16B) must be gathered.

   while($line = <CAN>)
   {
      # Remove newlines.

      chomp($line);

      # If the line contains LOOP, then, extract the canonical class name.

      if($line =~ /LOOP/)
      {
         @parts = split(/ /, $line);
         ($chothiaClassName, $canonicalClassName) = split(/\//, $parts[2]);

         push(@$canonicalClassNames, $canonicalClassName);
         $chothiaClassNames{$canonicalClassName} = $chothiaClassName;
      }
      elsif($line =~ /^[LH][0-9]/)
      {
         # Store the position and the residue.

         $criticalResidueLines{$canonicalClassName} .= "\n$line";
      }
   }

} # End of sub-routine "get_canonical_class_info".



###############################################################################
# sub gather_PDB_codes_mapping: Gather mapping of PDB codes to cluster numbers.
###############################################################################

sub gather_PDB_codes_mapping
{
   # &gather_PDB_codes_mapping(\%pdbCodesMappingHash);

   my $pdbCodesMappingHash = $_[0];
   my $line = "";
   my $clusterNumber = -1;
   my @parts = ();
   my $rest = "";
   my $pdbCode = "";

   # Go to the section with PDB codes - cluster number mapping.

   while($line = <CLAN>)
   {
      if($line =~ /BEGIN ASSIGN/)
      {
         last;
      }

   } # End of while loop.

   # Assign the cluster numbers to the PDB hash.

   while($line = <CLAN>)
   {
      # Remove newline characters.

      chomp($line);

      # Exit from the loop when the end of the assignments
      # section is encountered.

      if($line =~ /END ASSIGNMENT/)
      {
         last;
      }

      # Skip a line that does not contain an assignment.

      if($line !~ /^\s+[0-9]/)
      {
         next;
      }

      # Line is of the form:
      #
      #   1 /home/bsm2/abhi/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB//1cfq.pdb-L24-L34

      $line =~s/^\s+//g;
      ($clusterNumber, $rest) = split(/ /, $line);
      @parts = split(/\//, $rest);
      $pdbCode = $parts[$#parts];
      $pdbCode =~s/\.pdb.*//g;

      $$pdbCodesMappingHash{$clusterNumber} .= "$pdbCode:";

   } # End of while($line = <CLAN>).

} # End of sub-routine "gather_PDB_codes_mapping".

############################################################################
# sub gather_cluster_number_names_mapping: Gather mapping of cluster numbers
# to canonical class names.
############################################################################

sub gather_cluster_number_names_mapping
{
   # &gather_cluster_number_names_mapping(\%clusterNumberNameMapping);

   my $clusterNumberNameMapping = $_[0];

   my $line = "";
   my $clusterNumber = -1;
   my $canonicalClass = "";

   # Go to the section "BEGIN LABELS".

   while($line = <CLAN>)
   {
      if($line =~ /BEGIN_LABELS/)
      {
         last;
      }

   } # End of while loop.

   # Gather all the labels.

   while($line = <CLAN>)
   {
      # Skip the line if it does not start with a number.

      if($line !~ /^[0-9]/)
      {
         next;
      }

      # Line is of the form:
      #
      # 24      16B

      $line =~s/\s+/ /g;

      ($clusterNumber, $canonicalClass) = split(/ /, $line);
      $$clusterNumberNameMapping{$canonicalClass} = $clusterNumber;

   } # End of while loop.

} # End of sub-routine "gather_cluster_number_names_mapping".


######################################################################################
# sub write_representative_structure_and_critical_residues: For every canonical class,
# write a representative structure and the critical residues.
######################################################################################

sub write_representative_structure_and_critical_residues
{
   # &write_representative_structure_and_critical_residues($loop,
   #                                                       \%chothiaClassNames
   #                                                       \@canonicalClassNames
   #                                                       \%criticalResiduesLines,
   #                                                       \%pdbCodesMappingHash,
   #                                                       \%clusterNumberNameMapping);

   my ($loop,
       $chothiaClassNames,
       $canonicalClassNames,
       $criticalResidueLines,
       $pdbCodesMappingHash,
       $clusterNumberNameMapping) = @_;

   my $line = "";
   my $canonicalClassName = "";
   my $clusterNumber = -1;
   my @pdbCodes = ();
   my $i = 0;
   my $canonicalClassLength = -1;
   my $range = -1;

   # For every canonical class, choose a representative structure
   # and write this to the output file along with the critical residues.

   foreach $canonicalClassName (@$canonicalClassNames)
   {
      # Get the canonical class length.

      $canonicalClassLength = $canonicalClassName;
      $canonicalClassLength =~s/[A-Z]//g;

      # Get the cluster number.

      $clusterNumber = $$clusterNumberNameMapping{$canonicalClassName};

      # Get the list of PDB codes which belong to the cluster.

      @pdbCodes = ();
      @pdbCodes = split(/:/, $$pdbCodesMappingHash{$clusterNumber});

      $range = $#pdbCodes;

      # Choose a random representative structure.

      $i = int(rand($range));

      # Write the data to the output file. Output file is of the form:
      #
      # LOOP L1 ?/16B 16
      # SOURCE [b]
      # L2      V
      # L3      V
      # L4      M

      print WHD "LOOP ",
                $loop, " ",
                $$chothiaClassNames{$canonicalClassName}, "/",
                $canonicalClassName, " ",
                $canonicalClassLength, "\n";

      print WHD "SOURCE [", $pdbCodes[$i], "]";

      print WHD $criticalResidueLines{$canonicalClassName}, "\n\n";

   } # End of foreach loop.

} # End of "write_representative_structure_and_critical_residues".


# ----------- END OF SUB - ROUTINES SECTION ------------



# Main code of the program starts here.

if($#ARGV < 3)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. Canonical definition file (e.g. canonical_L1)";
   print STDERR "\n2. CLAN file (e.g. L1_clan.out)";
   print STDERR "\n3. Output file";
   print STDERR "\n4. Loop";
   print STDERR "\n\n";
   exit(0);
}

$canonicalsFilename = $ARGV[0];
$clanFilename = $ARGV[1];
$outputFilename = $ARGV[2];
$loop = $ARGV[3];

# Open the canonical and CLAN files. If unable to open, report error
# and exit from the program.

open(CAN, $canonicalsFilename) || die "\nUnable to open file \"$canonicalsFilename\".\n\n";
open(CLAN, $clanFilename) || die "\nUnable to open file \"$clanFilename\".\n\n";
open(WHD, ">$outputFilename") || die "\nUnable to open file \"$outputFilename\" in write mode.\n\n";

# Gather the canonical class names from the canonical definitions file..

&get_canonical_class_info(\@canonicalClassNames,
                          \%criticalResidueLines,
                          \%chothiaClassNames);

# Gather mapping of PDB codes to cluster numbers.

&gather_PDB_codes_mapping(\%pdbCodesMappingHash);

# Gather mapping of cluster numbers to canonical class names.

&gather_cluster_number_names_mapping(\%clusterNumberNameMapping);

# For every canonical class, write a representative structure and the critical residues.

&write_representative_structure_and_critical_residues($loop,
                                                      \%chothiaClassNames,
                                                      \@canonicalClassNames,
                                                      \%criticalResidueLines,
                                                      \%pdbCodesMappingHash,
                                                      \%clusterNumberNameMapping);

# Close the file handles.

close(CAN);
close(CLAN);
close(WHD);

# End of program.
