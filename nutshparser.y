%{
#include <stdlib.h>
#include "global.h"
#include "thisHalf.h"
#include "thatHalf.h"

int yylex();

%}

%union {char *string;}

%start cmd_line
%token <string> WIPE BYE PWD HOME GEN SETENV UNSETENV PRINTENV CD STRING ALIAS UNALIAS COMMAND CHECK END

%%
cmd_line    :
	BYE END 		                {exit(1);					return 1; }
	| WIPE END						{wipe();					return 1; }
	| PWD END						{runPWD();					return 1; } 
	| HOME END						{runCD(varTable.word[1]);	return 1; }
	| GEN STRING END				{genCommandNil($2);			return 1; }
	| GEN STRING STRING END			{genCommand($2, $3);		return 1; }
	| SETENV STRING STRING END		{runSetenv($2, $3);			return 1; }
	| UNSETENV STRING END			{runUnsetenv($2);			return 1; } 
	| PRINTENV END					{runPrintenv();				return 1; } 
	| CD END						{runCDnil();				return 1; }
	| CD STRING END        			{runCD($2);					return 1; }
	| CD STRING STRING END			{runCDspc($2, $3);			return 1; }
	| UNALIAS STRING  END			{runUnalias($2);			return 1; } 
	| ALIAS END						{runPrintAlias();			return 1; }
	| ALIAS STRING STRING END		{runSetAlias($2, $3);		return 1; }
	| COMMAND STRING END			{runCommand($1, $2);		return 1; }
	| COMMAND END					{runCommandNil($1);			return 1; }
	| CHECK STRING END				{runGlobal($2);				return 1; }


%%
