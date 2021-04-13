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
//
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <assert.h>

int wipe();
int yylex();
int yyerror(char *s);
int runCDnil();
int runCD(char* arg);
int runCDspc(char* arg1, char* arg2);
int runSetAlias(char *name, char *word);
int runPWD();
int runLSnil();
int runLS(char* name);
int runSetenv(const char* name, const char* value);
int runUnsetenv(const char* name);
int runPrintenv();
int runPrintAlias();
// more
int runUnalias(char* name);
int runVariable();
%}

%union {char *string;}

%start cmd_line
%token <string> WIPE BYE PWD HOME LS SETENV UNSETENV PRINTENV CD STRING ALIAS UNALIAS COMMAND CHECK END

%%
cmd_line    :
	BYE END 		                {exit(1);		return 1; }
	| WIPE END				{wipe();		return 1; }
	| PWD END				{runPWD();		return 1; } 
	| HOME END				{runCD(varTable.word[1]);return 1; }
	| LS END				{runLSnil();		return 1; }
	| LS STRING END				{runLS($2);		return 1; }
	| SETENV STRING STRING END		{runSetenv($2, $3);	return 1; }
	| UNSETENV STRING END			{runUnsetenv($2);	return 1; } 
	| PRINTENV END				{runPrintenv();		return 1; } 
	| CD END				{runCDnil();		return 1; }
	| CD STRING END        			{runCD($2);		return 1; }
	| CD STRING STRING END			{runCDspc($2, $3);	return 1; }
	| UNALIAS STRING  END			{runUnalias($2);	return 1; } 
	| ALIAS END				{runPrintAlias();	return 1; }
	| ALIAS STRING STRING END		{runSetAlias($2, $3);	return 1; }
 	| COMMAND END				{runCommand($1);	return 1; }
	| CHECK STRING END				{runGlobal($2);				return 1; }


