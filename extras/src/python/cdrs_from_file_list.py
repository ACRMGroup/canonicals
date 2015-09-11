#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: cdrs_from_file_list.py                       #
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
	return files
		

if __name__ == "__main__":
	if len(sys.argv)!=5:
		print "Usage: ./cdrs_from_file_list.py <filename> <abysispdb location> <config_dir> <pdb_sections dir>"
		sys.exit(1)
	fnames = getfilenames(sys.argv[1])
	current_dir = os.getcwd()
	# change to the directory
	os.chdir(sys.argv[2])
	for f in fnames:
		execute_st = "./abysispdb "+f+" " + sys.argv[4]
		print execute_st
		obtain = subprocess.Popen(execute_st,shell=True).wait()
	os.chdir(current_dir)
	# now copy the loop files to the config directory
	cpcommand = "cp /tmp/*.clan " + sys.argv[3]
	os.system(cpcommand) 	
