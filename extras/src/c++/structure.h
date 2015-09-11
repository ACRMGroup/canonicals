/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: structure.h                                  **/
/**    Date: Friday 14 Mar 2008                                **/
/***    Description: Class defintion to hold structure data.   **/
/**                                                            **/
/****************************************************************/

#ifndef STRUCTURE_DEFINED
#define STRUCTURE_DEFINED
#include <string>

using namespace std;

class Structure{
    private:
        double resolution;
        double rfact;
        string method;
        string pdb_id;
    public:
        Structure(double r_in, double res_in, string m_in, string id);
        Structure();
        string process_pdb_filename(string fname);
        void printXml();
        void clear();
};

#endif
