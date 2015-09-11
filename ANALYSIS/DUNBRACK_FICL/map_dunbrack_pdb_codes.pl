#! /usr/bin/perl

use strict 'vars';

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $dunbrackSupplementaryDataFilename = "";
my $dunbrackTypeIIIFilename = "";
my $acrmL1Filename = "";
my $acrmL2Filename = "";
my $acrmL3Filename = "";
my $acrmH1Filename = "";
my $acrmH2Filename = "";
my $outputFilename = "";

my $line = "";
my $ignore = "";
my $loopInfo = "";
my $pdbInfo = "";
my $pdbCode = "";
my $loop = "";

my $dunbrackClassName = "";
my %dunbrackClassNameHash = ();
my @dunbrackTypeIIIClasses = ();
my @pdbsInDunbrackClass = ();

my %L1Hash = ();
my %L2Hash = ();
my %L3Hash = ();
my %H1Hash = ();
my %H2Hash = ();

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


sub check_files
{
   # Files that need checking:
   #
   # $dunbrackSupplementaryDataFilename
   # $dunbrackTypeIIIFilename
   # $acrmL1Filename
   # $acrmL2Filename
   # $acrmL3Filename
   # $acrmH1Filename
   # $acrmH2Filename

   if(! -r $dunbrackSupplementaryDataFilename)
   {
      print STDERR "\nUnable to read file \"$dunbrackSupplementaryDataFilename\".\n\n";
      exit(0);
   }

   if(! -r $dunbrackTypeIIIFilename)
   {
      print STDERR "\nUnable to read file \"$dunbrackTypeIIIFilename\".\n\n";
      exit(0);
   }

   if(! -r $acrmL1Filename)
   {
      print STDERR "\nUnable to read file \"$acrmL1Filename\".\n\n";
      exit(0);
   }

   if(! -r $acrmL2Filename)
   {
      print STDERR "\nUnable to read file \"$acrmL2Filename\".\n\n";
      exit(0);
   }

   if(! -r $acrmL3Filename)
   {
      print STDERR "\nUnable to read file \"$acrmL3Filename\".\n\n";
      exit(0);
   }

   if(! -r $acrmH1Filename)
   {
      print STDERR "\nUnable to read file \"$acrmH1Filename\".\n\n";
      exit(0);
   }

   if(! -r $acrmH2Filename)
   {
      print STDERR "\nUnable to read file \"$acrmH2Filename\".\n\n";
      exit(0);
   }

} # End of sub-routine "check_files".


sub read_and_store_in_hash
{
   # &read_and_store_in_hash($acrmL1Filename,
   #                         \%L1Hash);

   my ($filename,
       $hash) = @_;

   my $line = "";
   my $pdbCode = "";
   my $loop = "";
   my $acrmClass = "";

   # Open the file in read mode.

   open(FILE, $filename);

   # Parse the contents.

   while($line = <FILE>)
   {
      # Remove newlines.

      chomp($line);

      # If the line does not contain a PDB code, skip to the next line.

      if($line !~ /^[0-9]/)
      {
         next;
      }

      # Line is of the form:
      #
      # 1bm3,L1,11A

      ($pdbCode, $loop, $acrmClass) = split(/,/, $line);

      $pdbCode = uc($pdbCode);

      # Store the information in a hash.

      $$hash{$pdbCode} = $acrmClass;

   } # End of while loop.

   # Close the file handle.

   close(FILE);

} # End of sub-routine "read_and_store_in_hash".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 7)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. File containing supplementary material about canonical classes of Dunbrack paper (supplementalData_mod.csv)";
   print STDERR "\n2. File with list of Dunbrack classes of type III";
   print STDERR "\n3. File with list of PDB codes and ACRM L1-canonical classes";
   print STDERR "\n4. File with list of PDB codes and ACRM L2-canonical classes";
   print STDERR "\n5. File with list of PDB codes and ACRM L3-canonical classes";
   print STDERR "\n6. File with list of PDB codes and ACRM H1-canonical classes";
   print STDERR "\n7. File with list of PDB codes and ACRM H2-canonical classes";
   print STDERR "\n8. Output file name";
   print STDERR "\n\n";
   exit(0);
}

$dunbrackSupplementaryDataFilename = $ARGV[0];
$dunbrackTypeIIIFilename = $ARGV[1];
$acrmL1Filename = $ARGV[2];
$acrmL2Filename = $ARGV[3];
$acrmL3Filename = $ARGV[4];
$acrmH1Filename = $ARGV[5];
$acrmH2Filename = $ARGV[6];
$outputFilename = $ARGV[7];

