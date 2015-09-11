/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: atoms.cc                                     **/
/**    Date: Thursday 6 Mar 2008                               **/
/**    Description: Class to hold atom details.                **/
/**                                                            **/
/****************************************************************/
#include "utils.h"
#include "atoms.h"
#include <iostream>
using namespace std;

Atom::Atom(double x_d, double y_d, double z_d, int num,string name){
    x = x_d;
    y = y_d;
    z = z_d;
    pdb_atom_number = num;
    atom_name = xml_escape_quote(name); 
}

Atom::Atom(){
    // Just a place holder really
}

void Atom::printXml(){
    cout<<"\t\t\t<atom atom_id=\'"<<pdb_atom_number<<"\' ";
    cout<<"atom_type=\'"<<atom_name<<"\'";
    cout<<" x=\'"<<x<<"\' ";
    cout<<" y=\'"<<y<<"\' ";
    cout<<" z=\'"<<z<<"\'></atom>\n";
}

void Atom::printAcaca_first(){
    cout<<"ATOM    ";
	if (pdb_atom_number<10){
		cout<<"  "<<pdb_atom_number<<"  "<<atom_name;
	}
	else if (pdb_atom_number>=10 && pdb_atom_number<100){
		cout<<" "<<pdb_atom_number<<"  "<<atom_name;
	}
	else{
		cout<<pdb_atom_number<<"  "<<atom_name;
	}
	if (atom_name.size()==1)
		cout<<"  ";
	else if (atom_name.size()==2)
		cout<<" ";
}

void Atom::printAcaca_second(){
    cout<<x<<" "<<y<<" "<<z<<endl;
}

void Atom::clear(){
    x = 0.0;
    y = 0.0;
    z = 0.0;
    pdb_atom_number =0;
    atom_name.clear();
}

void Atom::set_data_items(double x_d, double y_d, double z_d, int num, string name){
    x = x_d;
    y = y_d;
    z = z_d;
    pdb_atom_number = num;
    stripLeadingAndTrailingBlanks(name);
    atom_name = xml_escape_quote(name);
}

double Atom::euclidean_distance(Atom b){
    // determines the euclidean distance between this Atom and one passed in
    double ob;
    ob = pow((x - b.x),2) + pow((y - b.y),2) + pow((z - b.z),2);
    ob = sqrt(ob);
    return ob;
}
