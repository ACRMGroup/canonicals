/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: numbering.h                                  **/
/**    Date: Tuesday 11 Mar 2008                               **/
/**    Description: A wrapper to Abhi's numbering program.     **/
/**                                                            **/
/****************************************************************/
#ifndef NUMBERING_DEFINED
#define NUMBERING_DEFINED
#include <string>
#include <vector>
#include "utils.h"

using namespace std;
class Numbering{
    private:
        string seq_to_be_numbered;
        string pir_filename;
        string abnum_location;
        string get_numbered_residues(vector<string> num_out);
        vector<string> get_numbers(vector<string> num_out);
        vector<string> do_numbering(string e_string);
    public:
        Numbering(string seq);
        ~Numbering();
        vector<string> kabat_numbering();
        vector<string> chothia_numbering();
        vector<string> open_a_pipe_and_execute(string e_string);
};


#endif
