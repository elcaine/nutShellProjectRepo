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
#include <limits.h>
#include <glob.h>

#include "nutshparser.tab.h"
#include "global.h"
#include "thatHalf.h"

int yyerror(char* s) {
	printf("yyerror: %s\n", s);
	return 0;
}

//******************* SET ALIAS *******************
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
//******************* PRINTS ALIAS ******************* 
int runPrintAlias() {
	for (int i = 0; i < aliasIndex; i++) {
		if ((strcmp(aliasTable.name[i], "") != 0)) {
			printf("%s=%s\n", aliasTable.name[i], aliasTable.word[i]);
		}
	}
	return 1;
}

//******************* DELETES ALIAS ******************* 
int runUnalias(char* name) {
	for (int i = 0; i < aliasIndex; i++) {
		if (strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], "");
			strcpy(aliasTable.name[i], "");
		}
	}
	return 1;
}

//******************* SET ENV VARIABLE ******************* 
//https://man7.org/tlpi/code/online/dist/proc/setenv.c.html#setenv
int runSetenv(const char* name, const char* value)
{

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

//******************* UNSET VARIABLE   ******************* 
int runUnsetenv(const char* name)
{
	if ((strcmp(name, "HOME") == 0) || strcmp(name, "PATH") == 0) {
		printf("error: cannot unset %s\n", name);
		return 1;
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


//******************* PRINT ENVIROMENT ******************* 

extern char** environ; //Global variable of user environment 

//just iterate through it 
int runPrintenv() {
	char** s = environ;

	for (; *s; s++) {
		printf("%s\n", *s);
	}

	return 1;
}
//******************* NON BUILD IN TERRITORRY ******************* 

//******************* RUN SIMPLE COMMAND ******************* 
int runCommand(char* name, char* fml) {
	//printf("Here it is %s\t", name);
	//printf("fml is: %s\n", fml);
	 if((strchr(fml, '*') != NULL) || (strchr(fml, '?') != NULL)) {
		 
		runGlobal(name, fml);
		return 1;
	 } 
	 pid_t  pid;
     int    status;
     
     if ((pid = fork()) < 0) {     /* fork a child process           */
          printf("*** ERROR: forking child process failed\n");
          exit(1);
     }
     else if (pid == 0) {          /* for the child process:         */
        
	
		  char *binaryPath = findPath(name);
          char *args[] = {binaryPath,fml, NULL};
 	     if(  execv(binaryPath, args) < 0) {  
 		 //if (execv("/bin", &globbuf.gl_pathv[0]) < 0) {     /* execute the command  */
               printf("*** ERROR: exec failed\n");
               exit(1);
          }
     }
     else {                                  /* for the parent:      */
          while (wait(&status) != pid);
     }

return 1; 
            
 }



//******************* RUN WILDCARD MATCHING ******************* 
int runGlobal(char* command, char* argument) {
	printf("Runinng glob, command is %s, argument is %s\n", command, argument);
	glob_t globbuf;
	globbuf.gl_offs = 1;
	glob(argument, GLOB_DOOFFS, NULL, &globbuf);
	globbuf.gl_pathv[0] = command;


	pid_t  pid;
	int    status;

	if ((pid = fork()) < 0) {     /* fork a child process           */
		printf("*** ERROR: forking child process failed\n");
		exit(1);
	}
	else if (pid == 0) {          /* for the child process:         */


		char* binaryPath = findPath(command);
		char* args[] = { binaryPath,  NULL };
		if (execv(binaryPath, &globbuf.gl_pathv[0]) < 0) {
			//if (execv("/bin", &globbuf.gl_pathv[0]) < 0) {     /* execute the command  */
			printf("*** ERROR: exec failed\n");
			exit(1);
		}
	}
	else {                                  /* for the parent:      */
		while (wait(0));
	}

	return 1;

}

//******************* FIND PATH ******************* 
char* findPath(char* name) {

	int i1 = 0, i2 = 0;							// Indices 
	char argPtr[(int)strlen(varTable.word[3]) + 1];	// strcpy below copies PATH
	char argWords[128][128] = { '\0' };				// Array to hold each directory
	strcpy(argPtr, varTable.word[3]);


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
		exit(1);
	}
	while (argWords[i2][0] != '\0') {
		++i2;
	}


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

	char* directory = strcat(argWords[i2], "/");
	directory = strcat(argWords[i2], name);

	return directory;
}
