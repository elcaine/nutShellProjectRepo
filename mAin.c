#include <stdio.h>

void shell_init() {
	printf("********************************\n");
	printf("** shell_init has been init'd **\n");
	printf("********************************\n");
}

void printPrompt() {
	printf("printPrompt here:~$ ");
}

int getCommand() {
	return 2;
}

/*
* 
*/

int main() {
	int whileLooper = 0;
	shell_init();
	while(++whileLooper < 5) {
		printPrompt();
		printf("\n");
		switch(getCommand()) {
		case 1:		printf("case 1\n"); //exit();
			break;
		case 2: 	printf("case 2\n"); //recover_from_errors();
			break;
		case 42: 	printf("case 42\n"); //processCommand();
			break;
		default:	printf("Default case switch reached\n");
		}

		printf("whileLooper: %d\n", whileLooper);
	}

	return 0;
}
