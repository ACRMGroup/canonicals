#include <iostream>
#include "utils.h"

int main(int argc,char **argv){
string some = "   weeeeee   ";

cout<<"#"<<some<<"#"<<endl;
stripLeadingAndTrailingBlanks(some);
cout<<"#"<<some<<"#"<<endl;

}
