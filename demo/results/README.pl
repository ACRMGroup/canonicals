

Name Automation
===============

                            2015
                       Tanner K. Byer,
                  	   Pomona College

                Email: tanner.byer@pomona.edu
                
The Name Automation program is used to ensure that cluster names remain consistent for 
antibody loops when the ____ script is run in subsequent trials. It is the goal to make
sure that cluster names are specific for cluster templates and not arbitrary from 
trail to trail. 

USAGE INSTRUCTIONS
-------------------

After running a doit.sh script within the demo directory for all available CDR loop 
structures in the Protein Data Base, run this program to update cluster names for old and 
new antibody loops. Results from the doit.sh will be found in the results directory in the 
form of .out files, one file for each clan of CDRs. 

.out files contain arbitrary cluster names 1, 2, 3 , etc. The Name Automation file will 
check a file containing the cluster names of previous labelled CDR loops, and then using 
this information, create final labels for all clusters within the .out file based on these
previous name assignments, making sure that loops previously labelled as 9A, for example, 
retain this cluster name even after the new cluster grouping. 
 
 In order to perform this action, you must call the name automation program
 (NameAutomation.pl) and then provide the command line with the file containing the new 
 cluster data (.out) for a given clan and then also provide the old cluster 
 assignments (.txt). 
 
 The final assignment results will appear on the screen, and can then be saved as a text 
 file and used during the next run of the program, replacing the old cluster
 assignment file(.txt). 