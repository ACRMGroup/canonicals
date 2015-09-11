#! /usr/bin/perl

use strict 'vars';
use Env;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

# Set the control sequence for CTRL-C keystrokes.

$SIG{INT} = \&ctrlC;

my $HOME = $ENV{"HOME"};

my $loop = "";
my $loopDefinition = "";
my $case3Filename = "";
my $mappingFilename = "";
my $keyPositionsFilename = "";

my %pdb2can = ();
my %keyPos = ();
my $line = "";

my $queryPDBCode = "";
my $queryCanonicalClass = "";

my $bestMatchPDBCode = "";
my $bestMatchCanonicalClass = "";

my $ignore = "";
my $seqid = -1;
my $rms = -1;


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


sub read_mappings
{
   # &read_mappings($mappingFilename, \%pdb2can);

   my ($mappingsFilename, $pdb2can) = @_;

   my $line = "";
   my $pdbCode = "";
   my $loop = "";
   my $can = "";

   # Open the mappings file.

   open(HD, $mappingsFilename) || die "\nUnable to open file \"$mappingsFilename\".\n\n";

   # Parse the contents.

   while($line = <HD>)
   {
      # Remove newlines.

      chomp($line);

      # Line is of the form:
      #
      # 1bm3,L1,11A

      ($pdbCode, $loop, $can) = split(/,/, $line);

      # Store the canonical class in a hash.

      $$pdb2can{$pdbCode} = $can;

   } # End of while loop.

   # Close the file handle.

   close(HD);

} # End of sub-routine "read_mappings".


sub read_key_positions
{
   # &read_key_positions($keyPositionsFilename, \%keyPos);

   my ($keyPositionsFilename, $keyPos) = @_;

   my $line = "";
   my $ignore = "";
   my $can = "";

   # Open the key positions file.

   open(HD, $keyPositionsFilename) || die "\nUnable to open file \"$keyPositionsFilename\".\n\n";

   # Parse the contents.

   while($line = <HD>)
   {
      # Remove newlines.

      chomp($line);

      # Store the canonical class if it starts with a >.

      if($line =~ /^>/)
      {
         # Line is of the form:
         #
         # >L1:16B

         ($ignore, $can) = split(/:/, $line);
      }
      else
      {
         # Store the key positions.
         # Line is of the form:
         #
         # L2:L3:L4:L23:L28:L29:L30B:L30D:L32:L33:L35:L49:L51:L66:L69:L70:L71:L88:L90:L91:L92:L93:

         $$keyPos{$can} = $line;
      }

   } # End of while loop.

   # Close the file handle.

   close(HD);

} # End of sub-routine "read_key_positions".


