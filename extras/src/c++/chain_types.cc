/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: chain_types.cc                               **/
/**    Date: Tuesday 18 Mar 2008                               **/
/**    Description:  A C++ wrapper for Abhi's zscores          **/
/**                functions                                   **/
/**                                                            **/
/****************************************************************/
#include <iostream>
#include <vector>
#include <stdlib.h>
#include <unistd.h>
#include "chain_types.h"
#include "utils.h"

#define KAPPA_THRESHOLD_ZSCORE -3.873
#define LAMBDA_THRESHOLD_ZSCORE -4.497
#define HEAVY_THRESHOLD_ZSCORE -3.063
#define SSEARCHPATH "../../tools/fasta/"
#define MINIMUM_LENGTH_OF_ALIGNMENT 94

using namespace std;

// the constructor...
ChainType::ChainType(){
    FILE *dbmapFile;
    struct databaseMapFileFields *databaseMapFileFieldsPtr;
    // where the config file is hard coded.
    dbmapFile = fopen("../../config/zscores/database_map_file","r");
    // allocate some memory
    kappaDatabase=(struct databaseInformation *)malloc(sizeof(struct databaseInformation));
    lambdaDatabase=(struct databaseInformation *)malloc(sizeof(struct databaseInformation));
    heavyDatabase=(struct databaseInformation *)malloc(sizeof(struct databaseInformation));
    // now as in Abhi's code follow the sequence...
    // first we get the kappa data.
    databaseMapFileFieldsPtr=(struct databaseMapFileFields *)malloc(sizeof(struct databaseMapFileFields));
	char ka[30];
	strcpy(ka,"kappa");
	double k_tz = KAPPA_THRESHOLD_ZSCORE;
    fetch_values_from_database_map_file(dbmapFile,ka,databaseMapFileFieldsPtr);
    initialise_database_information_structure(kappaDatabase,
                        ka,
                        databaseMapFileFieldsPtr->humanDatabasePath,
                        databaseMapFileFieldsPtr->humanMeanPercentageIdentity,
                        databaseMapFileFieldsPtr->humanSD,
                        k_tz);
    // now we free the databaseMapFileFieldsPtr
    //free(databaseMapFileFieldsPtr);
    // now we get the lambda information
      strcpy(ka, "lambda");
      fetch_values_from_database_map_file(dbmapFile,ka,databaseMapFileFieldsPtr);
      initialise_database_information_structure(lambdaDatabase,
                                                ka,
                                                databaseMapFileFieldsPtr->humanDatabasePath,
                                                databaseMapFileFieldsPtr->humanMeanPercentageIdentity,
                                                databaseMapFileFieldsPtr->humanSD,
                                                LAMBDA_THRESHOLD_ZSCORE);

    // now we free the databaseMapFileFieldsPtr
    //free(databaseMapFileFieldsPtr);
    strcpy(ka, "heavy");
    fetch_values_from_database_map_file(dbmapFile,ka,databaseMapFileFieldsPtr);
    initialise_database_information_structure(heavyDatabase,
                                                ka,
                                                databaseMapFileFieldsPtr->humanDatabasePath,
                                                databaseMapFileFieldsPtr->humanMeanPercentageIdentity,
                                                databaseMapFileFieldsPtr->humanSD,
                                                HEAVY_THRESHOLD_ZSCORE);
    free(databaseMapFileFieldsPtr);
}

string ChainType::find_chain_type(string seq_in_q){
    // create a file to pass to ssearch in /tmp
    FILE *fp;
    // should be thread safe.
    char hold_this[100];
    string rm_string;
    int the_pid = getpid();
    sprintf(hold_this,"/tmp/ab_%d.fasta", the_pid);
    // if the string is not very long just bail
    if (seq_in_q.size()<35)
        return "";  
    fp = fopen(hold_this, "w");
    fprintf(fp, ">Temp sequence\n%s", seq_in_q.c_str() );
    fclose(fp);
    //cout<<"and heheheh"<<endl;
    if (run_ssearch33_and_check_threshold(hold_this, kappaDatabase)==true){
        // now junk that temp file
        rm_string = string("rm ") + hold_this;
        system(rm_string.c_str());
        return "kappa";
    }
    else if (run_ssearch33_and_check_threshold(hold_this, lambdaDatabase)==true){
        // now junk that temp file
        rm_string = string("rm ") + hold_this;
        system(rm_string.c_str());
        return "lambda";
    }
    else if (run_ssearch33_and_check_threshold(hold_this, heavyDatabase)==true){
        // now junk that temp file
        rm_string = string("rm ") + hold_this;
        system(rm_string.c_str());
        return "heavy";
    }
   rm_string = string("rm ") + hold_this;
   system(rm_string.c_str());
   return "";
}

