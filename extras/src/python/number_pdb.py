#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: number_pdb.py                                #
#    Date: Thursday 15 Jan 2009                              #
#    Description: runs program to produce clan files.        #
#                                                            #
#************************************************************#
import sys
import os
import subprocess

def getfilenames(fname):
	fIn = open(fname)
	lines = fIn.readlines()
	files = []
	for l in lines:
		l = l.rstrip("\n")
		files.append(l)
	# end for
	return files
# end def getfilenames
		

if __name__ == "__main__":
    if len(sys.argv)!=4:
        print "Usage: ./number_pdb.py <filename> <perl location> <pdb_sections dir>"
        sys.exit(1)
    # end if
    fnames = getfilenames(sys.argv[1])
    current_dir = os.getcwd()
	# change to the directory
    os.chdir(sys.argv[2])
    for f in fnames:
        parts = f.split("/")
        last = parts[len(parts)-1]
        execute_st = "./abnumpdb.pl "+f+" >"+ sys.argv[3]+"/"+ last
        print execute_st
        obtain = subprocess.Popen(execute_st,shell=True).wait()
    # end for
    os.chdir(current_dir)
# end if
	# now copy the loop files to the config directory
    #cpcommand = "cp /tmp/*.clan " + sys.argv[3]
    #os.system(cpcommand) 	
