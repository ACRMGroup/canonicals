#!/usr/bin/perl 

use strict;

# a program that takes a file containing old cluster assignments for PDBs, 
# a results file containing with new cluster assignments and PDB codes, and a file containing 
# all of the take cluster names to return updated cluster names for all PDB codes. 

# ---------- DECLARATION OF VARIABLES ----------

my ($oldClusterAssignmentsFile, $newClusterAssignmentsFile, 
    $takenClusterNamesFile) = @ARGV;
                                # 
my @clusterSuffixes = ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
                       "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
                       "Aa", "Ba", "Ca", "Da", "Ea", "Fa", "Ga", "Ha", "Ia", "Ja", "Ka", "La", "Ma", 
                       "Na", "Oa", "Pa", "Qa", "Ra", "Sa", "Ta", "Ua", "Va", "Wa", "Xa", "Ya", "Za",
                       "Ab", "Bb", "Cb", "Db", "Eb", "Fb", "Gb", "Hb", "Ib", "Jb", "Kb", "Lb", "Mb", 
                       "Nb", "Ob", "Pb", "Qb", "Rb", "Sb", "Tb", "Ub", "Vb", "Wb", "Xb", "Yb", "Zb", 
                       "Ac", "Bc", "Cc", "Dc", "Ec", "Fc", "Gc", "Hc", "Ic", "Jc", "Kc", "Lc", "Mc", 
                       "Nc", "Oc", "Pc", "Qc", "Rc", "Sc", "Tc", "Uc", "Vc", "Wc", "Xc", "Yc", "Zc",
                       "Ad", "Bd", "Cd", "Dd", "Ed", "Fd", "Gd", "Hd", "Id", "Jd", "Kd", "Ld", "Md", 
                       "Nd", "Od", "Pd", "Qd", "Rd", "Sd", "Td", "Ud", "Vd", "Wd", "Xd", "Yd", "Zd",);

                                # 
# ---------- END OF VARIABLE DECLARATION SECTION ----------
                                # 
# ---------- MAIN CODE ----------

my ($aOldPDBs, $aOldClasses, $aOldClusts) = GetOldFileData($oldClusterAssignmentsFile);
                                # 
my ($hNewClusterData) = GetNewFileData($newClusterAssignmentsFile);
                                # 
my ($hOldClusterData) = MakeHash($aOldClusts, $aOldPDBs);


my ($hFinalData, $aTakenClusterNames) = FindClusterLabel($hNewClusterData, 
                                                         $hOldClusterData, 
                                                         $newClusterAssignmentsFile, 
                                                         $takenClusterNamesFile, 
                                                         \@clusterSuffixes);
                                                                                                                
