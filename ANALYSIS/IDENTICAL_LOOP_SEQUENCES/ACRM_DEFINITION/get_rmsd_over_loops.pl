#! /acrm/usr/local/bin/perl

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $dbName = "kabat_seq_numbering";
my $userName = "abhi";
my $hostname = "acrm8";
my $dbport = 5432;

my $password = "";
my $command = "";
my $dbh;
my $dataSource = "";

# ------ END OF GLOBAL VARIABLES DECLARATION SECTON ----

if($#ARGV < 3)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments:\n";
   print STDERR "\n1. Loop name (Eg. L1)";
   print STDERR "\n2. Loop definition (E.g. L24-L34 for CDR-L1)";
   print STDERR "\n3. File with comparison of loop sequences";
   print STDERR "\n4. Output file";
   print STDERR "\n\n";
   exit(0);
}

$loopName = $ARGV[0];
$loopDefinition = $ARGV[1];
$comparisonsFilename = $ARGV[2];
$outputFilename = $ARGV[3];

$ProFitScriptFilename = "/tmp/PROFIT/".$$.".cmd";

open(HD, $comparisonsFilename) || die "\nUnable to open file \"$comparisonsFilename\" in read mode.\n\n";
open(WHD, ">$outputFilename") || die "\nUnable to open file \"$outputFilename\" in write mode.\n\n";

# Write the output file handle.

print WHD "LOOP\t\tPDB1\t\tCLASS1\t\tPDB2\t\tCLASS2\t\tLOOPDEF\t\tCA-RMS\n";

while($line = <HD>)
{
   # Remove newlines.

   chomp($line);

   # If the line contains PDBs, then they need to be fitted and compared over the loops.

   if($line =~ /PDB/)
   {
      # PDB Codes: 1gig, 1nc2

      ($ignore, $important) = split(/: /, $line);

      # Split the PDB codes.

      ($pdbCode1, $pdbCode2) = split(/, /, $important);

      # Set the PDB filenames.

      $pdbFilename1 = "~/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/".$pdbCode1.".pdb";
      $pdbFilename2 = "~/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB/".$pdbCode2.".pdb";
   }
   elsif($line =~ /Canonical/)
   {
      # Read the canonical classes.
      # Line is of the form:
      #
      # Canonical classes: 11A, 11A

      $line =~s/Canonical classes: //;
      ($class1, $class2) = split(/, /, $line);

      # Open the ProFit script file in write mode.

      open(PRFSCR, ">$ProFitScriptFilename") || die "\nUnable to open file \"$ProFitScriptFilename\" in write mode.\n\n";

      # Get the chains appropriately.

      if($loopDefinition =~ /^L/)
      {
          $pdbChainFilename1 = "/tmp/PROFIT/".$pdbCode1."_L.pdb";
          $pdbChainFilename2 = "/tmp/PROFIT/".$pdbCode2."_L.pdb";

         `getchain L $pdbFilename1 $pdbChainFilename1 ; getchain L $pdbFilename2 $pdbChainFilename2`;

          print PRFSCR <<EOT

         reference $pdbChainFilename1
         mobile $pdbChainFilename2
         zone $loopDefinition
         atoms ca
         ignoremissing
         fit

EOT
      }
      else
      {
          $pdbChainFilename1 = "/tmp/PROFIT/".$pdbCode1."_H.pdb";
          $pdbChainFilename2 = "/tmp/PROFIT/".$pdbCode2."_H.pdb";

         `getchain H $pdbFilename1 $pdbChainFilename1 ; getchain H $pdbFilename2 $pdbChainFilename2`;

          print PRFSCR <<EOT

         reference $pdbChainFilename1
         mobile $pdbChainFilename2
         zone $loopDefinition
         atoms ca
         ignoremissing
         fit

EOT
      }

      # Close the output file handle.

      close(PRFSCR);

      # Run the script.

      $rms = -1;
      $rms = `profit -f $ProFitScriptFilename | grep RMS | awk -F': ' '{print \$2}'`;

      print WHD $loopName, "\t\t",
                $pdbCode1, "\t\t",
                $class1, "\t\t",
                $pdbCode2, "\t\t",
                $class2, "\t\t",
                $loopDefinition, "\t\t",
                $rms;

      # Print the content.

   } # End of if loop.

} # End of while loop.

# Close the file handle.

close(HD);
close(WHD);

# End of program.
