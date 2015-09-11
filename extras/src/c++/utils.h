/****************************************************************/
/**                                                            **/
/**    Author: Jacob Hurst                                     **/
/**    File name: utils.h                                      **/
/**    Date: Wednesday 5 Mar 2008                              **/
/**    Description: Some useful C++ functions                  **/
/**                                                            **/
/****************************************************************/
#include <string>
#include <vector>

using namespace std;

// function prototype
void Tokenize(const string&, vector<string>& tokens,const string& delimiters);
void stripLeadingAndTrailingBlanks(string& str_in_q);
void stripLeadingAndTrailingBlanks_two(string& str_in_q);
void stripDigits(string& str_in_q);
void stripNewLine(string& str_in_q);
void stripQuotes(string& str_in_q);
void stripToken(string& str_in_q, char token);
string threeletter2singleletter_aacode(string code_in_q);
string singleletter2threeletter_aacode(string code_in_q);
string createPirFile(string seq);
int fexist(const char *filename);
string format_for_pir(string seq);
bool is_file(string f_in_q);
string xml_escape_quote(string s_in_q);
string month_name_to_number(string m_in_q);
string lower_case(string s_in_q);
