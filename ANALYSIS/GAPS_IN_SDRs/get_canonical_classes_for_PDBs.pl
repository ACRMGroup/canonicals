#! /usr/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $pdbCodesFilename = "";
my $clanFilename = "";
my $loop = "";
my $outputFilename = "";

my %can = ();

# Set the control sequence for CTRL-C keystrokes.

$SIG{INT} = \&ctrlC;

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# --------------- SUB - ROUTINES SECTION ---------------

sub ctrlC
{
   # Exit from the program.

   exit(0);

} # End of sub-routine "ctrlC".

###########################################################################
# sub gather_PDB_codes_to_cluster_number_mapping: Sub-routine that maps PDB
# codes to the cluster number.
###########################################################################

sub gather_PDB_codes_to_cluster_number_mapping
{
   # &gather_PDB_codes_to_cluster_number_mapping(\%pdb2Cluster);

   my $pdb2Cluster = $_[0];

   my $line = "";
   my $clusterNumber = -1;
   my @parts = ();
   my $rest = "";
   my $pdbCode = "";
   my $i = 0;

   # Go to the section "BEGIN ASSIGNMENTS".

   while($line = <CLAN>)
   {
      # Exit the loop when the line BEGIN ASSIGNMENTS is encountered.

      if($line =~ /BEGIN ASSIGN/)
      {
         last;
      }

   } # End of while loop.

   # Gather the mapping of PDB codes to their cluster number.

   my $counter = 0;

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
         # print "\nSkipping line: $line";
         # next;
      }

      # Line is of the form:
      #
      #   1 /home/bsm2/abhi/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB//1cfq.pdb-L24-L34

      $line =~s/^\s+//g;
      ($clusterNumber, $rest) = split(/ /, $line);

      @parts = split(/\//, $rest);
      $pdbCode = $parts[$#parts]; # $pdbCode is like "1cfq.pdb-L24-L34" or "p1acy.ab-L24-L34".

      @parts = split(//, $pdbCode);

      $i = 0;

      while($parts[$i] !~ /[0-9]/)
      {
         $i++;
      }

      # Check if the antibody is anti-idiotypic.

      if($pdbCode =~ /_/)
      {
         $pdbCode = "";
         $pdbCode = $parts[$i].$parts[$i+1].$parts[$i+2].$parts[$i+3].$parts[$i+4].$parts[$i+5];
      }
      else
      {
         $pdbCode = "";
         $pdbCode = $parts[$i].$parts[$i+1].$parts[$i+2].$parts[$i+3];
      }

      $counter++;

      $$pdb2Cluster{$pdbCode} = $clusterNumber;

   } # End of while($line = <CLAN>).

} # End of sub-routine "gather_PDB_codes_to_cluster_number_mapping".


#############################################################################
# sub gather_cluster_number_to_canonical_class_mapping: Sub-routine that maps
# cluster number to canonical class.
#############################################################################

sub gather_cluster_number_to_canonical_class_mapping
{
   # &gather_cluster_number_to_canonical_class_mapping(\%cluster2Class);

   my $cluster2Class = $_[0];

   my $line = "";
   my $clusterNumber = -1;
   my $canonicalClass = "";

   # Go to the section "BEGIN LABELS".

   while($line = <CLAN>)
   {
      if( ($line =~ /BEGIN_LABELS/) || ($line =~ /BEGIN LABELS/) )
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

      $$cluster2Class{$clusterNumber} = $canonicalClass;

   } # End of while loop.

} # End of sub-routine "gather_cluster_number_to_canonical_class_mapping".


#########################################################################
# sub get_canonical_class_assignments: Sub-routine that maps PDB codes to
# their canonical classes.
#########################################################################

sub get_canonical_class_assignments
{
   # &get_canonical_class_assignments($clanFilename,
   #                                  \%can);

   my ($clanFilename,
       $canonicalClasses) = @_;

   my %pdb2Cluster = ();
   my %cluster2Class = ();
   my $pdbCode = "";
   my $clusterNumber = -1;

   # Open the CLAN file in read mode.

   open(CLAN, $clanFilename) || return 0;

   # Gather the mapping of PDB codes to cluster number.

   &gather_PDB_codes_to_cluster_number_mapping(\%pdb2Cluster);

   # Gather the mapping of cluster numbers to canonical class names.

   &gather_cluster_number_to_canonical_class_mapping(\%cluster2Class);

   # Map the PDB codes to their canonical class.

   foreach $pdbCode (keys %pdb2Cluster)
   {
      $clusterNumber = $pdb2Cluster{$pdbCode};
      $$canonicalClasses{$pdbCode} =  $cluster2Class{$clusterNumber};

   } # End of foreach loop.

   # Close the file handle.

   close(CLAN);

   # Return 1 to the calling function to indicate successful processing.

   return 1;

} # End of sub-routine "get_old_canonical_class_assignments".


sub write_to_output_file
{
   # &write_to_output_file($outputFilename,
   #                       $loop,
   #                       \%can,
   #                       \%antibodyTypes);

   my ($outputFilename,
       $loop,
       $can,
       $antibodyTypes) = @_;

   my $pdbCode = "";

   # Open the output file in write mode.

   open(WHD, ">$outputFilename");

   # Write the header line.

   print WHD "PDB,LOOP,CAN_NEW\n";

   # For every PDB code, write the old and new canonical class
   # and also the type of antibody.

   foreach $pdbCode (keys %$can)
   {
      print WHD $pdbCode, ",",
                $loop, ",",
                $$can{$pdbCode}, "\n";
   }

   # Close the file handle.

   close(WHD);

} # End of sub-routine "write_to_output_file".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 3)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. File with current list of PDB codes";
   print STDERR "\n2. CLAN file";
   print STDERR "\n3. Loop";
   print STDERR "\n4. Output file";
   print STDERR "\n\n";
   exit(0);
}

$pdbCodesFilename = $ARGV[0];
$clanFilename = $ARGV[1];
$loop = $ARGV[2];
$outputFilename = $ARGV[3];

# Get the canonical class assignments for the PDBs.

if(! &get_canonical_class_assignments($clanFilename,
                                      \%can) )
{
   print STDERR "\nUnable to open file \"$clanFilename\".\n\n";
   exit(0);
}

# Write the old and new canonical class assignments to the output file.

if(! &write_to_output_file($outputFilename,
                           $loop,
                           \%can) )
{
   print STDERR "\nUnable to open file \"$outputFilename\" in write mode.\n\n";
   exit(0);
}

# End of program.
