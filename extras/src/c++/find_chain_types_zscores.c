#define SIM

/* This program contains functions to read a PIR format file containing amino acid sequence(s). Further,
   there is a function to ascertain the type of in the file: light, heavy, or antigen.
*/

# include <string.h>
# include <stdio.h>
# include <math.h>
# include <stdlib.h>
# include <errno.h>
# include <regex.h>
# include <unistd.h>

# include "standard.h"
# include "chaintype.h"
# include "subim.h"
#include "array.h"

# define MAXSEQS 40000
# define MAXSEQLEN 20000
# define MAXPROTEINIDLEN 200

/* ////////////////////////////////////[NEW ADDITION]////////////////////// */

BOOL completePIRFileFlag=FALSE;

/* ////////////////////////////////////[NEW ADDITION]////////////////////// */


/* -------------------- VARIABLES VISIBLE OUTSIDE ---------------------------

   struct databaseInformation
   {
      char type[10],path[200];
      double zScoreThreshold;
      double humanMeanPairwiseIdentity,humanSD;
   };
   
   struct databaseMapFileFields
   {
      char databaseType[10];
   
      char humanDatabasePath[100],
           mouseBarsFilePath[100],
           humanBarsFilePath[100];
   
      double humanMeanPercentageIdentity,humanSD;
   };


   FUNCTIONS:
   ----------

   int read_amino_acid_sequences(char *filename,char **seqs,char *proteinIdentifier,BOOL isConsensus);

   int read_pir_modified(char *filename,char **seqs,char **proteinIdentifiers,BOOL isConsensus)

   BOOL extract_chain_labels(char **proteinIdentifiers,char *chainLabels,int numberOfSequences);

   void find_chain_types(char **aaSequence,int *chainType,int numberOfSequences,BOOL iszScoreApproach);
   
   void find_chain_types_zscores(char **aaSequence,int *chainType,int numberOfSequences);
 
   void remove_junk_characters(char *newSequence,char *oldSequence);
 
   BOOL run_ssearch33_and_check_threshold(char *inputFilename,struct databaseInformation *obj);
 
   void initialise_database_information_structure(struct databaseInformation *obj,
                                                  char *type,
                                                  char *humanDBPath,
                                                  double humanMeanPercentageIdentity,
                                                  double humanSD,
                                                  double zScoreThreshold);
 
   int fetch_values_from_database_map_file(FILE *fp,
                                           char *databaseType,
                                           struct databaseMapFileFields *obj);

   int read_pir_final(char *inputFilename,
                      char **sequences,
                      char **proteinIdentifiers,
                      BOOL isConsensus)

--------------------------------------------------------------------------- */


/* ------------------- FUNCTION DEFINITION SECTION ------------------------ */


/* int read_amino_acid_sequences(char *filename,char **seqs,BOOL isConsensus):

   This function reads a PIR format input file (given by filename) and the
   amino acid sequences in the file are written into the two dimensional
   character array pointed to by "seqs". The flag isConensus indicates whether
   the input file contains normal sequences or specialized consensus patterns
   as used in the Kabat numbering program.

   It returns the number of sequences that were read successfully.
*/

int read_amino_acid_sequences(char *filename,char **seqs,char *proteinIdentifier,BOOL isConsensus)
{
   FILE *fp;
   char line[2000],*p;
   int n=0;
   char aaSequence[2000];

   aaSequence[0]=0;

   fp=fopen(filename,"r");

   if(fp == NULL)
      fp=stdin;

   if( feof(fp) )
   {
      fclose(fp);
      return -1;
   }

   while(line[0] != '>')
      fgets(line,200,fp);

   strcpy(proteinIdentifier,line);

   fgets(line,200,fp); /* Progress to the next line. */

   while(! feof(fp) )
   {
      strcpy(line,"");

      fgets(line,1000,fp);

      if(! strcmp(line,"") )
      {
	 break;
      }

      if(line[strlen(line)-1] == '\n')
	 line[strlen(line)-1] = '\0';

      if( (p= strchr(line,'*')) )
      {
	 *p = '\0';
	 strcat(aaSequence,line);
	 seqs[n]=(char *)malloc(strlen(aaSequence)+1);
	 remove_junk_characters(seqs[n],aaSequence);
	 strcpy(seqs[n],aaSequence);
	 aaSequence[0]=0;
	 n++;
      }
      else
	 strcat(aaSequence,line);
   }

   return n;
}


