/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: utils.cc                                     **/
/**    Date: Wednesday 5 Mar 2008                              **/
/**    Description: Some useful C++ functions               **/
/**                                                            **/
/****************************************************************/
#include "utils.h"
#include <ctype.h>
#include <sys/stat.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <cctype>
#include <algorithm>
#include <functional>
#include <string>
#include <stdio.h>
using namespace std;

string month_name_to_number(string month_in_q){
    string month;
        if (month_in_q=="JAN")
            month.assign("01");
        else if (month_in_q=="FEB")
            month.assign("02");
        else if (month_in_q=="MAR")
            month.assign("03");
        else if (month_in_q=="APR")
            month.assign("04");
        else if (month_in_q=="MAY")
            month.assign("05");
        else if (month_in_q=="JUN")
            month.assign("06");
        else if (month_in_q=="JUL")
            month.assign("07");
        else if (month_in_q=="AUG")
            month.assign("08");
        else if (month_in_q=="SEP")
            month.assign("09");
        else if (month_in_q=="OCT")
            month.assign("10");
        else if (month_in_q=="NOV")
            month.assign("11");
        else if (month_in_q=="DEC")
            month.assign("12");
    return month;
}

string xml_escape_quote(string s_in_q){
    int pos;
    pos = s_in_q.find("\'");
    if (pos==-1){
        return s_in_q;
    }
    string first,second;
    string escape;
    escape.assign("&quot;");
    first = s_in_q.substr(0,pos);
    int length;
    length = s_in_q.size()-pos;
    second = s_in_q.substr(pos+1,length);
    string return_s;
    return_s = first + escape + second;
    return return_s;
}

void Tokenize(const string& str,
                      vector<string>& tokens,
                      const string& delimiters = " ")
{
    // Skip delimiters at beginning.
    string::size_type lastPos = str.find_first_not_of(delimiters, 0);
    // Find first "non-delimiter".
    string::size_type pos     = str.find_first_of(delimiters, lastPos);

    while (string::npos != pos || string::npos != lastPos)
    {
        // Found a token, add it to the vector.
        tokens.push_back(str.substr(lastPos, pos - lastPos));
        // Skip delimiters.  Note the "not_of"
        lastPos = str.find_first_not_of(delimiters, pos);
        // Find next "non-delimiter"
        pos = str.find_first_of(delimiters, lastPos);
    }
}

void
stripLeadingAndTrailingBlanks(string& StringToModify)
{
   const char *p;
    int startpos, endpos;
    string holder;
    //cout<<"getting:"<<StringToModify<<endl;
    startpos = 0; endpos = 0;
   if(StringToModify.empty()) return;
   
    p = StringToModify.c_str();
    if (p==NULL) return;
    // find the start position;
    for (unsigned int count=0;count<strlen(p);count++){
        if (p[count]!=32){
            startpos = count;
            break;
        }
    }
    // find the tail position:
    for (unsigned int count=(unsigned int)(strlen(p)-1); count>(unsigned int)startpos; --count){
        if (p[count]!=32 && p[count]!=10 ){
            //printf("#%c# %d\n",p[count],p[count]);
            endpos = count;
            break;
        }
    }
    //if (endpos!=startpos){
        //cout<<"startpos:"<<startpos<<" endpos: "<<endpos<<" difference:"<<(endpos+1)-startpos<<endl;
        //cout<<"Input string is:"<<StringToModify.size()<<" "<<p<<endl;
        holder = StringToModify.substr(startpos,(endpos+1)-startpos);
        StringToModify.erase();
        StringToModify.assign(holder);
    //}
    //cout<<"sending"<<StringToModify<<endl;
}

void stripLeadingAndTrailingBlanks_two(string& StringToModify){
    int pos=0;
    pos=StringToModify.find(" ");
    while(pos!=-1){
        StringToModify.erase(pos);
        pos=StringToModify.find(" ");
    };
    string tempstring;
    for (unsigned int count=0;count<StringToModify.length();count++){
        if (isalpha(StringToModify[count]))
            tempstring += StringToModify[count];
    }
    StringToModify.erase();
    StringToModify = tempstring;
}

void stripDigits(string& StringToModify){
    string tempString;
    if (StringToModify.empty()) return;
    for (unsigned int count=0;count<StringToModify.length(); count++){
        if (!isdigit(StringToModify[count])){
            tempString += StringToModify[count];
        }
    }
    StringToModify.erase();
    StringToModify = tempString;
}

void stripNewLine(string& StringToModify){
    string tempString;
    if (StringToModify.empty()) return;
    for (unsigned int count=0;count<StringToModify.length(); count++){
        if (StringToModify[count]!='\n'){
            tempString += StringToModify[count];
        }
    }
    StringToModify.erase();
    StringToModify = tempString;
}

void stripQuotes(string& StringToModify){
	string tempString;
	if (StringToModify.empty()) return;
	for (unsigned int count=0;count<StringToModify.length(); count++){
		if (StringToModify[count]!='\''){
            tempString += StringToModify[count];
		}
	}
	StringToModify.erase();
	StringToModify = tempString;
}

void stripToken(string& StringToModify, char to_comp){
	string tempString;
	if (StringToModify.empty()) return;
	for (unsigned int count=0;count<StringToModify.length(); count++){
		if (StringToModify[count]!=to_comp){
            tempString += StringToModify[count];
		}
	}
	StringToModify.erase();
	StringToModify = tempString;
}

