#! /usr/bin/perl

use XML::DOM;
use DBI;
use strict 'vars';

# ---------- GLOBAL VARIABLES DECLARATION SECTION ----------

   my $dbName = "pdb_numbering";
   my $dbserver = "acrm8.biochem.ucl.ac.uk";
   my $dbport = 5432;
   my $userName = "abhi";
   my $password = "";
   my $command = "";
   my $sth;
   my $dbh;
   my $dataSource = "";

   my $inputFilename="";
   my $fvfabPDBCodesFilename;
   my $dimerPDBCodesFilename;
   my $line="";
   my $parser;
   my $doc;
   my $antibodyPDB;
   my $resolution;
   my $resolutionValue;
   my $rfactor;
   my $rfactorValue;
   my $method;
   my $methodValue;
   my $name;
   my $pdb;
   my $pdbID;
   my $frag;
   my $fragValue;

# ------ END OF GLOBAL VARIABLES DECLARATION SECTION -------

if($#ARGV < 2)
{
   print "\nUsage: $0 <Arguments>\n";
   print "\nArguments are:\n";
   print "\n1. XML file with antibody structure information";
   print "\n2. Output file: Fv or Fab PDB codes";
   print "\n3. Output file: Dimer (LC-dimers or HC-dimers) PDB codes";
   print "\n\n";
   exit(0);
}

$inputFilename = $ARGV[0];
$fvfabPDBCodesFilename = $ARGV[1];
$dimerPDBCodesFilename = $ARGV[2];

# Connect to the relational database.

$dataSource = "dbi:Pg:dbname=$dbName;host=$dbserver;port=$dbport";

$dbh = DBI->connect($dataSource, $userName, $password);

if(! $dbh)
{
   print "\nUnable to connect to database\n\n";
}
else
{
   print "\nConnected to database successfully\n\n";
}

# Open for XML parsing.

$parser=XML::DOM::Parser->new();
$doc=$parser->parsefile($inputFilename);

# Open the output files in write mode.

open(FV, ">$fvfabPDBCodesFilename");
open(DIMER, ">$dimerPDBCodesFilename");

# Process PDB entries from the XML file.

foreach $antibodyPDB ( $doc->getElementsByTagName('antibody') )
{
   $pdbID = $antibodyPDB -> getAttribute('pdb');
   $frag = $antibodyPDB -> getElementsByTagName('frag');
   $fragValue = $frag -> item(0)->getFirstChild->getNodeValue;

   # Convert the PDB code to lower case.

   $pdbID = lc($pdbID);

   # Get the resolution and R-factor.

   $resolution = $antibodyPDB -> getElementsByTagName('resolution');
   $resolutionValue = $resolution -> item(0) -> getFirstChild -> getNodeValue;

   $rfactor = $antibodyPDB -> getElementsByTagName('rfac');
   $rfactorValue = $rfactor -> item(0) -> getFirstChild -> getNodeValue;

   # Format resolution and the R-factor so that they are numbers.

   $resolutionValue =~s/[A-Z]//g; # Convert 2.3A to 2.3.
   $rfactorValue =~s/\%//g;       # Convert 21.30% into 21.30.

   if($rfactorValue > 1)
   {
      $rfactorValue /= 100; # Convert 21.30 into 0.213.
   }

   # Get the method for the structure.

   $method = $antibodyPDB -> getElementsByTagName('method');
   $methodValue = $method -> item(0) -> getFirstChild -> getNodeValue;

   # Check the fragment type.

   if( ( ($fragValue =~ /FV/i) ||
         ($fragValue =~ /FAB/i) ||
         ($fragValue =~ /LC\-dimer/i) ||
         ($fragValue =~ /HC\-dimer/i) ) &&
         ($methodValue =~ /Crystal/i) )
   {
      # Insert the data into the table "abstruc_data".
      #
      # pdb_code | character(8)           | 
      # resol    | real                   | 
      # rfactor  | real                   | 
      # method   | character varying(200) | 
      # abtype   | character varying(100) | 

      $command = qq/
                    INSERT INTO ABSTRUC_DATA(PDB_CODE,
                                             RESOL,
                                             RFACTOR,
                                             METHOD,
                                             ABTYPE)
                                      VALUES('$pdbID',
                                             $resolutionValue,
                                             $rfactorValue,
                                             '$methodValue',
                                             '$fragValue')
                   /;

      # Prepare the command.

      if(! ($sth = $dbh -> prepare($command) ) )
      {
         print STDERR "\nUnable to prepare command:\n\n$command\n\n";
      }

      # Execute the command.

      if(! ($sth -> execute) )
      {
         print STDERR "\nUnable to execute command:\n\n$command\n\n";
      }

      # Write the PDB code to the appropriate output file.

      if( ($fragValue =~ /dimer/i) &&
          ($resolutionValue < 4) ) # Ensure errors are eliminated.
      {
         print DIMER $pdbID, "\n";
      }
      elsif( ( ($fragValue =~ /Fv/i) ||
               ($fragValue =~ /Fab/i) ) && 
             ($resolutionValue < 4) )
      {
         print FV $pdbID, "\n";
      }

   } # End of if loop.

} # End of "foreach $antibodyPDB ( $doc->getElementsByTagName('antibody') )".


# Close the output file handles.

close(FV);
close(DIMER);

# Disconnect the database handle.

$dbh -> disconnect();

# End of program.