/* int read_pir_modified(char *filename,char **seqs,char **proteinIdentifier,BOOL isConsensus):

   This is a modified version of the function "read_amino_acid_sequences". It reads a PIR format
   file/stdin that contains a protein identifier for every sequence. These are read into the two
   dimensional character array "proteinIdentifier".

   The function returns the number of sequences read from the file/stdin successfully.
*/
 

int read_pir_modified(char *filename,char **seqs,char **proteinIdentifiers,BOOL isConsensus)
{
   FILE *fp;
   char line[2000],*p;
   int n=0;
   char aaSequence[2000];

   /* Declare and initialize variables for the regular expression part. */

   char pattern[]="[a-z0-9]";
   regex_t re;
   int status=0;

   /* Compile the regular expression. */

   aaSequence[0]=0;

   if( regcomp(&re, pattern, REG_EXTENDED|REG_NOSUB) != 0)
   {
      return -1;
   }

   /* Now that the regular expression has been compiled successfully, proceed ahead. */

   if(! strcmp(filename,"") )
   {
      fp=stdin;
   }
   else
   {
      fp=fopen(filename,"r");
   }

   if(fp == NULL)
   {
      return -1;
   }

   if( feof(fp) )
   {
      regfree(&re);
      fclose(fp);
      return -1;
   }

   while( fgets(line,2000,fp) )
   {
      if(line[0] == '>')
      {
         proteinIdentifiers[n]=(char *)malloc(strlen(line));
         line[strlen(line)-1]='\0';
         strcpy(proteinIdentifiers[n],line);
         continue;
      }

      /*
      if( strstr(line,"Sequence") )
         continue;
      */

      status=regexec(&re, line,(size_t) 0, NULL, 0);

      if(! status)
      {
	 /* In this case, "line" contains a pattern matching the regular expression,
	    which is a small case letter. We dont process this line.
	 */

	 continue;
      }

      if(! strcmp(line,"") )
      {
         break;
      }

      if(line[strlen(line)-1] == '\n')
      {
         line[strlen(line)-1] = '\0';
      }

      if( (p= strchr(line,'*')) )
      {
         *p = '\0';
         strcat(aaSequence,line);
         seqs[n]=(char *)malloc(strlen(aaSequence)+1);
         remove_junk_characters(seqs[n],aaSequence);
         strcpy(seqs[n],aaSequence);
         aaSequence[0]=0;
         n++;
      }
      else
      {
         strcat(aaSequence,line);
      }
   }

   regfree(&re);

   if( proteinIdentifiers[1] )
   {
      completePIRFileFlag = TRUE;
   }
   else
   {
      completePIRFileFlag = FALSE;
   }

   return n;

} /* End of "read_pir_modified". */


