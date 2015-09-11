/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: chain_types.h                                **/
/**    Date: Tuesday 18 Mar 2008                               **/
/**    Description:  A C++ wrapper for Abhi's zscores          **/
/**                functions                                   **/
/**                                                            **/
/****************************************************************/
#ifndef CHAIN_TYPE_DEF
#define CHAIN_TYPE_DEF

#include <stdio.h>
#include <string>
#include <iostream>

using namespace std;

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

class ChainType{
    private:
        struct databaseInformation *lambdaDatabase;
        struct databaseInformation *kappaDatabase;
        struct databaseInformation *heavyDatabase;
        bool run_ssearch33_and_check_threshold(char *inputFilename, struct databaseInformation *obj);
        void initialise_database_information_structure(struct databaseInformation *obj,
                                               char *type,
                                               char *humanDBPath,
                                               double humanMeanPairwiseIdentity,
                                               double humanSD,
                                               double zScoreThreshold);
        int fetch_values_from_database_map_file(FILE *fp,char *databaseType,struct databaseMapFileFields *obj); 
    public:
        ChainType();
        ~ChainType();
        string find_chain_type(string sequence);
        void print_database_fields();
};
#endif

