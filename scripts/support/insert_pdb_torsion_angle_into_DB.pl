#! /usr/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

   my $inputFilename = "";
   my $tableName = "";

   my $dbName = "pdb_numbering";
   my $dbserver = "acrm8.biochem.ucl.ac.uk";
   my $dbport = 5432;
   my $userName = "abhi";
   my $password = "";
   my $command = "";
   my $dbh;
   my $dataSource = "";

   my $rowNumber = 1;
   my $pdbCode = "";
   my $line = "";
   my @con = ();
   my $numberOfRows = 0;
   my $rowNumber = 0;
   my $torsionAngle = 0;

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----



# Main code of the program starts here.

if($#ARGV < 1)
{
   print "\nUsage: $0 <Arguments>\n";
   print "\nArguments are:\n";
   print "\n1. Name of file with torsion angles";
   print "\n2. Name of table";
   print "\n\n";
   exit(0);
}

$inputFilename = $ARGV[0];
$tableName = $ARGV[1];

# Connect to the database and report error attempt to connect fails.

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

# Open the input file.

open(hd, $inputFilename) || die "\nFile \"$inputFilename\" does not exist.\n\n";
@con = <hd>;
close(hd);

# Find the number of rows that are already in the table.

$command = "select count(*) from $tableName";

$numberOfRows = $dbh -> selectrow_array($command);

$rowNumber = $numberOfRows + 1;

# Commit the numbering into the database.
#
# Scheme of the table.
#
# row_number    | integer          |
# pdb_code      | character(8)     |
# torsion_angle | double precision |

foreach $line (@con)
{
   chomp($line);

   if($line =~ /PDB Code/)
   {
      $pdbCode = $line;
      $pdbCode =~s/PDB Code: //;
   }
   elsif($line =~ /Torsion angle:/)
   {
      $torsionAngle = $line;
      $torsionAngle =~s/Torsion angle: -//;

      $command = "INSERT INTO $tableName VALUES($rowNumber, '$pdbCode', $torsionAngle);";

      if(! $dbh -> do($command) )
      {
         print "\nThe following command did not work.\n\n$command\n\n";
         <STDIN>;
      }

      $rowNumber++;
   }
}

# End of program.
