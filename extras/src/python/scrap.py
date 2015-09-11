#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: scrap.py                                     #
#    Date: Wednesday 11 Feb 2009                             #
#    Description: reorders a file and prints                 #
#                                                            #
#************************************************************#
import sys

fIn=open(sys.argv[1])
lines = fIn.readlines()
holder_num = []
for i in range(500):
    holder_num.append([])
added_allready = set()
for line in lines:
    pos = line.find("CLUSTER")
    if pos == 0:
        line = line.rstrip("\n")
        pos2 = line.find(")")
        pos3 = line.rfind("=")
        number = line[pos3+1:pos2]
        pos4 =number.find("CLUSTER")
        if pos4==-1:
            parts = line.split()
            num_i = int(number)
            if parts[1] not in added_allready:
                holder_num[num_i].append(parts[1])
                added_allready.add(parts[1])

print "Number PDBs in Cluster\tNumber of clusters"

total = 0
for i in range(len(holder_num)):
    if len(holder_num[i])!=0:
        running = i*len(holder_num[i])
        total = total + running

running=0.0
for i in range(len(holder_num)):
    if len(holder_num[i])!=0:
        #print i,"\t",holder_num[i],len(holder_num[i])
        running = running + float(i*len(holder_num[i]))/float(total)*100
        print i,"\t",len(holder_num[i]), i*len(holder_num[i]), float(i*len(holder_num[i]))/float(total)*100
print running
print total
        
    
        
