#! /usr/bin/perl

use strict 'vars';
use DBI;

# ----------- DECLARATION OF GLOBAL VARIABLES ----------

my $dbName = "pdb_numbering";
my $userName = "abhi";
my $hostname = "acrm8";
my $dbport = 5432;

my $password = "";
my $command = "";
my $dbh;
my $sth;
my $dataSource = "";

my $pdbCodesFilename = "";
my $oldClanFilename = "";
my $newClanFilename = "";
my $loop = "";
my $outputFilename = "";

my %oldCan = ();
my %newCan = ();
my %antibodyTypes = ();

# Set the control sequence for CTRL-C keystrokes.

$SIG{INT} = \&ctrlC;

# ---- END OF GLOBAL VARIABLES DECLARATION SECTION -----


# --------------- SUB - ROUTINES SECTION ---------------

sub connect_to_db
{
   # if(! $dbh = &connect_to_db($dataSource, $userName, $password) )

   my ($dataSource, $userName, $password) = @_;

   # Connect to the database.

   $dataSource = "dbi:Pg:dbname=$dbName;host=$hostname;port=$dbport";
   $dbh = DBI->connect($dataSource, $userName, $password);

   # Return the database handle.

   return $dbh;

} # End of sub-routine "connect_to_db".


sub ctrlC
{
   # Disconnect the database handle.

   $dbh -> disconnect();

   # Exit from the program.

   exit(0);

} # End of sub-routine "ctrlC".

###########################################################################
# sub gather_PDB_codes_to_cluster_number_mapping: Sub-routine that maps PDB
# codes to the cluster number.
###########################################################################

