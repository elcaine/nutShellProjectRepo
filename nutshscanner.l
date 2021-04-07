%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run. 
#include <string.h>
#include <stdbool.h>
#include <errno.h>
#include "global.h"
#include "nutshparser.tab.h"

 int counter = 0; 
 
//#define unput(c) {yytchar= (c); if(yytchar=='\n') {yylineno--; *yysptr++=yytchar;}
char* subAliases(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}
bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}
%}
%array
%option noyywrap


CHAR            [.A-Za-z!\/_-][.A-Za-z!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*

%x string_condition
%x variable_condition


%%
    
     
<string_condition>{ANYCHAR}+     { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]           {BEGIN(INITIAL);} 

<variable_condition>{ANYCHAR}+     { yylval.string = strdup(yytext); return VARIABLE;}
<variable_condition>"}"            {BEGIN(INITIAL);} 

 


[ ]		    { }
bye         { return BYE; }
home        { return HOME; }
pwd			{ return PWD; } 
ls			{ return LS; }
setenv			{ return SETENV; }
unsetenv		{ return UNSETENV; }
printenv		{ return PRINTENV; }			
cd		        { return CD;}
unalias			{ return UNALIAS; }
alias		        { return ALIAS; }
"\n"		        { return END; }
 [\"]                 	{ BEGIN(string_condition); }
"${"			{ BEGIN(variable_condition); }
[0-9]+                	{ printf( "found an integer, = %d\n",atoi( yytext ) ); }
"$"        		{ printf( "found a dollar sign\n" ); }
"{"			{ printf("found a curly brace\n" ); }
"<"        		{ printf( "found forward\n" ); }
">"        		{ printf( "found backwards\n" ); }
"|"        		{ printf( "found a pipe\n" ); }
"&"        		{ printf( "found an amp\n" ); }
"Count"			{ printf( "%d\n", counter); }




{CHAR}+              {if(ifAlias(yytext) && counter == 0) {
                        printf("alias before sub: %s\n", yytext);
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );
                      } else {
                         printf("yytext: %s\n", yytext);
                        yylval.string = strdup(yytext);
			counter ++; 
                        return STRING;
                    };
                     }

%%

 // source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html