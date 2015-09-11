/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: structure.cc                                 **/
/**    Date: Friday 14 Mar 2008                                **/
/**    Description: Class definition to hold structure data    **/
/**                                                            **/
/****************************************************************/
#include <iostream>
#include "structure.h"

using namespace std;

Structure::Structure(double r_in, double res_in, string m_in, string id){
    rfact = r_in;
    resolution = res_in;
    method = m_in;
    pdb_id = process_pdb_filename(id);
}

Structure::Structure(){
}

void Structure::printXml(){
    cout<<"\t\t<structure pdb_id=\'"<<pdb_id<<"\' resolution=\'"<<resolution<<"\' rfac=\'"<<rfact<<"\' method=\'"<<method;
    cout<<"\'/>\n";
}

string Structure::process_pdb_filename(string fname){
    string return_s;
    string hold =fname;
    int pos2 = fname.rfind(".");
    int pos = fname.rfind("/");
    int num = pos2-pos;
    return_s = fname.substr(pos+1,num-1);
    // remove three letters which should be pdb
    return_s = return_s.substr(3,return_s.size());
    return return_s;
}

void Structure::clear(){
    rfact = 0.0;
    resolution =0.0;
    method.clear();
    pdb_id.clear();
}
