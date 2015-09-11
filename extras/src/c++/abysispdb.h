/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: abysispdb.h                                  **/
/**    Date: Friday 27 Jun 2008                                **/
/**    Description: Header file abysispdb.cc                   **/
/**                                                            **/
/****************************************************************/
/** include the critical C functions. ***/
extern "C" {
#include "pdb.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/types.h>
    PDB * ReadPDB(FILE *,int *);
    PDB * RemoveAlternates(PDB *);
#include "pdb2pir.h"
}
/*** STL and other standard header files. ***/
#include <vector>
#include <iostream>
#include <sstream>
#include <string>
#include <iterator>
#include <map>
#include <utility>
#include <fstream>
/*** abysis headers ***/
#include "utils.h"
#include "reference.h"
#include "author.h"
#include "chain.h"
#include "numbering.h"
#include "chain_types.h"
#include "structure.h"
#include "regionconfig.h"
#include "antibody.h"
using namespace std;
/*** Function prototypes and class declarations. ***/
void Usage();
/**************************************************************************/
typedef struct distance_label{
    double distance;
    string label;
}DISTANCE_LABEL;
/**************************************************************************/
class AbysisPdb{
    private:
		RegionConfig *rC;
		string original_filename;
        string the_filename;
        string pdb_sections_dir;
        double resolution;
        double rfactor;
        int    struc_type;
        string name;
        string accession;
        string species;
        string submission_date;
        string update_date;
        string iface_config_file;
        WHOLEPDB *whole_pdb;
        Reference *pdb_refs;
        Structure *a_structure;
        vector<Antibody> the_antibodies;
        vector<Chain> the_chains;
        multimap<string, Chain> all_the_chains;
        multimap<string, string> mol_id_to_chain_label;
        multimap<string, string>chain2species;
        void nearest_pairs(multimap<string,double>pairing_map);
        void make_ab(string label_one, string label_two, double distance);
        bool compatable_types(string t_one, string t_two);
        bool at_least_one_numbered();
        vector<string> obtain_seqres_chains();
        void add_chain_residue_objects(string seq, int chain_count);
        void add_chain_residue_objects_two(string seq, int chain_count, int start,int end);
        PDB* move_pdb_pointer_to_start_of_relevant_chain_data(int c_in_q);
        Chain set_chain_data(vector<string> config);
        void get_mol_id2chain_label();
        bool is_a_sc_fv(string seq_res_seq,int chain_in_q, vector<string>&ret_seqs, vector<int>&locations);
        double determine_percentage_alanine_or_glycine(string seq_in_q);
		//void write_loop_data(string filename, string start, string end);
    public:
        AbysisPdb(char *filename, string dname);
        ~AbysisPdb();
        void print_header();
        void obtain_update_date();
        void obtain_submission_date();
        void obtain_accession();
        void obtain_name();
        void obtain_chains_residues_atoms();
        void obtain_chains_residues_atoms_old();
        void obtain_chain_types();
        void obtain_numbering();
        void obtain_reference();
        void obtain_pairing();
        void obtain_species();
        void printXml();
        void printAcaca();
        void print_failed_chains();
        void open_a_pipe_and_wait(string filename);
        vector<string> what_numbered_residues_form_iface();
};
/**************************************************************************/

