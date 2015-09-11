#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: produce_canonical_class_config.py            #
#    Date: Friday 27 Feb 2009                                #
#    Description:  Produces file that enables canonical      #
#                classes to be generated from new cluster    #
#                data.                                       #
#                                                            #
#************************************************************#
import sys
from pprint import pprint

import cluster_members
import scheme
#************************************************************#
class ChothiaToAuto(object):
    def __init__(self, filename):
        config_file = open(filename)
        lines = config_file.readlines()
        self.mapper = {}
        for line in lines:
            if line[0]!="#":
                line = line.rstrip("\n")
                parts = line.split()
                if len(parts)>0:
                    if parts[0] not in self.mapper:
                        self.mapper[parts[0]]={}
                    self.mapper[parts[0]][parts[2]] = parts[1]   
        #pprint(self.mapper)
    #*******************************************************#
    def returnSpecificLoopConfig(self, loop_id):
        """ Returns the specific loop config """
        loop_id = loop_id.upper()
        if loop_id in self.mapper:
            return self.mapper[loop_id]
        else:
            return None       
#************************************************************#
class Cluster(object):
    def __init__(self, a_length, a_number):
        self.length = a_length
        self.number = a_number
        self.conserved_positions = {}
        self.scheme = scheme.ChothiaScheme()
    ###**************************************************#
    def add_position(self, position, amino_acids):
        if amino_acids != "-":
            if position not in self.conserved_positions:
                self.conserved_positions[position] = amino_acids   
            else:
                previous = self.conserved_positions[position] 
                to_add = ""
                add = True
                for aa in amino_acids:
                    for p in previous:
                        if p == aa:
                            add = False
                    if add == True and aa !="-":
                        to_add = to_add + aa
                    else:
                        add = True
                self.conserved_positions[position] = previous + to_add
                           
    ###**************************************************#
    def obtain_conserved_pos(self):
        printstring = ""
        for pos , data in self.scheme.hope_cmp(self.conserved_positions):
            if len(pos)==2:
                #printstring = printstring + pos + "  \t" + self.conserved_positions[pos] + "\n"
                printstring = printstring + pos + "  \t" + data + "\n"
            else:
                #printstring = printstring + pos + " \t" + self.conserved_positions[pos] + "\n"
                printstring = printstring + pos + " \t" + data + "\n"
        return printstring
