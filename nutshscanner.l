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

#define nutRED         "\x1b[31m"
#define nutGREEN       "\x1b[32m"
#define nutBLUE        "\x1b[34m"
#define nutYELLOW      "\x1b[33m"

int counter = 0; 
 
//#define unput(c) {yytchar= (c); if(yytchar=='\n') {yylineno--; *yysptr++=yytchar;}
//******************* SUBSTITUTE ALIAS *******************
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

//******************* SUBSTITUTE VARIABLE *******************
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

//******************* CHECK IF THE STRING IS A COMMAND *******************
bool ifNonBuild(char* name) {
if((strchr(name, '.') != NULL)) {
		return false;
 	 } 
	int i1 = 0, i2 = 0;								// Indices 
	char argPtr[(int)strlen(varTable.word[3]) + 1];	// strcpy below copies PATH
	char argWords[128][128] = { '\0' };				// Array to hold each directory
	strcpy(argPtr, varTable.word[3]);

	// Makes current directory the first directory of the directories array
	strcpy(argWords[i1++], varTable.word[4]);
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

	if (argWords[0][0] == '\0') {
		printf("*** SOME KIND OF ERROR HERE (no directories in PATH?) ***\n");
		return 1;
	}

	// Search for target command within the parsed directories
	DIR* d;
	struct dirent* dir;
	bool found = false;
	for (i2 = 0; i2 <= i1; ++i2) {
		d = opendir(argWords[i2]);
		if (d) {
			while ((dir = readdir(d)) != NULL) {
				if (strcmp(dir->d_name, name) == 0) {
					found = true;
				}
			}
			closedir(d);
		}
		if (found) break;
	}

	if (i2 > i1) {
		printf("Command <%s> not found.\tPlease try again.\n", name);
		return false;
	}
	else {
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
										printf("%s\n", yylval.string);
										 return STRING; 
									}
									else { printf("Error, no such variable"); } }
<variable_condition>"}"          {BEGIN(INITIAL);} 

[ ]		    { }
wipe        { return WIPE; }
bye         { return BYE; }
home        { return HOME; }
pwd			{ return PWD; } 
setenv		{ return SETENV; }
unsetenv	{ counter ++; return UNSETENV; }
pipe		{ return PIPE; }
printenv	{ return PRINTENV; }			
cd		    { counter ++; return CD;}
unalias		{ counter ++; return UNALIAS; }
alias		{ counter ++; return ALIAS; }
"\n"		{ return END; }
[\"]       	{ BEGIN (string_condition); }
"${"		{ BEGIN (variable_condition); }
"Count"		{ printf("%d\n", counter); }
<<EOF>>     { return END_OF_FILE;}

{CHAR}+ {
	 
	if (ifAlias(yytext) && counter == 0)
	{
		//printf("alias before substitute: %s\n", yytext);
		char* yycopy = strdup(subAliases(yytext));
		for (int i = strlen(subAliases(yytext)) - 1; i >= 0; --i)
			unput(yycopy[i]);
		free(yycopy);
	}
	if (ifNonBuild(yytext) && counter == 0)
	{
		yylval.string = strdup(yytext);
		//counter ++;
		return GEN;
	}
	else
	{
		printf(nutGREEN);
		yylval.string = strdup(yytext);
		counter = 0;
		return STRING;
	};
}

%%
// source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
