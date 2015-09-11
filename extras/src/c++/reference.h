/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: reference.h                                  **/
/**    Date: Wednesday 5 Mar 2008                              **/
/**    Description:  C++ class to hold reference             **/
/**                descriptions.                             **/
/**                                                            **/
/****************************************************************/
#ifndef REFERENCE_DEFINED
#define REFERENCE_DEFINED
#include <vector>
#include "author.h"
using namespace std;

class Reference{
      private:
        vector<Authors> author_v;
        string title;
        string publication;
        void process_title(string a_line);
        void process_publication(string a_line);
      public:
        Reference(vector <string>);
        ~Reference();
        void printXml();
};
#endif
