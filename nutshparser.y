%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run. 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"
#include <dirent.h> 
#include <errno.h>

int yylex();
int yyerror(char *s);
int runCD(char* arg);
int runSetAlias(char *name, char *word);
%}

%union {char *string;}

%start cmd_line
%token <string> BYE PWD LS SETENV CD STRING ALIAS END

%%
cmd_line    :
	BYE END 		                {exit(1); return 1; }
	| PWD END				{runPWD(); return 1; } 
	| LS STRING END				{runLS($2); return 1; } 
	| SETENV STRING STRING END		{runSetenv($2, $3); return 1;}
	| CD STRING END        			{runCD($2); return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3); return 1;}

%%

int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
  }

int runCD(char* arg) {
	if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			strcpy(aliasTable.word[0], varTable.word[0]);
			strcpy(aliasTable.word[1], varTable.word[0]);
			char *pointer = strrchr(aliasTable.word[1], '/');
			while(*pointer != '\0') {
				*pointer ='\0';
				pointer++;
			}
		}
		else {
			//strcpy(varTable.word[0], varTable.word[0]); // fix
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(aliasTable.word[0], arg);
			strcpy(aliasTable.word[1], arg);
			strcpy(varTable.word[0], arg);
			char *pointer = strrchr(aliasTable.word[1], '/');
			while(*pointer != '\0') {
			*pointer ='\0';
			pointer++;
			}
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
	return 1;
}

int runSetAlias(char *name, char *word) {
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}
int runPWD() {
	char cwd[1028];
	getcwd(cwd, sizeof(cwd));
	printf("Current hacker directory: %s\n", cwd);
	return 1;
}
int runLS(char *name) 
{ 
	struct dirent **namelist; 
	int n; 
	 
		n=scandir(".",&namelist,NULL,alphasort); 
	 	  
	if(n < 0) 
	{ 
		perror("scandir"); 
		exit(EXIT_FAILURE); 
	} 
	else 
	{ 
		while (n--) 
		{ 
			printf("%s\n",namelist[n]->d_name); 
			free(namelist[n]); 
		} 
		free(namelist); 
	} 
	return 1;  
} 
int runSetenv(const char *name, const char *value)
{
    char *es;

    if (name == NULL || name[0] == '\0' || strchr(name, '=') != NULL ||
            value == NULL) {
        errno = EINVAL;
        return -1;
    }

    if (getenv(name) != NULL  )
        return 0;

    unsetenv(name);             /* Remove all occurrences */

    es = malloc(strlen(name) + strlen(value) + 2);
                                /* +2 for '=' and null terminator */
    if (es == NULL)
        return -1;

    strcpy(es, name);
    strcat(es, "=");
    strcat(es, value);

    return (putenv(es) != 0) ? -1 : 0;
}

int unsetenv(const char *name)
{
    extern char **environ;
    char **ep, **sp;
    size_t len;

    if (name == NULL || name[0] == '\0' || strchr(name, '=') != NULL) {
        errno = EINVAL;
        return -1;
    }

    len = strlen(name);

    for (ep = environ; *ep != NULL; )
        if (strncmp(*ep, name, len) == 0 && (*ep)[len] == '=') {

            /* Remove found entry by shifting all successive entries
               back one element */

            for (sp = ep; *sp != NULL; sp++)
                *sp = *(sp + 1);

            /* Continue around the loop to further instances of 'name' */

        } else {
            ep++;
        }

    return 0;
}
