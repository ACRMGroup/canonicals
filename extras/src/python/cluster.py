#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: jacob hurst                                     #
#    File name: cluster.py                                   #
#    Date: Wednesday 11 Feb 2009                             #
#    Description: Analyses clusters                          #
#                                                            #
#************************************************************#
import sys
import psycopg2 as psycopg
#************************************************************#
class Cluster(object):
    def __init__(self, clustertype ):
        self.clustertype = clustertype
        self.pdb_ids = set()
        self.unique_sequences = set()
        self.duplicate_sequences = {}
        self.unobtainable_seq = set()
        self.length = 0
    ###****************************************************###
    def __repr__(self):
        printstring = "Number of pdb_ids:%d unique seq %d " %(len(self.pdb_ids), len(self.unique_sequences))
        printstring = printstring + " number of different duplicate sequences :%d length of sequence %d" %(len(self.duplicate_sequences),self.length)
        return printstring
    ###****************************************************###
    def addpdb(self, pdb_id2process):
        """ Process clan out line to add pdb id to a set """
        pos = pdb_id2process.rfind("/")
        pos2 = pdb_id2process.rfind(".")
        pdb_id = pdb_id2process[pos+4:pos2]
        self.pdb_ids.add(pdb_id)
    ###****************************************************###
    def addpdb_old(self, pdb_id2process):
        """ Process clan out line to add pdb id to a set """
        print pdb_id2process
        pos = pdb_id2process.rfind("/")
        pos2 = pdb_id2process.rfind(".")
        pdb_id = pdb_id2process[pos+2:pos2]
        self.pdb_ids.add(pdb_id)
    ###****************************************************###
    def obtain_cdr_sequences(self, cursor):
        """ Obtains the CDR sequence from Abysis for each pdb id """
        for id in self.pdb_ids: 
            print id
            selectstring = " select regions.region_sequence from regions,chain,structure2chain,structure where \
                structure.pdb_id=\'%s\' and \
                structure.structure_id=structure2chain.structure_id and \
                chain.chain_id = structure2chain.chain_id and \
                regions.chain_id =chain.chain_id and regions.regiondefs_id=20" %(id)
            cursor.execute(selectstring)
            data = cursor.fetchone()
            if data!=None and len(data)>0:
                self.length = len(data[0])
                if data[0] in self.unique_sequences:
                    if data[0] in self.duplicate_sequences:
                        self.duplicate_sequences[data[0]] = self.duplicate_sequences[data[0]] + 1
                    else:
                        self.duplicate_sequences[data[0]] = 1
                else:
                    self.unique_sequences.add(data[0])

#************************************************************#
class ClusterSet(object):
    def __init__(self, clustertype, clanfile, dbname, user, host="localhost",clan_type="new"):
        self.cluster_set = {}
        self.clanfile = open(clanfile)
        self.clustertype = clustertype
        self.clan_type = clan_type
        # connect to abysis
        connectstring = "dbname=%s user=%s host=%s" %(dbname, user, host)
        self.conn = psycopg.connect(connectstring)
        self.curs = self.conn.cursor()
        # process clan file
        self.processclanfile()
    ###***************************************************###
    def processclanfile(self):
        """ extract the RAW Assignments and adds pdb ids to clusters """
        lines = self.clanfile.readlines()
        process = False
        for line in lines:
            pos = line.find("END ASSIGNMENTS")
            if pos == 0:
                line = line.rstrip("\n")
                process = False
            if process == True:
                parts = line.split()
                cluster_no = int(parts[0])
                if cluster_no not in self.cluster_set:
                    cluster = Cluster(self.clustertype)
                    self.cluster_set[cluster_no] = cluster
                if self.clan_type == "new":
                    self.cluster_set[cluster_no].addpdb(parts[1])
                elif self.clan_type == "old":
                    self.cluster_set[cluster_no].addpdb_old(parts[1])
            pos = line.find("BEGIN ASSIGNMENTS")
            if pos == 0 :
                line = line.rstrip("\n")
                process = True
    ###***************************************************###
    def obtain_sequences(self):
        """ For each cluster obtain all the sequences"""
        for cluster in self.cluster_set:
            self.cluster_set[cluster].obtain_cdr_sequences(self.curs)
    ###***************************************************###
    def printdata(self):
        for cluster in self.cluster_set:
            print "Data Cluster",cluster
            print self.cluster_set[cluster]
    ###***************************************************###
    def printlengthvdiffcluster(self):
        for cluster in self.cluster_set:
            length = self.cluster_set[cluster].length
            number_diff = len(self.cluster_set[cluster].unique_sequences)+len(self.cluster_set[cluster].duplicate_sequences)
            print number_diff,length
#************************************************************#
def usage():
    print "Usage: ./cluster.py <clustertype> <clanfile>"
    sys.exit(1)        

#************************************************************#
if __name__ == "__main__":
    if len(sys.argv)!=3:
        usage()
    cS = ClusterSet(sys.argv[1], sys.argv[2], "abysis", "jacob",clan_type="old")
    cS.obtain_sequences()
    #cS.printdata()
    cS.printlengthvdiffcluster()

