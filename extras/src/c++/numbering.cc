/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: numbering.cc                                 **/
/**    Date: Tuesday 11 Mar 2008                               **/
/***    Description: A wrapper to Abhi's numbering program.    **/
/**                                                            **/
/****************************************************************/
extern "C"{
    #include <stdio.h>
}
#include "numbering.h"
#include "utils.h"
#include <iostream>
#include <vector>
using namespace std;

Numbering::Numbering(string c_in_q){
    seq_to_be_numbered = c_in_q;
    // create the pir file.
    pir_filename = createPirFile(c_in_q);
    // set the abnum location
    abnum_location = "../../tools/numbering";
}


Numbering::~Numbering(){
    // remove the pir file created for the
    // numbering
    string rm_string;
    rm_string = "rm " + pir_filename;
    system(rm_string.c_str());
}

vector<string> Numbering::kabat_numbering(){
    vector<string> num_s;
    string execute_string;
    execute_string = abnum_location + "/kabnum_wrapper.pl " + pir_filename + " -k";
    num_s = do_numbering(execute_string);
    return num_s;
}
vector<string> Numbering::chothia_numbering(){
    vector<string> num_s;
    string execute_string;
    execute_string = abnum_location + "/kabnum_wrapper.pl " + pir_filename + " -c";
    num_s = do_numbering(execute_string);
    return num_s;
}

vector<string> Numbering::do_numbering(string execute_string){
    vector<string> num_s;
    vector<string> return_vs;
    string numbered_sequence;
    vector<string> numbers;
    int pos;
    // opens a pipe and runs the execute string
    num_s = open_a_pipe_and_execute(execute_string);
    // pull out the numbered sequence 
    numbered_sequence = get_numbered_residues(num_s);
    numbers = get_numbers(num_s);
    pos = seq_to_be_numbered.find(numbered_sequence);
    string app_st;
    string something("LeaderSeq ");
    for (unsigned int count=0; count<(unsigned int)pos; count++){
            app_st = something + numbered_sequence[count];
            return_vs.push_back(app_st);
    }
    string holder;
    for (unsigned int count=0;count<numbers.size();count++){
        holder = numbers[count] + " " + numbered_sequence[count];
        return_vs.push_back(holder);
    }
    string something_else("TailSeq ");
    for (unsigned int count=return_vs.size();count<seq_to_be_numbered.size();count++){
        app_st = something_else + seq_to_be_numbered[count];
        return_vs.push_back(app_st);
    }
    return return_vs;
}

vector<string> Numbering::open_a_pipe_and_execute(string e_string){
    FILE *obtain_result;
    char line[100];
    string holder;
    vector<string> ret;
    // open a pipe
    obtain_result = popen(e_string.c_str(), "r");
    // clear the stl vector
    ret.clear();
    // now read the result.
    while (fgets(line,sizeof line, obtain_result)){
        holder = line;
        stripLeadingAndTrailingBlanks(holder);
        stripNewLine(holder);
        ret.push_back(holder);
    }
    // close the pipe
    pclose(obtain_result);
    return ret;
}       

string Numbering::get_numbered_residues(vector<string> numbering_output){
    string obtained;
    string hold;
    vector <string> parsed;
    for (unsigned int count=0;count<numbering_output.size();count++){
        Tokenize(numbering_output[count],parsed," ");
        if (parsed[1] != "-"){
            obtained = obtained + parsed[1];
        } 
        parsed.clear();
    }
    return obtained;
}

vector<string> Numbering::get_numbers(vector<string> numbering_output){
    vector<string> return_vs;
    vector<string> parsed;
    for (unsigned int count=0;count<numbering_output.size();count++){
        Tokenize(numbering_output[count],parsed," ");
        if (parsed[1]!= "-"){
            return_vs.push_back(parsed[0]);
        }
        parsed.clear();
    }
    return return_vs;
}
/******************************************************/