#gives all array elements a uniform structure within the array
my @editedTakenClusterNames = grep(s/\s*$//g, @$aTakenClusterNames);

CommittNames($takenClusterNamesFile, \@editedTakenClusterNames);
                                                        
Show($hFinalData);

# ---------- END OF MAIN CODE ----------
        
# ---------- SUB ROUTINES ---------- 

# a subroutine to open an old cluster assignment file and extract existing class, pdb, 
# and cluster assignment for antibodies
# and returns each piece of data to a separate array by reference. 

sub GetOldFileData
{
    my ($fileName) = @_;
        
    my @pdbs = ();
    my @classes = ();
    my @clusters = ();
        
    if(open(my $file, '<', $fileName))
    {       
        while(<$file>)
        {
            chomp;
            my @fileComponents = split (/ |\//);
            
            push @pdbs, $fileComponents[1];
            push @classes, $fileComponents[2];
            push @clusters, $fileComponents[3];
        }
        close $file;
    }
    else
    {
        printf STDERR "Can't read file $fileName yaya\n!!";
        
    }
        
    return (\@pdbs, \@classes, \@clusters); 
}

# a subroutine to open a file containing new cluster assignments and extract class, pdb, 
# and cluster assignment for antibodies
# and returns each piece of data to a separate array by reference.
sub GetNewFileData 
{
    my ($fileName) = @_;
        
    my %newClusterAssignments;
    my @interestingLines = ();
    my $inInteresting = 0; #flag for when in interesting part of file
    my $beginning = 'BEGIN ASSIGNMENTS';
    my $ending = 'END ASSIGNMENTS';
    
    if(open(my $file, '<', $fileName))
    {
        while( my $line = <$file>)
        {
            chomp;
                        
            if ($line =~ /$ending/)
            {
                $inInteresting = 0;
            }
            elsif ($inInteresting)
            {
                push @interestingLines, $line;
            }
            elsif ($line =~ /$beginning/)
            {
                $inInteresting = 1;
            }               
        }
        close $file;
    }
    else
    {
        printf STDERR "Can't read file $fileName!!";
    }
        
    #for each extracted line containing new assignment, sets PDB code as key and simplified 
    #cluster label (1,2,3) as value.
    foreach my $interestingLine (@interestingLines)
    {
        my @lineComponent = split (/[.\s\/]+/, $interestingLine);
        $newClusterAssignments{lc($lineComponent[3])} =  $lineComponent[1];
    }
    return (\%newClusterAssignments);
}

# subroutine that takes old clusters labels, original pdb codes and returns a hash
# originally I split the data from the old file b/c I wanted to have access the clan name 
# and old class name but I didn't have time to write code that would incorporate classes of
# new loops
sub MakeHash
{
    my($aClusters, $aPDBs) = @_;
    my %data;
        
    for (my $i=0; $i<scalar(@$aClusters); $i++)
    {
        $data{lc(@$aPDBs[$i])} =  @$aClusters[$i];      
    }
    return (\%data);
}

# Takes a (numerical) cluster number and a hash of (numerical) cluster
# assigments and returns all those PDB codes in the specified cluster.
sub GetLoopsInCluster
{
    my ($clusterNum, $hNewClusterAssignments) = @_;
    my @loops = ();
    foreach my $key (keys %$hNewClusterAssignments)
    {
        if($$hNewClusterAssignments{$key} == $clusterNum)
        {
            push (@loops, $key);
        }
    }
    return(\@loops);
}

# Takes a reference to an array of loop labels (PDB codes) and the hash of 
# old assignments. Finds the most common assignment for this set of loops.

sub FindClusterLabel
{
    my ($hNewClusterAssignments, 
        $hOldClusterAssignments, 
        $clanResultsFile, 
        $aAllClusterNames, 
        $aSuffixes) = @_;
    
    my $hfinalData;
    my $bestClusterLabel = '';  # The label we will assign for this cluster     
    my $found = 0;              # Flag to say whether we made an assignment
    my $clusterNum = 0;
        
    #creates array that will store all old and new cluster labels that have already been used 
    my @EditedClusterNames = ();
        
    #imports all old cluster labels that have been used
    open(FILEDATA, "< $aAllClusterNames") or die "Can't open $aAllClusterNames";
    my @EditedClusterNames; 
    while (<FILEDATA>)
    {
        push (@EditedClusterNames, $_);
    }
    close FILEDATA; 
        
    #returns an array of all pdb codes within the new, simple cluster names
    my($aArrayOfLoops) = GetArrayOfLoopsInNewClusterAssignments($hNewClusterAssignments, $clanResultsFile); 
        
    # Count old class assignments for each loop     
    foreach my $clusternumber (@$aArrayOfLoops)
    {
        #start at 0 which has no assignments b/c no cluster 0
        $clusterNum++;
        my %assignmentCounts = ();
        
        foreach my $loop (@$clusternumber)
        {
            if(defined($$hOldClusterAssignments{$loop}))
            {      
                $assignmentCounts{$$hOldClusterAssignments{$loop}}++;
                $found = 1;      
            }
        }
        if($found)
        {
            # See which is the most common
            my $bestCount = 0;
            foreach my $cluster (keys %assignmentCounts)
            {
                if($assignmentCounts{$cluster} > $bestCount)
                {
                    $bestCount = $assignmentCounts{$cluster};
                    $bestClusterLabel = $cluster;
                }               # 
            }
        }
        else
        {
            #gets cluster length of novel confirmation
            my $clusterLength= GetClusterLength ($clanResultsFile, $clusterNum);
            
            #returns a new cluster label
            $bestClusterLabel = CreateNewLabel($clanResultsFile, $clusterLength, 
                                               \@EditedClusterNames, $aSuffixes);

            # adds new label to array of used cluster labels                                        
            push @EditedClusterNames, $bestClusterLabel; 
                
        }
        #creates hash of final cluster label w/ cluster label we used from .out file 
        $found = 0; 
                
        #creates a hash of final cluster assignments for all pdbs run in program
        my ($hsimpleData) = SetFinalAssignments($hNewClusterAssignments, $clusterNum, $bestClusterLabel);
        @$hfinalData{keys %$hsimpleData} = values %$hsimpleData;

    }
    # Return the best cluster label    
    return ($hfinalData, \@EditedClusterNames);
}

# a routine that takes in new simple cluster assignments and the corresponding pdb codes 
# a returns an array of arrays with all of these new assignments
sub GetArrayOfLoopsInNewClusterAssignments
{
    my ($hNewClusterAssignments, $clanResultsFile) = @_;

    my @ClusterNumbers = ();        
    my $InInteresting = 0;
    my $beginning = 'BEGIN ASSIGNMENTS';
    my $ending = 'END ASSIGNMENTS';
    my @AoA = (); #array to contain all new simple cluster assignments and their 
    #corresponding pdb code 

    if(open(my $file, '<', $clanResultsFile))
    {
        while( my $line = <$file>)
        {
            chomp;
            if ($line =~ /$ending/)
            {
                $InInteresting = 0;
            }
            elsif ($InInteresting)
            {
                my @FileComponents = split (/ N/, $line);
                push @ClusterNumbers, $FileComponents[0];
            }
            elsif ($line =~ /$beginning/)
            {
                $InInteresting = 1;
            }
        }       
    }
    # finds the total number of simple cluster assignments
    use List::Util qw( min max );
    my $totalClusters = max( @ClusterNumbers );
    
    #for each simple cluster assignment (1, 2, 3) gets all corresponding pdbs and stores 
    #them in a comprehensive array 
    for (my $i=1; $i <= $totalClusters; $i++)
    {
        my ($array) = GetLoopsInCluster($i, $hNewClusterAssignments);
        push (@AoA, $array);
    }
    return(\@AoA);
}


# subroutine that takes in a clan.out file and a initial cluster assignment, and then
#returns the loop length for the given assignment
sub GetClusterLength
{
    my ($clanResultsFile, $clusterNumber) = @_;
        
    my $beginning = "CLUSTER $clusterNumber ";
    my $length = '';
        
    if(open(my $file, '<', $clanResultsFile))
    {
        while( my $line = <$file>)
        {
            chomp;
            if ($line =~ /$beginning/)
            {
                my $interestingLine = $line;
                my @parsedLine = split (/,|\s/, $interestingLine);
                $length = @parsedLine[4]; 
                
                last;
            }       
        }
        close $file;
    }
    return($length);
}

# subroutine takes in a new clan assignments file, cluster length, array of used cluster names, and
#       all potential cluster suffixes and return a novel cluster name
sub CreateNewLabel
{
    my ($clanResultsFile, $length, $aAllClusterNames, $aSuffixes) = @_;
        
    my @usedNames = ();

    foreach my $name (@$aAllClusterNames)
    {
        if ($name =~ /^$length\w/)
        {       
            push @usedNames, $name;
        }
    }
    my $newClusterName = $length . @$aSuffixes[scalar(@usedNames)];
        
    return ($newClusterName);
}

# Takes a reference to the newAssignments hash, the cluster number of interest,
# a reference to a finalAssignments hash which is to be populated with the
# final cluster labels and the cluster label that we are using for this cluster
# number. Finds all loops in the cluster of interest and populates the finalAssignment
# hash with the correct label for these loops and then returns the hash by reference.

sub SetFinalAssignments
{
    my($hNewAssignments, $clusterNum, $bestClusterLabel) = @_;
    my $hFinalAssignments;
        
    foreach my $loop (keys %$hNewAssignments)
    {               
        if($$hNewAssignments{$loop} == $clusterNum)
        {
            $$hFinalAssignments{$loop} = $bestClusterLabel;
        }
    }
    return ($hFinalAssignments);
}

# subroutine to display new assignments on terminal
sub Show
{
    my ($hFinalData) = @_;
    
    my @keys = keys %$hFinalData;
    my @values = values %$hFinalData;
    while (@keys) 
    {
        print pop(@keys), '=', pop(@values), "\n";
    }
}

# subroutine to update file containing all the taken cluster assignment names
sub CommittNames
{
    my ($nameFile,  $aUpdatedNames) = @_;
                
    unless (open NAMEFILE, '>'.$nameFile) 
    {
        die "\nCannot open folder $nameFile! boo\n";
        exit;
    }

    foreach my $name (@$aUpdatedNames)
    {
        print NAMEFILE "$name\n";
    }
    close NAMEFILE;
}       

#unfinished subroutine to update "old" cluster assignment for all pdbs. I couldn't get it to work b/c 
# for some reason the file wouldn't open. I tried many variations and it wasn't working..

# sub CommittAssignments
# {
#       my ($clanFile, $hFinalsAssignments) = @_;
#       
#       my @keys = keys %$hFinalsAssignments;
#       my @values = values %$hFinalsAssignments;
#       
#       unless (open CLANFILE, '>>'.$clanFile) 
#       {
#               die "\nCannot open folder $clanFile!\n";
#               exit;
#       }
#       
#     while (@keys) 
#     {
#         print CLANFILE   pop(@keys), ' /', pop(@values), '\n';
#     }
#       close CLANFILE;
# 
# }
# ---------- END OF SUB ROUTINES ---------- 