int read_pir_final(char *inputFilename,
                   char **sequences,
                   char **proteinIdentifiers,
                   BOOL isConsensus)
{
   char line[20000],
        aaSequence[20000],
        *p = NULL;

   int numberOfSequences = 0;

   FILE *fp = NULL;

   if(! getenv("STDERR") )
   {
      stderr = stdout;
   }

   if( access(inputFilename, R_OK) )
   {
      printf("\nIn function \"read_pir_final\".\n");
      printf("\nUnable to open file \"%s\" in read mode.\n",inputFilename);
      return -1;
   }

   if(sequences == NULL)
   {
      sequences = (char **)Array2D(sizeof(char), MAXSEQS, MAXSEQLEN);
   }

   if(proteinIdentifiers == NULL)
   {
      proteinIdentifiers = (char **)Array2D(sizeof(char), MAXSEQS, MAXPROTEINIDLEN);
   }

   /* Open the file and read its contents */

   numberOfSequences = 0;

   fp = fopen(inputFilename, "r");

   while( fgets(line, 20000, fp) )
   {
      p = strchr(line, '\n');

      if(p)
      {
         (*p) = '\0';
      }

      if(line[0] == '>')
      {
         fgets(line, 20000, fp);

         p = strchr(line, '\n');

         if(p)
         {
            (*p) = '\0';
         }

         strcpy(proteinIdentifiers[numberOfSequences], line);
         aaSequence[0] = '\0';

         continue;
      }
      else
      {
         strcat(aaSequence, line);
      }

      if( strchr(line,'*') )
      {
         /* Terminate the sequence */

         p = strchr(aaSequence, '*');

         if(p)
         {
            (*p) = '\0';
         }

         strcpy(sequences[numberOfSequences], aaSequence);
         numberOfSequences++;
      }
   }

   fclose(fp);

   /* Return the number of sequences read successfully */

   return numberOfSequences;

} /* End of function "read_pir_final". */


int read_pir_all(char *inputFilename,
                 char **sequences,
                 char **proteinDescriptionLine1,
                 char **proteinDescriptionLine2,
                 BOOL isConsensus)
{
   char line[20000],
        aaSequence[20000],
        *p = NULL;

   int numberOfSequences = 0;

   FILE *fp = NULL;

   if(! getenv("STDERR") )
   {
      stderr = stdout;
   }

   if( access(inputFilename, R_OK) )
   {
      printf("\nIn function \"read_pir_all\".\n");
      printf("\nUnable to open file \"%s\" in read mode.\n",inputFilename);
      return -1;
   }

   if(sequences == NULL)
   {
      sequences = (char **)Array2D(sizeof(char), MAXSEQS, MAXSEQLEN);
   }

   if(proteinDescriptionLine1 == NULL)
   {
      proteinDescriptionLine1 = (char **)Array2D(sizeof(char), MAXSEQS, MAXPROTEINIDLEN);
   }

   if(proteinDescriptionLine2 == NULL)
   {
      proteinDescriptionLine2 = (char **)Array2D(sizeof(char), MAXSEQS, MAXPROTEINIDLEN);
   }

   /* Open the file and read its contents */

   numberOfSequences = 0;

   fp = fopen(inputFilename, "r");

   while( fgets(line, 20000, fp) )
   {
      p = strchr(line, '\n');

      if(p)
      {
         (*p) = '\0';
      }

      if(line[0] == '>')
      {
         strcpy(proteinDescriptionLine1[numberOfSequences], line);

         fgets(line, 20000, fp);

         p = strchr(line, '\n');

         if(p)
         {
            (*p) = '\0';
         }

         strcpy(proteinDescriptionLine2[numberOfSequences], line);
         aaSequence[0] = '\0';

         continue;
      }
      else
      {
         strcat(aaSequence, line);
      }

      if( strchr(line,'*') )
      {
         /* Terminate the sequence */

         p = strchr(aaSequence, '*');

         if(p)
         {
            (*p) = '\0';
         }

         strcpy(sequences[numberOfSequences], aaSequence);
         numberOfSequences++;
      }
   }

   fclose(fp);

   /* Return the number of sequences read successfully */

   return numberOfSequences;

} /* End of function "read_pir_all". */

/* void extract_chain_labels(char **proteinIdentifiers,char *chainLabels,int numberOfSequences):

   This function extracts the chain label from the set of protein identifiers.
   The protein identifier should have the format:

   >P1;ChainY

   Here, Y is the chain label that has to be extracted.
*/

BOOL extract_chain_labels(char **proteinIdentifiers,char *chainLabels,int numberOfSequences)
{
   int i=0;
   char *p=NULL;

   for(i=0;i<numberOfSequences;i++)
   {
      p=strstr(proteinIdentifiers[i],"Ch");

      if(! p)
         return FALSE;

      p+=5;

      chainLabels[i]=*p;
   }

   chainLabels[i]='\0';

   return TRUE;

} /* End of function "extract_chain_labels". */


