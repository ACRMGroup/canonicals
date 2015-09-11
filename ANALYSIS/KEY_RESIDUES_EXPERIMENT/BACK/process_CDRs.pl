#! /usr/bin/perl

use strict 'vars';
use Env;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $HOME = $ENV{"HOME"};

my $temporaryProFitScriptFilename = "/tmp/$$.prf";

my $uniquePIRFilename = "";
my $cdr = "";
my $cdrRange = "";
my $mappingFilename = "";
my $outputFilename = "";

my @uniquePDBCodes = ();
my $loopStart = "";
my $loopEnd = "";

my $i = 0;
my $j = 0;

my %canonicalClassMapHash = ();

my $refPDBCode = "";
my $mobPDBCode = "";

my $refPDBFilename = "";
my $mobPDBFilename = "";

my $refCanonicalClass = "";
my $mobCanonicalClass = "";

my $refLoopLength = "";
my $mobLoopLength = "";

my $refLoopSequence = "";
my $mobLoopSequence = "";

my $sequenceIdentity = -1;
my $bestSequenceIdentity = -1;
my $bestMobPDBFilename = "";

my $bestMobPDBCode = "";
my $rms = -1;

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


sub read_mapping
{
   # &read_mapping($mappingFilename, \%canonicalClassMapHash);

   my ($mappingFilename, $canonicalClassMapHash) = @_;
   my $line = "";
   my $pdbCode = "";
   my $ignore = "";
   my $canonicalClass = "";

   # Open the map file.

   open(MAP, $mappingFilename) || die "\nUnable to open mapping file \"$mappingFilename\".\n\n";

   # Sift through the contents and store the required data in the hash.

   while($line = <MAP>)
   {
      chomp($line);

      # Skip the line if it does not have a mapping.
      #
      # PDB,LOOP,CAN_NEW

      if($line !~ /^[0-9][0-9A-Za-z][0-9A-Za-z][0-9A-Za-z]/)
      {
         next;
      }

      # Line is of the form:
      #
      # 1bm3,L1,11A

      ($pdbCode, $ignore, $canonicalClass) = split(/,/, $line);

      # Store the canonical class in the hash.

      $$canonicalClassMapHash{$pdbCode} = $canonicalClass;

   } # End of while loop.

   # Close the file handle.

   close(MAP);

} # End of sub-routine "read_mapping".


sub get_rms_over_loop
{
   # $rms = &get_rms_over_loop($refPDBFilename, $bestMobPDBFilename, $loopStart, $loopEnd);

   my ($refPDBFilename, $mobPDBFilename, $loopStart, $loopEnd) = @_;
   my $rms = -1;

   # Write a ProFit script.

   open(PRF, ">$temporaryProFitScriptFilename");

   # Write the ProFit commands.

   print PRF "REFERENCE $refPDBFilename\n";
   print PRF "MOBILE $mobPDBFilename\n";
   print PRF "ZONE $loopStart-$loopEnd:$loopStart-$loopEnd\n";
   print PRF "IGNOREMISSING\n";
   print PRF "FIT";

   # Close the file handle.

   close(PRF);

   # Run the ProFit command and get the RMS.

   $rms = `profit -f $temporaryProFitScriptFilename | grep RMS | awk '{print $2}' | sed 's/RMS://' | sed 's/ //g'`;

   chomp($rms);

   # Return the RMS to the calling function.

   return $rms;

} # End of sub-routine "get_rms_over_loop".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 4)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArugments are:\n";
   print STDERR "\n1. File with unique set of PIR sequences";
   print STDERR "\n2. CDR (e.g. L1)";
   print STDERR "\n3. CDR range (e.g. L24-L34)";
   print STDERR "\n4. File with mapping of PDB codes to canonical classes for the loop";
   print STDERR "\n5. Output filename";
   print STDERR "\n\n";
   exit(0);
}

$uniquePIRFilename = $ARGV[0];
$cdr = $ARGV[1];
$cdrRange = $ARGV[2];
$mappingFilename = $ARGV[3];
$outputFilename = $ARGV[4];

