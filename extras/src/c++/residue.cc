/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: residue.cc                                   **/
/**    Date: Thursday 6 Mar 2008                               **/
/**    Description: Class to hold residue details              **/
/**                                                            **/
/****************************************************************/
#include <iostream>
#include <fstream>
#include "residue.h"
#include "utils.h"
using namespace std;
/****************************************************************/
Residue::Residue(int a_number, string a_name){
    residue_name = threeletter2singleletter_aacode(a_name);
    pdb_number   = a_number;
}
/****************************************************************/
Residue::Residue(){
    
}
/****************************************************************/
void Residue::printXml(){
    if (kabat_number.size()==0){
        kabat_number = "TailSeq";
    }
    if (chothia_number.size()==0){
        chothia_number = "TailSeq";
    }
    cout<<"\t\t<residue aa=\'"<<residue_name<<"\' kabat_no=\'"<<kabat_number<<"\' chothia_no=\'"<<chothia_number<<"\'>\n";
    // print all the atom information...
    for(vector<Atom>::iterator pos=residue_atoms.begin(); pos!=residue_atoms.end(); ++pos){
        pos->printXml();
    }
    cout<<"\t\t</residue>\n";
}
/****************************************************************/
void Residue::extract_chain_resnum_insert_from_chothia(string c_num, string& f_chain, string& f_num,string& f_insert){
	f_chain = c_num.substr(0,1);
	
	char last_char = c_num[c_num.size()-1];
	if (!isdigit(last_char)){
		f_num = c_num.substr(1,c_num.size()-2);
		f_insert = last_char;
	}
	else{
		f_num = c_num.substr(1,c_num.size()-1);
		f_insert = " ";
	}
	if (f_num.size()==3){
		f_num = " " + f_num;
	}
	else if (f_num.size()==2){
		f_num = "  " + f_num;
	}
	else if (f_num.size()==1){
		f_num = "   " + f_num;
	}
	

}
/****************************************************************/
string Residue::numbered_line(string line_in_q){
	/** Returns the line but with the numbering inserted.. ***/
	string first_part;
	string last_part;
	string ret;
	string fake_chain;
	string fake_res_num;
	string fake_insert;
	// ok pull out the first part of the line before the chain label residue number and insert code
	first_part = line_in_q.substr(0,21);
	last_part = line_in_q.substr(31,80);
	
	if (chothia_number.size()>0 && chothia_number!="TailSeq"){
		//cout<<"first_part:"<<first_part<<endl;
		//cout<<chothia_number<<" and this makes sense:"<<residue_name<<endl;
		extract_chain_resnum_insert_from_chothia(chothia_number, fake_chain, fake_res_num, fake_insert);
		//cout<<"middle part:"<<fake_chain<<" "<<fake_res_num<<" "<<fake_insert<<endl;
		//cout<<"last_part:"<<last_part<<endl;
		ret = first_part + fake_chain +  fake_res_num + fake_insert;
		for (unsigned int count=ret.size();count<31;count++)
			ret = ret + " ";
		ret = ret + last_part;
		//cout<<"should be bountiful:"<<ret<<endl;
	}

	return ret;
}
/****************************************************************/
void Residue::write_lines(FILE *fp){
	string obtain;
	// first pull out and print the line for the residue.
	/*obtain = numbered_line(line);
	if (obtain.size()>0){
		fprintf(fp,"%s",obtain.c_str());
	}*/
	// now print the lines for each of the atoms.
	for (vector<Atom>::iterator pos=residue_atoms.begin();pos!=residue_atoms.end(); ++pos){
		//for (unsinged int count=0;count<pos->line.size();count++){
			string hold = pos->line;
			if (hold.size()>0){
			obtain = numbered_line(pos->line/*[count]*/);
			if (obtain.size()>0){
				fprintf(fp,"%s",obtain.c_str());
			}
			}
		//}
	}
}
/****************************************************************/
void Residue::printAcaca(){
    if (chothia_number.compare("TailSeq")!=0 && chothia_number.compare("LeaderSeq")!=0){
    for (vector<Atom>::iterator pos=residue_atoms.begin();pos!=residue_atoms.end(); ++pos){
        pos->printAcaca_first();
		cout<<" "<<singleletter2threeletter_aacode(residue_name);
        cout<<" "<<chothia_number[0]<<" "<<chothia_number.substr(1,chothia_number.size())<<"    ";
        pos->printAcaca_second();
    }
    }
}
/****************************************************************/
bool Residue::compare_chothia_number(string num_in_q){
    if (chothia_number.compare(num_in_q)==0){
        return true;
    }
    return false;
}
/****************************************************************/
void Residue::write_loop_data(FILE* outfile){
    string aa = singleletter2threeletter_aacode(residue_name);
    //fprintf(outfile, "%d %s %s",pdb_number,chothia_number.c_str(),aa.c_str());
    fprintf(outfile, "%s",resnum.c_str());
    fflush(outfile);
}
/****************************************************************/
void Residue::clear(){
    residue_atoms.clear();
    residue_name.clear();
    insert = "";
    unique_id = "";
    pdb_number = -1;
}

/****************************************************************/
void Residue::set_resnum_resname_insert(int num_i_q, string name_i_q, string insert_in_q, string resnum_in_q){
    ostringstream stream;
    residue_name = threeletter2singleletter_aacode(name_i_q);
    pdb_number = num_i_q;
    stream << pdb_number;
    insert = insert_in_q;
    unique_id = stream.str() + string("_") + insert_in_q ;
	resnum = resnum_in_q;
}
/****************************************************************/
void Residue::set_resnum_resname(string name_i_q, int num_i_q){
    ostringstream a_stream;
    if (name_i_q.size()>1)
        residue_name = threeletter2singleletter_aacode(name_i_q);
    else {
        // make sure it is uppercase.
        residue_name = name_i_q;
    }
    pdb_number = num_i_q;
    a_stream << pdb_number;
    unique_id = a_stream.str() + string("_"); 
}
/****************************************************************/
void Residue::add_atom(Atom to_add){
    residue_atoms.push_back(to_add);
}
/****************************************************************/
int Residue::obtain_resnum(){
    return pdb_number;
}
/****************************************************************/
string Residue::obtain_resname(){
    return residue_name;
}
/****************************************************************/
void Residue::set_kabat_number(string k_in_q){
    kabat_number = k_in_q;
}
/****************************************************************/
void Residue::set_chothia_number(string k_in_q){
    chothia_number = k_in_q;
}
/****************************************************************/
double Residue::closest_atom_distance(Residue another_residue){
    // for all the atoms in this residue compare the distance
    // with the atoms in the other residue
    double c_distance = 100000;
    double current_distance;
    Atom ap,ap_1; 
    for (vector<Atom>::iterator pos=residue_atoms.begin(); pos!=residue_atoms.end(); ++pos){
        ap_1 = *pos;
        for (vector<Atom>::iterator pos2=another_residue.residue_atoms.begin(); pos2!=another_residue.residue_atoms.end(); ++pos2){
            ap= *pos2;
            current_distance = ap_1.euclidean_distance(ap);
            if (current_distance < c_distance){
                c_distance = current_distance;
            }
        }
    }
    return c_distance;  
}
/****************************************************************/

