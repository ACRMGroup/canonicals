#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: jake                                            #
#    File name: listfiles.py                                 #
#    Date: Tuesday 20 Jan 2009                               #
##    Description: list some files                           #
#                                                            #
#************************************************************#
import os
import sys



if __name__ =="__main__":
	if len(sys.argv)!=3:
		print "Usage: ./listfiles.py <dirname> <outfile>"
		sys.exit(1)
	else:
		hold = os.listdir(sys.argv[1])
		fout = open(sys.argv[2],"w")
		for h in hold:
			fout.write(sys.argv[1]+"/"+h+"\n")

