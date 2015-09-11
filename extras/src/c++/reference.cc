/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: reference.cc                                 **/
/**    Date: Wednesday 5 Mar 2008                              **/
/**    Description:  C++ class to hold reference               **/
/**                descriptions.                               **/
/**                                                            **/
/****************************************************************/
#include "reference.h"
#include "utils.h"
#include <iostream>
using namespace std;

/****************************************************************/
// constructs from lines labeled JRNL
Reference::Reference(vector<string> jrnl_parts){
    string item;
    int pos;
    Authors *an_author;
    string holder;
    string surname,initials;
    title = "";
    for(vector<string>::iterator p=jrnl_parts.begin();p!=jrnl_parts.end();++p){
        item = *p;
        pos=item.find(" AUTH ");
        if (pos!=-1){
            holder = item.substr(pos+6,item.size());
            // strip digits
            stripDigits(holder);
            // strip newline
            stripNewLine(holder);
            // strip white space
            stripLeadingAndTrailingBlanks(holder);
            // now tokenize on the basis of comma
            vector<string> parts;
            Tokenize(holder, parts,",");
            // now for each name in parts find 
            // the last full stop and split on that 
            // basis
            for (vector<string>::iterator name=parts.begin();name!=parts.end();++name){
                int pos2;
                string n = *name;
                pos2 = n.find_last_of(".");
                if (pos2!=-1){
                    initials = n.substr(0,pos2);
                    surname = n.substr(pos2+1,n.size());
                    an_author = new Authors(initials, surname);
                    author_v.push_back(*an_author);
                    //delete an_author;
                    delete an_author;
                }
            }
        }
        else if ((pos=item.find(" TITL "))!=-1){
            process_title(item);
        }
        else if (((pos=item.find(" REF "))!=-1) || ((pos=item.find(" REFN "))!=-1)){
            process_publication(item);
        }
    }
}
/****************************************************************/
Reference::~Reference(){
    author_v.clear();
}
/****************************************************************/
void Reference::process_title(string a_line){
    int pos;
    string holder;
    pos = a_line.find(" TITL ");
    // hopefully removing unwanted material
    holder = a_line.substr(pos+7,a_line.size());
    stripNewLine(holder);
    // strip white space
    stripLeadingAndTrailingBlanks(holder);
    title += holder;
}
/****************************************************************/
void Reference::process_publication(string a_line){
    int pos;
    string holder;
    pos = a_line.find(" REF ");
    if (pos!=-1){
        holder = a_line.substr(pos+6,a_line.size());       
    }
    else if ((pos = a_line.find(" REFN "))!=-1){
        holder = a_line.substr(pos+7,a_line.size());       
    }
    // strip white space
    stripLeadingAndTrailingBlanks(holder);
    stripNewLine(holder);
    stripLeadingAndTrailingBlanks(holder);
    publication += " "+holder;
}
    
    
/****************************************************************/
void Reference::printXml(){
    string print_string;
    print_string = "\t\t<reference>\n";
    print_string += "\t\t\t<title>"+title+"</title>\n";
    print_string += "\t\t\t<publication>"+publication+"</publication>\n";
    cout<<print_string;
    // now print each of the Authors
    for (vector<Authors>::iterator pos = author_v.begin(); pos!=author_v.end();++pos){
        pos->printXml();
    }
    print_string = "\t\t</reference>\n";
    cout<<print_string;
}
/****************************************************************/