sub gather_PDB_codes_to_cluster_number_mapping
{
   # &gather_PDB_codes_to_cluster_number_mapping(\%pdb2Cluster);

   my $pdb2Cluster = $_[0];

   my $line = "";
   my $clusterNumber = -1;
   my @parts = ();
   my $rest = "";
   my $pdbCode = "";
   my $i = 0;

   # Go to the section "BEGIN ASSIGNMENTS".

   while($line = <CLAN>)
   {
      # Exit the loop when the line BEGIN ASSIGNMENTS is encountered.

      if($line =~ /BEGIN ASSIGN/)
      {
         last;
      }

   } # End of while loop.

   # Gather the mapping of PDB codes to their cluster number.

   while($line = <CLAN>)
   {
      # Remove newline characters.

      chomp($line);

      # Exit from the loop when the end of the assignments
      # section is encountered.

      if($line =~ /END ASSIGNMENT/)
      {
         last;
      }

      # Skip a line that does not contain an assignment.

      if($line !~ /^\s+[0-9]/)
      {
         next;
      }

      # Line is of the form:
      #
      #   1 /home/bsm2/abhi/CANONICALS/NEW_DATASET/NUMBERED_Fv_PDB//1cfq.pdb-L24-L34

      $line =~s/^\s+//g;
      ($clusterNumber, $rest) = split(/ /, $line);
      @parts = split(/\//, $rest);
      $pdbCode = $parts[$#parts]; # $pdbCode is like "1cfq.pdb-L24-L34" or "p1acy.ab-L24-L34".

      @parts = split(//, $pdbCode);

      $i = 0;

      while($parts[$i] !~ /[0-9]/)
      {
         $i++;
      }

      $pdbCode = "";
      $pdbCode = $parts[$i].$parts[$i+1].$parts[$i+2].$parts[$i+3];

      $$pdb2Cluster{$pdbCode} = $clusterNumber;

   } # End of while($line = <CLAN>).

} # End of sub-routine "gather_PDB_codes_to_cluster_number_mapping".


#############################################################################
# sub gather_cluster_number_to_canonical_class_mapping: Sub-routine that maps
# cluster number to canonical class.
#############################################################################

sub gather_cluster_number_to_canonical_class_mapping
{
   # &gather_cluster_number_to_canonical_class_mapping(\%cluster2Class);

   my $cluster2Class = $_[0];

   my $line = "";
   my $clusterNumber = -1;
   my $canonicalClass = "";

   # Go to the section "BEGIN LABELS".

   while($line = <CLAN>)
   {
      if( ($line =~ /BEGIN_LABELS/) || ($line =~ /BEGIN LABELS/) )
      {
         last;
      }

   } # End of while loop.

   # Gather all the labels.

   while($line = <CLAN>)
   {
      # Skip the line if it does not start with a number.

      if($line !~ /^[0-9]/)
      {
         next;
      }

      # Line is of the form:
      #
      # 24      16B

      $line =~s/\s+/ /g;

      ($clusterNumber, $canonicalClass) = split(/ /, $line);

      $$cluster2Class{$clusterNumber} = $canonicalClass;

   } # End of while loop.

} # End of sub-routine "gather_cluster_number_to_canonical_class_mapping".




#########################################################################
# sub get_canonical_class_assignments: Sub-routine that maps PDB codes to
# their canonical classes.
#########################################################################

sub get_canonical_class_assignments
{
   # &get_canonical_class_assignments($oldClanFilename,
   #                                  \%oldCan);

   my ($clanFilename,
       $canonicalClasses) = @_;

   my %pdb2Cluster = ();
   my %cluster2Class = ();
   my $pdbCode = "";
   my $clusterNumber = -1;

   # Open the CLAN file in read mode.

   open(CLAN, $clanFilename) || return 0;

   # Gather the mapping of PDB codes to cluster number.

   &gather_PDB_codes_to_cluster_number_mapping(\%pdb2Cluster);

   # Gather the mapping of cluster numbers to canonical class names.

   &gather_cluster_number_to_canonical_class_mapping(\%cluster2Class);

   # Map the PDB codes to their canonical class.

   foreach $pdbCode (keys %pdb2Cluster)
   {
      $clusterNumber = $pdb2Cluster{$pdbCode};
      $$canonicalClasses{$pdbCode} =  $cluster2Class{$clusterNumber};

   } # End of foreach loop.

   # Close the file handle.

   close(CLAN);

   # Return 1 to the calling function to indicate successful processing.

   return 1;

} # End of sub-routine "get_old_canonical_class_assignments".


sub get_antibody_type_data
{
   # &get_antibody_type_data($sth, $dbh,
   #                         $pdbCodesFilename,
   #                         \%antibodyTypes);

   my ($sth, $dbh,
       $pdbCodesFilename,
       $antibodyTypes) = @_;

   my $pdbCode = "";
   my $command = "";
   my @pdbCodes = ();
   my $abType = "";

   # Open the PDB codes file.

   open(PDB, $pdbCodesFilename) || return 0;
   @pdbCodes = <PDB>;
   close(PDB);

   # Extract the type of antibody for every PDB.

   foreach $pdbCode (@pdbCodes)
   {
      # Remove newlines.

      chomp($pdbCode);

      # SQL command.

      $command = qq/
                    SELECT ABTYPE
                      FROM ABSTRUC_DATA
                     WHERE PDB_CODE = '$pdbCode'
                   /;

      # Prepare the command.

      $sth = $dbh -> prepare($command);

      # Execute the command.

      if(! ($sth -> execute) )
      {
         print STDERR "\nUnable to execute statement:\n\n$command\n\n";
         return -1;
      }

      # Gather the output.

      while($abType = $sth -> fetchrow_array)
      {
         # Remove spaces in the antibody type.

         $abType =~s/ //g;

         # Assign to the hash.

         $$antibodyTypes{$pdbCode} = $abType;  

      } # End of while($abType = $sth -> fetchrow_array)

   } # End of foreach $pdbCode (@pdbCodes)

} # End of sub-routine "get_antibody_type_data".


sub write_to_output_file
{
   # &write_to_output_file($outputFilename,
   #                       $loop,
   #                       \%oldCan,
   #                       \%newCan,
   #                       \%antibodyTypes);

   my ($outputFilename,
       $loop,
       $oldCan,
       $newCan,
       $antibodyTypes) = @_;

   my $pdbCode = "";

   # Open the output file in write mode.

   open(WHD, ">$outputFilename");

   # Write the header line.

   print WHD "PDB,LOOP,CAN_OLD,CAN_NEW,TYPE\n";

   # For every PDB code, write the old and new canonical class
   # and also the type of antibody.

   foreach $pdbCode (keys %$newCan)
   {
      print WHD $pdbCode, ",",
                $loop, ",",
                $$oldCan{$pdbCode}, ",",
                $$newCan{$pdbCode}, ",",
                $$antibodyTypes{$pdbCode}, "\n";
   }

   # Close the file handle.

   close(WHD);

} # End of sub-routine "write_to_output_file".


# ----------- END OF SUB - ROUTINES SECTION ------------


# Main code of the program starts here.

if($#ARGV < 4)
{
   print STDERR "\nUsage: $0 <Arguments>\n";
   print STDERR "\nArguments are:\n";
   print STDERR "\n1. File with current list of PDB codes";
   print STDERR "\n2. Old CLAN file";
   print STDERR "\n3. New CLAN file";
   print STDERR "\n4. Loop";
   print STDERR "\n5. Output file";
   print STDERR "\n\n";
   exit(0);
}

$pdbCodesFilename = $ARGV[0];
$oldClanFilename = $ARGV[1];
$newClanFilename = $ARGV[2];
$loop = $ARGV[3];
$outputFilename = $ARGV[4];

# Connect to the database and report error attempt to connect fails.

if(! ($dbh = &connect_to_db($dataSource, $userName, $password) ) )
{
   print STDERR "\nUnable to connect to database\n\n";
   exit(0);
}

# Get the old canonical class assignments for the PDBs.

if(! &get_canonical_class_assignments($oldClanFilename,
                                      \%oldCan) )
{
   print STDERR "\nUnable to open file \"$oldClanFilename\".\n\n";
   $dbh -> disconnect();
   exit(0);
}

# Get the new canonical class assignments for the PDBs.

if(! &get_canonical_class_assignments($newClanFilename,
                                      \%newCan) )
{
   print STDERR "\nUnable to open file \"$newClanFilename\".\n\n";
   $dbh -> disconnect();
   exit(0);
}

# Get data about type of antibody (Fab, Fv, scFv, etc).

&get_antibody_type_data($sth, $dbh,
                        $pdbCodesFilename,
                        \%antibodyTypes);

# Write the old and new canonical class assignments to the output file.

my $pdbCode = "3hfm";

if(! &write_to_output_file($outputFilename,
                           $loop,
                           \%oldCan,
                           \%newCan,
                           \%antibodyTypes) )
{
   print STDERR "\nUnable to open file \"$outputFilename\" in write mode.\n\n";
   $dbh -> disconnect();
   exit(0);
}

# Disconnect the database handle.

$dbh -> disconnect();

# End of program.
