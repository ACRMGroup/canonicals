#! /acrm/usr/local/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $originalFASTAFilename = "";
my $newFASTAFilename = "";

my $class1 = "";
my $class2 = "";

my %originalMAP = ();
my %newMAP = ();

my $pdbCode = "";
my $aminoAcids = "";

my $class2PDBCode = "";

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


sub read_FASTA_file
{
   # &read_FASTA_file($newFASTAFile,
   #                  \%newMAP,
   #                  $class1);

   my ($FASTAFilename,
       $hash,
       $classToInclude) = @_;

   my $line = "";
   my $pdbCode = "";
   my $flag = 0;

   # Open the FASTA file.

   open(HD, $FASTAFilename) || die "\nUnable to open file \"$FASTAFilename\".\n\n";

   # Read the contents into a hash.

   while($line = <HD>)
   {
      chomp($line);

      # If the line starts with >.

      if($line =~ /^>/)
      {
         # Line is of the form:
         #
         # >2a6d-7B-L34:L48:L52:L56:L58:

         if( ( ($classToInclude ne "") && ($line =~ /$classToInclude/) ) ||
               ($classToInclude eq "") )
         {
            $pdbCode = $line;
            $pdbCode =~s/\-.*//;
            $pdbCode =~s/^>//;

            $flag = 1;
         }
         else
         {
            $flag = 0;
         }

         next;
      }
      elsif($flag == 1)
      {
         if($line eq "")
         {
            print "\n$class2 has no SDRs. Exiting program.\n";
            close(HD);
            exit(0);
         }

         # Line contains an amino acid sequence.

         $$hash{$pdbCode} = $line;
      }

   } # End of while.

   # Close the input file handle.

   close(HD);

} # End of sub-routine "read_FASTA_file".


sub check_amino_acids_at_SDRs
{
   # if( &check_amino_acids_at_SDRs($aminoAcids,
   #                              \%originalMAP) )

   my ($aminoAcids,
       $hash) = @_;

   my $pdbCode = "";
   my $returnPDBCodeString = "";

   # Check if the amino acids for one of the PDBs
   # in the hash matches $aminoAcids.

   foreach $pdbCode (keys %$hash)
   {
      if($$hash{$pdbCode} eq $aminoAcids)
      {
         $returnPDBCodeString .= ":".$pdbCode;
      }
   }

   # Return $returnPDBCodeString.

   return $returnPDBCodeString;

} # End of sub-routine "check_amino_acid

# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 3)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. Original FASTA file with amino acids for SDRs of various canonical classes";
   print STDERR "\n2. FASTA file with amino acids (of PDBs belonging to one class) at SDRs of another class";
   print STDERR "\n3. Class 1 (i.e. Class to which PDBs belong)";
   print STDERR "\n4. Class 2 (i.e. Class defined by the SDRs)";
   print STDERR "\n\n";
   exit(0);
}

$originalFASTAFilename = $ARGV[0];
$newFASTAFilename = $ARGV[1];
$class1 = $ARGV[2];
$class2 = $ARGV[3];

# Check if the files are readable.

if(! -r $originalFASTAFilename)
{
   print STDERR "\nUnable to read file \"$originalFASTAFilename\".\n\n";
   exit(0);
}

if(! -r $newFASTAFilename)
{
   print STDERR "\nUnable to read file \"$newFASTAFilename\".\n\n";
   exit(0);
}

# Read the original FASTA file.

&read_FASTA_file($originalFASTAFilename,
                 \%originalMAP,
                 $class2);

# Read the new FASTA file.

&read_FASTA_file($newFASTAFilename,
                 \%newMAP,
                 "");

# For every PDB belonging to class1 (i.e. PDBs in the hash newMAP).

foreach $pdbCode (keys %newMAP)
{
   # Remove newlines if required.

   chomp($pdbCode);

   # Check if the amino acids of the PDB corresponding to
   # SDRs of canonical class2 match the amino acids of
   # a PDB that belongs to class2.

   $aminoAcids = $newMAP{$pdbCode};

   if($class2PDBCode = &check_amino_acids_at_SDRs($aminoAcids,
                                                  \%originalMAP) )
   {
      print $pdbCode, "\t",
            $class1, "\t",
            $class2PDBCode, "\t",
            $class2, "\t",
            $newMAP{$pdbCode}, "\n";
   }

} # End of foreach loop.

# End of program.
