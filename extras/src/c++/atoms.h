/****************************************************************/
/**                                                            **/
/**    Author: Jacob hurst                                     **/
/**    File name: atoms.h                                      **/
/**    Date: Thursday 6 Mar 2008                               **/
/**    Description: Class to hold atom details.                **/
/**                                                            **/
/****************************************************************/
#ifndef ATOM_DEFINED
#define ATOM_DEFINED
extern "C"{
    #include <math.h>
}

#include <string>
#include <vector>
using namespace std;

class Atom{
    private:
        double x,y,z;
        int pdb_atom_number;
        string atom_name;
    public:
        Atom(double x_d, double y_d, double z_d,int num, string name);
        Atom();
		string line;
        void set_data_items(double x_d, double y_d, double z_d, int num,string name);
        void printXml();
        void printAcaca_first();
        void printAcaca_second();
        void clear();
        double euclidean_distance(Atom a);
};


#endif

