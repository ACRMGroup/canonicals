/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: regionconfig.cc                              **/
/**    Date: Tuesday 13 Jan 2009                               **/
/**    Description:  Reads Abysis region.xml to extract        **/
/**                region defintions.                          **/
/**                                                            **/
/****************************************************************/
using namespace std;
#include "regionconfig.h"
#include "utils.h"
#include <iostream>
#include <fstream>
/****************************************************************/
RegionDefinition::RegionDefinition(string a_scheme,string a_name,string a_start, string a_end){
	scheme = a_scheme;
	name   = a_name;
	start  = a_start;
	end    = a_end;	
}
/****************************************************************/
void RegionDefinition::printData(){
	cout<<"scheme:"<<scheme<<" name:"<<name<<" start:"<<start<<" end:"<<end<<endl;
}
/****************************************************************/
RegionConfig::RegionConfig(string filename, string type_in_q){
	ifstream configFile(filename.c_str(),ios::in);
	string holder,holder2,holder3;
	// step through the two lines which don't hold records;
	configFile>>holder>>holder2>>holder3;
	string scheme;
	string numbered;
	string r_type, r_type_2;
	string name;
	string s_pos;
	string e_pos;

	while (!configFile.eof()){
		configFile>>holder;
		if (holder.find("/>")==0){
			configFile>>holder;
		}
		configFile>>scheme>>numbered>>r_type>>r_type_2>>name>>s_pos>>e_pos;
		//cout<<"scheme:"<<scheme<<" r_type:"<<r_type<<" epos:"<<e_pos<<endl;
		// now pull out the attributes
		scheme = obtain_attribute(scheme);
		r_type = r_type + r_type_2;
		r_type = obtain_attribute(r_type);
		name = obtain_attribute(name);
		s_pos = obtain_attribute(s_pos);
		e_pos = obtain_attribute(e_pos);
		stripQuotes(scheme);
		stripQuotes(name);
		stripQuotes(r_type);
		stripQuotes(s_pos);
		stripQuotes(e_pos);
		stripToken(e_pos,'>');
		stripToken(e_pos,'/');
		char a_quote = 39;
		stripToken(e_pos,a_quote);
		//cout<<"scheme:"<<scheme<<" r_type:"<<r_type<<" epos:"<<e_pos<<endl;
		if (scheme == type_in_q){
			RegionDefinition rd(scheme,name,s_pos,e_pos);
			defs.insert(pair<string, RegionDefinition>(name,rd));
		}
		
	}
}
/*********************************/
string RegionConfig::obtain_attribute(string c_string){
	string holder;
	int pos;

	pos=c_string.find("=");
	if (pos!=-1){
		holder = c_string.substr(pos+1,c_string.size()-(pos+1));
	}
	else{
		holder = c_string;
	}	

	return holder;
}
/*********************************/
void RegionConfig::printRegionDefs(){

	for (multimap<string, RegionDefinition>::iterator pos=defs.begin();pos!=defs.end();++pos){
		cout<<pos->first<<endl;
	}

}
/*********************************/
void RegionConfig::obtainRegion(string r_in_q,string& start,string& end){
	multimap<string, RegionDefinition>::iterator pos;
	RegionDefinition *rd;
	pos = defs.find(r_in_q);
	rd = &pos->second;
	start = rd->start;
	end = rd->end;
	//rd->printData();
}
/*********************************
int main(int argc,char **argv){
	RegionConfig *rC;
	string fname = "../../config/region.xml";
	string a_type = "abm";
	//if (argc!=3){
	//	exit(1);
	//}
	rC = new RegionConfig(fname, a_type);
	rC->printRegionDefs();
	string start,end;
	string r_in_q = "L2";
	rC->obtainRegion(r_in_q,start, end);
	cout<<r_in_q<<" "<<start<<" "<<end<<endl;
}
*********************************/