# Check if the files can be read.

&check_files();

if(! -r $dunbrackSupplementaryDataFilename)
{
   print STDERR "\nUnable to open file \"$dunbrackSupplementaryDataFilename\" in read mode.\n\n";
   exit(0);
}

if(! -r $dunbrackTypeIIIFilename)
{
   print STDERR "\nUnable to open file \"$dunbrackTypeIIIFilename\" in read mode.\n\n";
   exit(0);
}

# Open the supplementary data file.

open(SUP, $dunbrackSupplementaryDataFilename);

# Read and parse through the contents.

while($line = <SUP>)
{
   # Remove newlines.

   chomp($line);

   # If the line contains a loop to start with, then parse it.

   if($line !~ /^[LH][1-3]/)
   {
      # Line is form:
      #
      # LoopID,ClusterID,Paper_Format,PDBid,ResStart,CoorStart,CoorEnd,seq,conf

      next;
   }

   # Line is of the form:
   #
   # L1-10,1,L1-10-1,1A6TA,24,24,33,SPSSSVSYMQ,BPABPBABBB

   ($loopInfo, $ignore,
    $dunbrackClassName, $pdbInfo,
    $ignore, $ignore,
    $ignore, $ignore, $ignore) = split(/,/, $line);

   # Extract the loop info. $loopInfo is of the form:
   #
   # L1-10.

   $loop = substr($loopInfo, 0, 2);

   # PDB Info is of the form "1A6TA" (i.e. PDB code and chain information).
   # Extract only the PDB code.

   $pdbCode = substr($pdbInfo, 0, 4);

   # Store the info in a hash.

   $dunbrackClassNameHash{$dunbrackClassName} .= "$pdbCode:";

} # End of while loop.

# Close the supplementary file handle.

close(SUP);

# Open the file with Type III Dunbrack classes.

open(DUN3, $dunbrackTypeIIIFilename);

# Parse the contents.

while($line = <DUN3>)
{
   # Remove newlines.

   chomp($line);

   # Skip the line if it does not correspond to a loop.

   if($line !~ /^[LH][1-3]/)
   {
      next;
   }

   # Parse the line.
   # Line is of the form:
   # L1-12-1,III

   ($dunbrackClassName, $ignore) = split(/,/, $line);

   # Store the Dunbrack classes in an array.

   push(@dunbrackTypeIIIClasses, $dunbrackClassName);

} # End of while loop.

# Close the type III classes file.

close(DUN3);

# Read and store the ACRM canonical classes for the PDBs for the
# loops L1, L2, L3, H1 and H2.

&read_and_store_in_hash($acrmL1Filename,
                        \%L1Hash);

&read_and_store_in_hash($acrmL2Filename,
                        \%L2Hash);

&read_and_store_in_hash($acrmL3Filename,
                        \%L3Hash);

&read_and_store_in_hash($acrmH1Filename,
                        \%H1Hash);

&read_and_store_in_hash($acrmH2Filename,
                        \%H2Hash);

# Open the output file in write mode.

open(WHD, ">$outputFilename");

# Write the header to the output file.

print WHD "PDB,LOOP,DUNBRACK_CLASS,ACRM_CLASS\n";

# Write a list of loops in specific PDBs that are of type III in the following format:
#
# PDB	LOOP	DUNBRACK_CLASS	ACRM_CLASS

foreach $dunbrackClassName (@dunbrackTypeIIIClasses)
{
   # Get the loop name for the dunbrack class.

   $loop = substr($dunbrackClassName, 0, 2);

   # Get the PDBs that belong to the Dunbrack class.

   @pdbsInDunbrackClass = split(/:/, $dunbrackClassNameHash{$dunbrackClassName});

   # For every PDB, print the appropriate data.

   foreach $pdbCode (@pdbsInDunbrackClass)
   {
      print WHD $pdbCode, ",", $loop, ",", $dunbrackClassName, ",";

      if($loop eq "L1")
      {
         print WHD $L1Hash{$pdbCode}, "\n";
      }
      elsif($loop eq "L2")
      {
         print WHD $L2Hash{$pdbCode}, "\n";
      }
      elsif($loop eq "L3")
      {
         print WHD $L3Hash{$pdbCode}, "\n";
      }
      elsif($loop eq "H1")
      {
         print WHD $H1Hash{$pdbCode}, "\n";
      }
      elsif($loop eq "H2")
      {
         print WHD $H2Hash{$pdbCode}, "\n";
      }

   } # End of inner foreach loop.

} # End of outer foreach loop.


# Close the output file handle.

close(WHD);

# End of program.
