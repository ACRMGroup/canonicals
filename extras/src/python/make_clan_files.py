#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: make_clan_files.py                           #
#    Date: Thursday 29 Jan 2009                              #
#    Description: creates clan files                         #
#                                                            #
#************************************************************#
import os,sys
import pprint
class MakeClan(object):
    def __init__(self, pdb_dir, config_dir, region_xml_file):
        self.config_dir = config_dir
        self.pdb_dir = pdb_dir
        self.region_config  = open(region_xml_file)
        self.L1_start, self.L1_end = self.get_region("L1" )
        self.L2_start, self.L2_end = self.get_region("L2" )
        self.L3_start, self.L3_end = self.get_region("L3" )
        self.H1_start, self.H1_end = self.get_region("H1" )
        self.H2_start, self.H2_end = self.get_region("H2" )
        self.H3_start, self.H3_end = self.get_region("H3" )
        self.get_file_names()
    ###*****************************************************#
    def get_file_names(self):
        """ extracts all the file names from the pdb dir. """
        filenames = os.listdir(self.pdb_dir)
        self.filenames = []
        for file in filenames:
            if os.path.getsize(self.pdb_dir+"/"+file) > 40:
                self.filenames.append(file)
    ###*****************************************************#
    def get_region(self, r_in_q):
        # seek to the start of the file
        self.region_config.seek(0)
        region = "CDR " + r_in_q
        for line in self.region_config:
            if line.find("scheme=\'abm\'")!=-1:
                pos = line.find(region)
                if pos!=-1:
                    # now pull out the start and the end
                    parts = line.split()
                    for section in parts:
                        if section.find("start=\'")!=-1:
                            start = section.rstrip("\'")
                            start = start.strip("start=\'")
                        if section.find("end=\'")!=-1:
                            end = section.rstrip("\'")
                            end = end.rstrip("\'/>")
                            end = end.strip("end=\'")
        return start, end
    ###*****************************************************#
    def write_files(self):
        """ writes the loop files to the config directory """
        self.write_file(self.L1_start, self.L1_end, self.config_dir+"/L1.clan")  
        self.write_file(self.L2_start, self.L2_end, self.config_dir+"/L2.clan")  
        self.write_file(self.L3_start, self.L3_end, self.config_dir+"/L3.clan")  
        self.write_file(self.H1_start, self.H1_end, self.config_dir+"/H1.clan")  
        self.write_file(self.H2_start, self.H2_end, self.config_dir+"/H2.clan")  
        self.write_file(self.H3_start, self.H3_end, self.config_dir+"/H3.clan")  
    ###*****************************************************#
    def write_file(self, start, stop, filename):
        """ writes the file . """
        fout = open(filename, "w")
        for file in self.filenames:
            fout.write("loop "+self.pdb_dir+"/"+file+" "+start.lower()+" "+stop.lower()+"\n")
        fout.close()
    ###*****************************************************#
    def cat_files(self):
        """ cats together the loop file and the clan config file. """
        c_files = []
        c_files.append(self.config_dir+"/loop_L1_config.txt")
        c_files.append(self.config_dir+"/L1.clan")
        cat_files(c_files, self.config_dir+"/L1_temp")
        os.system("mv "+self.config_dir+"/L1_temp "+self.config_dir+"/L1.clan")
        c_files = []
        c_files.append(self.config_dir+"/loop_L2_config.txt")
        c_files.append(self.config_dir+"/L2.clan")
        cat_files(c_files, self.config_dir+"/L2_temp")
        os.system("mv "+self.config_dir+"/L2_temp "+self.config_dir+"/L2.clan")
        c_files = []
        c_files.append(self.config_dir+"/loop_L3_config.txt")
        c_files.append(self.config_dir+"/L3.clan")
        cat_files(c_files, self.config_dir+"/L3_temp")
        os.system("mv "+self.config_dir+"/L3_temp "+self.config_dir+"/L3.clan")
        c_files = []
        c_files.append(self.config_dir+"/loop_H1_config.txt")
        c_files.append(self.config_dir+"/H1.clan")
        cat_files(c_files, self.config_dir+"/H1_temp")
        os.system("mv "+self.config_dir+"/H1_temp "+self.config_dir+"/H1.clan")
        c_files = []
        c_files.append(self.config_dir+"/loop_H2_config.txt")
        c_files.append(self.config_dir+"/H2.clan")
        cat_files(c_files, self.config_dir+"/H2_temp")
        os.system("mv "+self.config_dir+"/H2_temp "+self.config_dir+"/H2.clan")
        c_files = []
        c_files.append(self.config_dir+"/loop_H3_config.txt")
        c_files.append(self.config_dir+"/H3.clan")
        cat_files(c_files, self.config_dir+"/H3_temp")
        os.system("mv "+self.config_dir+"/H3_temp "+self.config_dir+"/H3.clan")
#************************************************************#
def usage():
    print "Usage: ./make_clan_files.py <pdb sections dir> <config dir> <regions_xml_file>"
    sys.exit(1)
#************************************************************#
def cat_files(files_to_cat, outfile):
    cat_st = "cat "
    for file in files_to_cat:
        cat_st = cat_st + file + " "
    cat_st = cat_st + " > " + outfile
    os.system(cat_st)
#************************************************************#
if __name__ == "__main__":
    if len(sys.argv)!=4:
        usage()
    mc = MakeClan(sys.argv[1], sys.argv[2], sys.argv[3])
    mc.write_files()
    # now cat the config files and loop files together.
    mc.cat_files()
