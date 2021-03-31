//Disabled VS Studio error code 4996 warnings
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void shell_init() {
	printf("********************************\n");
	printf("** shell_init has been init'd **\n");
	printf("********************************\n");
}

void printPrompt() {
	printf("Fareed & Daniel's super duper hacker prompt:~$ ");
}

int getCommand() {
	int comVal;
	char str1[512] = "";
	printPrompt();
	comVal = scanf("%s", str1); // comVal catches scanf return value only to remove warning
	//printf("\nThe crap you entered is: %s\n", str1); //verify scanf input
	if (strcmp(str1, "builtIn") == 0)
		comVal = 0;
	else if (strcmp(str1, "pwd") == 0)
		comVal = 1;
	else if (strcmp(str1, "cd") == 0)
		comVal = 2;
	else if (strcmp(str1, "printenv") == 0)
		comVal = 3;
	else
		comVal = 404;
	//printf("\ncomVal: %d\n", comVal); // comVal checker
	return comVal;
}

int cd(char *args) {
	if (args == NULL)
		printf(stderr, "NEED A PLACE TO GO!!\n");
	else
		if (chdir(args) != 0)
			perror("not sure what to printout here\n");
	return 1;
}

int pwd() {
	char cwd[1028];
	getcwd(cwd, sizeof(cwd));
	printf("Current hacker directory: %s\n", cwd);
	return 1;
}

void fixPathString(char* str, char find, char swap) {
	char* c = strchr(str, find);
	while (c) {
		*c = swap;
		c = strchr(c, find);
	}
	//return c;
}
/*
*
*/

int main() {
	char* pathVar = getenv("PATH");
	char* homeVar = getenv("HOME");
	char* rootVar = getenv("ROOT");
	int mas = 1; // Shell loop variable; 0 exits

	char tmp[512]; //holds token... expected to be replaced by flex/bison
	shell_init();
	do {
		//printPrompt();
		//printf("\n");
		switch (getCommand()) {
			//exit();
			//recover_from_errors();
			//processCommand();
		case 0:	// Built In commands (setevn, printevn, unsetenv, cd, alias, unalias, bye)
			//printf("case 0\n");
			mas = 0; // ends shell program
			break;
		case 1: // Non built in commands (needs fork * execv stuff)
			//printf("case 1\n");
			pwd();
			break;
		case 2:
			//printf("case 2\n");
			printf("Enter desired directory: ");
			gets(tmp);
			gets(tmp);  // Not sure why, but this works, one doesn't
			printf("tmp: %s", tmp);
			cd(tmp);
			break;
		case 3: 	
			//printf("case 3\n");
			fixPathString(pathVar, ';', '\n');

			printf("PATH=%s\n", pathVar);
			printf("HOME=%s\n", homeVar);
			printf("ROOT=%s\n", rootVar);
			break;
		case 404:
		default:	
			printf("Default case switch reached\n");
		}

	} while (mas);

	return 0;
}
