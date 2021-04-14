%{
#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <dirent.h> 
//
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <assert.h>
#include "nutshparser.tab.h"
#include "global.h"
int counter = 0; 
 
//#define unput(c) {yytchar= (c); if(yytchar=='\n') {yylineno--; *yysptr++=yytchar;}
char* subAliases(char* name) {
    for (int i = 0; i < aliasIndex; i++) {
        if (strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}

bool ifAlias(char* name) {
    for (int i = 0; i < aliasIndex; i++) {
        if (strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}

char* subVar(char* name) {
	for (int i = 0; i < varIndex; i++) {
		if (strcmp(varTable.var[i], name) == 0) {
			return varTable.word[i];
		}
	}
	return name;
}

bool ifVar(char* name) {
	for (int i = 0; i < varIndex; i++) {
		if (strcmp(varTable.var[i], name) == 0) {
			return true;
		}
	}
	return false;
}

bool ifNonBuild(char* name) {
	int i1 = 0, i2 = 0;								// Indices 
	char argPtr[(int)strlen(varTable.word[3]) + 1];	// strcpy below copies PATH
	char argWords[128][128] = { '\0' };				// Array to hold each directory
	strcpy(argPtr, varTable.word[3]);

	// *** Remove these printf shits ***
	//printf("===== PARSING PATH INTO DIRECTORY ELEMENTS =====\n");
	//printf("runLS with input parameter (char* name): %s\n", name);
	//printf("PATH from varTable.word[3]: %s\n", varTable.word[3]);

	// Appends each char from the PATH, moving to next string when ':' encountered
	while (argPtr[i2] != '\0') {
		if (argPtr[i2] == ':') {
			++i1;
		}
		else {
			strncat(argWords[i1], &argPtr[i2], 1);
		}
		++i2;
	}

	//  Printf-ing the different directories parsed *** REMOVE ME ***
	i2 = 0;
	//printf("The colon separated PATH variables after parsing:\n");
	if (argWords[i2][0] == '\0') {
		//printf("*** SOME KIND OF ERROR HERE (no directories in PATH?) ***\n");
		return 1;
	}
	while (argWords[i2][0] != '\0') {
		//printf("argWords[%d] holds: <%s>\n", i2, argWords[i2]);
		++i2;
	}

	// Search for target command within the parsed directories
	//printf("\n\n===== SEARCHING PARSED DIRECTORIES =====\n");
	DIR* d;
	struct dirent* dir;
	bool found = false;
	for (i2 = 0; i2 <= i1; ++i2) {
		//printf("Now inspectimating dir: %s\n", argWords[i2]);
		d = opendir(argWords[i2]);
		if (d) {
			while ((dir = readdir(d)) != NULL) {
				if (strcmp(dir->d_name, name) == 0) {
					//printf("*** WINNER WINNER, CHICKEN DINNER --> %s IS HERE!!!\n", dir->d_name);
					//printf("%s\n", dir->d_name);
					found = true;
				}
			}
			closedir(d);
		}
		if (found) break;
	}

	if (i2 > i1) {
		//	printf("Command not found, you suck!!!\n");
		return false;
	}
	else {
		//	printf("*** Command %s is in %s ***\n", name, argWords[i2]);
		//	printf("So, you found it, WHAT... AN... ACCOMPLISHMENT\tYou must be so proud!\n");
		strcat(argWords[i2], "/cat"); // * will need to change hard-coded "/ls" to 
		return true;
	}
}
%}
%array
%option noyywrap


CHAR            [.A-Za-z!\/_-][.A-Za-z!\/_-]*
ANYCHAR         [)(*&%$#@!`;,\.a-zA-Z0-9'*/_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'*/_=~ -]*

%x string_condition
%x variable_condition


%%
    
     
<string_condition>{ANYCHAR}+    { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]          {BEGIN(INITIAL);} 

<variable_condition>{ANYCHAR}+	{
									if(ifVar(yytext))
									{
										yylval.string = strdup(subVar(yytext));
										printf("%s\n", yylval.string); return STRING;
									}
									else { printf("Error, no such variable"); } }
<variable_condition>"}"          {BEGIN(INITIAL);} 



[ ]		    { }
check		{ return CHECK; }
wipe        { return WIPE; }
bye         { return BYE; }
home        { return HOME; }
pwd			{ return PWD; } 
gen			{ return GEN; }
setenv		{ return SETENV; }
unsetenv	{ return UNSETENV; }
printenv	{ return PRINTENV; }			
cd		    { counter ++; return CD;}
unalias		{ counter ++; return UNALIAS; }
alias		{ counter ++; return ALIAS; }
"\n"		{ return END; }
[\"]       	{ BEGIN (string_condition); }
"${"		{ BEGIN (variable_condition); }
[0-9]+     	{ printf("found an integer, = %d\n",atoi( yytext ) ); }
"$"        	{ printf("found a dollar sign\n" ); }
"{"		    { printf("found a curly brace\n" ); }
"<"        	{ printf("found forward\n" ); }
">"        	{ printf("found backwards\n" ); }
"|"        	{ printf("found a pipe\n" ); }
"&"        	{ printf("found an amp\n" ); }
"Count"		{ printf("%d\n", counter); }




{CHAR}+ {
	if (ifAlias(yytext) && counter == 0)
	{
		printf("alias before substitute: %s\n", yytext);
		char* yycopy = strdup(subAliases(yytext));
		for (int i = strlen(subAliases(yytext)) - 1; i >= 0; --i)
			unput(yycopy[i]);
		free(yycopy);
	}
	if (ifNonBuild(yytext) ) {
		printf("here we go sub: %s\n", yytext);
		yylval.string = strdup(yytext);
		return COMMAND;
	}
	else
	{
		//printf("string is: %s\n", yytext);
		yylval.string = strdup(yytext);
		counter = 0;
		return STRING;
	};
}

%%
// source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
