/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: main.cc                                      **/
/**    Date: Friday 27 Jun 2008                                **/
/**    Description:  calls and instansiates the abysispdb      **/
/**                class.                                      **/
/**                                                            **/
/****************************************************************/
#include "abysispdb.h"

int main(int argc,char** argv){
int check;
    if ((argc!=3) || (check=fexist(argv[1]))==1){
         Usage();
         exit(1);
    }
    AbysisPdb abPdb(argv[1],argv[2]);
    //abPdb.print_header();
    abPdb.obtain_name();
    abPdb.obtain_submission_date();
    abPdb.obtain_update_date();
    abPdb.obtain_species();
    abPdb.obtain_reference();
    abPdb.obtain_chains_residues_atoms();
    //abPdb.obtain_chain_types();
    abPdb.obtain_numbering();
    //abPdb.obtain_pairing();
    //abPdb.printXml();
    abPdb.printAcaca();
return 0;
}
