#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
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
#include "thatHalf.h"

int yyerror(char* s) {
    printf("yyerror: %s\n", s);
    return 0;
}


int runSetAlias(char* name, char* word) {
    for (int i = 0; i < aliasIndex; i++) {
        if (strcmp(name, word) == 0) {
            printf("Error, expansion of \"%s\" would create a loop.\n", name);
            return 1;
        }
        else if ((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)) {
            printf("Error, expansion of \"%s\" would create a loop.\n", name);
            return 1;
        }
        else if (strcmp(aliasTable.name[i], name) == 0) {
            strcpy(aliasTable.word[i], word);
            return 1;
        }
    }
    strcpy(aliasTable.name[aliasIndex], name);
    strcpy(aliasTable.word[aliasIndex], word);
    aliasIndex++;

    return 1;
}

//Prints all aliases 
int runPrintAlias() {
    for (int i = 1; i < aliasIndex; i++) {
        if ((strcmp(aliasTable.name[i], "") != 0) && (strcmp(aliasTable.name[i], "..") != 0)) {
            printf("%s=%s\n", aliasTable.name[i], aliasTable.word[i]);
        }
    }
    return 1;
}

// Deletes alias
int runUnalias(char* name) {
    for (int i = 0; i < aliasIndex; i++) {
        if (strcmp(aliasTable.name[i], name) == 0) {
            strcpy(aliasTable.name[i], "");
            strcpy(aliasTable.word[i], "");
        }
    }
    return 1;
}

//https://man7.org/tlpi/code/online/dist/proc/setenv.c.html#setenv
int runSetenv(const char* name, const char* value)
{    //Push intoVar Table
	strcpy(varTable.var[varIndex], name);
	strcpy(varTable.word[varIndex], value);
	varIndex++;
	char* es;

	if (name == NULL || name[0] == '\0' || strchr(name, '=') != NULL ||
		value == NULL) {
		errno = EINVAL;
		return -1;
	}

	if (getenv(name) != NULL)
		return 0;

	runUnsetenv(name);             /* Remove all occurrences */

	es = malloc(strlen(name) + strlen(value) + 2);
	/* +2 for '=' and null terminator */
	if (es == NULL)
		return -1;

	strcpy(es, name);
	strcat(es, "=");
	strcat(es, value);

	return (putenv(es) != 0) ? -1 : 0;
}

int runUnsetenv(const char* name)
{    //Delete from varTable
	for (int i = 0; i < varIndex; i++) {
		if (strcmp(varTable.var[i], name) == 0) {
			strcpy(varTable.var[i], "");
			strcpy(varTable.var[i], "");
		}
	}
	extern char** environ;
	char** ep, ** sp;
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

		}
		else {
			ep++;
		}

	return 0;
}

extern char** environ; //Global variable of user environment 

//just iterate through it 
int runPrintenv() {
	char** s = environ;

	for (; *s; s++) {
		printf("%s\n", *s);
	}

	return 1;
}

int runCommandNil(char* name) {
	printf("Here it is %s\t", name);
	genCommand(name, NULL);
	return 1;
}

int runCommand(char* name, char* fml) {
	printf("Here it is %s\t", name);
	printf("fml is: %s\n", fml);
	genCommand(name, fml);
	return 1;
}

int runGlobal(char* name) {
	/*
	printf("Runinng glob, string is %s\n", name);
	glob_t globbuf;
	globbuf.gl_offs = 1;
	glob(name, GLOB_DOOFFS, NULL, &globbuf);
	globbuf.gl_pathv[0] = "ls";


	pid_t  pid;
	int    status;

	if ((pid = fork()) < 0) {     // fork a child process           
		printf("*** ERROR: forking child process failed\n");
		exit(1);
	}
	else if (pid == 0) {          // for the child process:         
		if (execvp("ls", &globbuf.gl_pathv[0]) < 0) {     // execute the command  
			printf("*** ERROR: exec failed\n");
			exit(1);
		}
	}
	else {                                  // for the parent:   
		while (wait(&status) != pid);
	}
	*/


	/*
			   //globbuf.gl_pathv[1] = "-l";
		printf("Creating another process using fork()...\n");
		wait(NULL);
		if (fork() == 0) {
			// Newly spawned child Process. This will be taken over by "ls"
			int status_code = execvp("ls", &globbuf.gl_pathv[0]);
			exit(0);
			if (status_code == -1) {
				printf("Terminated Incorrectly\n");
				return 1;
			}
		}
		else {
			// Old Parent process. The C program will come here
			printf("back to parent\n");
		}
	 */

	return 1;
}