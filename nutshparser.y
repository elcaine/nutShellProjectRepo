%{ 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"
#include <dirent.h> 
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <assert.h>
#include <limits.h>
#include <glob.h>

int wipe();
int yylex();
int yyerror(char *s);
int runCDnil();
int runCD(char* arg);
int runCDspc(char* arg1, char* arg2);
int runSetAlias(char *name, char *word);
int runPWD();
int runSetenv(const char* name, const char* value);
int runUnsetenv(const char* name);
int runPrintenv();
int runPrintAlias();
int runUnalias(char* name);
int runCommand(char* command, char* argument);
int runGlobal(char* command, char* argument);
char* findPath(char* name); 
int genCommandNil(char* name);
int genCommandTwo(char* name, char* fml);
int genCommand(char* name, char* fml, char* die);
//extern int wait(int);
%}

%union {char *string;}

%start cmd_line
%token <string> CHECK WIPE BYE PWD HOME GEN SETENV UNSETENV PRINTENV  CD STRING ALIAS UNALIAS COMMAND PIPE END

%%
cmd_line    :
	BYE END 		                {exit(1);					return 1; }
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
 	| GEN END						{genCommandNil($1);			return 1; }
	| GEN STRING END				{genCommandTwo($1, $2);		return 1; }
	| GEN STRING STRING END			{genCommand($1, $2, $3);	return 1; }
	



%%
int wipe() {
		/*
		for (int i = 0; i < 10000; ++i) {
			printf("\e[1;1H\e[2J");
		}//*/
		system("clear");
		return 1;
	}

int yyerror(char *s) {
	printf("yyerror: %s\n",s);
	return 0;
  }

// Change Directory (CD) functions to accomodate 3 different args scenarios:  0, 1, or more
int runCDnil() {
	runCD(varTable.word[1]);
	return 1;
}
int runCDspc(char* arg1, char* arg2) {
	strcat(arg1, " ");
	strcat(arg1, arg2);
	runCD(arg1);
	return 1;
}
int runCD(char* arg)
{
	if (strcmp(arg, ".") == 0)
	{
		return 1; // Dummy changing to current directory politely ignored
	}
	else if (strcmp(arg, "..") == 0)
	{
		arg = varTable.word[5];
	}

	if (arg[0] != '/')	// arg is relative path
	{
		char tmpPathName[PATH_MAX];
		strcpy(tmpPathName, varTable.word[0]);
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if (chdir(varTable.word[0]) == 0)
		{
			strcpy(varTable.word[4], varTable.word[0]);	// sets cwd
			strcpy(varTable.word[5], varTable.word[0]);	// sets dir holding cwd
			char* pointer = strrchr(varTable.word[5], '/');
			while (*pointer != '\0')
			{
				*pointer = '\0';
				pointer++;
			}
		}
		else
		{
			printf("cd: %s: No such file or directory.\n", arg);
			strcpy(varTable.word[0], tmpPathName); // Replaces cwd with previous valid cwd
			return 1;
		}
	}
	else				// arg is absolute path
	{
		if (chdir(arg) == 0)
		{
			strcpy(varTable.word[0], arg);
			strcpy(varTable.word[4], arg);
			strcpy(varTable.word[5], arg);
			char* pointer = strrchr(varTable.word[5], '/');
			while (*pointer != '\0')
			{
				*pointer = '\0';
				pointer++;
			}
		}
		else
		{
			printf("cd: %s: No such file or directory.\n", arg);
			return 1;
		}
	}
	return 1;
}
//******************* SET ALIAS *******************
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
//******************* PRINTS ALIAS ******************* 
int runPrintAlias () {
for (int i = 0; i < aliasIndex; i++) {
	if((strcmp(aliasTable.name[i], "") != 0)){ 
             printf("%s=%s\n", aliasTable.name[i], aliasTable.word[i]);}
     }
return 1;
} 

