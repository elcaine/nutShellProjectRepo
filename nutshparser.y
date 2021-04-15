%{
#include <stdlib.h>
#include "global.h"
#include "thisHalf.h"
#include "thatHalf.h"

int yylex();

%}

%union {char *string;}

%start cmd_line
%token <string> WIPE BYE PWD HOME GEN SETENV UNSETENV PRINTENV CD STRING ALIAS UNALIAS PIPE END_OF_FILE END

%%
cmd_line    :
	BYE END 		                {exit(1);					return 1; }
	|END_OF_FILE					{exit(1);					return 1; }
	| WIPE END						{wipe();					return 1; }
	| PWD END						{runPWD();					return 1; } 
	| HOME END						{runCD(varTable.word[1]);	return 1; }
	| SETENV STRING STRING END		{runSetenv($2, $3);			return 1; }
	| UNSETENV STRING END			{runUnsetenv($2);			return 1; } 
	| PRINTENV END					{runPrintenv();				return 1; } 
	| CD END						{runCDnil();				return 1; }
	| CD STRING END        			{runCD($2);					return 1; }
	| CD STRING STRING END			{runCDspc($2, $3);			return 1; }
	| UNALIAS STRING  END			{runUnalias($2);			return 1; } 
	| ALIAS END						{runPrintAlias();			return 1; }
	| ALIAS STRING STRING END		{runSetAlias($2, $3);		return 1; }
	| GEN END											{genCommandOne($1);							return 1; }
	| GEN STRING END									{genCommandTwo($1, $2);						return 1; }
	| GEN STRING STRING END								{genCommandTre($1, $2, $3);					return 1; }
	| GEN STRING STRING STRING END						{genCommandFor($1, $2, $3, $4);				return 1; }
	| GEN STRING STRING STRING STRING END				{genCommandFiv($1, $2, $3, $4, $5);			return 1; }
	| GEN STRING STRING STRING STRING STRING END		{genCommandSix($1, $2, $3, $4, $5, $6);		return 1; }
	| GEN STRING STRING STRING STRING STRING STRING END	{genCommand   ($1, $2, $3, $4, $5, $6, $7);	return 1; }
	
%%
