#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: jacob hurst                                     #
#    File name: checkavailability.py                         #
#    Date: Monday 12 Jan 2009                                #
#    Description:  checks to see if some pdb files are       #
#                available.                                  #
#                                                            #
#************************************************************#
import sys
import os

def usage():
	print "Usage: ./checkavailability.py <pdb directory> <config file>"
	sys.exit(1)	

if __name__ == "__main__":
	if len(sys.argv)!=3:
		usage()
	pdb_directory = sys.argv[1]
	config_filename   = sys.argv[2]
	
	files = os.listdir(pdb_directory)
	pdbs = set()
	for f in files:
		if f.find("pdb")==0:
			pdbs.add(f[3:-4])
		

	config_in = open(config_filename)
	lines = config_in.readlines()
	for line in lines:
		line = line.rstrip("\n")
		if line.find("loop")==0:
			parts = line.split()
			filename = parts[1]
			more_parts = filename.split("/")
			last_part = more_parts[len(more_parts)-1]
			clean_last_part = last_part[1:-3]
			if clean_last_part in pdbs:
				print parts[0],"/home/jacob/data/ab_pdb_files/pdb%s.ent" %(clean_last_part),parts[2],parts[3]
		else:
			print line 
			
	