//******************* DELETES ALIAS ******************* 
 int runUnalias (char *name) {
    for (int i = 0; i < aliasIndex; i++) {
      		   if(strcmp(aliasTable.name[i], name) == 0) {
				  strcpy(aliasTable.word[i], "");
				  strcpy(aliasTable.name[i], "");
   				     		 }
	}
	 	return 1;
}
 
//******************* RUN PRIN WORKING DIRECTORY   ******************* 
int runPWD()
{
	printf("Directory: %s\n", varTable.word[4]);
	return 1;
}
 
//******************* SET ENV VARIABLE ******************* 
//https://man7.org/tlpi/code/online/dist/proc/setenv.c.html#setenv
int runSetenv(const char *name, const char *value)
{

    strcpy(varTable.var[varIndex], name); 
    strcpy(varTable.word[varIndex], value);
    varIndex++;
    char *es;

    if (name == NULL || name[0] == '\0' || strchr(name, '=') != NULL ||
            value == NULL) {
        errno = EINVAL;
        return -1;
    }

    if (getenv(name) != NULL  )
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
int runUnsetenv(const char *name)
{
	 if((strcmp(name,"HOME") == 0) || strcmp(name,"PATH") == 0 ){
		printf("error: cannot unset %s\n", name);
		return 1;
	}
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


//******************* PRINT ENVIROMENT ******************* 

extern char **environ; //Global variable of user environment 

//just iterate through it 
int runPrintenv() {
  char **s = environ;

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
int runGlobal(char* command, char* argument){
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
        
	
		  char *binaryPath = findPath(command);
          char *args[] = {binaryPath,  NULL};
 	     if(  execv(binaryPath, &globbuf.gl_pathv[0]) < 0) {  
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

//******************* FIND PATH ******************* 
     char* findPath(char* name){
	 
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

		char* directory = strcat(argWords[i2],"/" );
		directory = strcat(argWords[i2],name );

		return directory;
	}

//******************* RUN COMMAND WITH NO ARG ******************* 
int genCommandNil(char* name)
{
	genCommand(name, NULL, NULL);
	return 1;
}

//******************* RUN COMMAND WITH 2 ARG ******************* 
int genCommandTwo(char* name, char* fml)
{
	
	if((strchr(fml, '*') != NULL) || (strchr(fml, '?') != NULL)) {
		 
		runGlobal(name, fml);
		return 1;
	 } 
	 else if((strcmp(name, "echo") == 0) || (strcmp(name, "cat") == 0)){
		 runCommand(name,fml);
		 return 1; 
	 }
	
	genCommand(name, fml, NULL);
	return 1;
}

//******************* RUN COMMAND WITH 3 ARG ******************* 
int genCommand(char* name, char* fml, char* die)
{
	if((strcmp(name, "echo") == 0) || (strcmp(name, "cat") == 0)){
		 runCommand(name,fml);
		 return 1; 
	 }
	int i1 = 0, i2 = 0;								// Indices 
	char argPtr[(int)strlen(varTable.word[3]) + 1];	// strcpy below copies PATH // *I think the +1 can go
	char argWords[128][128] = { '\0' };				// Array to hold each directory
	strcpy(argPtr, varTable.word[3]);

	// *** Remove these printf shits ***
	printf("\n===== NON-BUILT-IN COMMAND <%s> RECEIVED FOR US TO DEAL WITH =====\n\n", name);

	printf("===== PARSING PATH INTO DIRECTORY ELEMENTS =====\n");
	printf("genCommand with input parameters *name: <%s>, *fml: <%s>, *die: <%s>\n", name, fml, die);
	printf("Raw PATH string from varTable.word[3] found in directory: [%s]\n", varTable.word[3]);

	// Makes current directory the first directory of the directories array only if command leads with '/'
	if (argPtr[0] == '/') // This is clunky.  Should "." automate this somehow?
	{
		strcpy(argWords[i1++], varTable.word[4]);
	}
	// Appends each char from the raw PATH string, moving to next string when ':' encountered
	while (argPtr[i2] != '\0')
	{
		if (argPtr[i2] == ':')
		{
			++i1;
		}
		else
		{
			strncat(argWords[i1], &argPtr[i2], 1);
		}
		++i2;
	}

	//  Printf-ing the different directories parsed *** REMOVE THESE 14ish LINES SUBMISSION ***
	printf("\n===== PRINTING EACH DIRECTORY AFTER PARSING FROM RAW COLON SEPARATED PATH STRING =====\n");
	i2 = 0;
	if (argWords[i2][0] == '\0')
	{
		printf("*** SOME KIND OF ERROR HERE (no directories in PATH?) ***\n");
		return 1;
	}
	while (argWords[i2][0] != '\0')
	{
		printf("argWords[%d] holds: [%s]\n", i2, argWords[i2]);
		++i2;
	}

	// Search for target command within the parsed directories
	printf("\n===== SEARCHING PARSED DIRECTORIES FOR COMMAND <%s> =====\n", name);
	DIR* d;
	struct dirent* dir;
	bool found = false;
	for (i2 = 0; i2 <= i1; ++i2)
	{
		printf("Now inspectimating dir: [%s]\n", argWords[i2]);
		d = opendir(argWords[i2]);
		if (d)
		{
			while ((dir = readdir(d)) != NULL)
			{
				if (strcmp(dir->d_name, name) == 0)
				{
					found = true;
				}
			}
			closedir(d);
		}
		if (found) break;
	}

	if (i2 > i1)
	{
		printf("Command not found, so sad!!!\n");
		return 1;
	}
	else
	{
		printf("*** Command <%s> is in directory [%s] ***\n", name, argWords[i2]);
		strcat(argWords[i2], "/");	// * will need to change hard-coded "/ls" to dynamic input
		strcat(argWords[i2], name);	// Updated on 4/12 to be dynamic
	}

	// Doing the fork() stuff
	printf("\n===== STARTING fork() STUFF =====\n");
	/*
	* CAINE.....   See about maybe making a large paramater'd genCommand to catch a lot of args.
	* (would be nice if genCommand could receive just 2 args: STRING:command-name, [ARRAY]:argument-arguments)
	*/
	char* args[] = { argWords[i2], fml, die, NULL }; // varTable.word[1] = HOME (for testing ls)
	pid_t p1, p2;
	int pipe1[2];

	// Crap below was coppied from lab 5... just in case part of it needed to be mimicked
	//int f2[2];
	//int f3[2];
	//int f4[2];
	//if (pipe(f2)) { printf("fork Failed"); return 1; }
	//if (pipe(f3)) { printf("fork Failed"); return 1; }
	//if (pipe(f4)) { printf("fork Failed"); return 1; }

	if (pipe(pipe1) < 0)	{ printf("Pipe did not piped!\n"); return 1; }
	else { close(pipe1[0]);		close(pipe1[1]); }
	p1 = fork();
	
	if (p1 < 0)				{ printf("Fork did not forked!\n");	exit(0);}
	else if (p1 == 0)		// Child
	{
		// Remove all this printf crap for deliverable
		//printf("This is the child. pid: %d\t", getpid());
		//printf("Child's parent: %d\n", p1);
		//printf("\n===== COMMAND <%s> EXECUTED VIA EXECV (", name);
		//printf(nutRED "results " nutGREEN);
		//printf("below) =====");
		//printf(nutRED "\n");
		//... end of printf crap
		//close(pipe1[0]); // Abandoned pipe dreams for now.
		execv(argWords[i2], args);	// execv(parameter 1, parameter 2)
									// 1. char*:	the path/command
									// 2. char*[]:	parameter 1 is first, rest are opitons, NULL must be last element
	}
	else					// Parent
	{
		//printf("This is the parent.  pid: %d\t", getpid());
		//printf("parent's parent: %d\n", p1);
		wait(0);
	}
	//printf(nutGREEN "*** End of results from command <%s> execution ****\n", name);
	//printf("\n===== END OF NON-BUILT-IN COMMAND <%s> =====\n", name);

	return 1;
}
 
 //******************* ONE CAN WISH ******************* 
  
