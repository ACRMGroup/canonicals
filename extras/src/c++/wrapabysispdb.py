#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: wrapabysispdb.py                             #
#    Date: Sunday 16 Mar 2008                                #
##    Description: Wrap the Pdb parsing.                     #
#                                                            #
#************************************************************#
import sys
import os
import pprint
import subprocess
def Usage():
    print "Usage: ./wrapabysispdb.py <config_file> <xml_out_file>"

class runAbysisPdb:
    def __init__(self, c_filename,xml_out_filename):
        self.files =[]
        self.c_filename = c_filename
        self.xml_filename = xml_out_filename
        self.getFilenames()
    def getFilenames(self):
        cF = open(self.c_filename)
        lines = cF.readlines()
        for line in lines:
            # split on white space.
            parts = line.split()
            if len(parts)>1:
                pos = parts[0].find(".ent")
                # if it is pdb file
                if pos!=-1:   
                    self.files.append(parts[0])
        pprint.pprint(self.files)
    def run(self):
        xFile = open(self.xml_filename,"w")
        xFile.write("<antibodies>\n")
        xFile.close()
        count = 0
        for file in self.files:
            # open a pipe and the close
            p_command = "./abysispdb "+file+" >>"+self.xml_filename
            print p_command,"Of: ",count,len(self.files)
            p=subprocess.Popen(p_command,shell=True,stdout=sys.stdout)
            p.wait()
            count =  count+1
        xFile = open(self.xml_filename,"a")
        xFile.write("</antibodies>\n")
        xFile.close()
    def cp(self, directory):
        for file in self.files:
            cp_st = "cp " + file + " " + directory
            print cp_st
            os.system(cp_st)
    
        

if __name__ == "__main__":
    if len(sys.argv)!=3:
        Usage()
        sys.exit(1)
           # need to cd to the python source code directory
    current_working_dir = os.getcwd()
    pos = sys.argv[0].rfind("/")
    if pos!=-1:
        where_i_want_to_be = sys.argv[0]
        where_i_want_to_be = where_i_want_to_be[:pos]
        os.chdir(where_i_want_to_be)
    a=runAbysisPdb(sys.argv[1],sys.argv[2])
    a.run()
    os.chdir(current_working_dir)
    


