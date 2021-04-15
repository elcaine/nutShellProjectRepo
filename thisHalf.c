#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h> 
#include <errno.h>
#include "global.h"
#include "thisHalf.h"

#define nutRED         "\x1b[31m"
#define nutGREEN       "\x1b[32m"
#define nutBLUE        "\x1b[34m"

int wipe() {
	/*
	for (int i = 0; i < 10000; ++i) {
		printf("\e[1;1H\e[2J");
	}//*/
	system("clear");
}


//Print working directory	***** DOES THIS NEED TO CHANGED??? ******* // updated on 4/12, should be good now
int runPWD()
{
	printf("Current directory: %s\n", varTable.word[4]);
	return 1;
}

// Change Directory (CD) functions to accomodate 3 different args scenarios:  0, 1, or more
int runCDnil()
{
	runCD(varTable.word[1]);
	return 1;
}
int runCDspc(char* arg1, char* arg2)
{
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

//
//	Runs genCommand if no arguments are passed to it (not sure if this should be part of deliverable since
//	variable numbers of arguments (none, 1, 2, 3, 4, ... ?) might need to be caught in lexx/yacc nested rule
//	...  not sure
//

int genCommandOne(char* comm)
		   { genCommand(comm,		NULL,		NULL,		NULL,		NULL,		NULL,		NULL); return 1; }

int genCommandTwo(char* comm, char* arg1)
		   {
			 
			   
			    genCommand(comm,		arg1,		NULL,		NULL,		NULL,		NULL,		NULL); 
		    
		   if((strchr(arg1, '*') != NULL) || (strchr(arg1, '?') != NULL)) {
		runGlobal(comm, arg1);
		return 1;
	 }
	  return 1; }

int genCommandTre(char* comm, char* arg1, char* arg2)
		   { genCommand(comm,		arg1,		arg2,		NULL,		NULL,		NULL,		NULL); return 1; }

int genCommandFor(char* comm, char* arg1, char* arg2, char* arg3)
		   { genCommand(comm,		arg1,		arg2,		arg3,		NULL,		NULL,		NULL); return 1; }

int genCommandFiv(char* comm, char* arg1, char* arg2, char* arg3, char* arg4)
		   { genCommand(comm,		arg1,		arg2,		arg3,		arg4,		NULL,		NULL); return 1; }

int genCommandSix(char* comm, char* arg1, char* arg2, char* arg3, char* arg4, char* arg5)
		   { genCommand(comm,		arg1,		arg2,		arg3,		arg4,		arg5,		NULL); return 1; }

int genCommand(	  char* comm, char* arg1, char* arg2, char* arg3, char* arg4, char* arg5, char* arg6)
{
	    if((strcmp(comm, "echo") == 0) || (strcmp(comm, "cat") == 0)){
		 runCommand(comm,arg1);
		 return 1; 
	 }
	int i1 = 0, i2 = 0;								// Indices 
	char argPtr[(int)strlen(varTable.word[3]) + 1];	// strcpy below copies PATH // *I think the +1 can go
	char argWords[128][128] = { '\0' };				// Array to hold each directory
	strcpy(argPtr, varTable.word[3]);

	/*/ *** Remove these printf shits ***
	printf("\n===== NON-BUILT-IN COMMAND <%s> RECEIVED FOR US TO DEAL WITH =====\n\n", comm);

	printf("===== PARSING PATH INTO DIRECTORY ELEMENTS =====\n");
	printf("genCommand with input parameters *name: <%s>, *arg1: <%s>, *arg2: <%s>\n", comm, arg1, arg2);
	printf("Raw PATH string from varTable.word[3] found in directory: [%s]\n", varTable.word[3]);
	//*/
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
	//printf("\n===== PRINTING EACH DIRECTORY AFTER PARSING FROM RAW COLON SEPARATED PATH STRING =====\n");
	i2 = 0;
	if (argWords[i2][0] == '\0')
	{
		printf("*** SOME KIND OF ERROR HERE (no directories in PATH?) ***\n");
		return 1;
	}
	while (argWords[i2][0] != '\0')
	{
		//printf("argWords[%d] holds: [%s]\n", i2, argWords[i2]);
		++i2;
	}

	// Search for target command within the parsed directories
	//printf("\n===== SEARCHING PARSED DIRECTORIES FOR COMMAND <%s> =====\n", comm);

	DIR* d;
	struct dirent* dir;
	bool found = false;
	for (i2 = 0; i2 <= i1; ++i2)
	{
		//printf("Now inspectimating dir: [%s]\n", argWords[i2]);
		d = opendir(argWords[i2]);
		if (d)
		{
			while ((dir = readdir(d)) != NULL)
			{
				if (strcmp(dir->d_name, comm) == 0)
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
		//printf("*** Command <%s> is in directory [%s] ***\n", comm, argWords[i2]);
		strcat(argWords[i2], "/");	// * will need to change hard-coded "/ls" to dynamic input
		strcat(argWords[i2], comm);	// Updated on 4/12 to be dynamic
	}

	// Doing the fork() stuff
	//printf("\n===== STARTING fork() STUFF =====\n");
	/*
	* CAINE.....   See about maybe making a large paramater'd genCommand to catch a lot of args.
	* (would be nice if genCommand could receive just 2 args: STRING:command-name, [ARRAY]:argument-arguments)
	*/
	char* args[] = { argWords[i2], arg1, arg2, arg3, arg4, arg5, arg6, NULL }; // varTable.word[1] = HOME (for testing ls)
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
		/*/ Remove all this printf crap for deliverable
		printf("This is the child. pid: %d\t", getpid());
		printf("Child's parent: %d\n", p1);
		printf("\n===== COMMAND <%s> EXECUTED VIA EXECV (", comm);
		printf(nutRED "results " nutGREEN);
		printf("below) =====");
		printf(nutRED "\n");
		//... end of printf crap
		//close(pipe1[0]); // Abandoned pipe dreams for now.
		//*/
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
	/*
	printf(nutGREEN "*** End of results from command <%s> execution ****\n", comm);
	printf("\n===== END OF NON-BUILT-IN COMMAND <%s> =====\n", comm);
	//*/
	return 1;
}
//*/
