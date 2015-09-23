Canonicals
==========

# NOTE! This code is not really ready for use by people outside the ACRM group.

Code for defining canonical classes

ACACA - Automatic Canonical Assignment by Cluster Analysis
----------------------------------------------------------

Reads a set of PDB files and a control file which specifies the loops to be
analysed. For each loop writes a file containing the CA pseudo-torsions
for the loops. Shorter loops are padded with torsions of 9999.0

For each loop in turn,
Performs cluster analysis.
Process results of C.A. to identify a sensible number of clusters.
Assigns each conformation to a cluster.
Look for features in each cluster?? Conserved buried residues?
Cluster analysis must provide the centre of the cluster, the dimensions of 
the cluster and the distance to the nearest other cluster such that new
structures can be scanned against the clusters.

Three programs:

1) CLAN - CLuster ANalysis.
---------------------------

Performs cluster analysis on a loop in a set of PDB files. Generates
information on the clusters.
Takes an input file of the following syntax:

    METHOD    <clustering method>           ! Ward, single, multiple, etc.
    LOOP      <pdb> <startres> <lastres>    ! Multiple records
    OUTPUT    <outfile>                     ! or stdout if not specified
    MAXLENGTH <length>                      ! Max length of a loop in analysis
    SCHEME    <insert scheme>               ! Order in which positions in the 
                                            ! loop should be assigned from the 
                                            ! actual loop i.e. where insertions 
                                            ! should be considered
    DENDOGRAM                               ! Show the clustering tree dendogram
    TABLE                                   ! Show the cluster table
    DATA                                    ! Show the data which is used for
                                            ! clustering
    POSTCLUSTER <cutoff>                    ! Specify RMS cutoff for post-cluster

The output file contains the METHOD, MAXLENGTH and SCHEME information as
well as the clustering data which includes the centre and size of each
cluster and the distance to the nearest neighbouring cluster.


2) FICL - FInd CLuster
----------------------

Takes a loop in a PDB file and matches it against a set of clusters to
find which cluster (if any) it matches.

Is run with the following syntax:

    ficl <datafile> <pdb> <startres> <lastres>

where

    <pdb> <startres> <lastres>    is the loop to be tested
    <datafile>                    is the output file from CLAN

FICL will pick up the cluster method from the output of CLAN

CLAN must be run with TABLE and DATA switched on!

3) FINDSDRS - Find Structurally Determining Residues
----------------------------------------------------

Analyzes the output of CLAN to identify the key residues responsible for
defining the canonical class.

Run with:

    findsdrs [-k] [clanfile [outfile]]
             -k Keep intermediate solvent accessibility files so they
                don't have to be recalculated for the next run.

Note that solvent accessibility calculation requires pdbsolv from
BiopTools to be in the path.

--------------------------------------------------------------------------

Key Tasks
=========

1. Automation
-------------

- Ensure that you can carry cluster labels forward from one run of the
  code to the next. There are probably scripts to do this already
  somewhere here, but they are not documented and I don't know where
  they are!

- Generate a file in the correct format for our canonical
  identification program

2. Check the clusters
---------------------

- Are the clusters really sensible? Could we improve them by using
  different clustering thresholds? For example, 12E8 CDR-L1 and 1A0Q
  CDR-L1 are both in the same cluster, but have a backbone flip at
  positions L30-L31. Should and could these be split into two
  clusters?

3. CDR-H3
---------

- CDR-H3 doesn't really form canonicals. However in our old paper we
  found that there were some clusters for 7-residue CDR-H3s. Extend
  this work and see if this holds up and whether we can now do longer
  CDR-H3s.




The basic procedure
===================

- Most of this is automated by the doit.sh script in the demo directory

1. Get a list of antibody structures
   (SACS: /acrm/www/html/abs/sacs/antibodies.xml
    or preferably from Jake's database)
   (You need to write this)
2. All the PDB files live in /acrm/data/pdb/pdbXXXX.ent
   Apply standard Chothia numbering to each PDB file
   extracting just the numbered Fv fragment and storing them
   in a directory
   (We should have a script that does this already)
3. For each of the CDRs, create an input file for CLAN (see
   below) and run the CLAN program - generates the sets of
   clusters and tells you which PDB files fall into each cluster.
   (You need to automate the creation of the input files for CLAN)
4. For each CDR, run the findsdrs program. This generates a list
   of the key residues which define each of the clusters.
   (This should simply be a case of running the program on the
   CLAN output)

- These stages are not yet automated

5. You need to maintain some sort of historical mapping so that
   you have cluster names (e.g. '11A') that are maintained in
   a consistent way. This needs to look at the CLAN output and
   check that antibodies that were assigned to a particular class
   stay in a class with that name.
   (You need to code this).
6. You need to convert the output from findsdrs into an input file
   for our canonicals program that assigns canonical class on the
   basis of a sequence file.
   (You need to code this).
7. Run the complete pipeline on the ~700 available antibody structures
   to update the results we had on ~50 antibodies.

Seen by Tanner
