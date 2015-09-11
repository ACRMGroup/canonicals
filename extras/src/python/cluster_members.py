#!/usr/bin/env python
#************************************************************#
#                                                            #
#    Author: Jacob Hurst                                     #
#    File name: cluster_members.py                           #
#    Date: Tuesday 20 Jan 2009                               #
#    Description: Pulls out the members of the clusters.     #
#                                                            #
#************************************************************#
import sys
import pprint

alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']

matchletters = {}
matchletters['A'] = 0
matchletters['B'] = 1
matchletters['C'] = 2
matchletters['D'] = 3
matchletters['E'] = 4
matchletters['F'] = 5
matchletters['G'] = 6
matchletters['H'] = 7
matchletters['I'] = 8
matchletters['J'] = 9
matchletters['K'] = 10
matchletters['L'] = 11
matchletters['M'] = 12
matchletters['N'] = 13
matchletters['O'] = 14
matchletters['P'] = 15
matchletters['Q'] = 16
matchletters['R'] = 17
matchletters['S'] = 18
matchletters['T'] = 19
matchletters['U'] = 20
matchletters['V'] = 21
matchletters['W'] = 22
matchletters['X'] = 23
matchletters['Y'] = 24
matchletters['Z'] = 25
matchletters['-'] = -1

class ClusterMembers(object):
    def __init__(self, filename ):
        self.clanfilename = filename
        fIn = open(filename)
        lines = fIn.readlines()
        start_processing = False
        process_cluster_labels = False
        self.holder = {}
        self.labels = {}
        self.max_labelsuffix = {}
        self.lengths = {}
        self.medians = {}
        for line in lines:
            pos = line.find("BEGIN ASSIGNMENTS")
            if pos == 0:
                start_processing = True
            pos2 = line.find("END ASSIGNMENTS")
            if pos2 == 0:
                start_processing = False
            if start_processing == True and pos!=0:
                parts = line.split()
                fname = self.processfilename(parts[1])
                parts[1] = fname
                if parts[0] in self.holder:
                    self.holder[parts[0]].add(fname)
                else:
                    self.holder[parts[0]] = set()
                    self.holder[parts[0]].add(fname)
            pos = line.find("END LABELS")
            if pos!=-1:
                process_cluster_labels = False
            if process_cluster_labels == True:
                self.process_labels(line)
            pos = line.find("CLUSTER CLUSTER_LABEL")
            if pos == 0 :
                process_cluster_labels = True
        self.process_cluster_lengths(lines)
        self.process_medians(lines)
        fIn.close()
    ###**************************************************###
    def process_cluster_lengths(self, the_lines):
        """ Extracts the cdr length of each cluster. """
        parse_section = False
        for line in the_lines:
            pos = line.find("BEGIN CRITICALRESIDUES")
            if pos !=-1:
                parse_section = True
            if parse_section == True:
                pos = line.find("END CRITICALRESIDUES")
                if pos!=-1:
                    parse_section = False
                else:
                    pos = line.find("CLUSTER")
                    if pos == 0:
                        parts = line.split()
                        number = parts[1]
                        front = line.find("(")
                        end = line.find(")")
                        section = line[front:end]
                        parts = section.split(",")
                        length = parts[0]
                        length = length[9:]
                        length = length.strip()
                        length = length.rstrip()
                        self.lengths[number] = length
    ###**************************************************###
    def process_medians(self, the_lines):
        """ extracts and stores the representive pdb file for each cluster. """
        parse_section = False
        for line in the_lines:
            pos = line.find("BEGIN MEDIANS")
            if pos !=-1:
                parse_section = True
            if parse_section == True:
                pos = line.find("END MEDIANS")
                if pos == 0:
                    parse_section = False
                    break
                else:
                    parts = line.split()
                    cluster_no = parts[0].strip()
                    cluster_no = cluster_no.rstrip()
                    if cluster_no.isdigit():
                        pdb_id = parts[1]
                        start = pdb_id.rfind("/")
                        end = pdb_id.rfind(".")
                        pdb_id = pdb_id[start+4:end]
                        self.medians[cluster_no] = pdb_id
    ###**************************************************###
    def process_labels(self, line):
        """ processes the labels part of the clan file.."""
        line = line.rstrip("\n")
        parts =  line.split()
        self.labels[parts[0]]= parts[1]
        tail = parts[1]
        tail = tail[len(tail)-1:]
        length = parts[1]
        length = length[:len(length)-1]
        #print "tail is:", tail, matchletters[tail],"length is:",length
        if length in self.max_labelsuffix:
            if matchletters[tail] > self.max_labelsuffix[length]:
                self.max_labelsuffix[length] = matchletters[tail]
    ###**************************************************###
    def process_labels_two(self, labels_other):
        # clear out anything that might have been set
        self.max_labelsuffix = {}
        unique_other_labels = set()
        for label in labels_other:
            unique_other_labels.add(labels_other[label])
        # now set up max_label_suffix
        for label in unique_other_labels:
            tail = label[len(label)-1:]
            length = label[:len(label)-1]
            print "am i interested",label, tail, length
            if length in self.max_labelsuffix:
                if matchletters[tail] > self.max_labelsuffix[length]:
                    self.max_labelsuffix[length] = matchletters[tail]
            else:
                self.max_labelsuffix[length] = matchletters[tail]
        pprint.pprint(self.max_labelsuffix)
    ###**************************************************###
    def obtain_cluster_label(self, cluster):
        """ returns the cluster label """
        if cluster in self.labels:
            return self.label[cluster]
        else:
            return None
    ###**************************************************###
    def processfilename(self, fname):
        """ Strips out the filename and makes it standard """
        pos = fname.find(".")
        workwith  = fname[:pos]
        pos = workwith.rfind("/")
        workwith = workwith[pos+1:]
        pos = workwith.find("pdb")
        if pos == 0:
            workwith = workwith[3:]
        else:
            pos = workwith.find("p")
            if pos == 0:
                workwith = workwith[1:]
        if len(workwith)==5:
            workwith =workwith[:-1]
        return workwith
    ###**************************************************###
    def cluster_subset(self, other_cluster_sets, other_labels):
        """ steps through the other cluster set looking to see which cluster matches.. """
        if len(other_cluster_sets)==0:
            return
        self.process_labels_two(other_labels)
        matched = set()
        unmatched = set()
        final_labels = {}
        all = set()
        for other_cluster in other_cluster_sets:
            max_count = 0
            max_match = -1
            for cluster in self.holder:
                if other_cluster_sets[other_cluster].issubset(self.holder[cluster]):
                    print "Match Cluster ",other_cluster,other_labels[other_cluster],"(",len(other_cluster_sets[other_cluster]),"members) is subset of",cluster,"(",len(self.holder[cluster]),"members)"
                    matched.add(cluster)
                    final_labels[cluster] = other_labels[other_cluster]
                    break
                else:
                    temp_hold = other_cluster_sets[other_cluster].intersection(self.holder[cluster])
                    if len(temp_hold)>max_count:
                        max_count = len(temp_hold)
                        max_match = cluster
            if max_match != -1:
                print "Best match:",other_cluster,other_labels[other_cluster],"matching:(",max_count,"/",len(other_cluster_sets[other_cluster]),") is",max_match,"(",len(self.holder[max_match]),"members)" 
                matched.add(max_match)
                final_labels[max_match] = other_labels[other_cluster]
        # now find the difference between the unmatched and the matched...
        totalmatched = 0
        for cluster in self.holder:
            totalmatched = totalmatched + len(self.holder[cluster])
            if cluster not in matched:
                unmatched.add(cluster)
        # now print details of the unmatched clusters...
        totalunmatched = 0
        for unmatch in unmatched:
            final_labels[unmatch] = self.determine_new_label(unmatch)
            print "new unmatched cluster:", unmatch, "with :",len(self.holder[unmatch]), "members label:-", final_labels[unmatch]
            totalunmatched = totalunmatched + len(self.holder[unmatch])
        print "Total unmatched=", totalunmatched
        print "Total matched=", totalmatched
        total = totalunmatched + totalmatched
        percent = float(float(totalmatched)/float(total)*100.0)
        print "Percentage matched=", percent
        self.writeClusterDetails(final_labels)
    ###**************************************************###
    def determine_new_label(self, cluster_id):
        """ determine the new labels. """
        # length of the new label is:-
        length = self.lengths[cluster_id]
        if length in self.max_labelsuffix:
            new_max_suffix = self.max_labelsuffix[length]
            new_max_suffix = new_max_suffix + 1
        else:
            new_max_suffix = 0
        #print "concerned:",new_max_suffix
        if new_max_suffix >= len(alphabet):
            times = new_max_suffix / len(alphabet)
            val = new_max_suffix % len(alphabet)
            new_label = length
            new_label = new_label + alphabet[val]    
            for step in range(0,times):
                new_label = new_label + alphabet[val]    
        else:
            new_label = length+alphabet[new_max_suffix]
        self.max_labelsuffix[length] = new_max_suffix
        return new_label   
    ###**************************************************###
    def writeClusterDetails(self, labels):
        """ writes the final allocation of labels to clusters to the end of the \
            clan file. """
        pos, c_file = self.find_annotations()
        if pos != -1:
            c_file.seek(pos)
        c_file.write("\nBEGIN_LABELS\n")
        c_file.write("CLUSTER CLUSTER_LABEL\n")
        for l_in_q in labels:
            c_file.write("%s\t%s\n" % (l_in_q, labels[l_in_q]))
        c_file.write("END LABELS\n")
        c_file.close()
    ###**************************************************###
    def find_annotations(self):
        """ returns the position of the label annotations. """
        clan_file = open(self.clanfilename, "r+")
        old_pos = clan_file.tell()
        line = clan_file.readline()
        while len(line) > 0:
            current_pos = clan_file.tell()
            pos = line.find("CLUSTER CLUSTER_LABEL")
            if pos==-1:
                old_pos = current_pos
                line = clan_file.readline()
            else:
                return old_pos, clan_file
       # gone through not found it return -1
        return -1, clan_file 
    #********************************************************#
    def create_new_labels(self):
        """ just step through all the clusters assigning labels...."""
        final_labels = {}
        for cluster in self.holder:
            final_labels[cluster] = self.determine_new_label(cluster)
        self.writeClusterDetails(final_labels)
        
#************************************************************#
def usage():
	print "Usage: ./cluster_members.py <new clan output file> <old clan output file>"
	sys.exit(1)
#************************************************************#
if __name__ == "__main__":
    if len(sys.argv)!=3:
        usage()
    new = ClusterMembers(sys.argv[1] )
    old = ClusterMembers(sys.argv[2] )
    if len(old.labels) > 0:
	print "here"
        new.cluster_subset(old.holder, old.labels)
    else:
        # there is nothing relevent in the old clan file (H3)
        new.create_new_labels()
