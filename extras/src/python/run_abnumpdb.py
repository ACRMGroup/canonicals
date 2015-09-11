#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: run_abnumpdb.py                              #
#    Date: Wednesday 17 Dec 2008                             #
#    Description:  runs the numbering program on a           #
#                collection of pdb files.                    #
#                                                            #
#************************************************************#
import sys
import subprocess

def usage():
    print "Usage: ./run_abnumpdb.py <saxs_xml> <abnum program> <pdb files location>"
    sys.exit(1)

class RunAbNumPdb(object):
    def __init__(self, saxs_filename, abnum_program, pdb_location, outfilename="/tmp/numberpdb.dat"):
        self.pdb_ids = set()
        self.saxs_filename = saxs_filename
        self.acrm_pdb_numbering_perl_wrapper = abnum_program
        self.pdb_location = pdb_location
        # write wrapping text to the outfile
        self.outFile = open(outfilename,"w")
        self.outFile.write("<antibodies>\n")
        self.outFile.flush()
        self.errorFile = open("/tmp/error.txt","w")
    def __del__(self):
        self.outFile.write("\n</antibodies>\n")
    def parseSacs(self):
        """ Parses the saxs xml to extract pdb ids. """
        saxs_file = open(self.saxs_filename)
        lines = saxs_file.readlines()
        for line in lines:
            line = line.rstrip("\n")
            # search for the tag <antibody pdb= 
            pos = line.find("<antibody pdb=")
            if pos == 0:
                pdb_file_name = line[15:-2].lower()
                pdb_file_name = "pdb" + pdb_file_name + ".ent"
                self.pdb_ids.add(pdb_file_name)
    def numberPdb(self):
        """ Calls the ACRM perl wrapper to number the Pdb files. """
        for pdb in self.pdb_ids:
            # set up the arguments
            args = []
            args.append(self.acrm_pdb_numbering_perl_wrapper)
            args.append(self.pdb_location+"/"+pdb)
            # write some wrapping tags to the outfile
            self.outFile.write("<antibody pdb=\""+pdb+"\">\n")
            self.outFile.write("<numbered_data>\n")
            self.outFile.flush()
            self.errorFile.write("<antibody pdb=\""+pdb+"\">\n")
            self.errorFile.flush()
            subprocess.Popen(args,stdout=self.outFile, stderr=self.errorFile).wait()
            self.outFile.flush()
            self.outFile.write("</numbered_data>\n</antibody>\n")
            self.outFile.flush()
            self.errorFile.flush()
            #if count == 5:
            #    sys.exit(1)           
        return True


if __name__ == "__main__":
    if len(sys.argv)!=4:
        usage()
    run_ab = RunAbNumPdb(sys.argv[1], sys.argv[2], sys.argv[3])
    run_ab.parseSacs()
    run_ab.numberPdb()
        


