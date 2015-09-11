/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: antibody.h                                   **/
/**    Date: Thursday 13 Mar 2008                              **/
/**    Description: holds Antibody data!                       **/
/**                                                            **/
/****************************************************************/

#ifndef ANTIBODY_DEFINED
#define ANTIBODY_DEFINED

#include <vector>
#include "chain.h"
#include "reference.h"
#include "structure.h"

using namespace std;

class Antibody{
    private:
        vector<Chain*> ab_chains;
        Reference *associated_ref; 
        Structure *a_structure;
        double distance_between_chains;
        string name;
        string sub_date;
    public:
        Antibody(string n_in_q);
        void printXml();
        void set_sub_date(string d_in_q);
        void set_distance(double to_set);
        void add_chain(Chain*); 
        void set_reference(Reference *ref);
        void set_structure(Structure *st);
};
#endif
