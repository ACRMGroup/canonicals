/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: residue.h                                    **/
/**    Date: Thursday 6 Mar 2008                               **/
/**    Description: Class to hold residue details              **/
/**                                                            **/
/****************************************************************/

#ifndef RESIDUE_DEFINED
#define RESIDUE_DEFINED
#include <string>
#include <stdio.h>
#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include "atoms.h"
using namespace std;

class Residue{
    private:
        string residue_name;
        string kabat_number;
        string chothia_number;
		string resnum;
        vector<Atom> residue_atoms;
        int pdb_number;
        string insert;
    public:
		string line;
        Residue();
        Residue(int num,string name);
        void printXml();
        void printAcaca();
		void print_res_line();
		void write_lines(FILE *fp);
		string numbered_line(string line_in_q);
        void write_loop_data(FILE* ofile);
        void clear();
        void set_resnum_resname_insert(int r_num,string name,string insert,string resnum_i);
        void set_resnum_resname(string name,int rnum);
        void set_kabat_number(string k_number);
        void set_chothia_number(string c_number);
        bool compare_chothia_number(string c_in_q);
        void add_atom(Atom an_atom);
        int  obtain_resnum();
        string obtain_resname();
        double closest_atom_distance(Residue another_res);
		void  extract_chain_resnum_insert_from_chothia(string c_num,string& a_chain, string& a_resn, string& a_insert);
        // a unique id combining pdb_number, residue_name and insert code
        string unique_id;
};

#endif
