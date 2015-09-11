/* Changes:

   18th Jan, 2007 - Added 2 fields to "struct region_consensus_sequences" (REGIONINFO)

                    char **segboundary
                    char *operation

   Changes have to be made to the following functions

   read_region_information_file
   allocate_region_info
   free_region_info

   to reflect the changes made to the structure.
*/



# include "antibody_regions.h"

# define MAXBUFFER 2000
# define MAXREGIONS 8
# define MAXREGIONNAMELEN 100
# define MAXREGIONSEQLEN 500
# define MAXSEGBOUNDARYSTRINGLEN 500


/* Note: Format of REGIONINFO:

   typedef struct region_consensus_sequences
   {
      char **regionNames;                 // Names of regions in the antibody //

      char **regionConsensusSequences;    // Consensus patterns for the regions //

      int *lengths;                       // Lengths of the consensus patterns //

      int *minlen,                        // Minimum length of sequence in region as seen in Kabat database //
          *maxlen;                        // Maximum length of sequence in region. //

      char *alignmentConditions;          // Whether the sequence in the region should be aligned with the consensus pattern //

      char *uain;                         // Whether or not alignment with consensus should be used in numbering //

      char **segboundary;                 // Indicates the segments between which a region is enclosed. //

      char *operation;                    // To indicate whether PROFILELEN of a segment must be subtracted from
                                             or added to the MAXLEN of the profile for finding segment mismatches.
                                             Eg: +/-
                                          //
   }REGIONINFO;

*/

int read_region_information_file(char *regionInformationFilename,
                                 REGIONINFO *regionInformation)
{
   FILE *fp = NULL;

   char *p = NULL;

   char line[MAXBUFFER],
        tagName[100];

   int i = -1;

   fp = fopen(regionInformationFilename, "r");

   if(fp == NULL)
   {
      printf("\nIn function \"read_region_information_file\".\n");
      printf("\nFile \"%s\" does not exist.\n",regionInformationFilename);
      return 0;
   }

   /* Read and parse the contents of the file */

   while( fgets(line, MAXBUFFER, fp) )
   {
      p = strchr(line, '\n');

      if(p != NULL)
      {
         (*p) = '\0';
      }

      if(! strncmp(line, "NAME: ", 6) )
      {
         /* >HFR1 */

         sscanf(line, "%s%s", tagName, regionInformation -> regionNames[++i]);
         continue;
      }
      else
      if(! strncmp(line, "SEQ: ", 5) )
      {
         /* The consensus pattern for the region.

            SEQ: XVQLXXSGXXL!XPGXS!$!SCX!S 
         */

         if( (regionInformation -> regionConsensusSequences[0]) == NULL )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nMemory not allocated for variable \"length\".");
            return 0;
         }

         if( (regionInformation -> lengths) == NULL )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nMemory not allocated for variable \"length\".");
            return 0;
         }

         regionInformation -> uain[i] = line[strlen(line) - 1];
         sscanf(line, "%s%s", tagName, regionInformation -> regionConsensusSequences[i]);

         regionInformation -> lengths[i] = strlen(regionInformation -> regionConsensusSequences[i]);

         continue;
      }
      else
      if(! strncmp(line, "MINLEN: ", 8) )
      {
         /* Minimum length of the region as seen in the Kabat database.

            MINLEN: 10
         */

         if( (regionInformation -> minlen) == NULL )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nMemory not allocated for variable \"minlen\".");
            return 0;
         }

         sscanf(line, "%s%d", tagName, &(regionInformation -> minlen[i]));

         if(! isdigit(line[strlen(line) - 1]) )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nInvalid line \"%s\" for range.",line);
            return 0;
         }

         continue;
      }
      else
      if(! strncmp(line, "MAXLEN: ", 8) )
      {
         /* The Range of lengths (deviation from length of consensus pattern)
            that can be accommodated in the region.

            MAXLEN: 25
         */

         if( (regionInformation -> maxlen) == NULL )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nMemory not allocated for variable \"maxlen\".");
            return 0;
         }

         sscanf(line, "%s%d", tagName, &(regionInformation -> maxlen[i]));

         if(! isdigit(line[strlen(line) - 1]) )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nInvalid line \"%s\" for range.",line);
            return 0;
         }

         continue;
      }
      else
      if(! strncmp(line, "ALIGN: ", 7) )
      {
         /* Whether the query sequence for this region must be aligned with the consensus pattern - (Y)es or (N)o.

            ALIGN: Y
         */

         if( (regionInformation -> alignmentConditions) == NULL )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nMemory not allocated for variable \"alignmentConditions\".");
            return 0;
         }

         regionInformation -> alignmentConditions[i] = line[strlen(line) - 1];

         if( (regionInformation -> alignmentConditions[i] != 'Y') &&
             (regionInformation -> alignmentConditions[i] != 'y') &&
             (regionInformation -> alignmentConditions[i] != 'N') &&
             (regionInformation -> alignmentConditions[i] != 'n') )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nInvalid line \"%s\" for alignment condition.",line);
            printf("\nOption \"%c\" not valid.\n",regionInformation -> alignmentConditions[i]);
            return 0;
         }

         regionInformation -> alignmentConditions[i] = toupper(regionInformation -> alignmentConditions[i]);

         continue;
      }
      else
      if(! strncmp(line, "UAIN: ", 6) )
      {
         if( (regionInformation -> uain) == NULL )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nMemory not allocated for variable \"uain\".");
            return 0;
         }

         regionInformation -> uain[i] = line[strlen(line) - 1];

         if( (regionInformation -> uain[i] != 'Y') && (regionInformation -> uain[i] != 'y') &&
             (regionInformation -> uain[i] != 'N') && (regionInformation -> uain[i] != 'n') )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nInvalid line \"%s\" for alignment condition.", line);
            printf("\nOption \"%c\" not valid.\n", regionInformation -> uain[i]);
            return 0;
         }

         regionInformation -> uain[i] = toupper(regionInformation -> uain[i]);

         continue;
      }
      else
      if(! strncmp(line, "SEGBOUNDARY: ", 13) )
      {
         /* SEGBOUNDARY: LFR2_Start-LFR1_End */

         sscanf(line, "%s%s", tagName, regionInformation -> segboundary[i]);
         continue;
      }
      else
      if(! strncmp(line, "OPERATION: ", 11) )
      {
         /* OPERATION: + */

         if( (regionInformation -> operation) == NULL )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nMemory not allocated for variable \"uain\".");
            return 0;
         }

         regionInformation -> operation[i] = line[strlen(line) - 1];

         if( (regionInformation -> operation[i] != '+') && (regionInformation -> operation[i] != '-') )
         {
            printf("\nIn function \"read_region_information_file\".");
            printf("\nInvalid line \"%s\" for operation.", line);
            printf("\nOption \"%c\" not valid.\n", regionInformation -> operation[i]);
            return 0;
         }

         continue;
      }

   }

   /* Close the file pointer */

   fclose(fp);

   /* Return the number of region regions successfully read */

   return i;

} /* End of function "read_region_information_file" */