#************************************************************#
class FindsdrsOutput(object):
    def __init__(self, filename):
        fIn = open(filename)
        loop = True
        self.cluster_conserved = {}
        self.position_view = {}
        self.scheme = scheme.ChothiaScheme()
        while loop == True:
            line =  fIn.readline()
            pos = line.find("Observed")
            if pos == -1:
                pos2 = line.find("CLUSTER")
                pos3 = line.find("CONSERVED")
                if pos2 !=-1:
                    self.add_to_cluster_conserved(line)
                elif pos3 !=-1:
                    self.add_residue_to_cluster(line)
            else:
                loop = False
        # move back to the start of the file
        fIn.seek(0)
        self.parse_second_section(fIn)
    #*******************************************************#
    def parse_second_section(self, fIn):
        lines = fIn.readlines()
        process = False
        for line in lines:
            if process == True:
                self.process_second_section(line)
            pos = line.find("Observed")
            if pos != -1:
                process = True       
    #*******************************************************#
    def process_second_section(self, a_line):
        if a_line.find("CLUSTER")!=-1:
            a_line = a_line.rstrip("\n")
            parts = a_line.split("(")
            cluster_no = parts[0]
            cluster_no = cluster_no[8:]
            self.current_cluster = cluster_no
            self.current_cluster = self.current_cluster.rstrip()
            self.current_cluster = self.current_cluster.strip()
        else:
            parts = a_line.split(":")
            numbered_pos = ""
            if len(parts) == 2:
                first_part = parts[0]
                for letter in first_part:
                    if letter != " ":
                        numbered_pos = numbered_pos + letter
                second_part = parts[1]
                pos = second_part.find("(")
                residues = second_part[:pos]
                residues = residues.strip()
                residues = residues.rstrip()
                print self.current_cluster, numbered_pos, residues
                self.cluster_conserved[self.current_cluster].add_position(numbered_pos, residues)
    #*******************************************************#
    def add_to_cluster_conserved(self, a_line):
        a_line = a_line.rstrip("\n")
        parts = a_line.split("(")
        cluster_no = parts[0]
        cluster_no = cluster_no[8:]
        cluster_no = cluster_no.rstrip()
        length = parts[1]
        more_parts = length.split(",")
        length = more_parts[0]
        pos = length.find("=")
        length = length[pos+1:]
        length = length.strip()
        length = length.rstrip()
        # create a new cluster object
        new_cluster = Cluster(length, cluster_no)
        self.current_cluster = cluster_no
        self.cluster_conserved[cluster_no] = new_cluster
    #*******************************************************#
    def add_residue_to_cluster(self, a_line):
        """ obtains the numbered position and the conserved residues """
        pos = a_line.find("0x")
        if pos!=-1:
            to_process = a_line[:pos-1]
            numbered_pos = ""
            for letter in to_process:
                if letter != " ":
                    numbered_pos = numbered_pos + letter
            pos_start = a_line.find("(")
            pos_end   = a_line.find(")")
            amino_acids = a_line[pos_start+1:pos_end]
            self.cluster_conserved[self.current_cluster].add_position(numbered_pos, amino_acids)
            if numbered_pos not in self.position_view:
                self.position_view[numbered_pos] = {}
            self.position_view[numbered_pos][self.current_cluster] = amino_acids
    #*******************************************************#
    def write_canonical_class_file(self, clanoutdata, chothia2auto, loop_id):
        fout = open("canonical_"+loop_id,"w")
        for count in clanoutdata.labels:
            index = count
            writestring = "\nLOOP "+loop_id
            currentlabel = clanoutdata.labels[index]
            if chothia2auto and currentlabel in chothia2auto:
                currentlabel = chothia2auto[currentlabel] + "/" +currentlabel
            else:
                currentlabel = "?/" + currentlabel
            writestring = writestring + " " +currentlabel + " " + self.cluster_conserved[index].length+"\n"
            writestring = writestring + "SOURCE [" + clanoutdata.medians[index] + "]\n"
            writestring = writestring + self.cluster_conserved[index].obtain_conserved_pos()
            if len(self.cluster_conserved[index].obtain_conserved_pos())>0:
                fout.write(writestring)
    #*******************************************************#
    def print_position_view(self, clanoutdata, chothia2auto):
        """ prints from a positional point of view..."""    
        #pprint(self.position_view)
        #print len(clanoutdata.labels)
        self.print_header(clanoutdata, chothia2auto)
        for position, data_to_ignore in self.scheme.hope_cmp(self.position_view):
            printst = ""
            count = 0
            for cluster in clanoutdata.labels:
                count = count +1
                if cluster in self.position_view[position]:
                    printst = printst + "\t" + self.position_view[position][cluster]#+str(count) 
                else:
                    printst = printst + "\t" + "-"#+str(count)
            if len(position)==2 or len(position)==3:
                printst = position + "\t" + printst
            elif len(position)==4:
                printst = position + "   " + printst
            elif len(position)==5:
                printst = position + "  " + printst
                
            print printst
            #print count 
    #*******************************************************#
    def print_header(self, clandata, cta):
        """ Produces a nice header to layout the findsdrs data. """
        printstring = ""
        for cluster in clandata.labels:
            printstring = printstring + "\t" +clandata.labels[cluster]
        print "Pos",printstring

#************************************************************#
def run_produce_can_config(clan_outfile, findsdrs_outfile, chothia_config_file, loop_id):
    print clan_outfile, findsdrs_outfile, chothia_config_file, loop_id
    # get the clan outfile data
    clanoutfiledata = cluster_members.ClusterMembers(clan_outfile)
    # get the findsdrs data
    findsdrsdata = FindsdrsOutput(findsdrs_outfile)
    # sort out the chothia linkage
    chothiaconfig = ChothiaToAuto(chothia_config_file)
    topass = chothiaconfig.returnSpecificLoopConfig(loop_id)
    # write the canonical class file
    findsdrsdata.write_canonical_class_file( clanoutfiledata, topass, loop_id)       
    findsdrsdata.print_position_view(clanoutfiledata,topass)
#************************************************************#
def usage():
    print "./produce_canonical_class_config.py <results directory><config directory>"
    sys.exit(1)
#************************************************************#
if __name__ == "__main__":
    # sort out the program's input
    if len(sys.argv)!=3:
        usage()
    results_dir = sys.argv[1]
    config_dir  = sys.argv[2]
    
    chothia_config_file = config_dir + "/chothia_to_auto.dat" 
    loops = [ "L1", "L2", "L3", "H1", "H2", "H3" ]
    #loops = [ "H3"  ]
    for loop in loops:
        clan_outfile = results_dir + "/" + loop + "_clan.out"
        findsdrs_outfile = results_dir + "/" + loop + "_findsdrs.out"
        run_produce_can_config(clan_outfile, findsdrs_outfile, chothia_config_file, loop)
