/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: chain.cc                                     **/
/**    Date: Thursday 6 Mar 2008                               **/
/**    Description:  This file holds the chain data from pdb   **/
/**                parsing.                                    **/
/**                                                            **/
/****************************************************************/
extern "C"{
#include <stdio.h>
}
#include "chain.h"
#include "utils.h"

Chain::Chain(string c_in_q){
    chain_name = c_in_q;
    numbering_ok = false;
}
/****************************************************************/
Chain::Chain(){
    numbering_ok = false;
}
/****************************************************************/
void Chain::set_name(string n_in_q){
    chain_name = n_in_q;
}
/****************************************************************/
void Chain::set_sub_date(string d_in_q){
    submission_date.assign(d_in_q);
}
/****************************************************************/
void Chain::set_up_date(string d_in_q){
    update_date.assign(d_in_q);
}
/****************************************************************/
void Chain::add_residue(Residue r_in_q){
    chain_residues.push_back(r_in_q);
}
/****************************************************************/
void Chain::printXml(bool printTail){
    cout<<"\t<chain type=\'"<<type<<"\' >"<<endl;
    cout<<"\t\t<accession>"<<accession<<"</accession>"<<endl;
    cout<<"\t\t<submission_date>"<<submission_date<<"</submission_date>"<<endl;
    cout<<"\t\t<last_update>"<<update_date<<"</last_update>"<<endl;
    cout<<"\t\t<name>"<<chain_name<<"</name>"<<endl;
    cout<<"\t\t<species>"<<species<<"</species>"<<endl;
    cout<<"\t\t<sequence>\n";
    cout<<"\t\t<aa_sequence>"<<sequence<<"</aa_sequence>"<<endl;
    // step through the residues and make them print..
    for(vector<Residue>::iterator pos=chain_residues.begin(); pos!=chain_residues.end(); ++pos){
        pos->printXml();
    }
    cout<<"\t\t</sequence>\n";
    cout<<"\t\t<data_source>pdb</data_source>\n";
    if (printTail==true)
        cout<<"\t</chain>\n";
}
/****************************************************************/
void Chain::printAcaca(){
    // realy just calls the residues printAcaca method.
    for (vector<Residue>::iterator pos=chain_residues.begin(); pos!=chain_residues.end(); ++pos){
        pos->printAcaca();
    }
}
/****************************************************************/
void Chain::print_res_line(string fname){
	string changed;
	FILE *ab_file = fopen(fname.c_str(),"a");
	for (vector<Residue>::iterator pos=chain_residues.begin(); pos!=chain_residues.end(); ++pos){
		//changed = pos->numbered_line();
		pos->write_lines(ab_file);
		//if (changed.size()>0){
		//	cout<<changed;
		//	fprintf(ab_file,"%s",changed.c_str());
		//	cout<<pos->line;
		//}
	}
	fclose(ab_file);
}
/****************************************************************/
void Chain::write_loop_data(FILE* out_file, string start, string stop, string c_label, string filename){
	/***
    bool inloop = false;
    int fpos = c_label.find("_");
    c_label = c_label.substr(fpos+1,c_label.size()-fpos);
    for (vector<Residue>::iterator pos=chain_residues.begin(); pos!=chain_residues.end(); ++pos){
        if (pos->compare_chothia_number(start)==true){
			c_label = lower_case(c_label);
            fprintf(out_file,"loop %s %s",filename.c_str(),c_label.c_str());
            pos->write_loop_data(out_file);
            inloop = true;
        }
        if (inloop == true){
            if (pos->compare_chothia_number(stop)==true){
                fprintf(out_file," %s",c_label.c_str());
                pos->write_loop_data(out_file);
                inloop = false;
                fprintf(out_file,"\n");
            }
        }
    }
	***/
	/** sort out if L or H **/
	string lower_start = lower_case(start);
	string lower_stop = lower_case(stop);
    fprintf(out_file,"loop %s %s %s\n",filename.c_str(),lower_start.c_str(),lower_stop.c_str());
	
}
/****************************************************************/
void Chain::increment_sequence(string n_res){
    string seq;
    stripLeadingAndTrailingBlanks(n_res);
    seq = threeletter2singleletter_aacode(n_res);
    sequence+=seq;
}
/****************************************************************/
void Chain::clear(){
    sequence.clear();
    chain_residues.clear();
}
/****************************************************************/
int Chain::lastresnum(){
    // method returns the last resnum add to the vector of residues..
    Residue last_res;
    int ret_i;
    // if there is something in the vector
    if (chain_residues.size()>0){
        last_res = chain_residues.back();
        ret_i = last_res.obtain_resnum();
    }
    else{
        ret_i = -1;
    }
    return ret_i;
}
/****************************************************************/
string Chain::lastres_uniqueid(){
    // method returns the last resnum add to the vector of residues..
    Residue last_res;
    string ret_s;
    // if there is something in the vector
    if (chain_residues.size()>0){
        last_res = chain_residues.back();
        ret_s = last_res.unique_id;
    }
    else{
        ret_s = "";
    }
    return ret_s;
}
/****************************************************************/
void Chain::add_atom_to_last_residue(Atom at_in_q){
    vector<Residue>::reverse_iterator pos;
    chain_residues.back().add_atom(at_in_q);
    //pos->add_atom(at_in_q);
}
/****************************************************************/
string Chain::obtain_sequence(){
    return sequence;
}
/****************************************************************/
string Chain::obtain_name(){
    return chain_name;
}
/****************************************************************/
void Chain::set_numbering(string num_type, vector<string> nums){
    // ok for the numbers strip out entries with -
    vector<string> parts;
    int count = 0;
    for (vector<string>::iterator pos=nums.begin(); pos!=nums.end(); ++pos){
        Tokenize(*pos,parts," ");
                if (strcmp(num_type.c_str(),"kabat")==0){
                    chain_residues[count].set_kabat_number(parts[0]);
                    knumber.insert(pair<string, Residue*>(parts[0],&chain_residues[count]));
                }
                // assume we are dealing with a chothia situation
                else{
                    cnumber.insert(pair<string, Residue*>(parts[0],&chain_residues[count]));
                    chain_residues[count].set_chothia_number(parts[0]);
                }
                if ((parts[0]) != "LeaderSeq" and (parts[0]!="TailSeq")){
                    numbering_ok = true;
                }
            count++;
        parts.clear();
    }
}
/****************************************************************/
void Chain::set_type(string type_in_q){
    type = type_in_q;
}
/****************************************************************/
void Chain::set_accession(string acc_in_q){
    accession = acc_in_q;
}
/****************************************************************/
string Chain::obtain_type(){
    return type;
}
/****************************************************************/
Residue* Chain::obtain_residue_ref_by_number(string number,string scheme){
    Residue *ob=NULL;
    multimap<string, Residue*>::iterator access_all_areas;
    if (strcmp(scheme.c_str(),"kabat")==0){
        if (knumber.count(number)!=0){
            access_all_areas = knumber.find(number);
            ob = access_all_areas->second;
        }
    }
    else if (strcmp(scheme.c_str(),"chothia")==0){
        if (cnumber.count(number)!=0){
            access_all_areas = cnumber.find(number);
            ob = access_all_areas->second;
        }
    }
    return ob;
}
/****************************************************************/
void Chain::set_interface_residues(vector<string>i_face, string n_scheme){
    Residue *ob;
    // obtain residue reference for the iface residues
    for (vector<string>::iterator pos=i_face.begin();pos!=i_face.end(); ++pos){
        ob = obtain_residue_ref_by_number(*pos, n_scheme);
        if (ob!=NULL){
            interface_residues.push_back(ob);
        }
    }
}
/****************************************************************/
void Chain::set_reference(Reference *r_in){
    associated_ref = r_in;
}
/****************************************************************/
void Chain::set_species(string sp_in){
    species = sp_in;
}
/****************************************************************/
double Chain::find_distance(Chain another_chain){
    Residue *well;
    Residue *better;
    double closest_residue_distance = 1000000.0;
    double a_distance;
    for (vector<Residue*>::iterator pos = interface_residues.begin(); pos!=interface_residues.end(); ++pos){
        well = *pos;
        for (vector<Residue*>::iterator pos2 = another_chain.interface_residues.begin(); pos2!=another_chain.interface_residues.end(); ++pos2){
        better = *pos2;
         a_distance = well->closest_atom_distance(*better);
         if (a_distance<closest_residue_distance){
            closest_residue_distance = a_distance;
         }
         //cout<<well->obtain_resname()<<" "<<well->obtain_resnum()<<endl;
         //cout<<better->obtain_resname()<<" "<<better->obtain_resnum()<<endl;
         //cout<<a_distance<<" "<<closest_residue_distance<<endl;
        }
    }
    return closest_residue_distance;
}
/****************************************************************/


