#! /usr/bin/perl -w

use strict;
use DBI;

# program to manually add all original cluster names

# ---------- DECLARATION OF GLOBAL VARIABLES ----------

my $clusters = "Taken_Cluster_Names.txt";

# ---------- END OF GLOBAL VARIABLES DECLARATION SECTION ----------

# ---------- SUB ROUTINES ----------  

# ---------- END OF SUB ROUTINES ----------

unless (open CLUSTERS, '+>'.$clusters) 
{

die "\nCannot open folder $clusters!\n";
exit;

}
print CLUSTERS "7A\n"; 
print CLUSTERS "7B\n";
print CLUSTERS "8A\n";
print CLUSTERS "8B\n"; 
print CLUSTERS "9A\n";
print CLUSTERS "9B\n";
print CLUSTERS "9C\n"; 
print CLUSTERS "9D\n";
print CLUSTERS "9E\n";
print CLUSTERS "9F\n"; 
print CLUSTERS "10A\n";
print CLUSTERS "10B\n";
print CLUSTERS "10C\n";
print CLUSTERS "10D\n";
print CLUSTERS "10E\n"; 
print CLUSTERS "10F\n";
print CLUSTERS "11A\n"; 
print CLUSTERS "11B\n"; 
print CLUSTERS "12A\n"; 
print CLUSTERS "12B\n"; 
print CLUSTERS "13A\n"; 
print CLUSTERS "14A\n"; 
print CLUSTERS "14B\n"; 
print CLUSTERS "15A\n";  
print CLUSTERS "15B\n";
print CLUSTERS "16A\n";
print CLUSTERS "16B\n";
print CLUSTERS "16C\n"; 
print CLUSTERS "17A\n"; 

close CLUSTERS;