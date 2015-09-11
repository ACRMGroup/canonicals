/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: author.c                                     **/
/**    Date: Wednesday 5 Mar 2008                              **/
/**    Description: C++ class to hold Author details.         **/
/**                                                            **/
/****************************************************************/
#include "author.h"
#include <iostream>
using namespace std;

Authors::Authors(string i_in_q, string s_in_q){
    surname = s_in_q;
    initials = i_in_q;
}

Authors::~Authors(){
    surname = "";
    initials ="";
}

void Authors::printXml(){
    cout<<"\t\t\t<authors>"<<initials<<" "<<surname<<"</authors>\n";
}
