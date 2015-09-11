/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: author.h                                     **/
/**    Date: Wednesday 5 Mar 2008                              **/
/**    Description: C++ class to hold Author details.          **/
/**                                                            **/
/****************************************************************/
#ifndef AUTHOR_DEFINED
#define AUTHOR_DEFINED
#include <string>
using namespace std;
class Authors{
    private:
        string initials;
        string surname;
    public:
        Authors(string i_in_q,string s_in_q);
        ~Authors();
        void printXml();
};
#endif