bool ChainType::run_ssearch33_and_check_threshold(char *filename, struct databaseInformation *obj){
    string pipe_string;
    FILE *pipe_out;
    char line[100];
    double percentage_identity=0.0;
    int   length_of_alignment;
    double total = 0.0;
    int   number_of_identities = 1;
    double mean_pairwise_identity, z_score;
    // construct the search string
    pipe_string = string(SSEARCHPATH) + string("/ssearch33 -q -E 200 ") + string(filename) + " " + string(obj->path);
    pipe_string += " | grep identity | awk '{print $4,$7}' | ";
    pipe_string += " sed 's/%//' ";
    // open a pipe and run it
    pipe_out = popen(pipe_string.c_str(), "r");
    // now read the result only interested in the first line!
    fgets(line,sizeof line,pipe_out);
    // scan the line to extract the length of alignment and percentage identity
    fscanf(pipe_out,"%lf %d",&percentage_identity,&length_of_alignment);    
    if (length_of_alignment < MINIMUM_LENGTH_OF_ALIGNMENT){
        fclose(pipe_out);
        return false;
    }
    // ok what we've got is worth looking at let us calculate and return a Z score.
    total+=percentage_identity;
    number_of_identities=1;
    while (! feof(pipe_out)){
        fscanf(pipe_out,"%lf %d",&percentage_identity,&length_of_alignment);    
        if (feof(pipe_out))
            break;
        total+=percentage_identity;
        number_of_identities++;
        //cout<<"Total:"<<total<<" num_of_identities:"<<number_of_identities<<endl;
    }
    // close the pipe
    fclose(pipe_out);
    // determine the mean pairwise identity
    mean_pairwise_identity = total/(double)number_of_identities;
    // set the zscore
    z_score = (mean_pairwise_identity - obj->humanMeanPairwiseIdentity)/obj->humanSD;
    // and determine if it is significant.
    if (z_score >= obj->zScoreThreshold)
        return true;
    else
        return false;
    return false;
}

ChainType::~ChainType(){
    free(heavyDatabase);
    free(lambdaDatabase);
    free(kappaDatabase);
}

void ChainType::initialise_database_information_structure(struct databaseInformation *obj,
                                               char *type,
                                               char *humanDBPath,
                                               double humanMeanPairwiseIdentity,
                                               double humanSD,
                                               double zScoreThreshold)
{
   if (type!=NULL)
   strcpy(obj->type,type);
   if (humanDBPath!=NULL)
   strcpy(obj->path,humanDBPath);
   obj->zScoreThreshold=zScoreThreshold;
   obj->humanMeanPairwiseIdentity=humanMeanPairwiseIdentity;
   obj->humanSD=humanSD;
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

int ChainType::fetch_values_from_database_map_file(FILE *fp,char *databaseType,struct databaseMapFileFields *obj)
{
   char line[400];
   vector<string> parts;
   // hold all the lines...
    vector<string> the_lines;
    string config_line;
    int pos;
    // stick the fp back to the start
    rewind(fp);
    while (fgets(line,sizeof line, fp)){
        the_lines.push_back(line);
    }
    // now find the line we are interested in.
    for (unsigned int count=0;count<the_lines.size();count++){
        pos = the_lines[count].find(databaseType);
        if (pos!=-1){
            config_line = the_lines[count];
        }
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
   string something;
   Tokenize(config_line,parts,"&");
   if (parts.size()>=1)
    strcpy(obj->databaseType,parts[0].c_str());
   if (parts.size()>=2)
    strcpy(obj->humanDatabasePath,parts[1].c_str());
   if (parts.size()>=3)
    strcpy(obj->mouseBarsFilePath, parts[2].c_str());
   if (parts.size()>=4)
    strcpy(obj->humanBarsFilePath, parts[3].c_str());
   if (parts.size()>=5)
   obj->humanMeanPercentageIdentity=atof(parts[4].c_str());
   if (parts.size()>=6){
        something = parts[5];
        something = something.substr(0,6);
        obj->humanSD=atof(something.c_str());
    }
   parts.clear();
   return 1;
}

void ChainType::print_database_fields(){
    cout<<kappaDatabase->type<<endl;
    cout<<kappaDatabase->path<<endl;
    cout<<kappaDatabase->zScoreThreshold<<endl;
    cout<<kappaDatabase->humanMeanPairwiseIdentity<<endl;
    cout<<endl;
    cout<<lambdaDatabase->type<<endl;
    cout<<lambdaDatabase->path<<endl;
    cout<<lambdaDatabase->zScoreThreshold<<endl;
    cout<<lambdaDatabase->humanMeanPairwiseIdentity<<endl;
    cout<<endl;
    cout<<heavyDatabase->type<<endl;
    cout<<heavyDatabase->path<<endl;
    cout<<heavyDatabase->zScoreThreshold<<endl;
    cout<<heavyDatabase->humanMeanPairwiseIdentity<<endl;
}

