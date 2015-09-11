#! /usr/bin/perl

use XML::DOM;
use strict 'vars';

# ---------- GLOBAL VARIABLES DECLARATION SECTION ----------

   my $inputFilename="";
   my $outputFilename="";
   my $line="";
   my $parser;
   my $doc;
   my $antibodyPDB;
   my $name;
   my $pdb;
   my $pdbID;
   my $frag;
   my $fragValue;

   my $resolution;
   my $resolutionValue = -1;

   my $rfactor;
   my $rfactorValue = "";

   my $structureMethod;
   my $structureMethodValue = "";

   my $command = "";

   my $resolution;
   my $resolutionValue = -1;


# ------ END OF GLOBAL VARIABLES DECLARATION SECTION -------


# --------------------------------

sub write_SQL
{
   my ($pdbID, $resolutionValue, $rfactorValue, $structureMethodValue) = @_;
   my $command = "";

   # Convert the resolution into a real number.
   #
   # E.g. Convert 1.90A into 1.90.

   $resolutionValue =~s/[A-Z]//g;

   # Convert the percentage figure for the R-factor into a
   # value between 0 and 1.
   #
   # E.g. Convert 22.10% into 0.221

   $rfactorValue =~s/[A-Z]//g;

   if($rfactorValue > 0)
   {
      $rfactorValue /= 100;
   }

   # Format the resolution and R-factor values for appropriate storage.

   $resolutionValue = sprintf("%3.2f", $resolutionValue);
   $rfactorValue = sprintf("%3.2f", $rfactorValue);

   # Compose the SQL command to insert into the table ABSTRUC_DATA.
   # Schema of the table:
   #
   # pdb_code | character(8)           |
   # resol    | real                   |
   # rfactor  | real                   |
   # method   | character varying(200) |

   # Convert the PDB code into lower case.

   $pdbID = lc($pdbID);

   $command = qq/
                 INSERT INTO ABSTRUC_DATA VALUES('$pdbID',
                                                 $resolutionValue,
                                                 $rfactorValue,
                                                 '$structureMethodValue');
                /;

   # Return the command to the calling function.

   return $command;

} # End of sub-routine 'write_SQL'.


# Main part of the program begins here.

if($#ARGV < 1)
{
   print "\nUsage: ./parse_xml_file.pl <Arguments>\n";
   print "\nArguments are:\n";
   print "\n1. XML file with the antibody structure information.";
   print "\n2. Output file for SQL commands.\n\n";
   exit(0);
}

$inputFilename = $ARGV[0];
$outputFilename = $ARGV[1];

# Open the output file in write mode.

open(WHD, ">$outputFilename");

$parser=XML::DOM::Parser->new();
$doc=$parser->parsefile($inputFilename);

foreach $antibodyPDB ( $doc->getElementsByTagName('antibody') )
{
   # Get the PDB ID.

   $pdbID = $antibodyPDB -> getAttribute('pdb');

   # Get the type of fragment.

   $frag = $antibodyPDB -> getElementsByTagName('frag');
   $fragValue = $frag -> item(0) -> getFirstChild -> getNodeValue;

   # Check type of fragment. If not Fab or Fv, skip to next PDB.

   if(! ( ($fragValue =~ /FV/i) || ($fragValue =~ /FAB/i) ) )
   {
      print STDERR "\nIgnoring $pdbID for being a $fragValue";
      next;
   }

   # Get the resolution.

   $resolution = $antibodyPDB -> getElementsByTagName('resolution');
   $resolutionValue = $resolution -> item(0) -> getFirstChild -> getNodeValue;

   # Get the R-factor.

   $rfactor = $antibodyPDB -> getElementsByTagName('rfac');
   $rfactorValue = $rfactor -> item(0) -> getFirstChild -> getNodeValue;

   # Get the method of solving the structure.

   $structureMethod = $antibodyPDB -> getElementsByTagName('method');
   $structureMethodValue = $structureMethod -> item(0) -> getFirstChild -> getNodeValue;

   # Write values into an SQL statement.

   $command = &write_SQL($pdbID,
                         $resolutionValue,
                         $rfactorValue,
                         $structureMethodValue);

   # Print the SQL command.

   print WHD $command;

} # End of sub-routine "foreach $antibodyPDB".

# Close the output file handle.

close(WHD);

# End of the program.
