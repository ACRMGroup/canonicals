# include "general.h"
# include "seq.h"
# include "macros.h"
# include "standard.h"

#ifndef CHAINTYPE
#define CHAINTYPE

extern BOOL completePIRFileFlag;

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

int read_amino_acid_sequences(char *filename,char **seqs,char *proteinIdentifier,BOOL isConsensus);

int read_pir_modified(char *filename,char **seqs,char **proteinIdentifiers,BOOL isConsensus);

int read_pir_final(char *filename,char **seqs,char **proteinIdentifiers,BOOL isConsensus);

int read_pir_all(char *inputFilename,
                 char **sequences,
                 char **proteinDescriptionLine1,
                 char **proteinDescriptionLine2,
                 BOOL isConsensus);

BOOL extract_chain_labels(char **proteinIdentifiers,char *chainLabels,int numberOfSequences);

void find_chain_types(char **aaSequence,int *chainType,int numberOfSequences,BOOL iszScoreApproach);

void find_chain_types_zscores(char **aaSequence,int *chainType,int numberOfSequences);

void remove_junk_characters(char *newSequence,char *oldSequence);

double calculate_zScore(char *databaseType);

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

#endif
