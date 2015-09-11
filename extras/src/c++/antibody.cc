/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: antibody.cc                                  **/
/**    Date: Thursday 13 Mar 2008                              **/
/**    Description: holds Antibody data!                       **/
/**                                                            **/
/****************************************************************/
#include "antibody.h"

Antibody::Antibody(string n_in_q){
    name = n_in_q;
}
/****************************************************************/
void Antibody::set_distance(double d_in_q){
    distance_between_chains = d_in_q;
}
/****************************************************************/
void Antibody::set_sub_date(string d_in_q){
    sub_date.assign(d_in_q);
}
/****************************************************************/
void Antibody::add_chain(Chain* c_in_q){
    ab_chains.push_back(c_in_q);
}
/****************************************************************/
void Antibody::printXml(){
    Chain *cp;
    cout<<"<antibody distance=\'"<<distance_between_chains<<"\'";
    cout<<" name=\'"<<name<<"\' >\n";
    a_structure->printXml();   
    for(vector<Chain*>::iterator pos=ab_chains.begin(); pos!=ab_chains.end();++pos){  
        cp = *pos;
        cp->printXml(true);
    }
    // print out the reference
    associated_ref->printXml();
    cout<<"</antibody>\n";
}
/****************************************************************/
void Antibody::set_reference(Reference *r_p){
    associated_ref = r_p;
}
/****************************************************************/
void Antibody::set_structure(Structure *sp){
    a_structure = sp;
}
/****************************************************************/

