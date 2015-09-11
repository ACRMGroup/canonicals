#! /usr/bin/perl

use strict 'vars';

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $pdbCodesFilename = "";
my $canonicalsDefinitionsFilename = "";
my $numberingDirectory = "";
my $numberingExtension = "";
my $outputFilename = "";

my %pdbCodesCanonicalClassesHash = ();
my %SDRsHash = ();
my $pdbCode = ""; 
my %numberingHash = ();
my $canonicalClass = "";
my @SDRPositions = ();
my $position = "";


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


#######################################################################
# sub read_PDB_codes_canonical_classes: This sub-routine maps canonical
# class labels to PDB code.
#######################################################################

sub read_PDB_codes_canonical_classes
{
   # &read_PDB_codes_canonical_classes($pdbCodesFilename,
   #                                   \%pdbCodesCanonicalClassesHash);

   my ($pdbCodesFilename,
       $pdbCodesCanonicalClassesHash) = @_;

   my $line = "";
   my $pdbCode = "";
   my $loop = "";
   my $canonicalClass = "";

   # Read the canonical classes.

   open(HD, $pdbCodesFilename) || die "\nUnable to open file \"$pdbCodesFilename\" in read mode.\n\n";

   # Parse through the contents.

   while($line = <HD>)
   {
      # Remove newlines.

      chomp($line);

      # If the line does not start with a number, go to the next line.

      if($line !~ /^[0-9]/)
      {
         next;
      }

      # Line is of the form:
      #
      # 1bm3,L1,11A

      ($pdbCode, $loop, $canonicalClass) = split(/,/, $line);

      # Assign the canonical class to a hash.

      $$pdbCodesCanonicalClassesHash{$pdbCode} = $canonicalClass;

   } # End of while($line = <HD>)

   # Close the file handle.

   close(HD);

} # End of sub-routine "read_PDB_codes_canonical_classes".


####################################################################################
# sub read_canonicals_definition_file: This sub-routine reads the canonical
# definitions file and creates a hash of SDRs and critical residues.
#
# For example, given a line such as the one below for canonical class 10E in CDR-H1:
# H27     YDF
# a hash of the following form is created:
#
# SDRsHash{10E:H27} = YDF
####################################################################################

sub read_canonicals_definition_file
{
   # &read_canonicals_definition_file($canonicalsDefitionsFilename,
   #                                  \%SDRsHash);

   my ($SDRsHashFilename,
       $SDRsHash) = @_;

   my $line = "";
   my $ignore = "";
   my $canonicalClass = "";
   my $label = "";
   my $residues = "";

   # Read the file.

   open(HD, $SDRsHashFilename) || die "\nUnable to open file \"$SDRsHashFilename\".\n\n";

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

         # Canonical class is of the form "?/16B". Remove the ?/ from the string.

         $canonicalClass =~s/.*\///;

         next;
      }

      # If the line contains a critical resiude.

      if($line =~ /^[LH][1-9]/)
      {
         # L4      M

         $line =~s/\t+/\t/g;
         $line =~s/ //g;
         ($label, $residues) = split(/\t/, $line);

         $$SDRsHash{$canonicalClass} .= "$label:";

         next;
      }

   } # End of while($line =....)

   # Close the file handle.

   close(HD);

} # End of sub-routine "read_canonical_definitions_file".



sub read_numbering
{
   # &read_numbering($pdbCode,
   #                 $numberingDirectory,
   #                 $numberingExtension,
   #                 \%numberingHash);

   my ($pdbCode,
       $numberingDirectory,
       $numberingExtension,
       $numberingHash) = @_;

   my $numberingFilename = $numberingDirectory."/".$pdbCode.".".$numberingExtension;
   my $line = "";

   my $label = "";
   my $residue = "";

   # Open the numbering file.

   open(HD, $numberingFilename) || die "\nUnable to open file \"$numberingFilename\".\n\n";

   # Read and parse the contents of the file.

   while($line = <HD>)
   {
      # Remove newlines.

      chomp($line);

      # Skip lines if not required.

      if($line !~ /^[LH][1-9]/)
      {
         next;
      }

      # Line is of the form:
      #
      # L1 D
      # Split the line and store the label and the residue in a hash
      # in the following way:
      #
      # numberingHash{L1} = D

      ($label, $residue) = split(/ /, $line);
      $$numberingHash{$label} = $residue;

   } # End of while($line = <HD>)

   # Close the file handle.

   close(HD);

} # End of sub-routine "read_numbering".



# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 4)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. File with list of PDB codes and their canonical classes for a specific loop ";
   print STDERR "\n2. Canonical definitions file for the loop";
   print STDERR "\n3. Directory with numbering files for every PDB";
   print STDERR "\n4. Extension of the numbering files (e.g.: out, num etc)";
   print STDERR "\n5. Output file";
   print STDERR "\n\n";
   exit(0);
}

$pdbCodesFilename = $ARGV[0];
$canonicalsDefinitionsFilename = $ARGV[1];
$numberingDirectory= $ARGV[2];
$numberingExtension= $ARGV[3];
$outputFilename = $ARGV[4];

# Read the PDB codes and their corresponding canonical classes.

&read_PDB_codes_canonical_classes($pdbCodesFilename,
                                  \%pdbCodesCanonicalClassesHash);

# Read the canonicals file and associate every canonical class with its list
# of SDR positions.

&read_canonicals_definition_file($canonicalsDefinitionsFilename,
                                 \%SDRsHash);

# Open the output file.

open(WHD, ">$outputFilename");

# For every structure and the SDRs associated with its canonical class, read the
# residues at the corresponding SDR positions.

foreach $pdbCode (keys %pdbCodesCanonicalClassesHash)
{
   # Read the numbering for the file.

   &read_numbering($pdbCode,
                   $numberingDirectory,
                   $numberingExtension,
                   \%numberingHash);

   # Get the canonical class.

   $canonicalClass = $pdbCodesCanonicalClassesHash{$pdbCode};

   # For every PDB, write the SDR positions and residues in FASTA format.

   print WHD ">$pdbCode-";
   print WHD $canonicalClass, "-";
   print WHD $SDRsHash{$canonicalClass}, "\n";

   @SDRPositions = split(/:/, $SDRsHash{$canonicalClass});

   foreach $position (@SDRPositions)
   {
      print WHD $numberingHash{$position};

      if($numberingHash{$position} eq "-")
      {
         print "PDB Code: $pdbCode, Canonical class: $canonicalClass, ",
               "Position: $position, Residue: ", $numberingHash{$position}, ", ",
               "Canonical class file: $canonicalsDefinitionsFilename\n";
      }
   }

   # Write a newline.

   print WHD "\n";

} # End of program.


# Close the output file handle.

close(WHD);

# End of program.
