/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: abysispdb.cc                                 **/
/**    Date: Monday 3 Mar 2008                                 **/
/**    Description:  Attempt to directly use the Andrew's    **/
/**                functions. Within a c++ STL program.      **/
/**                                                            **/
/****************************************************************/
#include "abysispdb.h"
using namespace std;
/**************************************************************************/
// constructor for AbysisPdb class
AbysisPdb::AbysisPdb(char *filename, string dir_name){
    FILE *fp,*fp2,*fp3;
    //int number_chains;
    bool obtain;
    Structure s;
    string meth;
    pdb_sections_dir = dir_name;
    the_filename = s.process_pdb_filename(filename);
	original_filename = filename;
    fp = fopen(filename,"r");
    // call ReadWholePDB to read atom records into pdb strucure
    whole_pdb = ReadWholePDB(fp );
    // second file pointer needed as ReadPDB closes it..
    fp2 = fopen(filename,"r");
    //pdbs = ReadPDB(fp,&number_of_atoms);
    obtain = GetResolPDB(fp2, &resolution, &rfactor, &struc_type);
    if (struc_type==STRUCTURE_TYPE_UNKNOWN)
        meth = "unknown";
    else if (struc_type==STRUCTURE_TYPE_XTAL)
        meth = "crystal";   
    else if (struc_type==STRUCTURE_TYPE_NMR)
        meth = "nmr";   
    else if (struc_type==STRUCTURE_TYPE_MODEL)
        meth = "model";   
    else if (struc_type==STRUCTURE_TYPE_ELECTDIFF)
        meth = "electdiff";   
    a_structure = new Structure(rfactor, resolution,meth,filename);   
    iface_config_file = "../../config/interface.txt";
    fclose(fp);
    pdb_refs = NULL;
    // Now read the SeqRes records
    fp3 = fopen(filename,"r");
    //ReadSeqresPDB(fp3,&number_chains);
    // now setup the regionconfig
    string fname = "../../config/region.xml";
    string a_type = "abm";
	rC = new RegionConfig(fname, a_type);
}
/******************************************************/
void AbysisPdb::print_header(){
    for(STRINGLIST *s=whole_pdb->header; s!=NULL;s=s->next){
        std::cout<<s->string;
    }
}
/******************************************************/
vector <string> AbysisPdb::obtain_seqres_chains(){
    char seqchains[80];
    char atomchains[80];
    char outchains[80];
    char *seqres;
    char *atom_seq;
    char *fixed;
    vector<string> fixed_sequences;
    MODRES *modres = NULL;
    // get the sequences from the seqres and modres records.
    modres = ReadMODRES(whole_pdb);
    seqres = ReadSEQRES(whole_pdb, seqchains, modres);
    // get the sequence from the atom records.
    atom_seq = PDBProt2Seq(whole_pdb->pdb);
    // get the atom chains
    GetPDBChains(whole_pdb->pdb, atomchains);
    string holder;
    holder = seqres;
    fixed = FixSequence(seqres, atom_seq,seqchains,atomchains,outchains);
    if (fixed==NULL){
        printf("WHY");
        if (seqres==NULL){
            cout<<"more doom"<<endl;
        }   
    }
    holder.assign(fixed);
    Tokenize(holder, fixed_sequences, "*");
    free(fixed);
    free(atom_seq);
    return fixed_sequences;
}
/******************************************************/
void AbysisPdb::obtain_submission_date(){
    int found;
    string s_in_q;
    string holder;
    vector <string> sections;
   // finds the header line..
    for(STRINGLIST *s=whole_pdb->header; s!=NULL; s=s->next){
        s_in_q.assign(s->string);
        found = s_in_q.find("HEADER");
        if (found!=-1){
            holder = s_in_q.substr(50,10);
            break;
        }
    } 
    Tokenize(holder, sections, "-");
    if (sections.size()==3){
        string month;
        month = month_name_to_number(sections[1]);
        submission_date = sections[0]+"/"+month+"/"+sections[2];
    }
    else{
        submission_date.assign("");
    }
}
/******************************************************/
void AbysisPdb::obtain_update_date(){
    int found;
    string s_in_q;
    string holder;
    vector <string> sections;
   // finds the header line..
    for(STRINGLIST *s=whole_pdb->header; s!=NULL; s=s->next){
        s_in_q.assign(s->string);
        found = s_in_q.find("REVDAT");
        if (found!=-1){
            holder = s_in_q.substr(14,8);
            break;
        }
    } 
    Tokenize(holder, sections, "-");
    if (sections.size()==3){
        string month;
        month = month_name_to_number(sections[1]);
        update_date = sections[0]+"/"+month+"/"+sections[2];
    }
    else{
        update_date.assign("");
    }
}
/******************************************************/
void AbysisPdb::obtain_name(){
    string s_in_q;
    int found;
    vector<string> parts;
    for (STRINGLIST *s=whole_pdb->header; s!=NULL; s=s->next){
        s_in_q.assign(s->string);
        found= s_in_q.find("TITLE",0);
        if (found!=-1){
            s_in_q = s_in_q.substr(found+5,s_in_q.size());
            stripNewLine(s_in_q);
            stripLeadingAndTrailingBlanks(s_in_q);
            if (isdigit(s_in_q[0]))
                s_in_q = s_in_q.substr(1,s_in_q.size());
            // strip new lines and blanks
            parts.push_back(s_in_q);
        }
    }
    for(unsigned int count=0;count<parts.size();count++)
        name+=parts[count];

    // make name lower case
    string holder;
    for (unsigned int count=0;count<name.size();count++){
        holder+=tolower(name[count]);
    }
    name.assign(holder);

}
/******************************************************/
void AbysisPdb::obtain_chains_residues_atoms(){
    vector<string> seqres_atoms_chains;
    vector<string> holder;
    vector<int> locs;
    bool what;
    // obtain the seqres sequences
    seqres_atoms_chains = obtain_seqres_chains();
    // cycle through the linked list.
    for (unsigned int count=0;count<seqres_atoms_chains.size();count++){
#ifdef DEBUG
        cout<<seqres_atoms_chains[count]<<endl;
#endif
        what = is_a_sc_fv(seqres_atoms_chains[count], count,holder,locs);
	    if (what==true){
            // now call add_chain_residue_objects for each 'chain'
            add_chain_residue_objects_two(seqres_atoms_chains[count], count, 0,locs[0]);
            add_chain_residue_objects_two(seqres_atoms_chains[count], count, locs[0],-1);
        }
	    else{
             // for each one of these add chain and residue objects
            add_chain_residue_objects(seqres_atoms_chains[count], count);	   
         }
       
    }
}
/******************************************************/
bool AbysisPdb::is_a_sc_fv(string sequence_in_q, int chain_in_q,vector<string>& seq_res_seqs, vector<int>&locations ){
    // Method returns true or false 
    // It returns true if the sequence_in_q is a scFv fragment.
    // If the sequence is an scFv fragment the sequence is split into two sections for light and heavy sequences, 
    PDB *p;
    int last_lower = -1;
    int start_pos = -1;
    string possible_linker;
    multimap<string,vector<int> > link_sections;
    bool return_b = false;
    // move the PDB pointer to the start of the relevant chain
    p = move_pdb_pointer_to_start_of_relevant_chain_data(chain_in_q);
    // step through the sequence
    for (unsigned int count=0; count<sequence_in_q.size();count++){
        if (islower(sequence_in_q[count])){
            if ((int)count==(last_lower+1)){
                possible_linker +=  sequence_in_q[count];
                last_lower++;
            }
            else{
                possible_linker = sequence_in_q[count];
                last_lower = count;  
                start_pos = count; 
            }
        }
        else{
            // if the size of the linker is greater than 0
            if (possible_linker.size()>0){
                vector<int> holder_iv;
                holder_iv.push_back(start_pos);
                holder_iv.push_back(last_lower);
                link_sections.insert(pair<string,vector<int> >(possible_linker,holder_iv));
                possible_linker.clear();
            }
        }
    }
    multimap<string,vector<int> >::iterator stepper;
    double percentage;
    int s_pos,e_pos;
    for(stepper=link_sections.begin();stepper!=link_sections.end();++stepper){
        s_pos = stepper->second[0];
        e_pos = stepper->second[1];
        percentage = determine_percentage_alanine_or_glycine(stepper->first);    
        // so if the section is either at least 50% G or A
        // and the section is at least 10 residues long
        if (percentage>0.5 && (e_pos-s_pos)>10){
            // and the separating fragement leaves numberable sequences...
            if ((s_pos>70) && ((sequence_in_q.size()-e_pos)>70)){
		        return_b = true;                
		        locations.push_back(s_pos);
		        locations.push_back(e_pos);
                // now split the sequence into sections and place the ab sections
                // in the return vector
                string first = sequence_in_q.substr(0,s_pos);
                string second = sequence_in_q.substr(e_pos,sequence_in_q.size()-e_pos);
                seq_res_seqs.push_back(first);
                seq_res_seqs.push_back(second);		
                break;
            }
        }
    }
    return return_b;
}
/******************************************************/
double AbysisPdb::determine_percentage_alanine_or_glycine(string seq_in_q){
    /*** method counts the number of alanines or glycines in the sequence and return a percentage
    based on total length of the sequence. ***/
    int alanine_count = 0;
    double return_d = 0.0;
    for (unsigned int count=0;count<seq_in_q.size();count++){
        if (seq_in_q[count]=='g' || seq_in_q[count]=='a')
            alanine_count++;
    }
    return_d =(double)((double)alanine_count/(double)seq_in_q.size());
    return return_d;
}
/******************************************************/
void AbysisPdb::add_chain_residue_objects(string chain_sequence, int chain_count){
    PDB *p;
    string key;
    string chain_label;
    string dash = "_";
    Chain chain_holder;
    Residue residue_holder;
    Atom atom_holder;
    string current_resnum;
    string current_insert;
	string last_resnum;
	string last_insert;
    string resnum_to_process;
    string insert_to_process;
    multimap<string,Chain>::iterator chain_p;
    // move the pdb pointer 
    p = move_pdb_pointer_to_start_of_relevant_chain_data(chain_count);
    // add a new chain object
    //cout<<"current chain_name:"<<p->chain<<endl;
    key = the_filename;
    key+= "_" + string(p->chain);
    chain_label.assign(p->chain);
    //cout<<"key:"<<key<<endl;
    // Add residues either from the seqres or the atom records.
    for (unsigned int count=0;count<chain_sequence.size();count++){
        if (isupper(chain_sequence[count])){
            //cout<<count<<" is upper:"<<chain_sequence[count];
            //cout<<" but inserting:"<<threeletter2singleletter_aacode(p->resnam)<<" "<<p->resnam<<" magic_number:"<<p->resnum<<" chain is what you think:"<<p->chain<<endl;
            residue_holder.clear();
			string a_1 = p->resnam;
			string a_2 = p->insert;
			 char nums[4];
            sprintf(nums,"%d",p->resnum);
            string a_3 = nums;

			//string a_3 = p->resnum;
            //residue_holder.set_resnum_resname_insert(count,p->resnam, p->insert,p->resnum);
            residue_holder.line = p->line;
            residue_holder.set_resnum_resname_insert(count,a_1, a_2, a_3);
            current_resnum = resnum_to_process = p->resnum;
            current_insert = insert_to_process = p->insert;
            // extract the atom records for that residue
            bool loop = true;
            //while ((current_resnum == resnum_to_process) && (current_insert == insert_to_process)){
            while (loop == true){
                current_resnum = p->resnum;
                current_insert = p->insert;
				if ((current_resnum == resnum_to_process) && (current_insert == insert_to_process)){
                	atom_holder.clear();
                //cout<<"resnum:"<<p->resnum<<endl;
                //cout<<"atnum:"<<p->atnum<<" atnam"<<p->atnam<<endl;
                	atom_holder.line = p->line;
                	atom_holder.set_data_items(p->x,p->y,p->z,p->atnum,p->atnam);
                	residue_holder.add_atom(atom_holder);
                // increment the PDB pointer
                	if (p->next!=NULL)
                    	p=p->next;
                	else{
                    	break;
                	}
				}
				else{
					loop = false;
				}
            }
        }
        else{
            //cout<<"is lower:"<<chain_sequence[count]<<endl;
            residue_holder.clear();
            char ob = toupper(chain_sequence[count]);
            string hold_s = "";
            hold_s+=ob;
            residue_holder.set_resnum_resname(hold_s,count);
        }
        // add the residue to the chain holder
        chain_holder.add_residue(residue_holder);
        chain_holder.increment_sequence(residue_holder.obtain_resname());
        // get the relevant species for this specific chain.
        multimap<string,string>::iterator pos;
        pos = chain2species.find(chain_label);
        if (pos!=chain2species.end())
            chain_holder.set_species(pos->second);
        chain_holder.set_name(name);
        chain_holder.set_sub_date(submission_date);
        chain_holder.set_up_date(update_date);
        chain_holder.set_accession(key);
    }
    all_the_chains.insert(pair<string, Chain>(key, chain_holder));
}
/******************************************************/
void AbysisPdb::add_chain_residue_objects_two(string chain_sequence, int chain_count, int start,int end){
    PDB *p;
    string key;
    string chain_label;
    string dash = "_";
    Chain chain_holder;
    Residue residue_holder;
    Atom atom_holder;
    string current_resnum;
    string current_insert;
    string resnum_to_process;
    string insert_to_process;
    multimap<string,Chain>::iterator chain_p;
    string little_i;little_i.assign("_i");
    string little_ii;little_ii.assign("_ii");
    // move the pdb pointer 
    p = move_pdb_pointer_to_start_of_relevant_chain_data(chain_count);
    // add a new chain object
    key = the_filename;
    key+= "_" + string(p->chain);
    
    if (start==0){
        chain_label.assign("i");
        key+= little_i;
    }
    else{
        chain_label.assign("ii");
        key+= little_ii;
    }
    // If the end tag is set to -1 continue until the end.
    if (end==-1){
        end = chain_sequence.size();
    }
    //cout<<"key:"<<key<<endl;
    // Add residues either from the seqres or the atom records.
    for (unsigned int count=0;count<chain_sequence.size();count++){
        if (isupper(chain_sequence[count])){
            if (count>=(unsigned int)start && count<=(unsigned int)end){
                //cout<<"inserting..."<<count<<" "<<start<<" "<<end<<endl;
                residue_holder.clear();
                 string a_1 = p->resnam;
            string a_2 = p->insert;
			char nums[4];
			sprintf(nums,"%d",p->resnum);
            string a_3 = nums;
            //residue_holder.set_resnum_resname_insert(count,p->resnam, p->insert,p->resnum);
            //            residue_holder.set_resnum_resname_insert(count,a_1, a_2, a_3);
				residue_holder.set_resnum_resname_insert(count,a_1,a_2,a_3);
            }
            current_resnum = resnum_to_process = p->resnum;
            current_insert = insert_to_process = p->insert;
            // extract the atom records for that residue
            while ((current_resnum == resnum_to_process) && (current_insert == insert_to_process)){
                current_resnum = p->resnum;
                current_insert = p->insert;
                if (count>=(unsigned int)start && count<=(unsigned int)end){
                    atom_holder.clear();
                //cout<<"resnum:"<<p->resnum<<endl;
                //cout<<"atnum:"<<p->atnum<<" atnam"<<p->atnam<<endl;
                    atom_holder.set_data_items(p->x,p->y,p->z,p->atnum,p->atnam);
                    residue_holder.add_atom(atom_holder);
                }
                // increment the PDB pointer
                if (p->next!=NULL)
                    p=p->next;
                else{
                    break;
                }
            }
        }
        else{
            //cout<<"is lower:"<<chain_sequence[count]<<endl;
            if (count>=(unsigned int)start && count<=(unsigned int)end){
                residue_holder.clear();
                char ob = toupper(chain_sequence[count]);
                string hold_s = "";
                hold_s+=ob;
                //cout<<"inserting..."<<count<<" "<<start<<" "<<end<<endl;
                residue_holder.set_resnum_resname(hold_s,count);
            }
        }
        if (count>=(unsigned int)start && count<=(unsigned int)end){
        // add the residue to the chain holder
        chain_holder.add_residue(residue_holder);
        chain_holder.increment_sequence(residue_holder.obtain_resname());
        // get the relevant species for this specific chain.
        multimap<string,string>::iterator pos;
        pos = chain2species.find(key);
        if (pos!=chain2species.end())
            chain_holder.set_species(pos->second);
        chain_holder.set_name(name);
        chain_holder.set_sub_date(submission_date);
        chain_holder.set_up_date(update_date);
        chain_holder.set_accession(key);
        }
    }
    all_the_chains.insert(pair<string, Chain>(key, chain_holder));
}
/********************************************************************/
PDB* AbysisPdb::move_pdb_pointer_to_start_of_relevant_chain_data(int c_in_q){
    int current_chain_count = 0;
    PDB* res;
    string current_chain_name;
    string holder;
    PDB* pdb_p = whole_pdb->pdb;
    current_chain_name = pdb_p->chain;
    while (current_chain_count!=c_in_q){
        pdb_p=pdb_p->next;
        holder = pdb_p->chain;
        if (holder!=current_chain_name){
            current_chain_name=holder;
            current_chain_count++;
        }
    }
    res = pdb_p;
    return res;
}
/******************************************************/
Chain AbysisPdb::set_chain_data(vector<string> config_items){
    Chain a_chain;
    a_chain.set_name(config_items[0]);
    a_chain.set_accession(config_items[1]);
    //a_chain.set_reference(config_items[2]);
    a_chain.set_species(config_items[3]);
    return a_chain;
}
/******************************************************/
void AbysisPdb::obtain_reference(){
    // cycle through the string list and gather reference 
    // information. 
    int found;
    vector<string> parts;
    std::string s_in_q;
    for (STRINGLIST *s=whole_pdb->header; s!=NULL;s=s->next){
        s_in_q.assign(s->string);
        found = s_in_q.find("JRNL",0);
        if (found!=-1){
            // add to a vector of strings and pass to reference constructor
            parts.push_back(s_in_q);
        }
    }
    pdb_refs = new Reference(parts);
    //pdb_refs->printXml();
    //exit(1);
}
/******************************************************/
void AbysisPdb::obtain_species(){
    string s_in_q;
    int found,found_2,found_3,found_4;
    species = "";
    string current_chain_label;
    string current_mol_id;
    string current_species_id;
    multimap<string,string>::iterator pos;
    get_mol_id2chain_label();
    // try to get the species from surce data associating the 
    // species name with chain name
    for (STRINGLIST *s=whole_pdb->header; s!=NULL; s=s->next){
        s_in_q.assign(s->string);
        // strip the white space
        stripLeadingAndTrailingBlanks(s_in_q);
        found = s_in_q.find("SOURCE");
        if (found != -1){
            found_2 = s_in_q.find("MOL_ID:");
            if (found_2!=-1){
                found_3 = s_in_q.find(";");
                if (found_3==-1){
                    found_3= s_in_q.size();
                }
                current_mol_id = s_in_q.substr(found_2+8,found_3-(found_2+8));
            }
            found_4 = s_in_q.find("ORGANISM_SCIENTIFIC:");
            if (found_4!=-1){
                found_3 = s_in_q.find(";");
                if (found_3==-1){
                    found_3= s_in_q.size();
                }
                current_species_id = s_in_q.substr(found_4+21,found_3-(found_4+21));
                //cout<<"molid:"<<current_mol_id<<" "<<current_species_id<<endl;
                // get the chain label that maps to that mol id
                pos=mol_id_to_chain_label.find(current_mol_id);
                current_chain_label = pos->second;
                // then link the species directly to the chain label
                //cout<<current_chain_label<<endl;
                chain2species.insert(pair<string,string>(current_chain_label,current_species_id));
            }
        }
    }
}
/******************************************************/
void AbysisPdb::get_mol_id2chain_label(){
    string s_in_q;
    int found_1;
    int found_2,found_3,found_4,found_5;
    string current_mol_id;
    string current_chain_id;
    
    for (STRINGLIST *s=whole_pdb->header; s!=NULL;s=s->next){
        s_in_q.assign(s->string);
        // strip the white space
        stripLeadingAndTrailingBlanks(s_in_q);
        found_1 = s_in_q.find("COMPND");
        if (found_1!=-1){
            found_2 = s_in_q.find("MOL_ID:");
            if (found_2!=-1){
                current_mol_id ="";
                // if line is not terminated by semi-colon then use the length of line.
                found_4 = s_in_q.find(";");
                if (found_4 == -1){
                    found_4 = s_in_q.size();
                }
                current_mol_id = s_in_q.substr(found_2+8,found_4-(found_2+8));
            }
            found_3 = s_in_q.find("CHAIN:");
            if (found_3!=-1){
                found_4 = s_in_q.find(";");
                if (found_4==-1){
                    found_4 = s_in_q.size();
                }
                found_5 = s_in_q.find(",");
                if (found_5==-1){
                    current_chain_id = s_in_q.substr(found_3+7,(found_4)-(found_3+7));
                    mol_id_to_chain_label.insert(pair<string,string>(current_mol_id, current_chain_id));
                }
                else{
                    string chain_ids = s_in_q.substr(found_3+7,(found_4)-(found_3+7));
                    vector<string> parts;
                    Tokenize(chain_ids,parts,",");
                    for (unsigned int count=0;count<parts.size();count++){
                        current_chain_id = parts[count];
                        // now strip any white space or new line characters
                        stripLeadingAndTrailingBlanks(current_chain_id);
                        stripNewLine(current_chain_id);
                        mol_id_to_chain_label.insert(pair<string,string>(current_mol_id,current_chain_id));
                    }
                }
            //cout<<"current mol_id:"<<current_mol_id<<endl;
            //cout<<"current chain_id:"<<current_chain_id<<endl;
            }
        }
    }
}
/******************************************************/
AbysisPdb::~AbysisPdb(){
    //if (pdb_refs != NULL)
        delete pdb_refs;
    delete a_structure;
    FreeStringList(whole_pdb->header);
    FreeStringList(whole_pdb->trailer);
    KillPDBAll(whole_pdb->pdb);
    free(whole_pdb);
}
/******************************************************/
bool AbysisPdb::at_least_one_numbered(){
    bool return_b=false;
    Chain cp;
    for(multimap<string, Chain>::iterator pos=all_the_chains.begin();pos!=all_the_chains.end(); ++pos){
        cp = pos->second;
        if (cp.numbering_ok == true){
            return_b=true;
            break;
        }
    }
    return return_b;
}
/******************************************************/
void AbysisPdb::printXml(){
    for(vector<Antibody>::iterator pos=the_antibodies.begin();pos!=the_antibodies.end();++pos){
        pos->printXml();
    }
    if (the_antibodies.size()==0 && (at_least_one_numbered()==true)){
    Chain cp;
    int ok_count=0;
    for (multimap<string, Chain>::iterator pos=all_the_chains.begin(); pos!=all_the_chains.end(); ++pos){
        cout<<"<antibody>"<<endl;
        a_structure->printXml();
        cp = pos->second;
        if (cp.numbering_ok == true){
            cp.printXml(false);
            ok_count = ok_count +1;
        }
        pdb_refs->printXml();
        cout<<"\t</chain>"<<endl;
        cout<<"</antibody>"<<endl;
    }
    //cout<<"<ab_match_fail pdb=\""<<the_filename<<">okcount="<<ok_count<<"</ab_match_fail>"<<endl;
    //print_failed_chains();
    }
    // print all the references
   // pdb_refs->printXml();
#ifdef DEBUG
    cout<<"Number of chains found..."<<all_the_chains.size()<<endl;
    cout<<"Number of antibodies found.."<<the_antibodies.size()<<endl;
    cout<<"at_least_one_numbered..."<<at_least_one_numbered()<<endl;
#endif
}
/******************************************************/
//void AbysisPdb::write_loop_data(string outfilename,string start, string end, Chain chain_in_q){
	// open an outstream
	//ofstream outfile(outfilename, ios::app);
	// cycle through the residues outputting the loop positions.
	//for (multimap<string, Chain>::iterator pos=all
	
