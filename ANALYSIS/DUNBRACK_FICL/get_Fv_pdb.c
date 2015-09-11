/* Program to extract the variable region of an antibody's structure from the entire Fab or IgG.

   March 2007 - Original version written by Abhinandan K. Raghavan while a PhD student in Andrew Martin's group.

   June 2011 - Modified by Abhinandan K. Raghavan while being employed by Novartis. Modifications made to
               accommodate the need to extract variable regions of LC/HC dimers.

   Program requirements (inputs):

   1) Numbering file for the variable region.
   2) The original PDB file.

*/

# include <string.h>
# include <stdio.h>
# include <stdlib.h>
# include <regex.h>

# include "chaintype.h"
# include "general.h"
# include "kabnum.h"


# define MAXBUFFER 2000
# define MAXSEQS 50
# define MAXSEQLEN 1000


/* ------------------------- FUNCTION DEFINITION SECTION --------------------- */


BOOL parse_command_line_parameters(int numberOfParam, char **param,
                                   char *numberedFile,
                                   char *pdbFilename,
                                   char *outputFilename)
{
   int i=1;

   while(i < numberOfParam)
   {
      if(! strcmp(param[i],"-num") )
      {
	 strcpy(numberedFile, param[i+1]);
	 i+=2;
	 continue;
      }
      else
      if(! strcmp(param[i],"-pdb") )
      {
	 strcpy(pdbFilename, param[i+1]);
	 i+=2;
	 continue;
      }
      else
      if(! strcmp(param[i],"-out") )
      {
	 strcpy(outputFilename,param[i+1]);
	 i+=2;
	 continue;
      }
      else
      {
	 return FALSE;
      }
   }

   return TRUE;

} /* End of function "parse_command_line_parameters". */


void Usage(char **argv)
{
   printf("\nUsage: %s <Arguments>\n\n", argv[0]);
   printf("Arguments are:\n");
   printf("\n1. -num <Kabat numbered file with alignment>");
   printf("\n2. -pdb <Original PDB file>");
   printf("\n3. -out <Output file (Optional)>\n\n");

} /* End of function "Usage". */


int get_chain_labels(FILE *fp, char *chainLabels)
{
   char line[MAXBUFFER],
        *p = NULL;

   int i = 0;

   while( fgets(line, MAXBUFFER, fp) )
   {
      if( ( p = strstr(line, "Chain: ") ) )
      {
         chainLabels[i++] = *(p + 7);
      }
   }

   chainLabels[i] = '\0';

   /* Return the number of chain labels read */

   return i;

} /* End of function "get_chain_labels" */


int write_chain(FILE *wfp, PDB *pdbCurrent, char *sequence, char *currentChain)
{
   int i = 0,
       firstResidueInChainNumber = 0;

   char currentInsertCode[8];

   firstResidueInChainNumber = pdbCurrent -> resnum;
   strcpy(currentInsertCode, pdbCurrent -> insert);

   while( (i < strlen(sequence) ) &&
          (pdbCurrent != NULL) &&
          (! strcmp(pdbCurrent -> chain, currentChain) ) )
   {
      if( (firstResidueInChainNumber != pdbCurrent -> resnum) ||
          ( strcmp(currentInsertCode, pdbCurrent -> insert) ) )
      {
         i++;

         while( islower(sequence[i]) )
         {
            i++;
         }

         firstResidueInChainNumber = pdbCurrent -> resnum;
         strcpy(currentInsertCode, pdbCurrent -> insert);
      }

      if(! strncmp(pdbCurrent -> record_type, "ATOM", 4) )
      {
         WritePDBRecord(wfp, pdbCurrent);
      }

      pdbCurrent = pdbCurrent -> next;
   }

   /* Check if number of residues written to the file is the same as length of sequence */

   if( i != strlen(sequence) )
   {
      fprintf(stderr, "\nIn function \"write_chain\".");
      fprintf(stderr, "\nMismatch in number of residues in PDB file and numbered sequence in Chain %s.", currentChain);
      fprintf(stderr, "\nLength of sequence: %d.", strlen(sequence));
      fprintf(stderr, "\nNumber of residues in PDB File: %d\n\n", i);
      return 0;
   }

   /* Return 1 to indicate successful processing */

   return 1;

} /* End of function "write_chain". */



int get_residue_number(char *position)
{
   /* The function is invoked in the following way:

      currentResidueNumber = get_residue_number(num -> position);

      The position string is of the following form: L28 or H36. The aim of
      this function is to extract the residue number (28 in L28 and 36 in H36)
      and return this number to the calling function.
   */

   char *p = position;
   int residueNumber = -1;

   if( ( (*p) != 'L' ) && ( (*p) != 'H' ) )
   {
      return -1;
   }

   /* Move p to point to the second character in the position string. */

   p++;

   /* Check if (*p) points to a number. If not, return -1 to the calling function. */

   if(! isdigit(*p) )
   {
      return -1;
   }

   /* Extract the number. */

   residueNumber = atoi(p);

   /* Return the residue number. */

   return residueNumber;

} /* End of function get_residue_number. */