%%
int wipe() {
		/*
		for (int i = 0; i < 10000; ++i) {
			printf("\e[1;1H\e[2J");
		}//*/
		system("clear");
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
int runCD(char* arg) {
	if (arg[0] != '/') { // arg is relative path
		char tmpPathName[PATH_MAX];
		strcpy(tmpPathName, varTable.word[0]); 
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			strcpy(aliasTable.word[0], varTable.word[0]);	// sets cwd
			strcpy(aliasTable.word[1], varTable.word[0]);	// sets dir holding cwd
			char *pointer = strrchr(aliasTable.word[1], '/');
			while(*pointer != '\0') {
				*pointer ='\0';
				pointer++;
			}
		}
		else {
			printf("cd: %s: No such file or directory.\n", arg);
			strcpy(varTable.word[0], tmpPathName); // Replaces cwd with previous valid cwd
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			strcpy(aliasTable.word[0], arg);
			strcpy(aliasTable.word[1], arg);
			char *pointer = strrchr(aliasTable.word[1], '/');
			while(*pointer != '\0') {
			*pointer ='\0';
			pointer++;
			}
		}
		else {
			printf("cd: %s: No such file or directory.\n", arg);
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

//Prints all aliases 
int runPrintAlias () {
for (int i = 1; i < aliasIndex; i++) {
	if((strcmp(aliasTable.name[i], "") != 0) && (strcmp(aliasTable.name[i], "..") != 0)){ 
             printf("%s=%s\n", aliasTable.name[i], aliasTable.word[i]);}
     }
return 1;
} 

// Deletes alias
 int runUnalias (char *name) {
    for (int i = 0; i < aliasIndex; i++) {
      		   if(strcmp(aliasTable.name[i], name) == 0) {
				  strcpy(aliasTable.name[i], "");
				  strcpy(aliasTable.word[i], "");
   				     		 }
	}
	 	return 1;
}
 

//Print working directory	***** DOES THIS NEED TO CHANGED??? *******
int runPWD() {
	char cwd[PATH_MAX];
	getcwd(cwd, sizeof(cwd));
	printf("Current hacker directory: %s\n", cwd);
	return 1;
}

//This will need more work but basics is here
int runLSnil() {
	runLS(" ");
	return 1;
}
int runLS(char* name)
{
	printf("runLS *name -->\t%s\n", name); // *** remove me ****
	char* bPath = "/usr/bin/ls";
	char* args[] = { bPath, name, NULL };

	pid_t dispid = getpid();
	pid_t shpid = fork();
	printf("Before if().... shpid: %d\n", shpid);
	int execvNUM = -69;
	if (!shpid) {
		//printf("Inside the if() thang\n");
		execvNUM = execv(bPath, args);
	}
	else {
		printf("else route:  \n");
	}
	//waitpid(shpid);
	printf("After if().... execvNUM: %d\n", execvNUM);

	// All of this is trash since LS (and all non-built in commands) should be called from bin
	/*  
	struct dirent **namelist; 
	int n;
	//n = scandir(".", &namelist, 1, alphasort);
	n = scandir(".", &namelist, NULL, alphasort);

	if(n < 0) 
	{ 
		perror("scandir"); 
		exit(EXIT_FAILURE); 
	} 
	else 
	{
		int o = 0;
		while (o < n) 
		{ 
			printf("%s\n", namelist[o]->d_name); 
			free(namelist[o]);
			++o;
		} 
		free(namelist); 
	} 
	//*/
	;
	// This too
	;
	/*
	int t = 1, done;
	int argc = 3;
	DIR* dir = opendir(name);
	struct dirent* ent;
	if (argc < 3)
	{
		printf("The correct syntax is ls dirname\n");
		exit(0);
	}
	if ((dir == NULL))  // To check the existence of the directory
	{
		perror("Unable to open");
		exit(1);
	}
	if (argc == 3)
	{
		dir = opendir(name);
		while ((ent = readdir(dir)) != NULL)
		{
			printf("%s\t", ent->d_name);
			if ((int)strlen(ent->d_name) < 17)
				printf("\t");

			if ((int)strlen(ent->d_name) < 5)
				printf("\t");
			//printf("size of ent->d_name: *** %d ***  ", (int)strlen(ent->d_name));
			if (1)
			{
				struct stat sbuf;
				stat(ent->d_name, &sbuf);
				if (sbuf.st_size == 0)   //Check for empty file
					printf("d");
				//Find out the permissions for files and directories
				if (sbuf.st_mode & S_IREAD)
					printf("r");
				else
					printf("-");
				
				if (sbuf.st_mode & S_IWRITE)
					printf("w");
				else
					printf("-");
				
				if (sbuf.st_mode & S_IEXEC)
					printf("x");
				else
					printf("-");
				//Print the size
				printf("\t%d", (int)sbuf.st_size);
				//Print the date and time of last modified
				printf("\t%s", ctime(&sbuf.st_ctime));
			}
		}
		//close(dir);
	}
	if (argc == 2)
	{
		while ((ent = readdir(dir)) != NULL)
			printf("%s\n", ent->d_name);
	}
	//*/
	return 1;  
}

//https://man7.org/tlpi/code/online/dist/proc/setenv.c.html#setenv
int runSetenv(const char *name, const char *value)
{    //Push intoVar Table
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

int runUnsetenv(const char *name)
{    //Delete from varTable
     for (int i = 0; i < varIndex; i++) {
      		   if(strcmp(varTable.var[i], name) == 0) {
				  strcpy(varTable.var[i], "");
				  strcpy(varTable.var[i], "");
   				     		 }
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

extern char **environ; //Global variable of user environment 

//just iterate through it 
int runPrintenv() {
  char **s = environ;

  for (; *s; s++) {
    printf("%s\n", *s);
  }

  return 1;
}


int runCommand(char* name){
	printf("Here it is %s\n", name);
	return 1;
}

int runGlobal(char* name){
	printf("Runinng glob, string is %s\n", name);
	glob_t globbuf;
           globbuf.gl_offs = 1;
           glob(name, GLOB_DOOFFS, NULL, &globbuf);
           globbuf.gl_pathv[0] = "ls";


	 pid_t  pid;
     int    status;
     
     if ((pid = fork()) < 0) {     /* fork a child process           */
          printf("*** ERROR: forking child process failed\n");
          exit(1);
     }
     else if (pid == 0) {          /* for the child process:         */
          if (execvp("ls", &globbuf.gl_pathv[0]) < 0) {     /* execute the command  */
               printf("*** ERROR: exec failed\n");
               exit(1);
          }
     }
     else {                                  /* for the parent:      */
          while (wait(&status) != pid);
     }



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
