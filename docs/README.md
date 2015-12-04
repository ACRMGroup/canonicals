DEFINING THE CLUSTERS (clan)
============================

clan (CLuster ANalysis of loops) performs cluster analysis to examine
loops in proteins. Clustering is a 2 stage process. First, we cluster
on pseudo-torsion angles (i.e. torsions between C-alpha atoms), then
clusters are merged if their RMSD in cartesian space is below a
specified cutoff.

Clan input
----------

The program is run as follows:

    clan [-t] [-c n] claninfile

`-t` causes it to use true torsion angles rather than Calpha
pseudo-torsions.  

`-c` allows you to specify the critical value used to define the number
 of clusters. This is overridden by the CVALUE command in the control file.

`claninfile` is a control file which has entries as follows:

`output clanoutfile`

   Specifies the name of the output file to be written

`maxlength N`

   The maximum length of a loop which can be handled e.g. 
   maxlength 20

`scheme x...y`

   This is a scheme by which loops of different lengths are
   handled. x...y are a set of integers from 1 to N (the maxlength
   specified previously). If you imagine the maxlength is 20 and you
   have a loop of only 2 residues then these would be at the ends of
   the loop. If you had 19 residues, all but a residue somewhere near
   the middle would be filled in. This the numbers represent the order
   in which the positions are occupied. e.g.
   scheme 1 3 5 7 12 13 14 15 16 17 18 19 20 11 10 9 8 6 4 2

`dendogram`

   Output a clustering dendogram (see below)

`table`

   Output the clustering table (see below)

`data`

   Output the torsion data that was used for clustering (see below)

`critical`

   Output the criticalresidues and allcriticalresidues sections (see
   below) 

`cvalue n`

   Specify the critical value used in the clustering to define
   the separate clusters. This overrides the value specified with -c
   on the command line

`postcluster n1 [n2 [n3]]`

   Perform post-cluster merging in cartesian space. Of the RMSD < n1
   and max CA deviation < n2 and max CB deviation < n2, merge the
   clusters. (n2 and n3 are optional and default to 1.5A and 1.9A
   respectively)

`distance / nodistance`

   Adds (or doesn't) the distance between the N-terminal CA and each
   of the other CAs into the clustering vector. (Default is nodistance)

`angle / noangle`

   Adds (or doesn't) the angle subtended at each CA by the
   neighbouring CAs into the clustering vector. (Default is nodangle)

`loop pdbfile startres stopres`

   multiple entries like this which specify PDB files and the loop
   range to be considered.

Clan Output
-----------

Output from the program is divided into blocks each bracketed by

    BEGIN xxxx
    END xxxx

### HEADER
This tells you what the input parameters were (i.e. what was in the
CLAN config file, the number of loops, etc)

### DATA
These are the torsion angle vectors that were extracted from the PDB
files - i.e. the data that were clustered

### CLUSTABLE
This is the result of the clustering. Initially (the left most number
in each row) each structure is in its own cluster, so each structure
has a unique number. Clusters are then merged in a hierarchical
manner, so as you move to the right, some of the structures have the
same cluster number

### DENDOGRAM
The dendogram gives you a graphical version of the information in
CLUSTABLE. You probably need a very wide printer! At the bottom you'll
see everything in its own cluster - as you move up, the clusters
merge. At the very end you see the initial cluster number for each of
the loops (note that they are somewhat jumbled - not just in numerical
order).

### RAWASSIGNMENTS
The problem with clustering is always to decide 'how many clusters' -
the clustering algorithm starts with everything in its own cluster and
does a hierarchical merging until everything is in one cluster.  This
is addressed within the code on the basis that the clusters separate
things that Chothia placed in different canonical classes. The data
presented here are the cluster numbers for each of the input
structures so that we have appropriate differences in the
conformations they contain.

### RAWMEDIANS n
This displays the structure which is at the centre of each cluster (n
is the number of clusters) - i.e. the best representative.

### POSTCLUSTER
This reports information on any clusters that are merged in the
cartesian space post-clustering step

### ASSIGNMENTS
This is equivalent to RAWASSIGNMENTS but reports the clusters after
any cartesian cluster-merging has occurred. Therefore this is the
final cluster assignments for each of the input structures.

### MEDIANS n
This is equivalent to RAWMEDIANS but for the clusters after
any cartesian cluster-merging has occurred. Therefore this is the
final set of representatives for the clusters.

### CRITICALRESIDUES n
This is a basic analysis of potentiall critical positions for defining
the loop conformation. All residues in the loop, plus those which make
contact are listed with their characteristics and observed residues. The
characteristics are supplied both as a string e.g.

    /hydrophilic/non-H-bonding/aliphatic/not glycine or proline/

and as a hexadecimal encoding e.g.

    0x5042

You can ignore this - it is just an internal representation of the
list of properties in an easy form for findsdrs to use.

### ALLCRITICALRESIDUES n
This is similar to CRITICALRESIDUES, but reports all residues that are
conserved anywhere in the structure amongst all members of any cluster.


IDENTIFYING THE KEY RESIDUES (findsdrs)
=======================================

Once the loops are in clusters, the next stage is to find the key
residues that are responsible for those clusters. This is done by the
findsdrs program which essentially automates the visually based rules
defined by Chothia:

Reads the output of CLAN and attempts to define SDRs using the
PDB files and sequence templates for each cluster.

The algorithm is as follows:

For each cluster:

1. If a residue is absolutely conserved and the cluster has at
   least MINABSCONS (5) members it is defined as key
2. If a Gly/Pro is absolutely conserved and the cluster has at
   least MINGLYPRO (2) members it is defined as key
3. Any residues which make sidechain HBonds between loop and
   framework in every member of the cluster are defined as key
4. Any residues which make sidechain/backbone HBonds within the
   loop in every member of the cluster are defined as key
5. Any residues in the loop which are buried (mean SA < SACUT
   (=3.0)) hydrophobics in every member of the cluster are defined
   as key 
6. Framework hydrophobic residues which make sidechain interactions
   (atom distance < sqrt(HPHOBCONTDISTSQ) (=5.0)) with loop key
   hydrophobics in every member of the cluster are defined as key

To report unified SDRs:

7. A list of key positions defined above in any cluster (of any
   loop length) with at least MINCLUSSIZE (5) members is assembled.
9. For each cluster, the key residues defined in step 7 are
   appended to the list generated in steps 1--6.
8. For each cluster, key positions from small clusters (<
   MINCLUSSIZE) are appended to the list if the loop length matches
   [OPTIONALLY: There must also be some ``added value'' (i.e. the
   amino acid at this position descriminates between the
   conformations)]. 

The input to the program is simply the clan output file.




UTILITY PROGRAMS
================

There are two utilities:

`getloops` - this is called as:

    getloops claninfile

It simply reads a clan input file and grabs the specified loop regions
outputting them to files in the current directory. 

`ficl` (FInd CLusters) - this is called as:

    ficl clanoutfile pdbfile startres endres

It reads the clan output file and a loop from a PDB file and reports
which cluster this additional loop fits into (or whether it is a novel
conformation). 