int get_sequence_from_numbering_mod(KABATLIST *num, char **sequences)
{
   int i = -1,
       k = 0;

   int currentResidueNumber = -1,
       previousResidueNumber = -1;

   char previousChainType = ' ';

   if(sequences == NULL)
   {
      return -1;
   }

   /* Structure of KABATLIST:

      typedef struct kabat_list
      {
         char position[8],
         residueOneLetterCode;
         struct kabat_list *next;

      }KABATLIST;

   */

   while(num)
   {
      /* Set the previous residue number. */

      printf("\nPosition: %s", num -> position);
      fflush(stdout);

      currentResidueNumber = get_residue_number(num -> position);

      if(currentResidueNumber < 0)
      {
         fprintf(stderr, "\nIncorrect label %s", num -> position);
      }

      /* Increment the number of chains if required. */

      if( (previousChainType != num -> position[0]) ||
          (currentResidueNumber < previousResidueNumber) )
      {
         i++;
         sequences[i][0] = '\0';
         k = 0;
      }

      /* Set the previous residue number. */

      previousResidueNumber = currentResidueNumber;

      previousChainType = num -> position[0];

      /* Extract sequence */

      if(num -> residueOneLetterCode != '-')
      {
         sequences[i][k++] = num -> residueOneLetterCode;
      }

      num = num -> next;
   }

   sequences[i][k] = '\0';

   i++;

   /* Return number of sequences read */

   return i;

} /* End of sub-routine "get_sequence_from_numbering_mod". */




/* ------------------- END OF FUNCTION DEFINITION SECTION ------------------- */


int main(int argc,char **argv)
{
   FILE *fp = NULL,
        *wfp = NULL;

   KABATLIST *pdbNumbering = NULL,
             *p = NULL;

   int i=0,
       j = 0,
       numberOfChains = 0,
       numberOfSequences = 0,
       numberOfAtoms = 0;

   char numberedFile[MAX_FILENAME_LENGTH],
        pdbFilename[MAX_FILENAME_LENGTH],
        outputFilename[MAX_FILENAME_LENGTH],
        chainLabels[MAXSEQS + 1],
        currentChain[8],
        currentResidue;

   char **pdbChainSequences = NULL;

   PDB *pdbCurrent = NULL,
       *pdbStart = NULL;

   /* Parse the command line parameters */

   if(argc < 5)
   {
      Usage(argv);
      exit(0);
   }

   if(! parse_command_line_parameters(argc,argv,
                                      numberedFile,
                                      pdbFilename,
                                      outputFilename) )
   {
      Usage(argv);
      exit(0);
   }

   /* Check whether the required files are present */

   if( access(numberedFile, R_OK) )
   {
      fprintf(stderr, "\nFile \"%s\" not present.\n", numberedFile);
      return 0;
   }

   /* Allocate memory for the PDB sequences */

   pdbChainSequences = (char **)Array2D(sizeof(char), MAXSEQS, MAXSEQLEN);

   /* Get chain descriptions */

   fp = fopen(numberedFile, "r");

   numberOfChains = get_chain_labels(fp, chainLabels);

   fclose(fp);

   /* Read the Kabat numbered file into the standard structure:

      typedef struct kabat_list
      {
         char position[8],
              residueOneLetterCode;

         struct kabat_list *next;

      }KABATLIST;
   */

   pdbNumbering = read_kabat_numbered_file(numberedFile);

   /* Get sequence of every chain from the numbering */

   numberOfSequences = get_sequence_from_numbering_mod(pdbNumbering, pdbChainSequences);

   /* Check if the number of sequences is the same as the number of labels */

   if(numberOfSequences != numberOfChains)
   {
      fprintf(stderr, "\nNumber of sequences numbered is not the same as the number of chains.");
      fprintf(stderr, "\nAborting program.\n\n");
      return 0;
   }

   /* Open the PDB file; exit the program if the file isn't present */

   fp = fopen(pdbFilename, "r");

   pdbStart = ReadPDB(fp, &numberOfAtoms);

   if(! pdbStart)
   {
      fprintf(stderr, "\nFile \"%s\" does not exist.\n", pdbFilename);
      return 0;
   }

   /* Extract the required region of the PDB for each chain. Note - PDB structure:

      typedef struct pdb_entry
      {
         REAL x,y,z,occ,bval;
         struct pdb_entry *next;
         int  atnum;
         int  resnum;
         char record_type[8];
         char atnam[8];
         char atnam_raw[8];
         char resnam[8];
         char insert[8];
         char chain[8];
         char altpos;
      }  PDB;
   */

   wfp = fopen(outputFilename, "w");

   i = 0;

   while(i < numberOfChains)
   {
      pdbCurrent = pdbStart;

      sprintf(currentChain, "%c", chainLabels[i]);

      while( strcmp(pdbCurrent -> chain, currentChain) && pdbCurrent)
      {
         pdbCurrent = pdbCurrent -> next;
      }

      /* Move to the first residue in the sequence of the chain for which there
         is an entry in the ATOM record.
      */

      j = 0;

      while( ! isupper(pdbChainSequences[i][j]) )
      {
         j++;
      }

      /* Now, advance the pdbCurrent pointer so that it points to the first residue
         in the variable region of the chain. This is essentially to skip over residues
         that might be a part of the leader sequence.
      */

      currentResidue = three_to_one_mapping(pdbCurrent -> resnam);

      while(currentResidue != pdbChainSequences[i][j])
      {
         pdbCurrent = pdbCurrent -> next;
         currentResidue = three_to_one_mapping(pdbCurrent -> resnam);
      }

      if(! pdbCurrent)
      {
         fprintf(stderr, "\nChain %c not present in file %s.\n", chainLabels[i], pdbFilename);
         continue;
      }

      write_chain(wfp, pdbCurrent, pdbChainSequences[i], currentChain);
      i++;

      fprintf(wfp, "TER\n");
   }

   fclose(wfp);

   /* Free the memory */

   FreeArray2D(pdbChainSequences, MAXSEQS, MAXSEQLEN);

   p = pdbNumbering;

   while(pdbNumbering)
   {
      p = pdbNumbering;
      pdbNumbering = pdbNumbering -> next;
      free(p);
   }

   /* Return 1 to the compiler. */

   return 1;

} /* End of program */