//}
/******************************************************/
void AbysisPdb::printAcaca(){
    Chain cp;
	/*** obtain all the region data... ***/
	string L1_start;
	string L1_end;
	string L1_label = "L1";
    FILE *l1_fp = fopen("/tmp/loop_L1.clan","a");
	rC->obtainRegion(L1_label, L1_start, L1_end);
	//cout<<"Loop L1:"<<L1_start<<" "<<L1_end<<endl;
	string L2_start;
	string L2_end;
	string L2_label = "L2";
    FILE *l2_fp = fopen("/tmp/loop_L2.clan","a");
	rC->obtainRegion(L2_label, L2_start, L2_end);
	//cout<<"Loop L2:"<<L2_start<<" "<<L2_end<<endl;
	string L3_start;
	string L3_end;
	string L3_label = "L3";
    FILE *l3_fp = fopen("/tmp/loop_L3.clan","a");
	rC->obtainRegion(L3_label, L3_start, L3_end);
	//cout<<"Loop L3:"<<L3_start<<" "<<L3_end<<endl;
	string H1_start;
	string H1_end;
	string H1_label = "H1";
    FILE *h1_fp = fopen("/tmp/loop_H1.clan","a");
	rC->obtainRegion(H1_label, H1_start, H1_end);
	//cout<<"Loop H1:"<<H1_start<<" "<<H1_end<<endl;
	string H2_start;
	string H2_end;
	string H2_label = "H2";
    FILE *h2_fp = fopen("/tmp/loop_H2.clan","a");
	rC->obtainRegion(H2_label, H2_start, H2_end);
	//cout<<"Loop H2:"<<H2_start<<" "<<H2_end<<endl;
	string H3_start;
	string H3_end;
	string H3_label = "H3";
    FILE *h3_fp = fopen("/tmp/loop_H3.clan","a");
	rC->obtainRegion(H3_label, H3_start, H3_end);
	//cout<<"Loop H3:"<<H3_start<<" "<<H3_end<<endl;
	
    // tell each chain to print for acaca
    for (multimap<string, Chain>::iterator pos=all_the_chains.begin();pos!=all_the_chains.end(); ++pos){
        cp = pos->second;
        if (cp.numbering_ok == true){
            //cp.printAcaca();
            //printf("calling here...\n");
            // ok we need to create a file with just the pdb section numbered..
            //string a_filename = "/export/data/abysis/pdb/ab_pdb_sections/" + pos->first;
            string a_filename = pdb_sections_dir + pos->first;
            //cp.write_loop_data(l1_fp, L1_start, L1_end, pos->first, original_filename);
            cp.write_loop_data(l1_fp, L1_start, L1_end, pos->first, a_filename);
            //cp.write_loop_data(l2_fp, L2_start, L2_end, pos->first, original_filename);
            cp.write_loop_data(l2_fp, L2_start, L2_end, pos->first, a_filename);
            //cp.write_loop_data(l3_fp, L3_start, L3_end, pos->first, original_filename);
            cp.write_loop_data(l3_fp, L3_start, L3_end, pos->first, a_filename);
            //cp.write_loop_data(h1_fp, H1_start, H1_end, pos->first, original_filename);
            cp.write_loop_data(h1_fp, H1_start, H1_end, pos->first, a_filename);
            //cp.write_loop_data(h2_fp, H2_start, H2_end, pos->first, original_filename);
            cp.write_loop_data(h2_fp, H2_start, H2_end, pos->first, a_filename);
            //cp.write_loop_data(h3_fp, H3_start, H3_end, pos->first, original_filename);
            cp.write_loop_data(h3_fp, H3_start, H3_end, pos->first, a_filename);
			cp.print_res_line(a_filename);
        }
		else{
			printf("numbering failure.\n");
		}
    }
}
/******************************************************/
void AbysisPdb::print_failed_chains(){
    Chain cp;
    for (multimap<string, Chain>::iterator pos=all_the_chains.begin(); pos!=all_the_chains.end(); ++pos){
        cp = pos->second;
        if (cp.numbering_ok == false){
            cout<<"<sequence_number_fail>"<<cp.obtain_sequence()<<"</sequence_number_fail>"<<endl;
        }
    }
}
/******************************************************/
void AbysisPdb::obtain_numbering(){
    // for each chain create a pir file and then push the file via 
    // Abhi's numbering program.
    string c_in_q,file_name;
    vector <string> kabat_holder;
    vector <string> chothia_holder;
    Numbering *num;
    for (multimap<string, Chain>::iterator pos=all_the_chains.begin(); pos!=all_the_chains.end(); ++pos){
        c_in_q = pos->second.obtain_sequence();
        num = new Numbering(c_in_q);
        kabat_holder = num->kabat_numbering();
        pos->second.set_numbering("kabat",kabat_holder);
        kabat_holder.clear();
        chothia_holder = num->chothia_numbering();   
        pos->second.set_numbering("chothia",chothia_holder);
        chothia_holder.clear();
        delete num;
    }
}
/******************************************************/
void AbysisPdb::obtain_pairing(){
    vector <string> iface_numbers;
    // get interface residues from text files
    iface_numbers = what_numbered_residues_form_iface();
    for(multimap<string, Chain>::iterator pos=all_the_chains.begin();pos!=all_the_chains.end();++pos){
        // ask each chain to determine the atoms for their interface positions
        pos->second.set_interface_residues(iface_numbers, "chothia");
    }
    multimap <string, double>done_all_ready;
    string map_key_1, map_key_2;
    // for each chain determine the closest distance between their atoms
    double distance;
    for(multimap<string, Chain>::iterator pos=all_the_chains.begin();pos!=all_the_chains.end();++pos){
        for (multimap<string, Chain>::iterator pos2=all_the_chains.begin();pos2!=all_the_chains.end();++pos2){
            if (pos!=pos2 /*&& (compatable_types(pos->second.obtain_type(),pos2->second.obtain_type())==true)*/){
                // avoid recalulating values that don't need to be.
                map_key_1 = pos->first + "-" + pos2->first;
                map_key_2 = pos2->first + "-" + pos->first;
                if ((done_all_ready.count(map_key_1) == 0) && (done_all_ready.count(map_key_1)==0)){ 
                    distance = pos->second.find_distance(pos2->second);
                    done_all_ready.insert(pair<string,double>(map_key_1,distance));
                    done_all_ready.insert(pair<string,double>(map_key_2,distance));
                }
            }
        }
    } // end of outer for loop

    // the program has the distances between each pairing
    // now it just needs find the smallest pairing distance and form 
    // the ab 
    nearest_pairs(done_all_ready);
}
/******************************************************/
bool AbysisPdb::compatable_types(string type_one, string type_two){
    bool return_b=false;
    if (type_one=="heavy" && (type_two=="kappa" || type_two=="lambda")){
        return_b=true;
    }
    else if (type_two=="heavy" && (type_one=="kappa" || type_one=="lambda")){
        return_b=true;
    }
    
    return return_b;
}
/******************************************************/
void AbysisPdb::nearest_pairs(multimap<string,double>pairing_map){
    multimap<string, DISTANCE_LABEL> the_hold;
    multimap<string, DISTANCE_LABEL>::iterator sp;
    vector<string> parts;
    DISTANCE_LABEL d_l;

    for (multimap<string,double>::iterator pos=pairing_map.begin(); pos!=pairing_map.end();++pos){
        //cout<<"All hope lost?"<<pos->first<<endl;
        // Tokenize the key part of the multimap
        Tokenize(pos->first, parts, "-");
        if (the_hold.count(parts[0])==0){
            d_l.distance = pos->second;
            d_l.label = parts[1];
            the_hold.insert(pair<string,DISTANCE_LABEL>(parts[0],d_l));
        }
        else{
            sp = the_hold.find(parts[0]);
            if (pos->second < sp->second.distance){
                sp->second.distance = pos->second;
                sp->second.label = parts[1];
            }
        }
        if (the_hold.count(parts[1])==0){
            d_l.distance = pos->second;
            d_l.label = parts[0];
            the_hold.insert(pair<string,DISTANCE_LABEL>(parts[1],d_l));
        }
        else{
            sp = the_hold.find(parts[1]);
            if (pos->second < sp->second.distance){
                sp->second.distance = pos->second;
                sp->second.label = parts[0];
            }
        }
        parts.clear();
    }
    multimap<string,bool> paired_allready;
    // now sort out this nightmare
    for(sp=the_hold.begin();sp!=the_hold.end();++sp){
        //cout<<"in here though?"<<endl;
        if (paired_allready.count(sp->first)==0 && paired_allready.count(sp->second.label)==0){
            //cout<<"distance is:"<<sp->second.distance<<endl;
            if (sp->second.distance<15){
                make_ab(sp->first,sp->second.label,sp->second.distance);
                paired_allready.insert(pair<string,bool>(sp->first,true));
                paired_allready.insert(pair<string,bool>(sp->second.label,true));
            }
        }
    }
        
}
/******************************************************/
void AbysisPdb::make_ab(string label_one,string label_two,double distance){
    Chain *ab_one;
    Chain *ab_two;
    Antibody an_ab(name);
    multimap<string,Chain>::iterator pos;
    pos = all_the_chains.find(label_one);
    ab_one = &pos->second;
    pos = all_the_chains.find(label_two);
    ab_two = &pos->second;
    an_ab.set_sub_date(submission_date);
    //an_ab.set_up_date(update_date);
    an_ab.set_distance(distance);
    an_ab.add_chain(ab_one);
    an_ab.add_chain(ab_two);
    an_ab.set_reference(pdb_refs);
    an_ab.set_structure(a_structure);
    // now add to the class globa
    the_antibodies.push_back(an_ab);
    
}
/******************************************************/
vector<string> AbysisPdb::what_numbered_residues_form_iface(){
    char line_holder[100];
    vector<string> the_answers;
    // open config file read and parse
    fstream fp_op(iface_config_file.c_str(),ios::in);
    while(!fp_op.eof()){
        fp_op.getline(line_holder,100);
        if (line_holder[0]!='#'){
            the_answers.push_back(line_holder);
        }
    }
    fp_op.close();
    return the_answers;
}
/******************************************************/
void AbysisPdb::obtain_chain_types(){
    ChainType the_types;
    string c_in_q;
    string c_type;
    // iterate through the chains obtaining the types
    for(multimap<string,Chain>::iterator pos=all_the_chains.begin(); pos!=all_the_chains.end(); ++pos){
        cout<<pos->first<<endl;
        cout<<pos->second.obtain_sequence()<<endl;
        c_in_q = pos->second.obtain_sequence();
        c_type = the_types.find_chain_type(c_in_q);
        pos->second.set_type(c_type);
    }
}

/******************************************************/
void Usage(){
    cout<<"Usage: ./abysispdb <pdb_filename> <pdb_sections_dir_name>\n";
}
/******************************************************/