int allocate_region_info(REGIONINFO *regionInfo)
{
   if(! (regionInfo -> regionNames = (char **)Array2D(sizeof(char), MAXREGIONS, MAXREGIONNAMELEN) ) )
   {
      return -1;
   }

   if(! ( regionInfo -> regionConsensusSequences = (char **)Array2D(sizeof(char), MAXREGIONS, MAXREGIONSEQLEN) ) )
   {
      return -1;
   }

   if(! ( regionInfo -> lengths = (int *)malloc(MAXREGIONS * sizeof(int) ) ) )
   {
      return -1;
   }

   if(! ( regionInfo -> minlen = (int *)malloc(MAXREGIONS * sizeof(int) ) ) )
   {
      return -1;
   }

   if(! ( regionInfo -> maxlen = (int *)malloc(MAXREGIONS * sizeof(int) ) ) )
   {
      return -1;
   }

   if(! ( regionInfo -> alignmentConditions = (char *)malloc( (MAXREGIONS + 1) * sizeof(char) ) ) )
   {
      return -1;
   }

   if(! ( regionInfo -> uain = (char *)malloc( (MAXREGIONS + 1) * sizeof(char) ) ) )
   {
      return -1;
   }

   if(! ( regionInfo -> segboundary = (char **)Array2D(sizeof(char), MAXREGIONS, MAXSEGBOUNDARYSTRINGLEN) ) )
   {
      return -1;
   }

   if(! (regionInfo -> operation = (char *)malloc( (MAXREGIONS + 1) * sizeof(char) ) ) )
   {
      return -1;
   }

   return 1;

} /* End of function "allocate_region_info" */


void free_region_info(REGIONINFO *regionInfo)
{
   FreeArray2D((char **)regionInfo -> regionNames, MAXREGIONS, MAXREGIONNAMELEN);
   FreeArray2D((char **)regionInfo -> regionConsensusSequences, MAXREGIONS, MAXREGIONSEQLEN);
   free(regionInfo -> lengths);
   free(regionInfo -> minlen);
   free(regionInfo -> maxlen);
   free(regionInfo -> alignmentConditions);
   free(regionInfo -> uain);
   FreeArray2D((char **)regionInfo -> segboundary, MAXREGIONS, MAXSEGBOUNDARYSTRINGLEN);
   free(regionInfo -> operation);

} /* End of function "free_region_info" */