sub get_seqid_over_keyres_and_loop
{
   # $seqid = &get_seqid_over_keyres_and_loop($queryPDBCode, $bestMatchPDBCode, $loopDefinition,
   #                                          $queryCanonicalClass, \%keyPos);

   my ($queryPDBCode, $bestMatchPDBCode, $loopDefinition,
       $queryCanonicalClass, $keyPos) = @_;

   my $queryLoopSequence = "";
   my $bestMatchLoopSequence = "";

   my $loopStartNumber = -1;
   my $loopEndNumber = -1;

   my @keyPositions = ();
   my $position = "";

   my $queryPDBFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/".$queryPDBCode.".pdb";
   my $queryNumberingFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_FILES/".$queryPDBCode.".out";

   my $bestMatchPDBFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/".$bestMatchPDBCode.".pdb";
   my $bestMatchNumberingFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_FILES/".$bestMatchPDBCode.".out";

   my $lightChainFlag = 0;
   my $heavyChainFlag = 0;

   my %queryHash = ();
   my %bestMatchHash = ();

   my @queryLoopSequenceResidues = ();
   my @bestMatchLoopSequenceResidues = ();

   my @querySequenceResidues = ();
   my @bestMatchSequenceResidues = ();

   my $sequenceIdentity = -1;

   my $positionNumber = -1;

   my ($loopStart, $loopEnd) = split(/\-/, $loopDefinition);

   # Get the starting and ending position numbers of the loop.

   $loopStartNumber = $loopStart;
   $loopStartNumber =~s/[A-Z]//g;

   $loopEndNumber = $loopEnd;
   $loopEndNumber =~s/[A-Z]//g;

   # Get the loop sequences for the query and the best match.

   $queryLoopSequence = `getpdb $loopStart $loopEnd $queryPDBFilename | pdb2pir -C | grep -v "^>" | grep -v "Seq" | sed 's/\*//'`;
   $bestMatchLoopSequence = `getpdb $loopStart $loopEnd $bestMatchPDBFilename | pdb2pir -C | grep -v "^>" | grep -v "Seq" | sed 's/\*//'`;

   chomp($queryLoopSequence, $bestMatchLoopSequence);

   # Set flag for light or heavy chain.

   if($loopDefinition =~ /^L/)
   {
      $lightChainFlag = 1;
      $heavyChainFlag = 0;
   }
   else
   {
      $lightChainFlag = 0;
      $heavyChainFlag = 1;
   }

   # Read the numbering files.

   &read_numbering($queryNumberingFilename, \%queryHash);
   &read_numbering($bestMatchNumberingFilename, \%bestMatchHash);

   # Get the residues at key positions.

   @keyPositions = split(/:/, $$keyPos{$queryCanonicalClass});

   foreach $position (@keyPositions)
   {
      # If the position is in the heavy chain and the loop is in the light
      # chain or vice versa, get the residue at the position.

      if( ( ($position =~ /^L/) && ($heavyChainFlag == 1) ) ||
            ($position =~ /^H/) && ($lightChainFlag == 1) )
      {
         push(@querySequenceResidues, $queryHash{$position});
         push(@bestMatchSequenceResidues, $bestMatchHash{$position});

         next;
      }

      # Check if $position is outside of the loop.

      $positionNumber = $position;
      $positionNumber =~s/[A-Z]//g;

      if( ($positionNumber < $loopStartNumber) ||
          ($positionNumber > $loopEndNumber) )
      {
         push(@querySequenceResidues, $queryHash{$position});
         push(@bestMatchSequenceResidues, $bestMatchHash{$position});

         next;
      }

   } # End of foreach $position.....

   # Add the loop sequence residues to the arrays.

   @queryLoopSequenceResidues = split(//, $queryLoopSequence);
   @bestMatchLoopSequenceResidues = split(//, $bestMatchLoopSequence);

   push(@querySequenceResidues, @queryLoopSequenceResidues);
   push(@bestMatchSequenceResidues, @bestMatchLoopSequenceResidues);

   # Check if the number of residues in the two arrays is equal. If not,
   # report an error.

   if($#querySequenceResidues != $#bestMatchSequenceResidues)
   {
      print STDERR "\nError in processing $queryPDBCode and $bestMatchPDBCode";
      return;
   }

   # Get the sequence identity.

   $sequenceIdentity = &get_sequence_identity(\@querySequenceResidues,
                                              \@bestMatchSequenceResidues);

} # End of "get_seqid_over_keyres_and_loop".



sub get_sequence_identity
{
   # $sequenceIdentity = &get_sequence_identity(\@querySequenceResidues,
   #                                            \@bestMatchSequenceResidues);

   my ($residues1, $residues2) = @_;
   my $sequenceIdentity = 0;

   my $i = 0;
   my $numberOfIdenticalResidues = 0;

   # Calculate the identity.

   for($i = 0 ; $i <= $#$residues1 ; $i++)
   {
      if( uc($$residues1[$i]) eq uc($$residues2[$i]) )
      {
         $numberOfIdenticalResidues++;
      }
   }

   # Calculate the sequence identity.

   $sequenceIdentity = sprintf("%2.1f", $numberOfIdenticalResidues/($#$residues1 + 1));

   # Return the sequence identity.

   return $sequenceIdentity;

} # End of sub-routine "get_sequence_identity".



sub get_rms
{
   # $rms = &get_rms($queryPDBCode, $bestMatchPDBCode, $loopDefinition);

   my ($pdbCode1, $pdbCode2, $loopDefinition) = @_;
   my $profitScriptFilename = "/tmp/".$pdbCode1."_".$pdbCode2."-".$loopDefinition.".prf";

   my ($loopStart, $loopEnd) = split(/\-/, $loopDefinition);

   my $referencePDBFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/".$pdbCode1.".pdb";
   my $mobilePDBFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/".$pdbCode2.".pdb";

   # Write the ProFit script.

   open(PRF, ">$profitScriptFilename");

   print PRF "REFERENCE $referencePDBFilename\n";
   print PRF "MOBILE $mobilePDBFilename\n";
   print PRF "ZONE $loopDefinition:$loopDefinition\n";
   print PRF "IGNOREMISSING\n";
   print PRF "FIT\n";

   close(PRF);

   # Invoke ProFit and get the RMS.

   $rms = `profit -f $profitScriptFilename | grep "RMS" | awk '{print \$2}' | sed 's/ //g'`;

   # Remove the ProFit script file.

   unlink($profitScriptFilename);

   # Remove newlines and return the RMS to the calling function.

   chomp($rms);

   return $rms;

} # End of sub-routine "get_rms".



sub read_numbering
{
   # &read_numbering($queryNumberingFilename, \%queryHash);

   my ($numberingFilename, $hash) = @_;

   my $line = "";
   my $position = "";
   my $residue = "";

   # Open the numbering file.

   open(NUM, $numberingFilename) || die "\nUnable to open file \"$numberingFilename\".\n\n";

   # Parse through the contents.

   while($line = <NUM>)
   {
      # Remove newlines.

      chomp($line);

      # Extract the required info.

      if($line =~ /^[LH][1-9]/)
      {
         ($position, $residue) = split(/ /, $line);

         $$hash{$position} = $residue;
      }

   } # End of while loop.

   # Close the file handle.

   close(NUM);

} # End of sub-routine "read_numbering".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

# Check for command line parameters.

if($#ARGV < 4)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. Loop (e.g. L1)";
   print STDERR "\n2. Loop definition (e.g. L24-L34)";
   print STDERR "\n3. Case 3 results file in the following format:\n";
   print STDERR "\n   >12e8,80.0\n";
   print STDERR "   2gsi,GFNIKDYYMY\n";
   print STDERR "\n4. File with mapping of PDB files to canonical classes";
   print STDERR "\n5. FASTA format file with list of key positions for the canonical class";
   print STDERR "\n\n";

   exit(0);
}

$loop = $ARGV[0];
$loopDefinition = $ARGV[1];
$case3Filename = $ARGV[2];
$mappingFilename = $ARGV[3];
$keyPositionsFilename = $ARGV[4];

# Read the mappings file.

&read_mappings($mappingFilename, \%pdb2can);

# Read the key positions.

&read_key_positions($keyPositionsFilename, \%keyPos);

# Print the header line.

print "Query,QCan,BestMatch,BCan,SeqID,RMS";

# Parse the file.

open(HD, $case3Filename) || die "\nUnable to open file \"$case3Filename\".\n\n";

while($line = <HD>)
{
   # Remove newlines.

   chomp($line);

   # If line starts with >, read the PDB code.

   if($line =~ /^>/)
   {
      # Line is of the form:
      #
      # >12e8,80.0

      ($queryPDBCode, $ignore) = split(/,/, $line);

      # Remove the > character.

      $queryPDBCode =~s/^>//g;

      # Get the canonical class for the PDB.

      $queryCanonicalClass = $pdb2can{$queryPDBCode};
   }
   elsif($line =~ /^[1-9]/)
   {
      # The line indicates a best-match in key residues with another pdb.
      #
      # Line is of the form:
      #
      # 2gsi,GFNIKDYYMY

      ($bestMatchPDBCode, $ignore) = split(/,/, $line);

      # Step 1: Get the sequence identity over key residues and the loop.

      $seqid = 0;
      $seqid = &get_seqid_over_keyres_and_loop($queryPDBCode, $bestMatchPDBCode, $loopDefinition,
                                               $queryCanonicalClass, \%keyPos);

      # Step 2: Fit the loops.

      $rms = &get_rms($queryPDBCode, $bestMatchPDBCode, $loopDefinition);

      # Get the canonical class for the best match.

      $bestMatchCanonicalClass = $pdb2can{$bestMatchPDBCode};

      # Write the information.

      print "\n$queryPDBCode,$queryCanonicalClass,$bestMatchPDBCode,$bestMatchCanonicalClass,$seqid,$rms";

   } # End of if-elsif.

} # End of while($line = <HD>)


# Close the file handle.

close(HD);


# End of program.
