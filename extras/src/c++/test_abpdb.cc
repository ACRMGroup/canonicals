/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: test_abpdb.cc                                **/
/**    Date: Friday 27 Jun 2008                                **/
/**    Description:  provides a test framework for parts of  **/
/**                the abysispdb code                        **/
/**                                                            **/
/****************************************************************/
#define TEST_ABPDB 1
using namespace std;
#include <iostream>
#include "abysispdb.h"

int main(int argc, char** argv){
    vector<string> numbers;
    //Numbering *num;
    int count;
    count =0;
    AbysisPdb hope(argv[1]);
    //AbysisPdb hope("/acrm/data/pdb/pdb1rzj.ent");
    //hope.print_header();
    hope.obtain_submission_date();
    hope.obtain_name();
    hope.obtain_species();
    hope.obtain_chains_residues_atoms();
    hope.obtain_reference();
    hope.obtain_chain_types();
    hope.obtain_numbering();
    hope.obtain_pairing();
    //hope.print_failed_chains();
    hope.printXml();
    return count;
}