/* int read_pir_abnum(char *filename,char **seqs,char **proteinIdentifier,BOOL isConsensus):

   This is a modified version of the function "read_amino_acid_sequences". It reads a PIR format
   file/stdin that contains a protein identifier for every sequence. These are read into the two
   dimensional character array "proteinIdentifier".

   The function returns the number of sequences read from the file/stdin successfully.
*/
 

int read_pir_abnum(char *filename,char **seqs,char **proteinIdentifiers,BOOL isConsensus)
{
   FILE *fp;
   char line[2000],*p;
   int n=0;
   char aaSequence[2000];

   /* Declare and initialize variables for the regular expression part. */

   char pattern[]="[a-z]";
   regex_t re;
   int status=0;

   /* Compile the regular expression. */

   aaSequence[0]=0;

   if( regcomp(&re, pattern, REG_EXTENDED|REG_NOSUB) != 0)
   {
      return -1;
   }

   /* Now that the regular expression has been compiled successfully, proceed ahead. */

   if(! strcmp(filename,"") )
   {
      fp=stdin;
   }
   else
   {
      fp=fopen(filename,"r");
   }

   if(fp == NULL)
   {
      return -1;
   }

   if( feof(fp) )
   {
      regfree(&re);
      fclose(fp);
      return -1;
   }

   while( fgets(line,2000,fp) )
   {
      if(line[0] == '>')
      {
         proteinIdentifiers[n]=(char *)malloc(strlen(line));
         line[strlen(line)-1]='\0';
         strcpy(proteinIdentifiers[n],line);
         continue;
      }

      /*
      if( strstr(line,"Sequence") )
         continue;
      */

      status=regexec(&re, line,(size_t) 0, NULL, 0);

      if(! status)
      {
	 /* In this case, "line" contains a pattern matching the regular expression,
	    which is a small case letter. We dont process this line.
	 */

	 continue;
      }

      if(! strcmp(line,"") )
      {
         break;
      }

      if(line[strlen(line)-1] == '\n')
      {
         line[strlen(line)-1] = '\0';
      }

      if( (p= strchr(line,'*')) )
      {
         *p = '\0';
         strcat(aaSequence,line);
         seqs[n]=(char *)malloc(strlen(aaSequence)+1);
         remove_junk_characters(seqs[n],aaSequence);
         strcpy(seqs[n],aaSequence);
         aaSequence[0]=0;
         n++;
      }
      else
      {
         strcat(aaSequence,line);
      }
   }

   regfree(&re);

   if( proteinIdentifiers[1] )
   {
      completePIRFileFlag = TRUE;
   }
   else
   {
      completePIRFileFlag = FALSE;
   }

   return n;

} /* End of function "read_pir_abnum" */


/* void find_chain_types(char **aaSequence,int *chainType,int numberOfSequences,BOOL iszScoreApproach):

   This function accepts a two dimensional character array containing the
   amino acid sequences of antibody variable chains. There is a parameter
   to indicate whether chain type must be determined through Z-Scores or
   using the SUBIM program.

   Chain assignments assume the following values:

   KAPPA - 1
   LAMBDA - 2
   HEAVY_CHAIN - 3
   ANTIGEN - 4

   This function does not return any values.
*/

void find_chain_types(char **aaSequence,int *chainType,int numberOfSequences,BOOL iszScoreApproach)
{
   if(iszScoreApproach)
      find_chain_types_zscores(aaSequence,chainType,numberOfSequences);
   else
      find_chain_types_subim(aaSequence,chainType,numberOfSequences);

} /* End of function "find_chain_types". */



