/* Program to understand the importance of key residues for canonical class assignment.
  
   1) Let's assume a set of 100 unique variable regions (VL + VH sequences) - X.
  
   2) Let's say for CDR-L1 (using CDR-L1 as an example), the following definitions apply:
  
      a) c is CDR-L1 sequence.

      b) k is the set of key residues in the CDR for the specific class of CDR-L1.

      c) f is the set of key residues in the framework for the class of CDR-L1.
  
    3) For each x in X, do the following steps:
  
    4) Define X' as (X - x).
  
    5) For each x' in X':
  
       Case I)
  
       a) Calculate the sequence identity of x,x' over c.
  
       b) Record the best PDB b.
  
       c) Calculate the RMS over the the loop between b and x.
  
  
       Case II)
  
       a) Calculate the sequence identity of x,x' over k + f.
  
       b) Record the best PDB b.
  
       c) Calculate the RMS over the the loop between b and x.
  
  
       Case III)
  
       a) Calculate the sequence identity of x,x' over k + f.
  
       b) Record ALL the best PDBs b - set B.
  
       c) Calculate the sequence identity over (f + c) between every b (in B) and x.
  
       d) For the best b in step (c), calculate the RMSD with x over the loop.
*/

# include <stdio.h>
# include <strings.h>
# include <stdlib.h>
# include <ctype.h>
# include <math.h>

/* ------------------ DECLARATION OF GLOBAL VARIABLES -------------- */


/* ----------- END OF GLOBAL VARIABLES DECLARATION SECTION --------- */



/* --------------------- DATA STRUCTURES SECTION ------------------- */


/* ------------------ END OF DATA STRUCTURES SECTION --------------- */


/* Main code of the program starts here. */

int main(int argc, char **argv)
{
   /* Check for command line arguments. Required arguments:

      1. File with unique sequences.
      2. CDR definition (e.g.: L24-L34).
      3. File with mapping of PDB to canonical class.
      4. Canonicals definition file for loop.
      5. Directory with numbering files for the PDB codes.
      6. Extension for files with numbering.
      7. Output file name
   */

   if(argc < 8)
   {
      fprintf(stderr, "\nUsage: %s <Arguments>\n", argv[0]);
      fprintf(stderr, "\nArguments are:\n");
      fprintf(stderr, "\n1. 1. File with list of unique sequences in FASTA format as follows:\n");
      fprintf(stderr, "\n>P1;12e8");
      fprintf(stderr, "\nDIVMTQSQKFMSTSVGDRVSITCKASQNVGTAVAWYQQKPGQSPKLMIYSASNRYTGVPD.....\n");
      fprintf(stderr, "\n2. CDR definition (Example: \"L1:L24-L34\"");
      fprintf(stderr, "\n3. File with mapping of PDBs to canonical classes");
      fprintf(stderr, "\n4. Canonicals definition file with key residues for the loop");
      fprintf(stderr, "\n5. Directory containing numbering for the PDBs");
      fprintf(stderr, "\n6. Extension for the files with numbering");
      fprintf(stderr, "\n7. Output file name");
      fprintf(stderr, "\n\n");

      return 0;
   }

   /* Copy the command line arguments to local variables. */

   strcpy(uniqueSequencesFilename, argv[1]);
   strcpy(cdrDefinition, argv[2]);
   strcpy(pdbCanonicalClassMappingFilename, argv[3]);
   strcpy(canonicalDefinitionsFilename, argv[4]);
   strcpy(numberingDirectory, argv[5]);
   strcpy(numberingExtension, argv[6]);
   strcpy(outputFilename, argv[7]);

   /* Open the unique sequences file. */
 


} /* End of program. */
