#include <iostream>
#include "utils.h"

using namespace std;

int main(int argc,char **argv){
    string something = "O5' ";
    string else_ = xml_escape_quote(something);
    cout<<endl;
    cout<<something<<" "<<else_<<endl;
return 0;
}