/* void find_chain_types_zscores(char **aaSequence,int *chainType,int numberOfSequences):

   This function implements the Z-Score approach to determining chain types of antibody sequences.
   Z-Scores are calculated against the human databases (lambda, kappa, and heavy) for every query
   sequence. The Z-Score against each database is compared with the respective threshold and a
   chain assignment is made

   It makes one of the following assignments:

   KAPPA - 1
   LAMBDA - 2
   HEAVY - 3
   ANTIGEN - 4

   This function does not return any values.
*/

void find_chain_types_zscores(char **aaSequence,int *chainType,int numberOfSequences)
{
   int i=0;
   FILE *wfp=NULL,*dbmapFile;
   struct databaseInformation *lambdaDatabase,*kappaDatabase,*heavyDatabase;
   struct databaseMapFileFields *databaseMapFileFieldsPtr;

   dbmapFile=fopen(DATABASE_MAP_FILE,"r");
   for(i=0;i < numberOfSequences;i++)
   {
      /* Check if length of input sequence is less than 75 residues. If it is, then
         assign ANTIGEN type to the sequence and continue to process next sequence.
      */

      if( strlen(aaSequence[i]) < 80 )
      {
	 chainType[i] = ANTIGEN;
	 continue;
      }

      /* First, write the input sequence into a temporary FASTA format file. */
      system("rm /tmp/ab.fasta");
      wfp=fopen("/tmp/ab.fasta","w");
      if (wfp==NULL){
	printf("problem with temporay file sleeping +try again...");
	fflush(stdout);
	sleep(5);
	find_chain_types_zscores(aaSequence,chainType,numberOfSequences);
      }
      fprintf(wfp,">Temporary Sequence\n%s",aaSequence[i]);
      fclose(wfp);

      kappaDatabase=(struct databaseInformation *)malloc(sizeof(struct databaseInformation));
      databaseMapFileFieldsPtr=(struct databaseMapFileFields *)malloc(sizeof(struct databaseMapFileFields));

      fetch_values_from_database_map_file(dbmapFile,"kappa",databaseMapFileFieldsPtr);

      initialise_database_information_structure(kappaDatabase,
						"kappa",
						databaseMapFileFieldsPtr->humanDatabasePath,
						databaseMapFileFieldsPtr->humanMeanPercentageIdentity,
						databaseMapFileFieldsPtr->humanSD,
						kappaThresholdZScore);

      /* Now, run ssearch33 on the input sequence. */

      if( run_ssearch33_and_check_threshold("/tmp/ab.fasta",kappaDatabase) )
      {
	 /* The sequence is a Kappa class light chain sequence. Assign light chain type
	    and proceed to the next sequence.
	 */

	 free(kappaDatabase);
	 free(databaseMapFileFieldsPtr);
	 chainType[i]=KAPPA;
	 continue;
      }

      free(databaseMapFileFieldsPtr);
      free(kappaDatabase);

      /* Proceed to processing Lambda class light chain */

      lambdaDatabase=(struct databaseInformation *)malloc(sizeof(struct databaseInformation));
      databaseMapFileFieldsPtr=(struct databaseMapFileFields *)malloc(sizeof(struct databaseMapFileFields));

      fetch_values_from_database_map_file(dbmapFile,"lambda",databaseMapFileFieldsPtr);

      initialise_database_information_structure(lambdaDatabase,
                                                "lambda",
                                                databaseMapFileFieldsPtr->humanDatabasePath,
                                                databaseMapFileFieldsPtr->humanMeanPercentageIdentity,
                                                databaseMapFileFieldsPtr->humanSD,
                                                lambdaThresholdZScore);


      if( run_ssearch33_and_check_threshold("/tmp/ab.fasta",lambdaDatabase) )
      {
	 /* Sequence is a lambda class light chain. Assign lambda class type and proceed to next chain. */

	 free(lambdaDatabase);
	 free(databaseMapFileFieldsPtr);
	 chainType[i]=LAMBDA;
	 continue;
      }

      free(lambdaDatabase);
      free(databaseMapFileFieldsPtr);

      /* Finally check for Heavy chains */

      heavyDatabase=(struct databaseInformation *)malloc(sizeof(struct databaseInformation));
      databaseMapFileFieldsPtr=(struct databaseMapFileFields *)malloc(sizeof(struct databaseMapFileFields));

      fetch_values_from_database_map_file(dbmapFile,"heavy",databaseMapFileFieldsPtr);

      initialise_database_information_structure(heavyDatabase,
                                                "heavy",
                                                databaseMapFileFieldsPtr->humanDatabasePath,
                                                databaseMapFileFieldsPtr->humanMeanPercentageIdentity,
                                                databaseMapFileFieldsPtr->humanSD,
                                                heavyThresholdZScore);

      if( run_ssearch33_and_check_threshold("/tmp/ab.fasta",heavyDatabase) )
      {
	 free(heavyDatabase);
	 free(databaseMapFileFieldsPtr);
	 chainType[i]=HEAVY;
	 continue;
      }

      free(databaseMapFileFieldsPtr);
      free(heavyDatabase);

      /* After all this, the only remaining option is to assign an Antigen specification to the chain */

      chainType[i]=ANTIGEN;
   }

   fclose(dbmapFile);

} /* End of function "find_chain_types_zscores". */


