/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: regionconfig.h                               **/
/**    Date: Tuesday 13 Jan 2009                               **/
/**    Description:  Reads Abysis region.xml to extract        **/
/**                region definitions.                         **/
/**                                                            **/
/****************************************************************/
#ifndef REGION_CONFIG
#define REGION_CONFIG
#include <string>
#include <map>
using namespace std;

class RegionDefinition{
	public:
		string name;
		string scheme;
		string start;
		string end;
		RegionDefinition(string scheme,string name,string start,string end);
		void printData();
};

class RegionConfig{
	private:
		multimap<string, RegionDefinition> defs;
		void add_definitions(string def_type); 
	public:
		RegionConfig(string config_filename, string def_type);
		string obtain_attribute(string);
		void printRegionDefs();
		void obtainRegion(string r_in_q, string& s_in_q, string& end_in_q);
};
#endif
