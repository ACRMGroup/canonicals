#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: run_findsdrs.py                              #
#    Date: Monday 9 Feb 2009                                 #
#    Description:  Rejigs Clan files to make findsdrs run    #
#                smoothly.                                   #
#                                                            #
#************************************************************#
import sys
import os
import tempfile
import subprocess
import pprint
#************************************************************#
class Rejig(object):
    """ Writes the full path to the PDB fiile rather than path to the \
    actual pdb file used to cluster..."""
    def __init__(self, clan_out_file, old_path, new_path, path_to_exe):
        self.clan_out_file = clan_out_file
        self.old_path = old_path
        self.new_path = new_path
        self.path_to_exe = path_to_exe
        self.tempFile = tempfile.NamedTemporaryFile(dir="/tmp")
        #self.tempFile = open("small.out2","w")
        self.rewriteclan(clan_out_file)
    ####*************************************************####
    def __del__(self):
        # trash all the contents of the temporary directory and
        rmcommand = "rm -f " + self.temp_dir+"/*"
        print rmcommand
        import os
        os.system(rmcommand)
        # removes the directory
        rmcommand = "rmdir "+self.temp_dir
        os.system(rmcommand)
    ####*************************************************####
    def rewriteclan(self, original_clan_out_file):
        """ Takes the old clan file and changes the reference to pdb files. """
        fIn = open(original_clan_out_file)
        lines = fIn.readlines()
        self.temp_dir = tempfile.mkdtemp(dir="/tmp")
        print self.temp_dir
        holder = set()
        for line in lines:
            pos = line.find(self.old_path)
            if pos!=-1:
                parts = line.split()
                filename = parts[1]
                pos = filename.find("-")
                filename = filename[:pos]
                lastslash = filename.rfind("/")
                basefilename = filename[lastslash:]
                if basefilename not in holder:
                    cp_command = "cp "+self.new_path+basefilename+" "+self.temp_dir+basefilename
                    #print cp_command
                    os.system(cp_command)
                    holder.add(basefilename)
            line = line.replace(self.old_path, self.temp_dir)
            self.tempFile.write(line)
            #print line.rstrip("\n")
        self.tempFile.flush()
    ####*************************************************####
    def run_findsdrs(self):
        """ runs the findsdrs program """
        pos = self.clan_out_file.rfind(".")
        outfilename = self.clan_out_file[:pos] + ".findsdrs"
        exe_string = self.path_to_exe + "/findsdrs " + self.tempFile.name + " " + outfilename
        print exe_string
        args = []
        args.append(exe_string)
        output = subprocess.Popen(args,shell=True).wait()
    
        

#************************************************************#
def usage():
    print "Usage: ./run_findsdrs.py <old path> <new path> <path to findsdrs> <clan out files...>"
    sys.exit(1)

#************************************************************#
if __name__ == "__main__":
    if len(sys.argv)<=3:
        usage()
    oldpath = sys.argv[1]
    newpath = sys.argv[2]
    pathtofindsdrs = sys.argv[3]
    clanoutfiles = sys.argv[4:]
    #pprint.pprint(clanoutfiles)
    #sys.exit(1)
    for cfile in clanoutfiles:
        rj = Rejig(cfile, oldpath, newpath, pathtofindsdrs)
        rj.run_findsdrs()
        del rj
        #break