/* void remove_junk_characters(char *newSequence,char *oldSequence):

   It copies printable characters in the array oldSequence into the array newSequence. This ensures
   the exclusion of junk characters from the new array.
*/

void remove_junk_characters(char *newSequence,char *oldSequence)
{
   int length=strlen(oldSequence),i=0,j=0;

   while( i < length ) 
   {
      if( isprint(oldSequence[i]) )
	 newSequence[j++]=oldSequence[i];

      i++;
   }

   newSequence[j]='\0';
}


/* int fetch_values_from_database_map_file(FILE *fp,char *databaseType,struct databaseMapFileFields *obj)

   This function parses the database map file and retrieves the following fields.

   1. Type of database.
   2. Path of human database.
   3. Path of mouse bars file.
   4. Path of human bars file.
   5. Human mean for the given database.
   6. Human standard deviation.

   All this information is stored in an object of type "struct databaseMapFileFields".
*/

int fetch_values_from_database_map_file(FILE *fp,char *databaseType,struct databaseMapFileFields *obj)
{
   char line[400],delimiter[]="&",*p,*field;
   int i=0;

   if(! fp)
      return 0;

   if( feof(fp) )
      rewind(fp);

   while( fgets(line,400,fp) && ! strchr(line,'&') )

   if( feof(fp) )
   {
      fclose(fp);
      return -1;
   }

   /* We are now at the first line with the required information. */

   while( fgets(line,400,fp) && (! strstr(line,databaseType)) );

   if( feof(fp) )
   {
      rewind(fp);

      while( fgets(line,400,fp) && (! strstr(line,databaseType)) );
   }

   if( feof(fp) )
   {
      fclose(fp);
      return -1;
   }

   /* Line now resembles the following format.

      human_heavy&/acrm/www/html/abhi/Z_SCORE_ANALYSIS/HUMAN_DATABASES/human_heavy.db.out&/acrm/www/html/abhi/Z_SCORE_ANALYSIS/BAR_FILES/mouse_heavy_zScore.bars&/acrm/www/html/abhi/Z_SCORE_ANALYSIS/BAR_FILES/human_heavy_zScore.bars&56.8365022788409&4.2223498316098

      We parse through the fields in this line (delimited by the character '&') and store the fields in
      a variable of type databaseMapFileFields. This is a structure consisting of the following fields.

      char databaseType[10];
      char humanDatabasePath[100];
      char mouseBarsFilePath[100];
      char humanBarsFilePath[100];
      double humanMeanPercentageIdentity,humanStandardDeviation;
   */

   line[strlen(line)-1] = '\0';

   p=line;
   i=0;

   while(i < 6)
   {
      field = strsep(&p,delimiter);

      if(i == 0)
	 strcpy(obj->databaseType,field);

      if(i == 1)
         strcpy(obj->humanDatabasePath,field);

      if(i == 2)
	 strcpy(obj->mouseBarsFilePath,field);

      if(i == 3)
	 strcpy(obj->humanBarsFilePath,field);

      if(i == 4)
         obj->humanMeanPercentageIdentity=atof(field);

      if(i == 5)
         obj->humanSD=atof(field);

      i++;
   }

   return 1;
}


