#! /acrm/usr/local/bin/perl

my $HOME = $ENV{"HOME"};

if($#ARGV < 1)
{
   print STDERR "\nUsage: $0 <File with list of PDB codes> <File with list of critical positions>";
   print STDERR "\n\n";
   exit(0);
}

$pdbCodesFilename = $ARGV[0];
$criticalPositionsFilename = $ARGV[1];

# Sub-routine to get the critical residues.

sub get_critical_residues
{
   my ($numberingFilename, $criticalPositions) = @_;

   my $criticalPosition = "";
   my $criticalResidues = "";
   my @parts = ();
   my $searchString = "";

   # Open the numbering file.

   open(NUM, $numberingFilename) || print STDERR "\nUnable to open file \"$numberingFilename\".\n";
   @con = <NUM>;
   close(NUM);

   # Get the critical residues.

   foreach $criticalPosition (@$criticalPositions)
   {
      $searchString = "$criticalPosition ";

      @parts = grep(/$searchString/, @con);
      chomp(@parts);

      if($#parts == -1)
      {
         next;
      }

      ($criticalPosition, $criticalResidue) = split(/ /, $parts[0]);

      $criticalResidues .= $criticalResidue;
   }

   # Return the critical residues.

   return $criticalResidues;

} # End of sub-routine "get_critical_residues".



# Open the pdb codes file and the file with critical positions.

open(HD, $pdbCodesFilename) || die "\nUnable to open file \"$pdbCodesFilename\".\n\n";

open(CR, $criticalPositionsFilename) || die "\nUnable to open file \"$criticalPositionsFilename\".\n\n";
@criticalPositions = <CR>;
close(CR);

chomp(@criticalPositions);

# Get the residues in the critical positions.

while($pdbCode = <HD>)
{
   # Remove newlines.

   chomp($pdbCode);

   # Set the numbering filename.

   $numberingFilename = "$HOME/CANONICALS/NEW_DATASET/NUMBERED_FILES/$pdbCode.out";

   $criticalResidues = &get_critical_residues($numberingFilename, \@criticalPositions);

   print ">$pdbCode\n";
   print $criticalResidues, "\n";
}

# Close the input file handle.

close(HD);

# End of program.