string singleletter2threeletter_aacode(string code_in_q){
	string return_s="";
    string holder;
    for (unsigned int pos=0; pos<code_in_q.size(); pos++){
        holder += toupper(code_in_q[pos]);
    }
    code_in_q = holder;
    if (code_in_q.size()==3){
        return code_in_q;
    }
    // strip whitespace is necessary
    stripLeadingAndTrailingBlanks(code_in_q);
	if (code_in_q=="A"){
		return_s = "ALA";
	}
	else if (code_in_q=="R"){
		return_s = "ARG";
	}
	else if (code_in_q=="N"){
		return_s = "ASN";
	}
	else if (code_in_q=="D"){
		return_s = "ASP";
	}
	else if (code_in_q=="C"){
		return_s = "CYS";
	}
	else if (code_in_q=="E"){
		return_s = "GLU";
	}
	else if (code_in_q=="Q"){
		return_s = "GLN";
	}
	else if (code_in_q=="G"){
		return_s = "GLY";
	}
	else if (code_in_q=="H"){
		return_s = "HIS";
	}
	else if (code_in_q=="I"){
		return_s = "ILE";
	}
	else if (code_in_q=="L"){
		return_s = "LEU";
	}
	else if (code_in_q=="K"){
		return_s = "LYS";
	}
	else if (code_in_q=="M"){
		return_s = "MET";
	}
	else if (code_in_q=="F"){
		return_s = "PHE";
	}
	else if (code_in_q=="P"){
		return_s = "PRO";
	}
	else if (code_in_q=="S"){
		return_s = "SER";
	}
	else if (code_in_q=="T"){
		return_s = "THR";
	}
	else if (code_in_q=="W"){
		return_s = "TRP";
	}
	else if (code_in_q=="Y"){
		return_s = "TYR";
	}
	else if (code_in_q=="V"){
		return_s = "VAL";
	}
	
	return return_s;
}

string threeletter2singleletter_aacode(string code_in_q){
    string return_s="";
    //code_in_q = code_in_q.lower();
    // use the transform algorithm to turn the letters lower case.
    //transform(code_in_q.begin(), code_in_q.end(), code_in_q.begin(), tolower)
    // or do it the lame way
    string holder;
    for (unsigned int pos=0; pos<code_in_q.size(); pos++){
        holder += tolower(code_in_q[pos]);
    }
    code_in_q = holder;
    if (code_in_q.size()==1){
        return code_in_q;
    }
    // strip whitespace is necessary
    stripLeadingAndTrailingBlanks(code_in_q);
    if (code_in_q=="ala")
        return_s = "A";
    else if (code_in_q=="arg")
        return_s = "R";
    else if (code_in_q=="asn")
        return_s = "N";
    else if (code_in_q=="asp")
        return_s = "D";
    else if (code_in_q=="cys")
        return_s = "C";
    else if (code_in_q=="glu")
        return_s = "E";
    else if (code_in_q=="gln")
        return_s = "Q";
    else if (code_in_q=="gly")
        return_s = "G";
    else if (code_in_q=="his")
        return_s = "H";
    else if (code_in_q=="ile")
        return_s = "I";
    else if (code_in_q=="leu")
        return_s = "L";
    else if (code_in_q=="lys")
        return_s = "K";
    else if (code_in_q=="met")
        return_s = "M";
    else if (code_in_q=="phe")
        return_s = "F";
    else if (code_in_q=="pro")
        return_s = "P";
    else if (code_in_q=="ser")
        return_s = "S";
    else if (code_in_q=="thr")
        return_s = "T";
    else if (code_in_q=="trp")
        return_s = "W";
    else if (code_in_q=="tyr")
        return_s = "Y";
    else if (code_in_q=="val")
        return_s = "V";
    return return_s;
}

int fexist(const char *filename){
    struct stat buffer;
    if (stat(filename, &buffer)) return 1;
    return 0;
}

string format_for_pir(string seq){
    // function puts new lines in every 30 chars of the string
    // and terminates the string by adding a *
    string holder,nl;
    int another;
    nl = "\n";
    for(unsigned int count=0;count<seq.size();count++){
        another = count%30;
        if (count!=0 && (another==0)){
            holder += seq[count] + nl;
        }
        else{
            holder += seq[count];
        }
    }
    holder += "*";
    return holder;
}

string createPirFile(string sequence ){
/** Returns the name of the pir file that has been created **/
/** Big Warning this is NOT THREAD SAFE **/
    string return_s;
    string location = "/tmp/";
    string file_name;
    static int counters=0;
    fstream inFile;
    char hold[500];
    do{
        counters++;
        sprintf(hold,"%sabysispdb_%d.pir",location.c_str(),counters);
    }while (!fexist(hold));
    // ok we know the file is good so open and just write to it..
    inFile.open(hold, ios::out);
    // does this work
    inFile<<">P1;PDB_CHAIN\nGenerated by abysispdb\n"<<format_for_pir(sequence)<<endl;
    inFile.close(); 
    return hold;
}

string lower_case(string s_in_q){
    string holder;
    for (unsigned int pos=0; pos<s_in_q.size(); pos++){
        holder += tolower(s_in_q[pos]);
	}
	return holder;
}