/* CHAIN_TYPE run_ssearch33_and_check_threshold(char *inputFilename,struct databaseInformation *obj):

   This function accepts an amino acid sequence and determines whether it is an antibody chain or not.
   If it is, then it returns the type of chain (KAPPA, LAMBDA, or  HEAVY chain).
*/

BOOL run_ssearch33_and_check_threshold(char *inputFilename,struct databaseInformation *obj)
{
   char command[200],outputFilename[MAX_FILENAME_LENGTH];
	char holder[100];
   FILE *fp=NULL;

   double percentageIdentity=0,zScore=0,total=0,meanPairwiseIdentity=0;

   int lengthOfAlignment=0,numberOfPairwiseIdentities=0;

   sprintf(outputFilename,"%s.out",inputFilename);
   /*
   sprintf(command,"%s/ssearch33 -q -E 200 %s %s | grep identity | awk '{print $4,$7}' | sed 's/%//' > %s ",SSEARCH33PATH,
			  							                            inputFilename,
		  							                            obj->path,
													    outputFilename);**/
   sprintf(command,"%s/ssearch33 -q -E 200 %s %s | grep identity | awk '{print $4,$7}' | ",SSEARCH33PATH,
			  							                            inputFilename,
		  							                            obj->path);
   strcpy(holder," sed 's/%//' >");
   strcat(holder,outputFilename);
   strcat(command,holder);
   /*printf("%s\n",command);*/	
   system(command);

   /* Read the first line and check the length of alignment (2nd field). If this is less than the
      threshold alignment length, return ANTIGEN.
   */

   fp=fopen(outputFilename,"r");

   fscanf(fp,"%lf %d",&percentageIdentity,&lengthOfAlignment);

   if(lengthOfAlignment < MINIMUM_LENGTH_OF_ALIGNMENT)
   {
      fclose(fp);
      return FALSE;
   }

   /* Now calculate the following:

      1. Mean percentage identity against the human database.
      2. Z-Score.
   */

   total+=percentageIdentity;
   numberOfPairwiseIdentities=1;

   while(! feof(fp) )
   {
      fscanf(fp,"%lf %d",&percentageIdentity,&lengthOfAlignment);

      if( feof(fp) )
	 break;

      total+=percentageIdentity;
      numberOfPairwiseIdentities++;
   }

   fclose(fp);

   meanPairwiseIdentity=total/(double)numberOfPairwiseIdentities;

   zScore=(meanPairwiseIdentity - obj->humanMeanPairwiseIdentity)/obj->humanSD;

   if(zScore >= obj->zScoreThreshold)
      return TRUE;
   else
      return FALSE;

} /* End of function "run_ssearch33_and_check_threshold". */


/* void initialise_database_information_structure(struct databaseInformation *obj,
                                                  char *type,
                                                  char *humanDBPath,
                                                  double humanMeanPercentageIdentity,
                                                  double humanSD,
                                                  double zScoreThreshold):

   This function initialises the structure databaseInformation with the values that are passed
   to it as parameters.

   The format of the structure is:

   struct databaseInformation
   {
      char type[10],path[200];
      double zScoreThreshold;
      double humanMeanPairwiseIdentity,humanSD;
   };

*/

void initialise_database_information_structure(struct databaseInformation *obj,
                                               char *type,
                                               char *humanDBPath,
                                               double humanMeanPairwiseIdentity,
                                               double humanSD,
                                               double zScoreThreshold)
{
   strcpy(obj->type,type);
   strcpy(obj->path,humanDBPath);
   obj->zScoreThreshold=zScoreThreshold;
   obj->humanMeanPairwiseIdentity=humanMeanPairwiseIdentity;
   obj->humanSD=humanSD;
}
