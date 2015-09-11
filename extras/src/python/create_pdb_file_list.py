#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: jacob Hurst                                     #
#    File name: create_pdb_file_list.py                      #
#    Date: Wednesday 18 Mar 2009                             #
#    Description:  creates a list from saxs of the PDB       #
#                antibodies.                                 #
#                                                            #
#************************************************************#
import sys

#************************************************************#
class CreateList(object):
    def __init__(self, saxsfilename, pdblocation, outfilename):
        self.pdb_ids = []
        self.location = pdblocation
        self.parse_saxs_file(saxsfilename)
        self.write_file(outfilename)
    ###******************************************************#
    def parse_saxs_file(self, filename):
        """ parses the sax file to extract pdb ids. """
        fIn = open(filename)
        lines = fIn.readlines()
        for line in lines:
            line = line.rstrip("\n")
            # search for the tag <antibody pdb= 
            pos = line.find("<antibody pdb=")
            if pos == 0:
                pdb_file_name = line[15:-2].lower()
                pdb_file_name = "pdb" + pdb_file_name + ".ent"
                self.pdb_ids.append(pdb_file_name)
        fIn.close()
    ###******************************************************#
    def write_file(self, outfilename):
        """ files are written """ 
        fOut = open(outfilename, "w")
        for pdb_id in self.pdb_ids:
            fOut.write("%s/%s\n" %(self.location, pdb_id))
        fOut.close()   
#************************************************************#
def usage():
    print "./create_pdb_file_list.py <saxsfile> <pdblocation> <outfilename>"
    sys.exit(1)
#************************************************************#
if __name__ == "__main__":
    if len(sys.argv)!=4:
        usage()
    cL = CreateList(sys.argv[1], sys.argv[2], sys.argv[3])
        
#************************************************************#

