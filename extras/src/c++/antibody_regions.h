/* Changes:

   18th Jan 2007 - Adding 2 fields to "struct region_consensus_sequences".

                   char **segboundary
                   char *operation
*/

# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <math.h>
# include <ctype.h>

# include "standard.h"
# include "array.h"



typedef struct region_consensus_sequences
{
   char **regionNames;                 /* Names of regions in the antibody */

   char **regionConsensusSequences;    /* Consensus patterns for the regions */

   int *lengths;                       /* Lengths of the consensus patterns */

   int *minlen,                        /* Minimum length of sequence in region as seen in Kabat database */
       *maxlen;                        /* Maximum length of sequence in region. */

   char *alignmentConditions;          /* Whether the sequence in the region should be aligned with the consensus pattern */

   char *uain;                         /* Whether or not alignment with consensus should be used in numbering */

   char **segboundary;                 /* Indicates the segments between which a region is enclosed. */

   char *operation;                    /* To indicate whether PROFILELEN of a segment must be subtracted from
                                          or added to the MAXLEN of the profile for finding segment mismatches.
                                          Eg: +/-
                                       */

}REGIONINFO;


int read_region_information_file(char *regionInformationFilename,
                                 REGIONINFO *regionInformation);

int allocate_region_info(REGIONINFO *regionInfo);

void free_region_info(REGIONINFO *regionInfo);
