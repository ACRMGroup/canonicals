#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: run_findsrds.py                              #
#    Date: Thursday 19 Mar 2009                              #
##    Description: fires findsdrs through a python pipe      #
#                                                            #
#************************************************************#
import sys
import subprocess
import os

def runfindsdrs(executable, clan_out_file, outfile):
    if "DISPLAY" not in os.environ:
        os.environ["DISPLAY"] ="something"
    execute_st = executable + " " + clan_out_file + " " + outfile
    #execute_st = "/home/bsm2/jacob/projects/acaca/tools/acaca2009/src/findsdrs /home/bsm2/jacob/projects/acaca/results/L1_clan.out hope"
    output = subprocess.Popen(execute_st,shell=True).wait()
    print output

def usage():    
    print "./runfindsdrs.py <clanfile_location> <findsrds executable path> "
    sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv)!=3:
        usage()

    clanfile_location = sys.argv[1]
    executable = sys.argv[2]

    runfindsdrs(executable, clanfile_location+"/L1_clan.out", clanfile_location+"/L1_findsdrs.out")    
    runfindsdrs(executable, clanfile_location+"/L2_clan.out", clanfile_location+"/L2_findsdrs.out")    
    runfindsdrs(executable, clanfile_location+"/L3_clan.out", clanfile_location+"/L3_findsdrs.out")    
    runfindsdrs(executable, clanfile_location+"/H1_clan.out", clanfile_location+"/H1_findsdrs.out")    
    runfindsdrs(executable, clanfile_location+"/H2_clan.out", clanfile_location+"/H2_findsdrs.out")    
    runfindsdrs(executable, clanfile_location+"/H3_clan.out", clanfile_location+"/H3_findsdrs.out")    
