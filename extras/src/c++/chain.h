/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: chain.h                                      **/
/**    Date: Thursday 6 Mar 2008                               **/
/**    Description:  This file holds the chain data from pdb   **/
/**                parsing.                                    **/
/**                                                            **/
/****************************************************************/
#ifndef CHAIN_DEFINED
#define CHAIN_DEFINED

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include "residue.h"
#include "atoms.h"
#include "reference.h"

using namespace std;

class Chain{
    private:
        string species;
        string accession;
        string sequence;
        string type;
        string chain_name;
        string submission_date;
        string update_date;
        vector<Residue> chain_residues;
        multimap<string, Residue*> knumber;
        multimap<string, Residue*> cnumber;
        vector<Residue*> interface_residues;
        Reference *associated_ref;
    public:
        Chain();
        Chain(string c_n);
        bool numbering_ok;
        void increment_sequence(string a_res);
        void add_residue(Residue res);
        void add_atom_to_last_residue(Atom at);
        void printXml(bool print_tail);
        void write_loop_data(FILE* ofile, string start, string end, string c_label, string filename);
        void printAcaca();
		void print_res_line(string well);
        void clear();
        void set_type(string s_in_q);
        void set_name(string n_in_q);
        void set_sub_date(string d_in_q);
        void set_up_date(string d_in_q);
        void set_accession(string a_in_q);
        void set_numbering(string num_type,vector <string>nums);
        void set_interface_residues(vector<string> interface, string scheme);
        void set_reference(Reference *ref);
        void set_species(string sp_in_q);
        int lastresnum();
        string lastres_uniqueid();
        string obtain_sequence();
        string obtain_name();
        string obtain_type();
        Residue* obtain_residue_ref_by_number(string num,string scheme);
        double find_distance(Chain);       
};

#endif