# Check if the input PIR file is readable.

if(! -r $uniquePIRFilename)
{
   print STDERR "\nUnable to read file \"$uniquePIRFilename\".\n\n";
   exit(0);
}

# Gather all the unique PDB codes (unique in sequence of VL + VH).

@uniquePDBCodes = `grep "^>" $uniquePIRFilename | sed 's/>P1;//'`;

chomp(@uniquePDBCodes); # Remove newline characters.

# Get the loop start and end.

if($cdrRange !~ /[LH][1-9+\-[LH][1-9]+/)
{
   print STDERR "\nCDR range \"$cdrRange\" is not in proper format.\nAborting program.\n\n";
   exit(0);
}

($loopStart, $loopEnd) = split(/\-/, $cdrRange);

# Read the file that maps PDB Codes to canonical classes.

&read_mapping($mappingFilename, \%canonicalClassMapHash);

# Open the output file in write mode.

open(WHD, ">$outputFilename");

# Print the header line.

print WHD "CDR,CDR_DEF,BEST_SEQ_ID,PDB,BEST_PDF,RMS\n";

# Go through every unique PDB.

for($i = 0 ; $i <= $#uniquePDBCodes ; $i++)
{
   # Get the required information about the CDR boundaries and key residues.

   $refPDBCode = $uniquePDBCodes[$i];
   $refPDBFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/".$refPDBCode.".pdb";
   $refCanonicalClass = $canonicalClassMapHash{$refPDBCode};

   $refLoopLength = $refCanonicalClass;
   $refLoopLength =~s/[A-Z]//g;

   $refLoopSequence = `getpdb $loopStart $loopEnd $refPDBFilename | pdb2pir -C -s | grep -v "^>" | grep -v "Sequence" | sed 's/\*//'`;

   chomp($refLoopSequence);

   # Reset the best sequence identity.

   $bestSequenceIdentity = -100000;
   $bestMobPDBCode = "";
   $rms = -1;

   for($j = $i + 1 ; $j <= $#uniquePDBCodes ; $j++)
   {
      # Case I: Compare the CDRs alone.

      $mobPDBCode = $uniquePDBCodes[$j];

      $mobPDBFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/".$mobPDBCode.".pdb";
      $mobCanonicalClass = $canonicalClassMapHash{$mobPDBCode};

      $mobLoopLength = $mobCanonicalClass;
      $mobLoopLength =~s/[A-Z]//g;

      $mobLoopSequence = `getpdb $loopStart $loopEnd $mobPDBFilename | pdb2pir -C -s | grep -v "^>" | grep -v "Sequence" | sed 's/\*//'`;

      chomp($mobLoopSequence);

      # If the length of the mobile PDB loop is different from that
      # of the reference, go to the next mobile PDB.

      if($refLoopLength != $mobLoopLength)
      {
         next;
      }

      # Calculate the sequence identity between the reference and mobile CDR.

      $sequenceIdentity = `perl get_sequence_identity.pl $refLoopSequence $mobLoopSequence`;

      chomp($sequenceIdentity);

      if($sequenceIdentity > $bestSequenceIdentity)
      {
         # Replace the best sequence identity and store the mobile PDB Code.

         $bestSequenceIdentity = $sequenceIdentity;
         $bestMobPDBCode = $mobPDBCode;
      }

   } # End of for($j....)

   # Calculate the RMS over the loop for the best mobile PDB over the reference PDB.
   #
   # Write the ProFit script to perform the calculation.

   $bestMobPDBFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/".$bestMobPDBCode.".pdb";

   $rms = &get_rms_over_loop($refPDBFilename, $bestMobPDBFilename, $loopStart, $loopEnd);

   print WHD "$cdr,$cdrRange,$bestSequenceIdentity,$refPDBCode,$bestMobPDBCode,$rms\n";

} # End of for($i.....)

# Close the output file handle.

close(WHD);

# End of program.
